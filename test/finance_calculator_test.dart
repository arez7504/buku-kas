import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_calculator.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';

void main() {
  group('FinanceCalculator - Rumus Saldo & Ringkasan Keuangan', () {
    test(
        'Kasus Khusus: Saldo awal BCA 1.000.000 dan Tunai 200.000, transfer BCA ke Tunai 300.000 -> BCA 700.000, Tunai 500.000, total pengeluaran 0',
        () {
      // 1. Inisialisasi dompet sesuai kasus uji
      final bca = const Wallet(
        id: 'bca',
        name: 'BCA',
        initialBalance: 1000000,
      );
      final tunai = const Wallet(
        id: 'tunai',
        name: 'Tunai',
        initialBalance: 200000,
      );
      final wallets = [bca, tunai];

      // 2. Transaksi transfer 300.000 dari BCA ke Tunai
      final transactions = [
        Transaction(
          id: 'tr_1',
          type: TransactionType.transfer,
          amount: 300000,
          date: DateTime(2026, 10, 3),
          walletId: 'bca',
          targetWalletId: 'tunai',
        ),
      ];

      // 3. Hitung saldo masing-masing dompet
      final balances = FinanceCalculator.calculateAllWalletBalances(wallets, transactions);

      expect(balances['bca'], equals(700000));
      expect(balances['tunai'], equals(500000));

      // 4. Hitung ringkasan bulanan (transfer tidak boleh masuk ke pemasukan maupun pengeluaran)
      final summary = FinanceCalculator.calculateMonthlySummary(transactions, 2026, 10);

      expect(summary.totalIncome, equals(0));
      expect(summary.totalExpense, equals(0));
      expect(summary.netCashFlow, equals(0));
    });

    test('Pemasukan menambah saldo dompet dan pengeluaran mengurangi saldo dompet', () {
      final wallet = const Wallet(
        id: 'bca',
        name: 'BCA',
        initialBalance: 500000,
      );

      final transactions = [
        Transaction(
          id: 'tr_inc',
          type: TransactionType.income,
          amount: 200000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
        ),
        Transaction(
          id: 'tr_exp',
          type: TransactionType.expense,
          amount: 150000,
          date: DateTime(2026, 10, 2),
          walletId: 'bca',
        ),
      ];

      final balance = FinanceCalculator.calculateWalletBalance(wallet, transactions);
      // 500.000 + 200.000 - 150.000 = 550.000
      expect(balance, equals(550000));

      final summary = FinanceCalculator.calculateMonthlySummary(transactions, 2026, 10);
      expect(summary.totalIncome, equals(200000));
      expect(summary.totalExpense, equals(150000));
      expect(summary.netCashFlow, equals(50000));
    });

    test('Filter transaksi bulanan memisahkan transaksi berdasarkan bulan dan tahun', () {
      final transactions = [
        Transaction(
          id: 't_oct',
          type: TransactionType.income,
          amount: 100000,
          date: DateTime(2026, 10, 15),
          walletId: 'bca',
        ),
        Transaction(
          id: 't_sep',
          type: TransactionType.expense,
          amount: 50000,
          date: DateTime(2026, 9, 20),
          walletId: 'bca',
        ),
      ];

      final octList = FinanceCalculator.filterTransactionsByMonth(transactions, 2026, 10);
      final sepList = FinanceCalculator.filterTransactionsByMonth(transactions, 2026, 9);
      final novList = FinanceCalculator.filterTransactionsByMonth(transactions, 2026, 11);

      expect(octList.length, equals(1));
      expect(octList.first.id, equals('t_oct'));

      expect(sepList.length, equals(1));
      expect(sepList.first.id, equals('t_sep'));

      expect(novList.isEmpty, isTrue);
    });
  });
}
