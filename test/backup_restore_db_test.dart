import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/logic/backup_service.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';

void main() {
  group('Backup & Restore Database - Kriteria (a), (b), (c)', () {
    late FinanceRepository repoA;
    late FinanceRepository repoB;

    setUp(() {
      repoA = FinanceRepository.inMemory();
      repoB = FinanceRepository.inMemory();
    });

    tearDown(() async {
      await repoA.close();
      await repoB.close();
    });

    test('(a) Round-trip ekspor lalu impor ke database kosong menghasilkan saldo dan ringkasan identik', () async {
      // 1. Inisialisasi data kaya di database A
      final stateA = FinanceState(repository: repoA);
      await stateA.loadData();

      // Atur saldo awal
      await stateA.updateWallet(const Wallet(id: 'bca', name: 'BCA', initialBalance: 1000000));
      await stateA.updateWallet(const Wallet(id: 'tunai', name: 'Tunai', initialBalance: 200000));
      await stateA.updateWallet(const Wallet(id: 'ewallet', name: 'E-Wallet', initialBalance: 50000));

      // Tambah dompet baru dan arsipkan salah satu
      await stateA.addWallet(const Wallet(id: 'tabungan', name: 'Tabungan', initialBalance: 500000));
      await stateA.archiveWallet('ewallet', isArchived: true);

      // Tambah transaksi berbagai jenis (pemasukan, pengeluaran, transfer)
      await stateA.addTransaction(
        Transaction(
          id: 'tx_gaji',
          type: TransactionType.income,
          amount: 5000000,
          date: DateTime(2026, 10, 1, 9, 0),
          walletId: 'bca',
          categoryId: 'inc_gaji',
          note: 'Gaji Oktober',
        ),
      );
      await stateA.addTransaction(
        Transaction(
          id: 'tx_makan',
          type: TransactionType.expense,
          amount: 75000,
          date: DateTime(2026, 10, 2, 12, 0),
          walletId: 'tunai',
          categoryId: 'exp_makanan',
          note: 'Makan siang',
        ),
      );
      await stateA.addTransaction(
        Transaction(
          id: 'tx_transfer',
          type: TransactionType.transfer,
          amount: 300000,
          date: DateTime(2026, 10, 3, 15, 0),
          walletId: 'bca',
          targetWalletId: 'tunai',
          note: 'Tarik tunai dari BCA',
        ),
      );

      // Hitung saldo dan ringkasan dari DB A
      final balancesA = Map<String, int>.from(stateA.walletBalances);
      final summaryA = stateA.getMonthlySummary(2026, 10);
      final countWalletsA = stateA.wallets.length;
      final countCategoriesA = stateA.categories.length;
      final countTxA = stateA.transactions.length;

      expect(balancesA['bca'], 1000000 + 5000000 - 300000); // 5.700.000
      expect(balancesA['tunai'], 200000 - 75000 + 300000); // 425.000
      expect(summaryA.totalIncome, 5000000);
      expect(summaryA.totalExpense, 75000);
      expect(summaryA.netCashFlow, 5000000 - 75000);

      // 2. Ekspor database A ke format JSON
      final exportedJson = BackupService.exportToJson(
        wallets: stateA.wallets,
        categories: stateA.categories,
        transactions: stateA.transactions,
      );

      // 3. Database B adalah database kosong / baru
      final stateB = FinanceState(repository: repoB);
      // Sebelum restore, verifikasi DB B memiliki seed bawaan atau belum memiliki transaksi di atas
      await stateB.loadData();
      expect(stateB.transactions, isEmpty);

      // 4. Lakukan validasi dan pemulihan ke Database B
      final parsed = BackupService.parseAndValidate(exportedJson);
      await stateB.restoreData(
        wallets: parsed.wallets,
        categories: parsed.categories,
        transactions: parsed.transactions,
      );

      // 5. Verifikasi saldo dan ringkasan Database B persis sama dengan Database A
      final balancesB = stateB.walletBalances;
      final summaryB = stateB.getMonthlySummary(2026, 10);

      expect(stateB.wallets.length, countWalletsA);
      expect(stateB.categories.length, countCategoriesA);
      expect(stateB.transactions.length, countTxA);

      expect(balancesB['bca'], balancesA['bca']);
      expect(balancesB['tunai'], balancesA['tunai']);
      expect(balancesB['ewallet'], balancesA['ewallet']);
      expect(balancesB['tabungan'], balancesA['tabungan']);

      expect(summaryB.totalIncome, summaryA.totalIncome);
      expect(summaryB.totalExpense, summaryA.totalExpense);
      expect(summaryB.netCashFlow, summaryA.netCashFlow);

      // Verifikasi status arsip di DB B
      expect(stateB.wallets.firstWhere((w) => w.id == 'ewallet').isArchived, true);
      expect(stateB.wallets.firstWhere((w) => w.id == 'bca').isArchived, false);
    });

    test('(b) Test Penolakan: JSON rusak, version asing, walletId tidak ada, nominal bukan integer tidak mengubah data lama', () async {
      final state = FinanceState(repository: repoA);
      await state.loadData();

      // Tambah transaksi awal
      await state.addTransaction(
        Transaction(
          id: 'initial_tx',
          type: TransactionType.income,
          amount: 500000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'inc_gaji',
        ),
      );

      final initialWallets = List.of(state.wallets);
      final initialTransactions = List.of(state.transactions);
      final initialBalance = state.getWalletBalance('bca');

      // Kasus 1: JSON Rusak
      const invalidJson = '{"broken": json file}';
      expect(() => BackupService.parseAndValidate(invalidJson), throwsA(isA<BackupValidationException>()));
      expect(state.wallets.length, initialWallets.length);
      expect(state.transactions.length, initialTransactions.length);
      expect(state.getWalletBalance('bca'), initialBalance);

      // Kasus 2: formatVersion asing
      final unknownVersionJson = jsonEncode({
        'formatVersion': 99,
        'exportedAt': DateTime.now().toIso8601String(),
        'wallets': [],
        'categories': [],
        'transactions': [],
      });
      expect(() => BackupService.parseAndValidate(unknownVersionJson), throwsA(isA<BackupValidationException>()));
      expect(state.transactions.length, initialTransactions.length);

      // Kasus 3: walletId yang tidak ada dalam daftar berkas
      final nonExistentWalletJson = jsonEncode({
        'formatVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'wallets': [
          {'id': 'w1', 'name': 'BCA', 'initialBalance': 0}
        ],
        'categories': [
          {'id': 'c1', 'name': 'Gaji', 'type': 'income'}
        ],
        'transactions': [
          {
            'id': 't1',
            'type': 'income',
            'amount': 10000,
            'date': '2026-10-01T00:00:00.000',
            'walletId': 'w_tidak_ada',
            'categoryId': 'c1',
          }
        ],
      });
      expect(() => BackupService.parseAndValidate(nonExistentWalletJson), throwsA(isA<BackupValidationException>()));
      expect(state.transactions.length, initialTransactions.length);

      // Kasus 4: Nominal bukan integer (string atau pecahan)
      final nonIntegerAmountJson = jsonEncode({
        'formatVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'wallets': [
          {'id': 'w1', 'name': 'BCA', 'initialBalance': 0}
        ],
        'categories': [
          {'id': 'c1', 'name': 'Gaji', 'type': 'income'}
        ],
        'transactions': [
          {
            'id': 't1',
            'type': 'income',
            'amount': 10000.5,
            'date': '2026-10-01T00:00:00.000',
            'walletId': 'w1',
            'categoryId': 'c1',
          }
        ],
      });
      expect(() => BackupService.parseAndValidate(nonIntegerAmountJson), throwsA(isA<BackupValidationException>()));
      expect(state.transactions.length, initialTransactions.length);
      expect(state.getWalletBalance('bca'), initialBalance);
    });

    test('(c) Test Atomik: Kegagalan di tengah proses restore di-rollback, data lama tetap utuh', () async {
      final state = FinanceState(repository: repoA);
      await state.loadData();

      await state.addTransaction(
        Transaction(
          id: 'tx_aman',
          type: TransactionType.income,
          amount: 250000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'inc_gaji',
        ),
      );

      final initialWallets = await repoA.getAllWallets();
      final initialCategories = await repoA.getAllCategories();
      final initialTransactions = await repoA.getAllTransactions();

      expect(initialTransactions.length, 1);
      expect(initialTransactions.first.id, 'tx_aman');

      // Siapkan data pemulihan yang secara sengaja akan gagal di level SQLite pada transaksi kedua
      // (misal transaksi kedua melanggar foreign key constraint di database level SQLite)
      final validWallets = [
        const Wallet(id: 'w_baru', name: 'Dompet Baru', initialBalance: 100),
      ];
      final validCategories = [
        const Category(id: 'c_baru', name: 'Kategori Baru', type: CategoryType.income),
      ];
      final badTransactions = [
        Transaction(
          id: 'tx1_valid',
          type: TransactionType.income,
          amount: 100,
          date: DateTime(2026, 10, 1),
          walletId: 'w_baru',
          categoryId: 'c_baru',
        ),
        // Transaksi kedua menunjuk ke dompet 'w_tidak_terdaftar' yang akan memicu SQLite foreign key exception
        Transaction(
          id: 'tx2_broken',
          type: TransactionType.income,
          amount: 200,
          date: DateTime(2026, 10, 1),
          walletId: 'w_tidak_terdaftar',
          categoryId: 'c_baru',
        ),
      ];

      // Panggil repoA.restoreData: ini akan melempar exception saat memasukkan tx2_broken
      try {
        await repoA.restoreData(
          wallets: validWallets,
          categories: validCategories,
          transactions: badTransactions,
        );
        fail('Harus melempar exception foreign key constraint');
      } catch (e) {
        // Exception diharapkan
        expect(e, isNotNull);
      }

      // Verifikasi ATOMIK: Seluruh perubahan di-rollback!
      // Database tidak boleh berisi data setengah jadi (w_baru, c_baru, atau tx1_valid).
      // Data lama (tx_aman dan dompet/kategori awal) harus utuh 100%!
      final postWallets = await repoA.getAllWallets();
      final postCategories = await repoA.getAllCategories();
      final postTransactions = await repoA.getAllTransactions();

      expect(postWallets.map((w) => w.id), initialWallets.map((w) => w.id));
      expect(postCategories.map((c) => c.id), initialCategories.map((c) => c.id));
      expect(postTransactions.length, initialTransactions.length);
      expect(postTransactions.first.id, 'tx_aman');
    });
  });
}
