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
}
