import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_calculator.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/transaction_form_screen.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/widgets/buku_kas_hero_summary.dart';

void main() {
  final testWallets = [
    const Wallet(id: 'w_bca', name: 'BCA', initialBalance: 1000000),
    const Wallet(id: 'w_tunai', name: 'Tunai', initialBalance: 500000),
  ];

  final testCategories = [
    const Category(id: 'c_gaji', name: 'Gaji', type: CategoryType.income),
    const Category(id: 'c_bonus', name: 'Bonus', type: CategoryType.income),
    const Category(id: 'c_makan', name: 'Makan', type: CategoryType.expense),
    const Category(id: 'c_belanja', name: 'Belanja', type: CategoryType.expense),
  ];

  group('Kriteria (a): Unit Test Fungsi Pengelompokan & Header', () {
    test('Transaksi di dua hari berbeda menghasilkan dua kelompok urut terbaru di atas', () {
      final txs = [
        Transaction(
          id: 'tx_1',
          type: TransactionType.expense,
          amount: 25000,
          date: DateTime(2026, 10, 5, 10, 0),
          walletId: 'w_tunai',
          categoryId: 'c_makan',
        ),
        Transaction(
          id: 'tx_2',
          type: TransactionType.income,
          amount: 100000,
          date: DateTime(2026, 10, 7, 14, 0),
          walletId: 'w_bca',
          categoryId: 'c_gaji',
        ),
      ];

      final groups = FinanceCalculator.groupTransactionsByDay(txs, 2026, 10);

      expect(groups.length, 2);
      expect(groups[0].date.day, 7);
      expect(groups[1].date.day, 5);
      expect(groups[0].date.isAfter(groups[1].date), isTrue);
    });

    test('Di dalam satu hari, transaksi terbaru diurutkan di atas', () {
      final txs = [
        Transaction(
          id: 'tx_pagi',
          type: TransactionType.expense,
          amount: 15000,
          date: DateTime(2026, 10, 6, 8, 30),
          walletId: 'w_tunai',
          categoryId: 'c_makan',
        ),
        Transaction(
          id: 'tx_malam',
          type: TransactionType.expense,
          amount: 45000,
          date: DateTime(2026, 10, 6, 20, 15),
          walletId: 'w_tunai',
          categoryId: 'c_makan',
        ),
        Transaction(
          id: 'tx_siang',
          type: TransactionType.income,
          amount: 50000,
          date: DateTime(2026, 10, 6, 12, 0),
          walletId: 'w_bca',
          categoryId: 'c_bonus',
        ),
      ];

      final groups = FinanceCalculator.groupTransactionsByDay(txs, 2026, 10);

      expect(groups.length, 1);
      final dayTxs = groups[0].transactions;
      expect(dayTxs.length, 3);
      expect(dayTxs[0].id, 'tx_malam');
      expect(dayTxs[1].id, 'tx_siang');
      expect(dayTxs[2].id, 'tx_pagi');
    });

    test('Subtotal harian = total pemasukan dikurangi total pengeluaran hari itu', () {
      final txs = [
        Transaction(
          id: 'tx_inc',
          type: TransactionType.income,
          amount: 200000,
          date: DateTime(2026, 10, 6, 9, 0),
          walletId: 'w_bca',
          categoryId: 'c_gaji',
        ),
        Transaction(
          id: 'tx_exp',
          type: TransactionType.expense,
          amount: 75000,
          date: DateTime(2026, 10, 6, 13, 0),
          walletId: 'w_bca',
          categoryId: 'c_makan',
        ),
      ];

      final groups = FinanceCalculator.groupTransactionsByDay(txs, 2026, 10);

      expect(groups.length, 1);
      expect(groups[0].subtotal, 125000);
      expect(FinanceCalculator.formatDailySubtotal(groups[0].subtotal), '+ Rp 125.000');
    });

    test('Transfer tidak dihitung dalam subtotal harian', () {
      final txs = [
        Transaction(
          id: 'tx_tf',
          type: TransactionType.transfer,
          amount: 500000,
          date: DateTime(2026, 10, 6, 10, 0),
          walletId: 'w_bca',
          targetWalletId: 'w_tunai',
        ),
        Transaction(
          id: 'tx_exp',
          type: TransactionType.expense,
          amount: 30000,
          date: DateTime(2026, 10, 6, 15, 0),
          walletId: 'w_tunai',
          categoryId: 'c_makan',
        ),
      ];

      final groups = FinanceCalculator.groupTransactionsByDay(txs, 2026, 10);

      expect(groups.length, 1);
      // Transfer diabaikan: income 0, expense 30000 -> subtotal = -30000
      expect(groups[0].subtotal, -30000);
      expect(FinanceCalculator.formatDailySubtotal(groups[0].subtotal), '- Rp 30.000');
    });

    test('Hari berisi transfer saja tidak punya subtotal (subtotal bernilai null)', () {
      final txs = [
        Transaction(
          id: 'tx_tf_only',
          type: TransactionType.transfer,
          amount: 250000,
          date: DateTime(2026, 10, 6, 11, 0),
          walletId: 'w_bca',
          targetWalletId: 'w_tunai',
        ),
      ];

      final groups = FinanceCalculator.groupTransactionsByDay(txs, 2026, 10);

      expect(groups.length, 1);
      expect(groups[0].subtotal, isNull);
      expect(groups[0].hasSubtotal, isFalse);
      expect(FinanceCalculator.formatDailySubtotal(groups[0].subtotal), isNull);
    });

    test('Hari ini dan kemarin berlabel benar dengan singkatan bulan Indonesia kapital', () {
      final now = DateTime(2026, 10, 8, 14, 30);
      final today = DateTime(2026, 10, 8, 9, 0);
      final yesterday = DateTime(2026, 10, 7, 21, 0);
      final otherDay = DateTime(2026, 10, 6, 10, 0);

      expect(
        FinanceCalculator.formatDayGroupHeader(today, now: now),
        'HARI INI, 8 OKT 2026',
      );
      expect(
        FinanceCalculator.formatDayGroupHeader(yesterday, now: now),
        'KEMARIN, 7 OKT 2026',
      );
      expect(
        FinanceCalculator.formatDayGroupHeader(otherDay, now: now),
        '6 OKT 2026',
      );
    });

    test('Format header bulan lainnya memakai singkatan kapital baku', () {
      final now = DateTime(2026, 12, 31);
      expect(
        FinanceCalculator.formatDayGroupHeader(DateTime(2026, 1, 15), now: now),
        '15 JAN 2026',
      );
      expect(
        FinanceCalculator.formatDayGroupHeader(DateTime(2026, 8, 17), now: now),
        '17 AGU 2026',
      );
    });
  });

  group('Kriteria (b): Konsistensi Subtotal Harian vs Selisih Bulanan', () {
    test('Jumlah semua subtotal harian satu bulan sama persis dengan Selisih bulanan di kartu ringkasan', () {
      final txs = [
        // Hari 1: Income 1.000.000, Expense 200.000 -> subtotal = +800.000
        Transaction(
          id: 'tx_1',
          type: TransactionType.income,
          amount: 1000000,
          date: DateTime(2026, 10, 1, 9, 0),
          walletId: 'w_bca',
          categoryId: 'c_gaji',
        ),
        Transaction(
          id: 'tx_2',
          type: TransactionType.expense,
          amount: 200000,
          date: DateTime(2026, 10, 1, 12, 0),
          walletId: 'w_bca',
          categoryId: 'c_belanja',
        ),
        // Hari 3: Transfer saja -> subtotal null (kontribusi 0)
        Transaction(
          id: 'tx_3',
          type: TransactionType.transfer,
          amount: 300000,
          date: DateTime(2026, 10, 3, 10, 0),
          walletId: 'w_bca',
          targetWalletId: 'w_tunai',
        ),
        // Hari 5: Expense 150.000 -> subtotal = -150.000
        Transaction(
          id: 'tx_4',
          type: TransactionType.expense,
          amount: 150000,
          date: DateTime(2026, 10, 5, 14, 0),
          walletId: 'w_tunai',
          categoryId: 'c_makan',
        ),
        // Hari 8: Income 50.000, Expense 80.000 -> subtotal = -30.000
        Transaction(
          id: 'tx_5',
          type: TransactionType.income,
          amount: 50000,
          date: DateTime(2026, 10, 8, 8, 0),
          walletId: 'w_tunai',
          categoryId: 'c_bonus',
        ),
        Transaction(
          id: 'tx_6',
          type: TransactionType.expense,
          amount: 80000,
          date: DateTime(2026, 10, 8, 18, 0),
          walletId: 'w_tunai',
          categoryId: 'c_makan',
        ),
      ];

      final groups = FinanceCalculator.groupTransactionsByDay(txs, 2026, 10);
      final monthlySummary = FinanceCalculator.calculateMonthlySummary(txs, 2026, 10);

      // Jumlahkan semua subtotal harian (abaikan null transfer-only)
      int totalDailySubtotals = 0;
      for (final g in groups) {
        if (g.subtotal != null) {
          totalDailySubtotals += g.subtotal!;
        }
      }

      // 800.000 + (-150.000) + (-30.000) = 620.000
      expect(totalDailySubtotals, 620000);
      expect(monthlySummary.netCashFlow, 620000);
      expect(totalDailySubtotals, equals(monthlySummary.netCashFlow));
    });

    test('Konsistensi tetap terjaga ketika total selisih bulanan bernilai negatif', () {
      final txs = [
        Transaction(
          id: 'tx_a',
          type: TransactionType.expense,
          amount: 500000,
          date: DateTime(2026, 10, 2, 10, 0),
          walletId: 'w_bca',
          categoryId: 'c_belanja',
        ),
        Transaction(
          id: 'tx_b',
          type: TransactionType.income,
          amount: 100000,
          date: DateTime(2026, 10, 4, 11, 0),
          walletId: 'w_tunai',
          categoryId: 'c_bonus',
        ),
      ];

      final groups = FinanceCalculator.groupTransactionsByDay(txs, 2026, 10);
      final monthlySummary = FinanceCalculator.calculateMonthlySummary(txs, 2026, 10);

      int totalDailySubtotals = 0;
      for (final g in groups) {
        if (g.subtotal != null) {
          totalDailySubtotals += g.subtotal!;
        }
      }

      expect(totalDailySubtotals, -400000);
      expect(monthlySummary.netCashFlow, -400000);
      expect(totalDailySubtotals, equals(monthlySummary.netCashFlow));
    });
  });

  group('Kriteria (c): Test Widget Kartu Ringkasan & Selisih Negatif', () {
    testWidgets('Selisih negatif tampil merah dengan tanda minus di kartu ringkasan', (tester) async {
      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: [
          // Income 100.000, Expense 250.000 -> Selisih = -150.000
          Transaction(
            id: 'tx_inc',
            type: TransactionType.income,
            amount: 100000,
            date: DateTime(2026, 10, 2, 9, 0),
            walletId: 'w_bca',
            categoryId: 'c_bonus',
          ),
          Transaction(
            id: 'tx_exp',
            type: TransactionType.expense,
            amount: 250000,
            date: DateTime(2026, 10, 2, 15, 0),
            walletId: 'w_bca',
            categoryId: 'c_belanja',
          ),
        ],
      );

      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Verifikasi teks "- Rp 150.000" ada di layar
      final negativeSelisihFinder = find.text('- Rp 150.000');
      expect(negativeSelisihFinder, findsWidgets);

      // Verifikasi warna teksnya adalah AppColors.expenseRed
      final Text selisihTextWidget = tester.widget<Text>(negativeSelisihFinder.first);
      expect(selisihTextWidget.style?.color, AppColors.expenseRed);
    });

    testWidgets('Selisih nol atau positif tampil warna selisihTeal tanpa tanda minus di depan nominal', (tester) async {
      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: [
          Transaction(
            id: 'tx_inc',
            type: TransactionType.income,
            amount: 300000,
            date: DateTime(2026, 10, 2, 9, 0),
            walletId: 'w_bca',
            categoryId: 'c_gaji',
          ),
          Transaction(
            id: 'tx_exp',
            type: TransactionType.expense,
            amount: 100000,
            date: DateTime(2026, 10, 2, 15, 0),
            walletId: 'w_bca',
            categoryId: 'c_belanja',
          ),
        ],
      );

      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Selisih = 200.000 -> "Rp 200.000"
      final selisihFinder = find.text('Rp 200.000');
      expect(selisihFinder, findsWidgets);

      final Text selisihTextWidget = tester.widget<Text>(selisihFinder.first);
      expect(selisihTextWidget.style?.color, AppColors.selisihTeal);
    });

    testWidgets('Kartu ringkasan memiliki 2 kartu kecil berdampingan (Expanded flex: 1) dan FittedBox(scaleDown)', (tester) async {
      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: [],
      );

      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      final heroFinder = find.byType(BukuKasHeroSummary);
      expect(heroFinder, findsOneWidget);

      // Verifikasi 2 kartu kecil berdampingan Expanded flex: 1 (Pemasukan & Selisih)
      final expandedColumns = find.descendant(
        of: heroFinder,
        matching: find.byType(Expanded),
      );
      expect(expandedColumns, findsNWidgets(2));
      for (final element in expandedColumns.evaluate()) {
        final exp = element.widget as Expanded;
        expect(exp.flex, 1);
      }

      // Verifikasi 3 FittedBox dengan fit scaleDown (Pengeluaran, Pemasukan, Selisih)
      final fittedBoxes = find.descendant(
        of: heroFinder,
        matching: find.byType(FittedBox),
      );
      expect(fittedBoxes, findsNWidgets(3));
      for (final element in fittedBoxes.evaluate()) {
        final fb = element.widget as FittedBox;
        expect(fb.fit, BoxFit.scaleDown);
      }
    });

    testWidgets('Tautan "Lihat rincian pengeluaran" berada di baris tersendiri dan rata kanan', (tester) async {
      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: [],
      );

      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Memastikan tautan terlihat dan dapat ditemukan
      expect(find.byKey(const Key('lihat_rincian_link')), findsOneWidget);
      expect(find.text('Lihat rincian'), findsOneWidget);
      expect(find.text(' pengeluaran'), findsOneWidget);

      // Memastikan ada ikon chevron_right
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('Baris transaksi tidak memuat tanggal, dan tap membuka form edit', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: [
          Transaction(
            id: 'tx_edit_test',
            type: TransactionType.expense,
            amount: 75000,
            date: DateTime(2026, 10, 2, 10, 0),
            walletId: 'w_bca',
            categoryId: 'c_belanja',
            note: 'Beli buku tulis',
          ),
        ],
      );

      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Nama kategori (huruf kapital kecil) dan catatan muncul
      expect(find.text('BELANJA'), findsOneWidget);
      expect(find.text('Beli buku tulis'), findsOneWidget);

      // Tap baris transaksi untuk membuka form edit
      await tester.tap(find.text('Beli buku tulis'));
      await tester.pumpAndSettle();

      // Verifikasi layar edit transaksi terbuka
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      expect(find.text('Edit Transaksi'), findsOneWidget);
    });

    testWidgets('Judul kelompok menampilkan subtotal harian hijau (+), merah (-), dan tidak ada jika transfer saja', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: [
          // Hari 2: Transfer saja -> subtotal tidak ditampilkan
          Transaction(
            id: 'tx_d2',
            type: TransactionType.transfer,
            amount: 50000,
            date: DateTime(2026, 10, 2, 8, 0),
            walletId: 'w_bca',
            targetWalletId: 'w_tunai',
          ),
          // Hari 3: Pengeluaran 50.000 & Pemasukan 10.000 -> subtotal = -40.000 (merah)
          Transaction(
            id: 'tx_d3_exp',
            type: TransactionType.expense,
            amount: 50000,
            date: DateTime(2026, 10, 3, 10, 0),
            walletId: 'w_tunai',
            categoryId: 'c_makan',
          ),
          Transaction(
            id: 'tx_d3_inc',
            type: TransactionType.income,
            amount: 10000,
            date: DateTime(2026, 10, 3, 14, 0),
            walletId: 'w_tunai',
            categoryId: 'c_bonus',
          ),
          // Hari 4: Pemasukan 100.000 & Pengeluaran 20.000 -> subtotal = +80.000 (hijau)
          Transaction(
            id: 'tx_d4_inc',
            type: TransactionType.income,
            amount: 100000,
            date: DateTime(2026, 10, 4, 12, 0),
            walletId: 'w_bca',
            categoryId: 'c_gaji',
          ),
          Transaction(
            id: 'tx_d4_exp',
            type: TransactionType.expense,
            amount: 20000,
            date: DateTime(2026, 10, 4, 16, 0),
            walletId: 'w_bca',
            categoryId: 'c_belanja',
          ),
        ],
      );

      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Subtotal positif: "+ Rp 80.000" hijau
      final greenSubtotal = find.text('+ Rp 80.000');
      expect(greenSubtotal, findsOneWidget);
      final Text greenTextWidget = tester.widget<Text>(greenSubtotal);
      expect(greenTextWidget.style?.color, AppColors.incomeGreen);

      // Subtotal negatif: "- Rp 40.000" merah
      final redSubtotal = find.text('- Rp 40.000');
      expect(redSubtotal, findsOneWidget);
      final Text redTextWidget = tester.widget<Text>(redSubtotal);
      expect(redTextWidget.style?.color, AppColors.expenseRed);

      // Hari transfer saja: tidak ada subtotal untuk hari itu
      expect(find.text('2 OKT 2026'), findsOneWidget);
      // Memastikan bukan "Rp 0" yang ditampilkan
      expect(find.text('Rp 0'), findsNothing);
    });
  });
}
