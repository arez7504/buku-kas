import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/backup_service.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';

void main() {
  group('BackupService - Serialisasi dan Penamaan Berkas', () {
    test('generateBackupFileName menghasilkan format catatan_keuangan_YYYY-MM-DD.json', () {
      final date = DateTime(2026, 10, 6);
      final fileName = BackupService.generateBackupFileName(date);
      expect(fileName, 'catatan_keuangan_2026-10-06.json');
    });

    test('Round-trip serialisasi dan deserialisasi data utuh', () {
      final wallets = [
        const Wallet(id: 'w1', name: 'BCA', initialBalance: 1000000, isArchived: false),
        const Wallet(id: 'w2', name: 'Dompet Lama', initialBalance: 50000, isArchived: true),
      ];
      final categories = [
        const Category(id: 'c1', name: 'Gaji', type: CategoryType.income, isArchived: false),
        const Category(id: 'c2', name: 'Makan', type: CategoryType.expense, isArchived: false),
        const Category(id: 'c3', name: 'Langganan Lama', type: CategoryType.expense, isArchived: true),
      ];
      final transactions = [
        Transaction(
          id: 't1',
          type: TransactionType.income,
          amount: 5000000,
          date: DateTime(2026, 10, 1, 10, 0),
          walletId: 'w1',
          categoryId: 'c1',
          note: 'Gaji Bulanan',
        ),
        Transaction(
          id: 't2',
          type: TransactionType.expense,
          amount: 25000,
          date: DateTime(2026, 10, 2, 12, 30),
          walletId: 'w1',
          categoryId: 'c2',
          note: 'Makan siang',
        ),
        Transaction(
          id: 't3',
          type: TransactionType.transfer,
          amount: 200000,
          date: DateTime(2026, 10, 3, 14, 0),
          walletId: 'w1',
          targetWalletId: 'w2',
          note: 'Top up',
        ),
      ];

      final exportTime = DateTime(2026, 10, 6, 12, 0);
      final jsonString = BackupService.exportToJson(
        wallets: wallets,
        categories: categories,
        transactions: transactions,
        exportTime: exportTime,
      );

      final parsed = BackupService.parseAndValidate(jsonString);
      expect(parsed.formatVersion, BackupService.currentFormatVersion);
      expect(parsed.exportedAt, exportTime);
      expect(parsed.wallets.length, 2);
      expect(parsed.categories.length, 3);
      expect(parsed.transactions.length, 3);

      // Verifikasi dompet
      expect(parsed.wallets[0].id, 'w1');
      expect(parsed.wallets[0].name, 'BCA');
      expect(parsed.wallets[0].initialBalance, 1000000);
      expect(parsed.wallets[0].isArchived, false);
      expect(parsed.wallets[1].isArchived, true);

      // Verifikasi kategori
      expect(parsed.categories[0].type, CategoryType.income);
      expect(parsed.categories[1].type, CategoryType.expense);
      expect(parsed.categories[2].isArchived, true);

      // Verifikasi transaksi
      expect(parsed.transactions[0].type, TransactionType.income);
      expect(parsed.transactions[0].amount, 5000000);
      expect(parsed.transactions[1].type, TransactionType.expense);
      expect(parsed.transactions[2].type, TransactionType.transfer);
      expect(parsed.transactions[2].targetWalletId, 'w2');

      // Verifikasi ringkasan
      final summary = parsed.summary;
      expect(summary.walletCount, 2);
      expect(summary.categoryCount, 3);
      expect(summary.transactionCount, 3);
      expect(summary.dateRangeText, '01/10/2026 - 03/10/2026');
    });
  });

  group('BackupService - Validasi Penolakan (Error Handling)', () {
    Map<String, dynamic> createBasePayload() => {
          'formatVersion': 1,
          'exportedAt': '2026-10-06T12:00:00.000',
          'wallets': [
            {'id': 'w1', 'name': 'BCA', 'initialBalance': 100000, 'isArchived': false},
            {'id': 'w2', 'name': 'Tunai', 'initialBalance': 50000, 'isArchived': false},
          ],
          'categories': [
            {'id': 'c1', 'name': 'Gaji', 'type': 'income', 'isArchived': false},
            {'id': 'c2', 'name': 'Makan', 'type': 'expense', 'isArchived': false},
          ],
          'transactions': [
            {
              'id': 't1',
              'type': 'expense',
              'amount': 25000,
              'date': '2026-10-06T10:00:00.000',
              'walletId': 'w1',
              'categoryId': 'c2',
              'note': 'Makan',
            }
          ],
        };

    test('Menolak berkas kosong', () {
      expect(
        () => BackupService.parseAndValidate('   '),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('kosong'),
        )),
      );
    });

    test('Menolak JSON rusak (syntax error)', () {
      expect(
        () => BackupService.parseAndValidate('{"formatVersion": 1, invalid_json}'),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('Format JSON tidak valid atau berkas rusak'),
        )),
      );
    });

    test('Menolak jika root JSON bukan objek', () {
      expect(
        () => BackupService.parseAndValidate('[1, 2, 3]'),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('harus berupa objek JSON'),
        )),
      );
    });

    test('Menolak jika field formatVersion tidak ada', () {
      final payload = createBasePayload()..remove('formatVersion');
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('formatVersion" wajib ada'),
        )),
      );
    });

    test('Menolak formatVersion asing/tidak dikenal (misal version 2 atau 99)', () {
      final payload = createBasePayload()..['formatVersion'] = 99;
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('tidak dikenal atau tidak didukung'),
        )),
      );
    });

    test('Menolak formatVersion bukan integer', () {
      final payload = createBasePayload()..['formatVersion'] = '1';
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('harus berupa bilangan bulat'),
        )),
      );
    });

    test('Menolak tanggal ekspor exportedAt tidak valid', () {
      final payload = createBasePayload()..['exportedAt'] = 'bukan-tanggal';
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('Format tanggal ekspor'),
        )),
      );
    });

    test('Menolak jika saldo awal dompet bukan integer (pecahan/string)', () {
      final payload = createBasePayload();
      (payload['wallets'] as List)[0]['initialBalance'] = 50000.75;
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('harus berupa bilangan bulat (integer)'),
        )),
      );
    });

    test('Menolak jika ID dompet duplikat dalam berkas', () {
      final payload = createBasePayload();
      (payload['wallets'] as List).add({
        'id': 'w1',
        'name': 'BCA Lain',
        'initialBalance': 0,
      });
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('duplikat'),
        )),
      );
    });

    test('Menolak jika tipe kategori tidak valid', () {
      final payload = createBasePayload();
      (payload['categories'] as List)[0]['type'] = 'investasi';
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('Tipe kategori'),
        )),
      );
    });

    test('Menolak nominal transaksi bukan integer (pecahan/string)', () {
      final payload = createBasePayload();
      (payload['transactions'] as List)[0]['amount'] = 25000.5;
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('harus berupa bilangan bulat (integer)'),
        )),
      );
    });

    test('Menolak nominal transaksi <= 0', () {
      final payload = createBasePayload();
      (payload['transactions'] as List)[0]['amount'] = 0;
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('harus lebih besar dari 0'),
        )),
      );
    });

    test('Menolak transaksi yang merujuk ke walletId yang tidak ada di berkas', () {
      final payload = createBasePayload();
      (payload['transactions'] as List)[0]['walletId'] = 'dompet_hantu';
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('tidak ditemukan dalam daftar dompet berkas ini'),
        )),
      );
    });

    test('Menolak transaksi yang merujuk ke categoryId yang tidak ada di berkas', () {
      final payload = createBasePayload();
      (payload['transactions'] as List)[0]['categoryId'] = 'kategori_gaib';
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('tidak ditemukan dalam daftar kategori berkas ini'),
        )),
      );
    });

    test('Menolak transaksi transfer dengan dompet asal dan tujuan sama', () {
      final payload = createBasePayload();
      (payload['transactions'] as List)[0] = {
        'id': 't2',
        'type': 'transfer',
        'amount': 50000,
        'date': '2026-10-06T10:00:00.000',
        'walletId': 'w1',
        'targetWalletId': 'w1',
      };
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('tidak boleh sama'),
        )),
      );
    });

    test('Menolak transaksi transfer dengan targetWalletId tidak ada di berkas', () {
      final payload = createBasePayload();
      (payload['transactions'] as List)[0] = {
        'id': 't2',
        'type': 'transfer',
        'amount': 50000,
        'date': '2026-10-06T10:00:00.000',
        'walletId': 'w1',
        'targetWalletId': 'w_tidak_ada',
      };
      expect(
        () => BackupService.parseAndValidate(jsonEncode(payload)),
        throwsA(isA<BackupValidationException>().having(
          (e) => e.message,
          'message',
          contains('tidak ditemukan dalam daftar dompet berkas ini'),
        )),
      );
    });
  });
}
