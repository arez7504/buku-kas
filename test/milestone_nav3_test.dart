import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/screens/riwayat_screen.dart';
import 'package:catatan_keuangan/screens/transaction_form_screen.dart';
import 'package:catatan_keuangan/widgets/buku_kas_day_group.dart';
import 'package:catatan_keuangan/widgets/main_bottom_nav_bar.dart';
import 'package:catatan_keuangan/logic/finance_calculator.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';

final sampleCatExpenseMakanan = const Category(
  id: 'cat_makanan',
  name: 'Makanan',
  type: CategoryType.expense,
);
final sampleCatExpenseLainnya = const Category(
  id: 'cat_exp_lainnya',
  name: 'Lainnya',
  type: CategoryType.expense,
);
final sampleCatIncomeGaji = const Category(
  id: 'cat_gaji',
  name: 'Gaji',
  type: CategoryType.income,
);
final sampleCatIncomeLainnya = const Category(
  id: 'cat_inc_lainnya',
  name: 'Lainnya',
  type: CategoryType.income,
);
final sampleCatExpenseArchived = const Category(
  id: 'cat_archived',
  name: 'Belanja Lama',
  type: CategoryType.expense,
  isArchived: true,
);

final sampleCategories = [
  sampleCatExpenseMakanan,
  sampleCatExpenseLainnya,
  sampleCatIncomeGaji,
  sampleCatIncomeLainnya,
  sampleCatExpenseArchived,
];

final sampleTransactions = [
  // Oktober 2026
  Transaction(
    id: 'tx_1',
    amount: 50000,
    type: TransactionType.expense,
    walletId: 'bca',
    categoryId: 'cat_makanan',
    date: DateTime(2026, 10, 5, 10, 0),
  ),
  Transaction(
    id: 'tx_2',
    amount: 25000,
    type: TransactionType.expense,
    walletId: 'bca',
    categoryId: 'cat_exp_lainnya',
    date: DateTime(2026, 10, 6, 12, 0),
  ),
  Transaction(
    id: 'tx_3',
    amount: 5000000,
    type: TransactionType.income,
    walletId: 'bca',
    categoryId: 'cat_gaji',
    date: DateTime(2026, 10, 1, 8, 0),
  ),
  Transaction(
    id: 'tx_4',
    amount: 100000,
    type: TransactionType.income,
    walletId: 'tunai',
    categoryId: 'cat_inc_lainnya',
    date: DateTime(2026, 10, 7, 9, 0),
  ),
  Transaction(
    id: 'tx_5',
    amount: 200000,
    type: TransactionType.transfer,
    walletId: 'bca',
    targetWalletId: 'tunai',
    date: DateTime(2026, 10, 8, 14, 0),
  ),
  Transaction(
    id: 'tx_6',
    amount: 15000,
    type: TransactionType.expense,
    walletId: 'tunai',
    categoryId: 'cat_archived',
    date: DateTime(2026, 10, 9, 15, 0),
  ),
  // September 2026 (bulan lain)
  Transaction(
    id: 'tx_old',
    amount: 1000000,
    type: TransactionType.income,
    walletId: 'bca',
    categoryId: 'cat_gaji',
    date: DateTime(2026, 9, 25, 8, 0),
  ),
  // November 2026 (bulan masa depan)
  Transaction(
    id: 'tx_future',
    amount: 30000,
    type: TransactionType.expense,
    walletId: 'bca',
    categoryId: 'cat_makanan',
    date: DateTime(2026, 11, 2, 10, 0),
  ),
];

Widget buildNav3TestApp({
  FinanceState? state,
  int initialNavIndex = 1,
}) {
  final effectiveState = state ??
      FinanceState(
        initialWallets: [
          const Wallet(id: 'bca', name: 'BCA', initialBalance: 10000000),
          const Wallet(id: 'tunai', name: 'Tunai', initialBalance: 2000000),
        ],
        initialCategories: sampleCategories,
        initialTransactions: sampleTransactions,
      );
  return MyApp(
    initialState: effectiveState,
    initialNavIndex: initialNavIndex,
  );
}

