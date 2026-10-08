import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_calculator.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';

void main() {
  group('FinanceCalculator.calculateExpenseBreakdown', () {
    final categories = [
      const Category(id: 'cat_makanan', name: 'Makanan', type: CategoryType.expense),
      const Category(id: 'cat_transportasi', name: 'Transportasi', type: CategoryType.expense),
      const Category(id: 'cat_tagihan', name: 'Tagihan', type: CategoryType.expense),
      const Category(id: 'cat_hiburan', name: 'Hiburan', type: CategoryType.expense),
      const Category(id: 'cat_gaji', name: 'Gaji', type: CategoryType.income),
      const Category(
        id: 'cat_arsip',
        name: 'Langganan Lama',
        type: CategoryType.expense,
        isArchived: true,
      ),
    ];

    test(
        '(a) Makanan 35.000, Transportasi 50.000, Tagihan 120.000 menghasilkan urutan Tagihan, Transportasi, Makanan dengan persen 58,5 / 24,4 / 17,1 dan total 205.000',
        () {
      final transactions = [
        Transaction(
          id: 'tx_1',
          type: TransactionType.expense,
          amount: 35000,
          date: DateTime(2026, 10, 2),
          walletId: 'bca',
          categoryId: 'cat_makanan',
        ),
        Transaction(
          id: 'tx_2',
          type: TransactionType.expense,
          amount: 50000,
          date: DateTime(2026, 10, 5),
          walletId: 'tunai',
          categoryId: 'cat_transportasi',
        ),
        Transaction(
          id: 'tx_3',
          type: TransactionType.expense,
          amount: 120000,
          date: DateTime(2026, 10, 10),
          walletId: 'bca',
          categoryId: 'cat_tagihan',
        ),
      ];

      final result = FinanceCalculator.calculateExpenseBreakdown(
        transactions,
        categories,
        2026,
        10,
      );

      // Total harus 205.000
      expect(result.totalExpense, equals(205000));
      expect(result.items.length, equals(3));

      // Baris 1: Tagihan (120.000, 58,5%)
      final item0 = result.items[0];
      expect(item0.categoryName, equals('Tagihan'));
      expect(item0.amount, equals(120000));
      expect(item0.percentageText, equals('58,5'));
      expect(item0.formattedPercentage, equals('58,5%'));
      expect(item0.percentage, equals(58.5));

      // Baris 2: Transportasi (50.000, 24,4%)
      final item1 = result.items[1];
      expect(item1.categoryName, equals('Transportasi'));
      expect(item1.amount, equals(50000));
      expect(item1.percentageText, equals('24,4'));
      expect(item1.formattedPercentage, equals('24,4%'));
      expect(item1.percentage, equals(24.4));

      // Baris 3: Makanan (35.000, 17,1%)
      final item2 = result.items[2];
      expect(item2.categoryName, equals('Makanan'));
      expect(item2.amount, equals(35000));
      expect(item2.percentageText, equals('17,1'));
      expect(item2.formattedPercentage, equals('17,1%'));
      expect(item2.percentage, equals(17.1));
    });

    test('(b) Transfer dan pemasukan tidak masuk rincian pengeluaran', () {
      final transactions = [
        Transaction(
          id: 'tx_inc',
          type: TransactionType.income,
          amount: 10000000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'cat_gaji',
        ),
        Transaction(
          id: 'tx_trf',
          type: TransactionType.transfer,
          amount: 500000,
          date: DateTime(2026, 10, 2),
          walletId: 'bca',
          targetWalletId: 'tunai',
        ),
        Transaction(
          id: 'tx_exp',
          type: TransactionType.expense,
          amount: 75000,
          date: DateTime(2026, 10, 3),
          walletId: 'bca',
          categoryId: 'cat_makanan',
        ),
      ];

      final result = FinanceCalculator.calculateExpenseBreakdown(
        transactions,
        categories,
        2026,
        10,
      );

      expect(result.totalExpense, equals(75000));
      expect(result.items.length, equals(1));
      expect(result.items.first.categoryName, equals('Makanan'));
      expect(result.items.first.amount, equals(75000));
      expect(result.items.first.formattedPercentage, equals('100,0%'));
    });

    test('(b) Kategori yang diarsipkan tetap dihitung dan tampil dengan namanya', () {
      final transactions = [
        Transaction(
          id: 'tx_archived',
          type: TransactionType.expense,
          amount: 80000,
          date: DateTime(2026, 10, 4),
          walletId: 'bca',
          categoryId: 'cat_arsip',
        ),
        Transaction(
          id: 'tx_food',
          type: TransactionType.expense,
          amount: 40000,
          date: DateTime(2026, 10, 5),
          walletId: 'tunai',
          categoryId: 'cat_makanan',
        ),
      ];

      final result = FinanceCalculator.calculateExpenseBreakdown(
        transactions,
        categories,
        2026,
        10,
      );

      expect(result.totalExpense, equals(120000));
      expect(result.items.length, equals(2));

      final archivedItem = result.items.firstWhere((i) => i.categoryId == 'cat_arsip');
      expect(archivedItem.categoryName, equals('Langganan Lama'));
      expect(archivedItem.amount, equals(80000));
      expect(archivedItem.formattedPercentage, equals('66,7%'));
    });

    test('(b) Bulan tanpa pengeluaran menghasilkan daftar kosong', () {
      final transactions = [
        // Hanya ada pemasukan dan transfer di bulan Oktober
        Transaction(
          id: 'tx_inc',
          type: TransactionType.income,
          amount: 500000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'cat_gaji',
        ),
        Transaction(
          id: 'tx_trf',
          type: TransactionType.transfer,
          amount: 100000,
          date: DateTime(2026, 10, 2),
          walletId: 'bca',
          targetWalletId: 'tunai',
        ),
        // Pengeluaran ada di bulan September
        Transaction(
          id: 'tx_exp_sep',
          type: TransactionType.expense,
          amount: 25000,
          date: DateTime(2026, 9, 28),
          walletId: 'bca',
          categoryId: 'cat_makanan',
        ),
      ];

      final result = FinanceCalculator.calculateExpenseBreakdown(
        transactions,
        categories,
        2026,
        10,
      );

      expect(result.totalExpense, equals(0));
      expect(result.items, isEmpty);
      expect(result.isEmpty, isTrue);
    });

    test('(c) Total rincian = Pengeluaran bulan ini di Buku Kas pada data uji yang sama', () {
      final transactions = [
        Transaction(
          id: 'tx_1',
          type: TransactionType.expense,
          amount: 45000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'cat_makanan',
        ),
        Transaction(
          id: 'tx_2',
          type: TransactionType.expense,
          amount: 130000,
          date: DateTime(2026, 10, 2),
          walletId: 'bca',
          categoryId: 'cat_tagihan',
        ),
        Transaction(
          id: 'tx_3',
          type: TransactionType.income,
          amount: 3000000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'cat_gaji',
        ),
        Transaction(
          id: 'tx_4',
          type: TransactionType.transfer,
          amount: 500000,
          date: DateTime(2026, 10, 3),
          walletId: 'bca',
          targetWalletId: 'tunai',
        ),
        Transaction(
          id: 'tx_5',
          type: TransactionType.expense,
          amount: 65000,
          date: DateTime(2026, 10, 4),
          walletId: 'tunai',
          categoryId: 'cat_transportasi',
        ),
      ];

      // Hitung ringkasan bulanan seperti di Buku Kas
      final summary = FinanceCalculator.calculateMonthlySummary(transactions, 2026, 10);

      // Hitung rincian pengeluaran per kategori
      final breakdown = FinanceCalculator.calculateExpenseBreakdown(
        transactions,
        categories,
        2026,
        10,
      );

      // Total rincian harus sama persis dengan total pengeluaran di Buku Kas
      expect(breakdown.totalExpense, equals(summary.totalExpense));

      // Akumulasi manual seluruh nominal baris rincian juga harus sama persis
      final sumOfItems = breakdown.items.fold<int>(0, (sum, i) => sum + i.amount);
      expect(sumOfItems, equals(summary.totalExpense));
      expect(breakdown.totalExpense, equals(240000));
    });

    test('Beberapa transaksi pada kategori yang sama diakumulasikan ke satu baris', () {
      final transactions = [
        Transaction(
          id: 'tx_1',
          type: TransactionType.expense,
          amount: 15000,
          date: DateTime(2026, 10, 1),
          walletId: 'bca',
          categoryId: 'cat_makanan',
        ),
        Transaction(
          id: 'tx_2',
          type: TransactionType.expense,
          amount: 20000,
          date: DateTime(2026, 10, 2),
          walletId: 'tunai',
          categoryId: 'cat_makanan',
        ),
      ];

      final result = FinanceCalculator.calculateExpenseBreakdown(
        transactions,
        categories,
        2026,
        10,
      );

      expect(result.items.length, equals(1));
      expect(result.items.first.categoryName, equals('Makanan'));
      expect(result.items.first.amount, equals(35000));
      expect(result.items.first.formattedPercentage, equals('100,0%'));
      expect(result.totalExpense, equals(35000));
    });
  });
}
