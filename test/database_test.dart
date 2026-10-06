import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/data/database/app_database.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';

void main() {
  group('Database Local Drift/SQLite Repository Test (Milestone 4)', () {
    late AppDatabase db;
    late FinanceRepository repository;

    setUp(() {
      db = AppDatabase.inMemory();
      repository = FinanceRepository(db);
    });

    tearDown(() async {
      await repository.close();
    });

    test('(d) Database baru dibuat: 3 dompet saldo 0, kategori lengkap, tanpa transaksi', () async {
      final wallets = await repository.getAllWallets();
      final categories = await repository.getAllCategories();
      final transactions = await repository.getAllTransactions();

      // Verifikasi 3 dompet awal dengan saldo 0
      expect(wallets.length, equals(3));
      final walletNames = wallets.map((w) => w.name).toList();
      expect(walletNames, containsAll(['BCA', 'Tunai', 'E-Wallet']));
      for (final w in wallets) {
        expect(w.initialBalance, equals(0), reason: 'Dompet ${w.name} harus bersaldo 0');
      }

      // Verifikasi kategori
      expect(categories.length, equals(9));
      final expenseCategories =
          categories.where((c) => c.type == CategoryType.expense).map((c) => c.name).toList();
      final incomeCategories =
          categories.where((c) => c.type == CategoryType.income).map((c) => c.name).toList();

      expect(
        expenseCategories,
        containsAll([
          'Makanan',
          'Transportasi',
          'Tagihan',
          'Belanja',
          'Hiburan',
          'Kesehatan',
          'Lainnya',
        ]),
      );
      expect(incomeCategories, containsAll(['Gaji', 'Lainnya']));

      // Verifikasi TANPA transaksi awal
      expect(transactions, isEmpty);
    });

    test('Operasi CRUD Transaksi: Tambah, Baca, Ubah, dan Hapus', () async {
      // 1. Tambah Transaksi Pengeluaran
      final tx1 = Transaction(
        id: 'tx_db_1',
        type: TransactionType.expense,
        amount: 50000,
        date: DateTime(2026, 10, 10),
        walletId: 'tunai',
        categoryId: 'exp_makanan',
        note: 'Makan siang padang',
      );
      await repository.addTransaction(tx1);

      var txList = await repository.getAllTransactions();
      expect(txList.length, equals(1));
      expect(txList.first.id, equals('tx_db_1'));
      expect(txList.first.amount, equals(50000));
      expect(txList.first.walletId, equals('tunai'));
      expect(txList.first.categoryId, equals('exp_makanan'));
      expect(txList.first.note, equals('Makan siang padang'));

      // 2. Tambah Transaksi Transfer (foreign key walletId & targetWalletId, categoryId null)
      final txTransfer = Transaction(
        id: 'tx_db_2',
        type: TransactionType.transfer,
        amount: 100000,
        date: DateTime(2026, 10, 11),
        walletId: 'bca',
        targetWalletId: 'tunai',
        categoryId: null,
        note: 'Tarik tunai ATM',
      );
      await repository.addTransaction(txTransfer);

      txList = await repository.getAllTransactions();
      expect(txList.length, equals(2));
      final readTransfer = txList.firstWhere((t) => t.id == 'tx_db_2');
      expect(readTransfer.type, equals(TransactionType.transfer));
      expect(readTransfer.walletId, equals('bca'));
      expect(readTransfer.targetWalletId, equals('tunai'));
      expect(readTransfer.categoryId, isNull);

      // 3. Ubah (Update) Transaksi
      final updatedTx1 = Transaction(
        id: 'tx_db_1',
        type: TransactionType.expense,
        amount: 65000,
        date: DateTime(2026, 10, 10),
        walletId: 'tunai',
        categoryId: 'exp_makanan',
        note: 'Makan siang padang komplit',
      );
      await repository.updateTransaction(updatedTx1);

      txList = await repository.getAllTransactions();
      final readUpdated = txList.firstWhere((t) => t.id == 'tx_db_1');
      expect(readUpdated.amount, equals(65000));
      expect(readUpdated.note, equals('Makan siang padang komplit'));

      // 4. Hapus Transaksi
      await repository.deleteTransaction('tx_db_1');
      txList = await repository.getAllTransactions();
      expect(txList.length, equals(1));
      expect(txList.any((t) => t.id == 'tx_db_1'), isFalse);
    });

    test('(b) & (c) Integrasi FinanceState: Persistence dan penghitungan ulang saldo saat hapus', () async {
      final state = FinanceState(repository: repository);
      await state.loadData();

      // Pastikan saldo awal semua 0
      expect(state.getWalletBalance('tunai'), equals(0));
      expect(state.getWalletBalance('bca'), equals(0));

      // Catat pemasukan gaji ke BCA 5.000.000
      await state.addTransaction(
        Transaction(
          id: 'tx_gaji',
          type: TransactionType.income,
          amount: 5000000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'inc_gaji',
        ),
      );

      // Catat transfer BCA ke Tunai 500.000
      await state.addTransaction(
        Transaction(
          id: 'tx_tarik',
          type: TransactionType.transfer,
          amount: 500000,
          date: DateTime(2026, 10, 2),
          walletId: 'bca',
          targetWalletId: 'tunai',
        ),
      );

      // Catat pengeluaran dari Tunai 75.000
      await state.addTransaction(
        Transaction(
          id: 'tx_belanja',
          type: TransactionType.expense,
          amount: 75000,
          date: DateTime(2026, 10, 3),
          walletId: 'tunai',
          categoryId: 'exp_belanja',
        ),
      );

      // Verifikasi saldo terhitung benar
      expect(state.getWalletBalance('bca'), equals(4500000)); // 5.000.000 - 500.000
      expect(state.getWalletBalance('tunai'), equals(425000)); // 500.000 - 75.000

      // Simulasi app dimatikan dan dibuka ulang (membaca ulang dari database yang sama)
      final stateReopened = FinanceState(repository: repository);
      await stateReopened.loadData();

      expect(stateReopened.transactions.length, equals(3));
      expect(stateReopened.getWalletBalance('bca'), equals(4500000));
      expect(stateReopened.getWalletBalance('tunai'), equals(425000));

      // Hapus transaksi pengeluaran tx_belanja
      await stateReopened.deleteTransaction('tx_belanja');

      // (c) Saldo harus otomatis dihitung ulang: saldo Tunai kembali ke 500.000
      expect(stateReopened.getWalletBalance('tunai'), equals(500000));
      expect(stateReopened.transactions.length, equals(2));

      // Verifikasi di level database juga terhapus
      final dbTxList = await repository.getAllTransactions();
      expect(dbTxList.length, equals(2));
      expect(dbTxList.any((t) => t.id == 'tx_belanja'), isFalse);
    });

    test('Foreign key constraint aktif di SQLite: menolak dompet yang tidak terdaftar', () async {
      final invalidTx = Transaction(
        id: 'tx_invalid',
        type: TransactionType.expense,
        amount: 10000,
        date: DateTime(2026, 10, 1),
        walletId: 'dompet_palsu_tidak_ada',
        categoryId: 'exp_makanan',
      );

      expect(
        () async => await repository.addTransaction(invalidTx),
        throwsA(isA<Exception>()),
      );
    });

    test('Operasi Dompet di Database: Tambah, Ubah saldo awal, Arsipkan, dan Deteksi Transaksi (Milestone 5)', () async {
      // 1. Tambah dompet baru
      final newWallet = const Wallet(
        id: 'jago',
        name: 'Bank Jago',
        initialBalance: 250000,
        isArchived: false,
      );
      await repository.addWallet(newWallet);

      var wallets = await repository.getAllWallets();
      expect(wallets.any((w) => w.id == 'jago'), isTrue);
      expect(wallets.firstWhere((w) => w.id == 'jago').initialBalance, equals(250000));

      // 2. Ubah nama dan saldo awal
      await repository.updateWallet(newWallet.copyWith(name: 'Jago Utama', initialBalance: 1000000));
      wallets = await repository.getAllWallets();
      final updated = wallets.firstWhere((w) => w.id == 'jago');
      expect(updated.name, equals('Jago Utama'));
      expect(updated.initialBalance, equals(1000000));

      // 3. Deteksi isWalletUsed: sebelum transaksi -> false
      expect(await repository.isWalletUsed('jago'), isFalse);

      // Tambah transaksi yang memakai dompet jago
      await repository.addTransaction(
        Transaction(
          id: 'tx_jago_1',
          type: TransactionType.income,
          amount: 500000,
          date: DateTime(2026, 10, 5),
          walletId: 'jago',
          categoryId: 'inc_gaji',
        ),
      );

      // Setelah transaksi -> true
      expect(await repository.isWalletUsed('jago'), isTrue);

      // 4. Arsipkan dompet
      await repository.updateWallet(updated.copyWith(isArchived: true));
      wallets = await repository.getAllWallets();
      expect(wallets.firstWhere((w) => w.id == 'jago').isArchived, isTrue);

      // 5. Hapus transaksi lalu hapus dompet secara permanen
      await repository.deleteTransaction('tx_jago_1');
      expect(await repository.isWalletUsed('jago'), isFalse);
      await repository.deleteWallet('jago');
      wallets = await repository.getAllWallets();
      expect(wallets.any((w) => w.id == 'jago'), isFalse);
    });

    test('Operasi Kategori di Database: Tambah, Ubah nama, Arsipkan, dan Deteksi Transaksi (Milestone 5)', () async {
      // 1. Tambah kategori baru
      final newCat = const Category(
        id: 'exp_investasi',
        name: 'Investasi',
        type: CategoryType.expense,
        isArchived: false,
      );
      await repository.addCategory(newCat);

      var categories = await repository.getAllCategories();
      expect(categories.any((c) => c.id == 'exp_investasi'), isTrue);

      // 2. Ubah nama
      await repository.updateCategory(newCat.copyWith(name: 'Reksadana'));
      categories = await repository.getAllCategories();
      expect(categories.firstWhere((c) => c.id == 'exp_investasi').name, equals('Reksadana'));

      // 3. Deteksi isCategoryUsed
      expect(await repository.isCategoryUsed('exp_investasi'), isFalse);

      await repository.addTransaction(
        Transaction(
          id: 'tx_inv_1',
          type: TransactionType.expense,
          amount: 200000,
          date: DateTime(2026, 10, 6),
          walletId: 'tunai',
          categoryId: 'exp_investasi',
        ),
      );
      expect(await repository.isCategoryUsed('exp_investasi'), isTrue);

      // 4. Arsipkan
      await repository.updateCategory(newCat.copyWith(name: 'Reksadana', isArchived: true));
      categories = await repository.getAllCategories();
      expect(categories.firstWhere((c) => c.id == 'exp_investasi').isArchived, isTrue);

      // 5. Hapus transaksi dan hapus kategori
      await repository.deleteTransaction('tx_inv_1');
      expect(await repository.isCategoryUsed('exp_investasi'), isFalse);
      await repository.deleteCategory('exp_investasi');
      categories = await repository.getAllCategories();
      expect(categories.any((c) => c.id == 'exp_investasi'), isFalse);
    });
  });
}