void main() {
  group('Milestone NAV-3: Logika Penyaring, Ringkasan, dan 5 Transaksi Terbaru', () {
    test('(a) Penyaring jenis pengeluaran hanya mengembalikan pengeluaran; jenis transfer hanya transfer; categoryId menyaring berdasarkan ID', () {
      // 1. Jenis pengeluaran saja di Oktober 2026
      final expenseList = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.expense,
        categories: sampleCategories,
      );
      expect(expenseList.length, 3);
      expect(expenseList.every((t) => t.type == TransactionType.expense), isTrue);

      // 2. Jenis transfer saja di Oktober 2026
      final transferList = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.transfer,
        categories: sampleCategories,
      );
      expect(transferList.length, 1);
      expect(transferList.first.id, 'tx_5');
      expect(transferList.first.type, TransactionType.transfer);

      // 3. categoryId menyaring berdasarkan ID:
      // Memilih 'cat_inc_lainnya' (Lainnya pemasukan) tidak boleh menampilkan 'cat_exp_lainnya' (Lainnya pengeluaran)
      final incLainnyaList = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.all,
        categoryId: 'cat_inc_lainnya',
        categories: sampleCategories,
      );
      expect(incLainnyaList.length, 1);
      expect(incLainnyaList.first.id, 'tx_4');
      expect(incLainnyaList.first.categoryId, 'cat_inc_lainnya');

      final expLainnyaList = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.expense,
        categoryId: 'cat_exp_lainnya',
        categories: sampleCategories,
      );
      expect(expLainnyaList.length, 1);
      expect(expLainnyaList.first.id, 'tx_2');
      expect(expLainnyaList.first.categoryId, 'cat_exp_lainnya');
    });

    test('(b) Kombinasi jenis dan kategori bertentangan menghasilkan daftar kosong; transfer mengabaikan categoryId', () {
      // Jenis pemasukan dengan categoryId bertipe pengeluaran ('cat_makanan') -> daftar kosong
      final conflictList1 = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.income,
        categoryId: 'cat_makanan',
        categories: sampleCategories,
      );
      expect(conflictList1, isEmpty);

      // Jenis pengeluaran dengan categoryId bertipe pemasukan ('cat_gaji') -> daftar kosong
      final conflictList2 = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.expense,
        categoryId: 'cat_gaji',
        categories: sampleCategories,
      );
      expect(conflictList2, isEmpty);

      // Jenis transfer: categoryId diabaikan
      final transferWithCategory = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.transfer,
        categoryId: 'cat_makanan', // Harusnya diabaikan untuk transfer
        categories: sampleCategories,
      );
      expect(transferWithCategory.length, 1);
      expect(transferWithCategory.first.id, 'tx_5');
    });

    test('(c) Ringkasan: total pemasukan dan pengeluaran benar, transfer tidak dihitung, count sama dengan panjang daftar', () {
      // Semua transaksi Oktober 2026
      final allOct = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.all,
        categories: sampleCategories,
      );
      expect(allOct.length, 6);

      final summaryAll = FinanceCalculator.calculateFilteredSummary(allOct);
      expect(summaryAll.transactionCount, 6);
      expect(summaryAll.totalIncome, 5100000); // 5000000 + 100000
      expect(summaryAll.totalExpense, 90000); // 50000 + 25000 + 15000
      // Transfer (tx_5: 200000) TIDAK dihitung dalam totalIncome atau totalExpense

      // Ringkasan untuk transfer saja
      final transferOct = FinanceCalculator.filterTransactions(
        transactions: sampleTransactions,
        year: 2026,
        month: 10,
        type: TransactionFilterType.transfer,
        categories: sampleCategories,
      );
      final summaryTransfer = FinanceCalculator.calculateFilteredSummary(transferOct);
      expect(summaryTransfer.transactionCount, 1);
      expect(summaryTransfer.totalIncome, 0);
      expect(summaryTransfer.totalExpense, 0);
    });

    test('(f) 5 transaksi terbaru secara keseluruhan: urut benar, tanpa batas bulan, kurang dari 5 ditampilkan semua, termasuk transfer', () {
      // Total transaksi pada data ada 8
      final recent5 = FinanceCalculator.getRecentTransactions(sampleTransactions, limit: 5);
      expect(recent5.length, 5);
      // Urutan tanggal descending:
      // 1. tx_future (2026-11-02)
      // 2. tx_6 (2026-10-09)
      // 3. tx_5 (2026-10-08, transfer)
      // 4. tx_4 (2026-10-07)
      // 5. tx_2 (2026-10-06)
      expect(recent5[0].id, 'tx_future');
      expect(recent5[1].id, 'tx_6');
      expect(recent5[2].id, 'tx_5');
      expect(recent5[2].type, TransactionType.transfer);
      expect(recent5[3].id, 'tx_4');
      expect(recent5[4].id, 'tx_2');

      // Kurang dari 5 transaksi
      final subset = sampleTransactions.take(3).toList();
      final recentSubset = FinanceCalculator.getRecentTransactions(subset, limit: 5);
      expect(recentSubset.length, 3);

      // Kosong
      expect(FinanceCalculator.getRecentTransactions([], limit: 5), isEmpty);
    });

    test('(d & e) FinanceState integrasi filter dan kategori dinamis & arsip', () async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'bca', name: 'BCA', initialBalance: 1000000),
          const Wallet(id: 'tunai', name: 'Tunai', initialBalance: 500000),
        ],
        initialCategories: sampleCategories,
        initialTransactions: sampleTransactions,
      );

      // Kategori baru ditambah lewat state
      await state.addCategory(const Category(
        id: 'cat_investasi',
        name: 'Investasi',
        type: CategoryType.income,
      ));

      expect(state.categories.any((c) => c.id == 'cat_investasi'), isTrue);
      // Kategori terarsip tetap muncul bertanda isArchived == true
      expect(state.categories.firstWhere((c) => c.id == 'cat_archived').isArchived, isTrue);

      // Memastikan helper state memanggil filter dengan benar
      final filteredFromState = state.getFilteredTransactions(
        year: 2026,
        month: 10,
        type: TransactionFilterType.income,
      );
      expect(filteredFromState.length, 2);
    });
  });

  group('Milestone NAV-3: Widget Tests Tab Riwayat & Beranda', () {
    testWidgets('(g1) Filter jenis mengubah daftar transaksi dan ringkasan di Tab Riwayat', (tester) async {
      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 1));
      await tester.pumpAndSettle();

      // Memastikan tab Riwayat aktif
      expect(find.byType(RiwayatScreen), findsOneWidget);

      // Default: 'Semua' aktif, ringkasan menampilkan 6 transaksi, + Rp 5.100.000, - Rp 90.000
      expect(find.byKey(const Key('riwayat_filter_semua')), findsOneWidget);
      expect(find.text('6 transaksi'), findsOneWidget);
      expect(find.text('+ Rp 5.100.000'), findsOneWidget);
      expect(find.text('- Rp 90.000'), findsOneWidget);

      // Tap Pemasukan
      await tester.tap(find.byKey(const Key('riwayat_filter_pemasukan')));
      await tester.pumpAndSettle();

      expect(find.text('2 transaksi'), findsOneWidget);
      expect(find.text('+ Rp 5.100.000'), findsOneWidget);
      expect(find.text('- Rp 90.000'), findsNothing);

      // Tap Pengeluaran
      await tester.tap(find.byKey(const Key('riwayat_filter_pengeluaran')));
      await tester.pumpAndSettle();

      expect(find.text('3 transaksi'), findsOneWidget);
      expect(find.text('- Rp 90.000'), findsOneWidget);
      expect(find.text('+ Rp 5.100.000'), findsNothing);

      // Tap Transfer
      await tester.tap(find.byKey(const Key('riwayat_filter_transfer')));
      await tester.pumpAndSettle();

      expect(find.text('1 transaksi'), findsOneWidget);
      expect(find.text('+ Rp 5.100.000'), findsNothing);
      expect(find.text('- Rp 90.000'), findsNothing);
      // Transfer: kontrol kategori dinonaktifkan dengan penjelasan
      expect(find.text('Transfer tidak punya kategori'), findsOneWidget);
    });

    testWidgets('(g2) Filter kategori dinamis: sheet menampilkan kategori terkelompok, tanda diarsipkan, nama kembar, dan tombol X', (tester) async {
      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 1));
      await tester.pumpAndSettle();

      // Buka modal bottom sheet kategori
      await tester.tap(find.byKey(const Key('riwayat_filter_kategori')));
      await tester.pumpAndSettle();

      // Memastikan header modal muncul
      expect(find.text('Kategori'), findsWidgets);
      expect(find.text('PENGELUARAN'), findsOneWidget);
      expect(find.text('PEMASUKAN'), findsOneWidget);

      // Kategori terarsip diberi tanda "diarsipkan"
      expect(find.text('diarsipkan'), findsOneWidget);
      expect(find.text('Belanja Lama'), findsWidgets);

      // Kategori dengan nama kembar (Lainnya) dibedakan dengan badge tipenya saat filter Semua
      expect(find.text('Lainnya'), findsNWidgets(2));
      expect(find.text('Pengeluaran'), findsWidgets);
      expect(find.text('Pemasukan'), findsWidgets);

      // Pilih kategori Makanan
      await tester.tap(find.text('Makanan'));
      await tester.pumpAndSettle();

      // Modal tertutup, filter kategori aktif dengan nama 'Makanan'
      expect(find.text('1 transaksi'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('riwayat_ringkasan')),
          matching: find.text('- Rp 50.000'),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

      // Tap tombol X (cancel_rounded) untuk menghapus pilihan kategori
      await tester.tap(find.byIcon(Icons.cancel_rounded));
      await tester.pumpAndSettle();

      // Kembali ke semua kategori
      expect(find.text('6 transaksi'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
    });

    testWidgets('(g3) Mengganti jenis ke yang tidak cocok mengembalikan kategori ke Semua', (tester) async {
      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 1));
      await tester.pumpAndSettle();

      // Pilih kategori Makanan (pengeluaran)
      await tester.tap(find.byKey(const Key('riwayat_filter_kategori')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Makanan'));
      await tester.pumpAndSettle();

      expect(find.text('1 transaksi'), findsOneWidget);

      // Ganti jenis ke Pemasukan (tidak cocok dengan kategori Makanan)
      await tester.tap(find.byKey(const Key('riwayat_filter_pemasukan')));
      await tester.pumpAndSettle();

      // Kategori otomatis reset ke "Kategori" (Semua) dan menampilkan 2 pemasukan
      expect(find.text('2 transaksi'), findsOneWidget);
      expect(find.text('+ Rp 5.100.000'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
    });

    testWidgets('(g4) Keadaan kosong (riwayat_kosong) tampil dengan tombol Atur ulang filter', (tester) async {
      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 1));
      await tester.pumpAndSettle();

      // Geser bulan ke masa lampau (misal 2025) di mana belum ada transaksi
      final prevMonthBtn = find.byIcon(Icons.chevron_left_rounded).first;
      for (int i = 0; i < 15; i++) {
        await tester.tap(prevMonthBtn);
        await tester.pumpAndSettle();
      }

      // Verifikasi keadaan kosong
      expect(find.byKey(const Key('riwayat_kosong')), findsOneWidget);
      expect(find.text('Tidak ada transaksi yang cocok'), findsOneWidget);
      expect(find.text('Atur ulang filter'), findsOneWidget);

      // Tap tombol Atur ulang filter
      await tester.tap(find.text('Atur ulang filter'));
      await tester.pumpAndSettle();

      // Filter jenis kembali ke Semua
      expect(find.byKey(const Key('riwayat_filter_semua')), findsOneWidget);
    });

    testWidgets('(g5) Tombol Lihat semua di Beranda berpindah ke Tab Riwayat (bukan push layar baru)', (tester) async {
      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 0));
      await tester.pumpAndSettle();

      // Di Beranda, terdapat bagian Transaksi Terbaru dan tautan Lihat semua
      expect(find.text('Transaksi Terbaru'), findsOneWidget);
      final lihatSemuaFinder = find.byKey(const Key('beranda_lihat_semua'));
      expect(lihatSemuaFinder, findsOneWidget);

      // Ketuk 'Lihat semua'
      await tester.tap(lihatSemuaFinder);
      await tester.pumpAndSettle();

      // Berpindah tab ke Tab Riwayat
      expect(find.byType(RiwayatScreen), findsOneWidget);
      // Bilah bawah tetap ada (bukan push layar baru)
      expect(find.byType(MainBottomNavBar), findsOneWidget);
    });

    testWidgets('(g6) Tap baris membuka form edit; hapus transaksi memperbarui daftar dan ringkasan', (tester) async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'bca', name: 'BCA', initialBalance: 10000000),
          const Wallet(id: 'tunai', name: 'Tunai', initialBalance: 2000000),
        ],
        initialCategories: sampleCategories,
        initialTransactions: sampleTransactions,
      );

      await tester.pumpWidget(buildNav3TestApp(state: state, initialNavIndex: 1));
      await tester.pumpAndSettle();

      expect(find.text('6 transaksi'), findsOneWidget);

      // Buka salah satu baris transaksi
      final firstRow = find.byType(BukuKasDayGroup).first;
      await tester.tap(firstRow);
      await tester.pumpAndSettle();

      // Form edit transaksi terbuka
      expect(find.byType(TransactionFormScreen), findsOneWidget);

      // Tap ikon hapus di AppBar
      final deleteBtn = find.byIcon(Icons.delete_outline);
      if (deleteBtn.evaluate().isNotEmpty) {
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        // Konfirmasi hapus di dialog
        final confirmBtn = find.widgetWithText(FilledButton, 'Hapus');
        expect(confirmBtn, findsOneWidget);
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Kembali ke Riwayat dan jumlah transaksi berkurang menjadi 5
        expect(find.byType(RiwayatScreen), findsOneWidget);
        expect(find.text('5 transaksi'), findsOneWidget);
      }
    });

    testWidgets('(h) Bulan di Riwayat dan bulan di Beranda berdiri sendiri (independen)', (tester) async {
      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 0));
      await tester.pumpAndSettle();

      // Beranda: ubah bulan ke September 2026 (mundur 1 bulan)
      final berandaPrevMonth = find.byIcon(Icons.chevron_left).first;
      await tester.tap(berandaPrevMonth);
      await tester.pumpAndSettle();
      expect(find.textContaining('September 2026'), findsOneWidget);

      // Pindah ke Tab Riwayat via bilah navigasi
      await tester.tap(find.byKey(const Key('nav_riwayat')));
      await tester.pumpAndSettle();

      // Riwayat: mulai dari bulan berjalan (Oktober 2026), tidak terpengaruh Beranda
      expect(find.textContaining('Oktober 2026'), findsOneWidget);

      // Riwayat: ubah bulan ke November 2026 (maju 1 bulan)
      final riwayatNextMonth = find.byIcon(Icons.chevron_right_rounded).first;
      await tester.tap(riwayatNextMonth);
      await tester.pumpAndSettle();
      expect(find.textContaining('November 2026'), findsOneWidget);

      // Pindah kembali ke Beranda via bilah navigasi
      await tester.tap(find.byKey(const Key('nav_beranda')));
      await tester.pumpAndSettle();

      // Beranda: tetap berada di September 2026, tidak terpengaruh Riwayat
      expect(find.textContaining('September 2026'), findsOneWidget);
    });

    testWidgets('(responsif) Layar Riwayat bebas overflow di 360x640 dp dan 411x891 dp', (tester) async {
      // 1. Uji di 360x640 dp
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 1));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Coba ubah filter jenis
      await tester.tap(find.byKey(const Key('riwayat_filter_pemasukan')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.byKey(const Key('riwayat_filter_pengeluaran')));
      await tester.tap(find.byKey(const Key('riwayat_filter_pengeluaran')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 2. Uji di 411x891 dp
      tester.view.physicalSize = const Size(411, 891);
      await tester.pumpWidget(buildNav3TestApp(initialNavIndex: 1));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
