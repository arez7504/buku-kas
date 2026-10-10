import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/theme/category_icon_mapping.dart';
import 'package:catatan_keuangan/widgets/buku_kas_action_button.dart';
import 'package:catatan_keuangan/widgets/buku_kas_day_group.dart';
import 'package:catatan_keuangan/widgets/buku_kas_header.dart';
import 'package:catatan_keuangan/widgets/buku_kas_hero_summary.dart';
import 'package:catatan_keuangan/widgets/buku_kas_wallet_bar.dart';

void main() {
  final sampleWallets = [
    const Wallet(id: 'w_bca', name: 'BCA', initialBalance: 3850000),
    const Wallet(id: 'w_tunai', name: 'Tunai', initialBalance: 385000),
    const Wallet(id: 'w_ewallet', name: 'E-Wallet', initialBalance: 300000),
  ];

  final sampleCategories = [
    const Category(id: 'c_makanan', name: 'Makanan', type: CategoryType.expense),
    const Category(id: 'c_belanja', name: 'Belanja', type: CategoryType.expense),
    const Category(id: 'c_tagihan', name: 'Tagihan', type: CategoryType.expense),
    const Category(id: 'c_gaji', name: 'Gaji', type: CategoryType.income),
  ];

  final sampleTransactions = [
    Transaction(
      id: 'tx_1',
      type: TransactionType.expense,
      amount: 85000,
      date: DateTime(2026, 10, 18, 14, 20),
      walletId: 'w_bca',
      categoryId: 'c_belanja',
      note: 'Belanja Bahan Makanan',
    ),
    Transaction(
      id: 'tx_2',
      type: TransactionType.expense,
      amount: 32000,
      date: DateTime(2026, 10, 18, 9, 15),
      walletId: 'w_tunai',
      categoryId: 'c_makanan',
      note: '', // Catatan kosong -> nama kategori yang tampil
    ),
    Transaction(
      id: 'tx_3',
      type: TransactionType.transfer,
      amount: 100000,
      date: DateTime(2026, 10, 17, 10, 0),
      walletId: 'w_bca',
      targetWalletId: 'w_ewallet',
      note: '',
    ),
    Transaction(
      id: 'tx_4',
      type: TransactionType.income,
      amount: 8500000,
      date: DateTime(2026, 10, 15, 8, 0),
      walletId: 'w_bca',
      categoryId: 'c_gaji',
      note: 'Gaji Bulanan',
    ),
  ];

  Widget createTestApp({
    List<Wallet>? wallets,
    List<Category>? categories,
    List<Transaction>? transactions,
  }) {
    final state = FinanceState(
      initialWallets: wallets ?? sampleWallets,
      initialCategories: categories ?? sampleCategories,
      initialTransactions: transactions ?? sampleTransactions,
    );
    return MyApp(initialState: state);
  }

  group('Milestone UI-3: Uji Responsif & Bebas Overflow', () {
    testWidgets('Layar 360x640 dp (layar kecil) bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BukuKasHeader), findsOneWidget);
      expect(find.byType(BukuKasHeroSummary), findsOneWidget);
      expect(find.byType(BukuKasWalletBar), findsOneWidget);
      expect(find.byType(BukuKasActionButton), findsOneWidget);
    });

    testWidgets('Layar 411x891 dp (layar modern) bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BukuKasHeader), findsOneWidget);
      expect(find.byType(BukuKasHeroSummary), findsOneWidget);
      expect(find.byType(BukuKasWalletBar), findsOneWidget);
      expect(find.byType(BukuKasActionButton), findsOneWidget);
    });
  });

  group('Milestone UI-3: Header & Navigasi Bulan', () {
    testWidgets('Header hanya menampilkan satu judul "Buku Kas", ikon dompet, dan tombol pengaturan', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Hanya satu judul Buku Kas
      expect(find.text('Buku Kas'), findsOneWidget);
      // Tanpa kata "Pribadi"
      expect(find.textContaining('Pribadi'), findsNothing);
      // Ada ikon pengaturan
      expect(find.byKey(const Key('settings_button')), findsOneWidget);
      // Ada ikon dompet di header
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });
  });

  group('Milestone UI-3: Kartu Utama (Hero Summary)', () {
    testWidgets('Label PENGELUARAN BULAN INI, dua kartu kecil Pemasukan & Selisih, dan tautan rincian', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('PENGELUARAN BULAN INI'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('Selisih'), findsOneWidget);
      expect(find.byKey(const Key('lihat_rincian_link')), findsOneWidget);

      // Pastikan elemen yang dilarang tidak ada
      expect(find.textContaining('Alokasi gaji & dividen'), findsNothing);
    });

    testWidgets('Selisih negatif tampil tanda minus dan warna merah', (tester) async {
      // Buat transaksi dengan pengeluaran melebihi pemasukan
      final deficitTransactions = [
        Transaction(
          id: 'tx_d1',
          type: TransactionType.expense,
          amount: 500000,
          date: DateTime(2026, 10, 5),
          walletId: 'w_bca',
          categoryId: 'c_belanja',
        ),
      ];

      await tester.pumpWidget(createTestApp(transactions: deficitTransactions));
      await tester.pumpAndSettle();

      final minusFinder = find.descendant(
        of: find.byType(BukuKasHeroSummary),
        matching: find.text('- Rp 500.000'),
      );
      expect(minusFinder, findsOneWidget);

      final Text selisihText = tester.widget<Text>(minusFinder);
      expect(selisihText.style?.color, AppColors.expenseRed);
    });
  });

  group('Milestone UI-3: Akun & Dompet', () {
    testWidgets('Menampilkan jumlah akun aktif dan kartu dompet horizontal', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('AKUN & DOMPET'), findsOneWidget);
      expect(find.text('3 Akun Aktif'), findsOneWidget);
      expect(find.text('BCA'), findsWidgets);
      expect(find.text('Tunai'), findsWidgets);
      expect(find.text('E-Wallet'), findsWidgets);

      // Keterangan rekening fisik / e-wallet sengaja dihilangkan
      expect(find.text('Rekening Utama'), findsNothing);
      expect(find.text('Dompet Fisik'), findsNothing);
    });
  });

  group('Milestone UI-3: Transaksi Terkini & Day Groups', () {
    testWidgets('Header seksi Transaksi Terkini + counter catatan', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Transaksi Terkini'), findsOneWidget);
      expect(find.text('4 Catatan'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsNothing);
      expect(find.byType(BukuKasDayGroup), findsWidgets);
    });

    testWidgets('Baris transaksi menampilkan judul, subtitle dompet & jam, nominal, dan kategori kapital kecil', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Judul = catatan bila ada: "Belanja Bahan Makanan"
      expect(find.text('Belanja Bahan Makanan'), findsOneWidget);
      // Kategori kapital kecil di kanan: "BELANJA"
      expect(find.text('BELANJA'), findsOneWidget);
      // Subtitle dengan jam: "BCA • 14:20"
      expect(find.text('BCA • 14:20'), findsOneWidget);

      // Judul = nama kategori jika catatan kosong: "Makanan"
      expect(find.text('Makanan'), findsOneWidget);
      // Kategori kapital kecil di kanan: "MAKANAN"
      expect(find.text('MAKANAN'), findsOneWidget);

      // Gulir ke bawah untuk memunculkan item transaksi berikutnya (lazy sliver)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Transfer: "Transfer: BCA → E-Wallet"
      expect(find.text('Transfer: BCA → E-Wallet'), findsOneWidget);
      expect(find.text('TRANSFER'), findsOneWidget);
    });
  });

  group('Milestone UI-3: Pemetaan Ikon Kategori & Tombol Aksi', () {
    testWidgets('AppCategoryIcons memetakan kategori bawaan dan transfer dengan benar', (tester) async {
      expect(AppCategoryIcons.getStyle('Makanan').icon, Icons.restaurant);
      expect(AppCategoryIcons.getStyle('Transportasi').icon, Icons.directions_car);
      expect(AppCategoryIcons.getStyle('Tagihan').icon, Icons.bolt);
      expect(AppCategoryIcons.getStyle('Belanja').icon, Icons.shopping_bag);
      expect(AppCategoryIcons.getStyle('Hiburan').icon, Icons.sports_esports);
      expect(AppCategoryIcons.getStyle('Kesehatan').icon, Icons.medical_services);
      expect(AppCategoryIcons.getStyle('Gaji').icon, Icons.payments);
      expect(AppCategoryIcons.getStyle('Lainnya').icon, Icons.category);
      expect(AppCategoryIcons.getStyle('Kustom Saya').icon, Icons.label_outline);
      expect(AppCategoryIcons.getStyle(null, type: TransactionType.transfer).icon, Icons.swap_horiz);
    });

    testWidgets('Tombol gradasi Catat Transaksi menggantikan bilah navigasi', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BukuKasActionButton), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });
  });
}
