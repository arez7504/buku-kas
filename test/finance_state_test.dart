import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';

void main() {
  group('FinanceState & Validasi (Milestone 3)', () {
    late FinanceState state;
    const bca = Wallet(id: 'bca', name: 'BCA', initialBalance: 1000000);
    const tunai = Wallet(id: 'tunai', name: 'Tunai', initialBalance: 200000);
    const katMakan = Category(id: 'c_makan', name: 'Makan', type: CategoryType.expense);
    const katGaji = Category(id: 'c_gaji', name: 'Gaji', type: CategoryType.income);

    setUp(() {
      state = FinanceState(
        initialWallets: [bca, tunai],
        initialCategories: [katMakan, katGaji],
        initialTransactions: [],
      );
    });

    test(
        '(a) Tambah pengeluaran 50.000 dari Tunai: saldo Tunai turun 50.000 dan total pengeluaran bulan itu naik 50.000',
        () {
      final initialTunai = state.getWalletBalance('tunai');
      expect(initialTunai, equals(200000));

      final initialSummary = state.getMonthlySummary(2026, 10);
      expect(initialSummary.totalExpense, equals(0));

      state.addTransaction(
        Transaction(
          id: 'tx_exp_1',
          type: TransactionType.expense,
          amount: 50000,
          date: DateTime(2026, 10, 10),
          walletId: 'tunai',
          categoryId: 'c_makan',
        ),
      );

      expect(state.getWalletBalance('tunai'), equals(150000));
      final updatedSummary = state.getMonthlySummary(2026, 10);
      expect(updatedSummary.totalExpense, equals(50000));
      expect(updatedSummary.netCashFlow, equals(-50000));
    });

    test(
        '(b) Tambah transfer BCA ke Tunai 300.000: saldo kedua dompet berubah, total pemasukan/pengeluaran tidak berubah',
        () {
      final initialBca = state.getWalletBalance('bca');
      final initialTunai = state.getWalletBalance('tunai');
      expect(initialBca, equals(1000000));
      expect(initialTunai, equals(200000));

      state.addTransaction(
        Transaction(
          id: 'tx_tr_1',
          type: TransactionType.transfer,
          amount: 300000,
          date: DateTime(2026, 10, 12),
          walletId: 'bca',
          targetWalletId: 'tunai',
        ),
      );

      expect(state.getWalletBalance('bca'), equals(700000));
      expect(state.getWalletBalance('tunai'), equals(500000));

      final summary = state.getMonthlySummary(2026, 10);
      expect(summary.totalIncome, equals(0));
      expect(summary.totalExpense, equals(0));
      expect(summary.netCashFlow, equals(0));
    });

    test('(c) Edit nominal sebuah transaksi: saldo dan ringkasan ikut dihitung ulang', () {
      final tx = Transaction(
        id: 'tx_edit_1',
        type: TransactionType.expense,
        amount: 50000,
        date: DateTime(2026, 10, 1),
        walletId: 'tunai',
        categoryId: 'c_makan',
      );
      state.addTransaction(tx);

      expect(state.getWalletBalance('tunai'), equals(150000));
      expect(state.getMonthlySummary(2026, 10).totalExpense, equals(50000));

      // Edit nominal menjadi 120.000
      final updatedTx = Transaction(
        id: 'tx_edit_1',
        type: TransactionType.expense,
        amount: 120000,
        date: DateTime(2026, 10, 1),
        walletId: 'tunai',
        categoryId: 'c_makan',
      );
      state.updateTransaction(updatedTx);

      expect(state.getWalletBalance('tunai'), equals(80000)); // 200.000 - 120.000
      expect(state.getMonthlySummary(2026, 10).totalExpense, equals(120000));
    });

    test('(d) Hapus transaksi: hilang dari daftar, saldo dan ringkasan kembali', () {
      final tx = Transaction(
        id: 'tx_del_1',
        type: TransactionType.expense,
        amount: 75000,
        date: DateTime(2026, 10, 5),
        walletId: 'tunai',
        categoryId: 'c_makan',
      );
      state.addTransaction(tx);
      expect(state.transactions.length, equals(1));
      expect(state.getWalletBalance('tunai'), equals(125000));

      // Hapus transaksi
      state.deleteTransaction('tx_del_1');
      expect(state.transactions.length, equals(0));
      expect(state.getWalletBalance('tunai'), equals(200000));
      expect(state.getMonthlySummary(2026, 10).totalExpense, equals(0));
    });

    test('(e) Validasi menolak nominal 0, nominal negatif, dan transfer ke dompet yang sama', () {
      // Nominal 0
      final errZero = FinanceState.validate(
        amount: 0,
        type: TransactionType.expense,
        walletId: 'bca',
        categoryId: 'c_makan',
      );
      expect(errZero, isNotNull);
      expect(errZero, contains('lebih besar dari 0'));

      // Nominal negatif
      final errNegative = FinanceState.validate(
        amount: -5000,
        type: TransactionType.expense,
        walletId: 'bca',
        categoryId: 'c_makan',
      );
      expect(errNegative, isNotNull);

      // Transfer ke dompet yang sama
      final errSameWallet = FinanceState.validate(
        amount: 50000,
        type: TransactionType.transfer,
        walletId: 'bca',
        targetWalletId: 'bca',
      );
      expect(errSameWallet, isNotNull);
      expect(errSameWallet, contains('tidak boleh sama'));

      // Transfer tanpa dompet tujuan
      final errNoTarget = FinanceState.validate(
        amount: 50000,
        type: TransactionType.transfer,
        walletId: 'bca',
        targetWalletId: null,
      );
      expect(errNoTarget, isNotNull);

      // Pemasukan/pengeluaran tanpa kategori
      final errNoCat = FinanceState.validate(
        amount: 50000,
        type: TransactionType.expense,
        walletId: 'bca',
        categoryId: null,
      );
      expect(errNoCat, isNotNull);
      expect(errNoCat, contains('Kategori wajib'));
    });

    test('Mengingat dompet yang dipilih terakhir', () {
      expect(state.lastSelectedWalletId, isNull);
      state.addTransaction(
        Transaction(
          id: 'tx_wallet_last',
          type: TransactionType.expense,
          amount: 10000,
          date: DateTime(2026, 10, 2),
          walletId: 'tunai',
          categoryId: 'c_makan',
        ),
      );
      expect(state.lastSelectedWalletId, equals('tunai'));
    });
  });

  group('Kelola Dompet dan Kategori (Milestone 5)', () {
    late FinanceState state;
    const bca = Wallet(id: 'bca', name: 'BCA', initialBalance: 0);
    const tunai = Wallet(id: 'tunai', name: 'Tunai', initialBalance: 200000);
    const katMakan = Category(id: 'c_makan', name: 'Makanan', type: CategoryType.expense);
    const katGaji = Category(id: 'c_gaji', name: 'Gaji', type: CategoryType.income);

    setUp(() {
      state = FinanceState(
        initialWallets: [bca, tunai],
        initialCategories: [katMakan, katGaji],
        initialTransactions: [],
      );
    });

    test('(b) Ubah saldo awal BCA jadi 1.000.000: saldo BCA berubah dan menghitung ulang seluruh saldo', () async {
      expect(state.getWalletBalance('bca'), equals(0));

      // Ada transaksi pengeluaran 150.000 di BCA
      await state.addTransaction(
        Transaction(
          id: 'tx_bca_1',
          type: TransactionType.expense,
          amount: 150000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'c_makan',
        ),
      );
      expect(state.getWalletBalance('bca'), equals(-150000));

      // Ubah saldo awal BCA menjadi 1.000.000
      final updatedBca = bca.copyWith(initialBalance: 1000000);
      await state.updateWallet(updatedBca);

      // Saldo sekarang BCA otomatis terhitung ulang: 1.000.000 - 150.000 = 850.000
      expect(state.getWalletBalance('bca'), equals(850000));
      expect(state.walletBalances['bca'], equals(850000));
    });

    test('(c) Dompet yang punya transaksi tidak bisa dihapus permanen, tapi bisa diarsipkan; riwayat lamanya tetap tampil', () async {
      await state.addTransaction(
        Transaction(
          id: 'tx_tunai_1',
          type: TransactionType.expense,
          amount: 50000,
          date: DateTime(2026, 10, 2),
          walletId: 'tunai',
          categoryId: 'c_makan',
        ),
      );

      // Coba hapus dompet 'tunai' yang memiliki transaksi -> harus gagal
      expect(state.isWalletUsed('tunai'), isTrue);
      expect(
        () async => await state.deleteWallet('tunai'),
        throwsA(isA<StateError>()),
      );

      // Arsipkan dompet 'tunai'
      await state.archiveWallet('tunai', isArchived: true);
      expect(state.wallets.firstWhere((w) => w.id == 'tunai').isArchived, isTrue);

      // Riwayat lamanya tetap menampilkan nama dompet
      expect(state.getWalletName('tunai'), equals('Tunai'));
      expect(state.transactions.length, equals(1));
    });

    test('(d) Dompet yang diarsipkan hilang dari activeWallets (form Catat)', () async {
      expect(state.activeWallets.map((w) => w.id), containsAll(['bca', 'tunai']));

      // Arsipkan BCA
      await state.archiveWallet('bca', isArchived: true);

      // BCA hilang dari daftar dompet aktif
      expect(state.activeWallets.map((w) => w.id), isNot(contains('bca')));
      expect(state.activeWallets.map((w) => w.id), contains('tunai'));

      // Tetapi tetap ada di daftar total dompet
      expect(state.wallets.map((w) => w.id), contains('bca'));
    });

    test('(e) Nama dompet kembar dan nama kosong ditolak', () {
      // Nama kosong
      expect(state.validateWalletName(''), isNotNull);
      expect(state.validateWalletName('   '), isNotNull);

      // Nama kembar (case-insensitive)
      expect(state.validateWalletName('bca'), isNotNull);
      expect(state.validateWalletName('BCA'), isNotNull);
      expect(state.validateWalletName('  Bca  '), isNotNull);
      expect(state.validateWalletName('tunai'), isNotNull);

      // Nama baru yang belum ada -> valid
      expect(state.validateWalletName('Mandiri'), isNull);

      // Mengubah dompet dengan nama yang sama miliknya sendiri -> valid
      expect(state.validateWalletName('BCA', excludeWalletId: 'bca'), isNull);
    });

    test('(e) Nama kategori kembar dalam kelompok yang sama dan nama kosong ditolak', () {
      // Nama kosong
      expect(state.validateCategoryName('', CategoryType.expense), isNotNull);
      expect(state.validateCategoryName('   ', CategoryType.expense), isNotNull);

      // Nama kembar di tipe yang sama (case-insensitive)
      expect(state.validateCategoryName('makanan', CategoryType.expense), isNotNull);
      expect(state.validateCategoryName('MAKANAN', CategoryType.expense), isNotNull);
      expect(state.validateCategoryName('  Makanan  ', CategoryType.expense), isNotNull);

      // Nama sama tapi di tipe berbeda diperbolehkan (misal 'Lainnya' di pengeluaran dan pemasukan)
      expect(state.validateCategoryName('Makanan', CategoryType.income), isNull);

      // Mengubah kategori dengan nama yang sama miliknya sendiri -> valid
      expect(state.validateCategoryName('Makanan', CategoryType.expense, excludeCategoryId: 'c_makan'), isNull);
    });

    test('Kategori dengan transaksi tidak bisa dihapus permanen, tapi bisa diarsipkan', () async {
      await state.addTransaction(
        Transaction(
          id: 'tx_kat_1',
          type: TransactionType.expense,
          amount: 25000,
          date: DateTime(2026, 10, 3),
          walletId: 'tunai',
          categoryId: 'c_makan',
        ),
      );

      expect(state.isCategoryUsed('c_makan'), isTrue);
      expect(
        () async => await state.deleteCategory('c_makan'),
        throwsA(isA<StateError>()),
      );

      // Arsipkan kategori
      await state.archiveCategory('c_makan', isArchived: true);
      expect(state.categories.firstWhere((c) => c.id == 'c_makan').isArchived, isTrue);

      // Kategori yang diarsipkan hilang dari activeCategories dan getCategoriesByType tanpa arsip
      expect(state.activeCategories.map((c) => c.id), isNot(contains('c_makan')));
      expect(
        state.getCategoriesByType(TransactionType.expense, includeArchived: false).map((c) => c.id),
        isNot(contains('c_makan')),
      );

      // Riwayat lamanya tetap menampilkan nama kategori
      expect(state.getCategoryName('c_makan'), equals('Makanan'));
    });

    test('Dompet dan kategori tanpa transaksi dapat dihapus permanen', () async {
      // Tambah dompet baru tanpa transaksi
      final newWallet = const Wallet(id: 'w_test', name: 'Dompet Baru', initialBalance: 50000);
      await state.addWallet(newWallet);
      expect(state.wallets.any((w) => w.id == 'w_test'), isTrue);

      // Hapus permanen
      await state.deleteWallet('w_test');
      expect(state.wallets.any((w) => w.id == 'w_test'), isFalse);

      // Tambah kategori baru tanpa transaksi
      final newCat = const Category(id: 'c_test', name: 'Bonus Tahunan', type: CategoryType.income);
      await state.addCategory(newCat);
      expect(state.categories.any((c) => c.id == 'c_test'), isTrue);

      // Hapus permanen
      await state.deleteCategory('c_test');
      expect(state.categories.any((c) => c.id == 'c_test'), isFalse);
    });
  });
}
