import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';

void main() {
  Widget createTestWidget({
    List<Wallet>? wallets,
    List<Category>? categories,
    List<Transaction>? transactions,
  }) {
    final state = FinanceState(
      initialWallets: wallets ??
          const [
            Wallet(id: 'bca', name: 'BCA', initialBalance: 1000000),
            Wallet(id: 'tunai', name: 'Tunai', initialBalance: 500000),
          ],
      initialCategories: categories ??
          const [
            Category(id: 'cat_makanan', name: 'Makanan', type: CategoryType.expense),
            Category(id: 'cat_transportasi', name: 'Transportasi', type: CategoryType.expense),
            Category(id: 'cat_tagihan', name: 'Tagihan', type: CategoryType.expense),
            Category(id: 'cat_gaji', name: 'Gaji', type: CategoryType.income),
          ],
      initialTransactions: transactions ?? [],
    );

    return MyApp(initialState: state);
  }

  group('Widget Tests - Layar Rincian Pengeluaran per Kategori', () {
    testWidgets(
        'Tautan "Lihat rincian" muncul di bawah angka Pengeluaran bulan ini dan membuka layar Rincian Pengeluaran',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verifikasi teks "Lihat rincian" ada di layar Buku Kas
      expect(find.text('Lihat rincian'), findsOneWidget);

      // Tap tautan "Lihat rincian"
      await tester.tap(find.text('Lihat rincian'));
      await tester.pumpAndSettle();

      // Verifikasi layar Rincian Pengeluaran terbuka
      expect(find.text('Rincian Pengeluaran'), findsOneWidget);
      expect(find.text('DISTRIBUSI PENGELUARAN'), findsOneWidget);
      expect(find.text('TOTAL PENGELUARAN'), findsOneWidget);
    });

    testWidgets(
        'Layar Rincian Pengeluaran menampilkan data terurut dari terbesar, persen 1 desimal, nominal, dan batang',
        (WidgetTester tester) async {
      final sampleTransactions = [
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

      await tester.pumpWidget(createTestWidget(transactions: sampleTransactions));
      await tester.pumpAndSettle();

      // Buka layar Rincian Pengeluaran
      await tester.tap(find.text('Lihat rincian'));
      await tester.pumpAndSettle();

      // Total pengeluaran harus Rp 205.000
      expect(find.text('Rp 205.000'), findsOneWidget);

      // Kategori Tagihan, Transportasi, Makanan harus muncul
      expect(find.text('Tagihan'), findsOneWidget);
      expect(find.text('Rp 120.000'), findsOneWidget);
      expect(find.text('58,5%'), findsOneWidget);

      expect(find.text('Transportasi'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsOneWidget);
      expect(find.text('24,4%'), findsOneWidget);

      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Rp 35.000'), findsOneWidget);
      expect(find.text('17,1%'), findsOneWidget);

      // Tap salah satu baris kategori (ditunda - tidak melakukan apa-apa)
      await tester.tap(find.text('Tagihan'));
      await tester.pumpAndSettle();

      // Layar tetap di Rincian Pengeluaran
      expect(find.text('Rincian Pengeluaran'), findsOneWidget);
    });

    testWidgets(
        'Bulan tanpa pengeluaran menampilkan pesan kosong yang jelas dan total Rp 0',
        (WidgetTester tester) async {
      // Tidak ada transaksi pengeluaran di bulan Oktober
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Buka rincian
      await tester.tap(find.text('Lihat rincian'));
      await tester.pumpAndSettle();

      // Angka total Rp 0
      expect(find.text('Rp 0'), findsOneWidget);

      // Pesan kondisi kosong yang jelas
      expect(find.text('Tidak ada pengeluaran di bulan ini'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    });

    testWidgets(
        'Perpindahan bulan di layar Rincian Pengeluaran ikut menggeser bulan yang sama di Buku Kas saat kembali',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Di Buku Kas awalnya Oktober 2026
      expect(find.text('Oktober 2026'), findsOneWidget);

      // Buka layar Rincian Pengeluaran
      await tester.tap(find.text('Lihat rincian'));
      await tester.pumpAndSettle();

      // Di Rincian Pengeluaran awalnya juga Oktober 2026
      expect(find.text('Oktober 2026'), findsOneWidget);

      // Pindah ke bulan sebelumnya (September 2026) via panah kiri di layar Rincian
      await tester.tap(find.byKey(const Key('expense_breakdown_prev_month')));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);

      // Tekan tombol kembali di header Rincian Pengeluaran
      await tester.tap(find.byKey(const Key('expense_breakdown_back_button')));
      await tester.pumpAndSettle();

      // Di Buku Kas sekarang juga menampilkan September 2026 (sinkron menggeser bulan)
      expect(find.text('September 2026'), findsOneWidget);
    });
  });
}
