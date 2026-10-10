import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/screens/settings_screen.dart';

void main() {
  group('Milestone 6 Widget Tests: Cadangkan & Pulihkan Data UI', () {
    late FinanceRepository repository;
    late FinanceState state;

    setUp(() async {
      repository = FinanceRepository.inMemory();
      state = FinanceState(repository: repository);
      await state.loadData();
    });

    tearDown(() async {
      await repository.close();
    });

    Widget createTestWidget({
      Future<void> Function(String fileName, String jsonString)? shareOverride,
      Future<String?> Function()? filePickerOverride,
    }) {
      return FinanceScope(
        state: state,
        child: MaterialApp(
          home: SettingsScreen(
            shareOverride: shareOverride,
            filePickerOverride: filePickerOverride,
          ),
        ),
      );
    }

    testWidgets('Menampilkan menu Cadangkan data dan Pulihkan data di Pengaturan', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Cadangkan data'), findsOneWidget);
      expect(find.text('Pulihkan data'), findsOneWidget);
      expect(find.text('MASTER DATA'), findsOneWidget);
      expect(find.text('CADANGAN & PEMULIHAN'), findsOneWidget);
    });

    testWidgets('Cadangkan data memicu share dengan nama file catatan_keuangan_YYYY-MM-DD.json', (tester) async {
      String? sharedFileName;
      String? sharedContent;

      await tester.pumpWidget(
        createTestWidget(
          shareOverride: (name, content) async {
            sharedFileName = name;
            sharedContent = content;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cadangkan data'));
      await tester.pumpAndSettle();

      expect(sharedFileName, startsWith('catatan_keuangan_'));
      expect(sharedFileName, endsWith('.json'));
      expect(sharedContent, isNotNull);

      // Verifikasi JSON yang dibagikan memuat formatVersion 3 dan dompet seed
      final decoded = jsonDecode(sharedContent!) as Map<String, dynamic>;
      expect(decoded['formatVersion'], 3);
      expect((decoded['wallets'] as List).length, 3);
      expect(find.text('File cadangan siap dibagikan'), findsOneWidget);
    });

    testWidgets('Pulihkan data ditolak jika format JSON rusak atau aturan dilanggar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          filePickerOverride: () async => '{"broken_json": [}',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pulihkan data'));
      await tester.pumpAndSettle();

      // Menampilkan dialog Berkas Ditolak
      expect(find.text('Berkas Ditolak'), findsOneWidget);
      expect(find.text('Format JSON tidak valid atau berkas rusak'), findsOneWidget);

      // Tutup dialog
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      expect(find.text('Berkas Ditolak'), findsNothing);
    });

    testWidgets('Pulihkan data menampilkan ringkasan, bisa dibatalkan, dan jika dikonfirmasi data terganti', (tester) async {
      // 1. Data saat ini di state
      await state.addTransaction(
        Transaction(
          id: 'tx_old',
          type: TransactionType.expense,
          amount: 50000,
          date: DateTime(2026, 9, 1),
          walletId: 'tunai',
          categoryId: 'exp_makanan',
        ),
      );
      expect(state.transactions.length, 1);

      // 2. Berkas JSON cadangan yang akan dipulihkan
      final backupJson = jsonEncode({
        'formatVersion': 1,
        'exportedAt': '2026-10-06T12:00:00.000',
        'wallets': [
          {'id': 'w_bank', 'name': 'Bank Mandiri', 'initialBalance': 2000000, 'isArchived': false},
        ],
        'categories': [
          {'id': 'c_gaji', 'name': 'Gaji Tetap', 'type': 'income', 'isArchived': false},
        ],
        'transactions': [
          {
            'id': 'tx_restore_1',
            'type': 'income',
            'amount': 3000000,
            'date': '2026-10-05T08:00:00.000',
            'walletId': 'w_bank',
            'categoryId': 'c_gaji',
            'note': 'Gaji restore',
          }
        ],
      });

      await tester.pumpWidget(
        createTestWidget(
          filePickerOverride: () async => backupJson,
        ),
      );
      await tester.pumpAndSettle();

      // Klik menu Pulihkan data
      await tester.tap(find.text('Pulihkan data'));
      await tester.pumpAndSettle();

      // Verifikasi dialog ringkasan muncul dengan tanggal ekspor
      expect(find.text('Pulihkan Data?'), findsOneWidget);
      expect(find.text('06/10/2026 12:00'), findsOneWidget);
      expect(find.text('1 dompet'), findsOneWidget);
      expect(find.text('1 kategori'), findsOneWidget);
      expect(find.text('1 transaksi'), findsOneWidget);
      expect(find.text('05/10/2026'), findsOneWidget);

      // Test batal terlebih dahulu
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Data lama masih utuh
      expect(state.transactions.length, 1);
      expect(state.transactions.first.id, 'tx_old');

      // Buka lagi untuk konfirmasi
      await tester.tap(find.text('Pulihkan data'));
      await tester.pumpAndSettle();

      // Klik 'Ganti Seluruh Data'
      await tester.tap(find.text('Ganti Seluruh Data'));
      await tester.pumpAndSettle();

      // Data sekarang terganti dengan isi berkas cadangan!
      expect(state.wallets.length, 1);
      expect(state.wallets.first.name, 'Bank Mandiri');
      expect(state.categories.length, 1);
      expect(state.categories.first.name, 'Gaji Tetap');
      expect(state.transactions.length, 1);
      expect(state.transactions.first.id, 'tx_restore_1');
      expect(state.getWalletBalance('w_bank'), 5000000); // initial 2.000.000 + income 3.000.000

      expect(find.text('Data berhasil dipulihkan'), findsOneWidget);
    });

    testWidgets('Isi backup valid dengan nama sembarang (.bin / nama acak) tetap bisa dipulihkan', (tester) async {
      final validBackupContent = jsonEncode({
        'formatVersion': 1,
        'exportedAt': '2026-10-06T15:30:00.000',
        'wallets': [
          {'id': 'w_cash', 'name': 'Dompet Saku', 'initialBalance': 150000, 'isArchived': false},
        ],
        'categories': [
          {'id': 'c_snack', 'name': 'Camilan', 'type': 'expense', 'isArchived': false},
        ],
        'transactions': [
          {
            'id': 'tx_bin_1',
            'type': 'expense',
            'amount': 20000,
            'date': '2026-10-06T14:00:00.000',
            'walletId': 'w_cash',
            'categoryId': 'c_snack',
            'note': 'Kopi',
          }
        ],
      });

      // Menyimulasikan pemilih berkas mengembalikan isi berkas yang berasal dari file bernama '174-11f1-a49a.bin'
      await tester.pumpWidget(
        createTestWidget(
          filePickerOverride: () async => validBackupContent,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pulihkan data'));
      await tester.pumpAndSettle();

      // Dialog menampilkan tanggal ekspor dari isi file
      expect(find.text('Pulihkan Data?'), findsOneWidget);
      expect(find.text('06/10/2026 15:30'), findsOneWidget);
      expect(find.text('1 dompet'), findsOneWidget);

      await tester.tap(find.text('Ganti Seluruh Data'));
      await tester.pumpAndSettle();

      expect(state.wallets.first.name, 'Dompet Saku');
      expect(state.transactions.first.id, 'tx_bin_1');
      expect(find.text('Data berhasil dipulihkan'), findsOneWidget);
    });

    testWidgets('File .json yang isinya bukan backup ditolak tanpa mengubah data', (tester) async {
      final initialTxCount = state.transactions.length;

      // File .json sembarang (contoh package.json / arbitrary file)
      final nonBackupJson = jsonEncode({
        'project': 'my_flutter_app',
        'version': '1.2.0',
        'dependencies': {'flutter': 'sdk'},
      });

      await tester.pumpWidget(
        createTestWidget(
          filePickerOverride: () async => nonBackupJson,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pulihkan data'));
      await tester.pumpAndSettle();

      expect(find.text('Berkas Ditolak'), findsOneWidget);
      expect(find.textContaining('formatVersion'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      expect(state.transactions.length, initialTxCount);
    });

    testWidgets('File di atas 20 MB ditolak tanpa mengubah data', (tester) async {
      final initialTxCount = state.transactions.length;

      // String melebihi 20 MB
      await tester.pumpWidget(
        createTestWidget(
          filePickerOverride: () async {
            throw const FormatException('Ukuran berkas melebihi batas maksimal 20 MB');
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pulihkan data'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal Memulihkan Data'), findsOneWidget);
      expect(find.textContaining('20 MB'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      expect(state.transactions.length, initialTxCount);
    });
  });
}
