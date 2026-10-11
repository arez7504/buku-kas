import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_calculator.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/wallet_management_screen.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/widgets/buku_kas_header.dart';
import 'package:catatan_keuangan/widgets/buku_kas_month_section.dart';
import 'package:catatan_keuangan/widgets/buku_kas_wallet_bar.dart';
import 'package:catatan_keuangan/widgets/wallet_archive_dialog.dart';

void main() {
  final defaultWallets = [
    const Wallet(id: 'w_bca', name: 'BCA', initialBalance: 1000000),
    const Wallet(id: 'w_tunai', name: 'Tunai', initialBalance: 500000),
    const Wallet(id: 'w_arsip', name: 'Celengan Lama', initialBalance: 200000, isArchived: true),
  ];

  final defaultCategories = [
    const Category(id: 'c_gaji', name: 'Gaji', type: CategoryType.income),
    const Category(id: 'c_makan', name: 'Makan', type: CategoryType.expense),
    const Category(id: 'c_belanja', name: 'Belanja', type: CategoryType.expense),
  ];

  Widget buildTestApp(FinanceState state, {Size? physicalSize, double textScale = 1.0}) {
    return MediaQuery(
      data: MediaQueryData(
        size: physicalSize ?? const Size(411, 891),
        textScaler: TextScaler.linear(textScale),
      ),
      child: MyApp(initialState: state),
    );
  }

  group('Milestone NAV-2: Kriteria (a) - totalBalance = Jumlah Saldo Dompet Aktif', () {
    test('totalBalance menjumlahkan semua dompet aktif dan mengabaikan dompet terarsip', () {
      final wallets = [
        const Wallet(id: 'w1', name: 'BCA', initialBalance: 1000000),
        const Wallet(id: 'w2', name: 'Tunai', initialBalance: 500000),
        const Wallet(id: 'w3', name: 'Arsip', initialBalance: 300000, isArchived: true),
      ];

      final transactions = [
        Transaction(
          id: 't1',
          type: TransactionType.expense,
          amount: 200000,
          date: DateTime(2026, 10, 5),
          walletId: 'w1',
        ),
        Transaction(
          id: 't2',
          type: TransactionType.income,
          amount: 100000,
          date: DateTime(2026, 10, 6),
          walletId: 'w2',
        ),
        Transaction(
          id: 't3',
          type: TransactionType.income,
          amount: 50000,
          date: DateTime(2026, 10, 7),
          walletId: 'w3',
        ),
      ];

      // W1: 1.000.000 - 200.000 = 800.000
      // W2: 500.000 + 100.000 = 600.000
      // W3 (arsip): 300.000 + 50.000 = 350.000 (tidak dihitung)
      // Total = 800.000 + 600.000 = 1.400.000
      final total = FinanceCalculator.calculateTotalBalance(wallets, transactions);
      expect(total, 1400000);

      final state = FinanceState(
        initialWallets: wallets,
        initialCategories: defaultCategories,
        initialTransactions: transactions,
      );
      expect(state.totalBalance, 1400000);
    });

    test('totalBalance menjumlahkan saldo negatif dompet aktif apa adanya', () {
      final wallets = [
        const Wallet(id: 'w1', name: 'BCA', initialBalance: 500000),
        const Wallet(id: 'w2', name: 'Kartu Kredit', initialBalance: 0),
      ];

      final transactions = [
        Transaction(
          id: 't1',
          type: TransactionType.expense,
          amount: 300000,
          date: DateTime(2026, 10, 5),
          walletId: 'w2',
        ),
      ];

      // W1: 500.000
      // W2: 0 - 300.000 = -300.000
      // Total = 500.000 + (-300.000) = 200.000
      final total = FinanceCalculator.calculateTotalBalance(wallets, transactions);
      expect(total, 200000);
    });
  });

  group('Milestone NAV-2: Kriteria (b) - Tambah, Ubah Saldo Awal, & Arsipkan Dompet', () {
    test('Tambah dompet 100.000 menaikkan total; ubah saldo awal mengubah total; arsip mengurangi total', () async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w1', name: 'BCA', initialBalance: 500000),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      expect(state.totalBalance, 500000);

      // 1. Tambah dompet dengan saldo awal 100.000 -> total naik 100.000 jadi 600.000
      await state.addWallet(const Wallet(id: 'w_gopay', name: 'Gopay', initialBalance: 100000));
      expect(state.totalBalance, 600000);

      // 2. Ubah saldo awal Gopay dari 100.000 jadi 250.000 -> total jadi 750.000
      await state.updateWallet(const Wallet(id: 'w_gopay', name: 'Gopay', initialBalance: 250000));
      expect(state.totalBalance, 750000);

      // Tambahkan transaksi pengeluaran 50.000 pada Gopay -> saldo Gopay jadi 200.000, total jadi 700.000
      await state.addTransaction(
        Transaction(
          id: 'tx_gopay_1',
          type: TransactionType.expense,
          amount: 50000,
          date: DateTime(2026, 10, 10),
          walletId: 'w_gopay',
          categoryId: 'c_makan',
        ),
      );
      expect(state.getWalletBalance('w_gopay'), 200000);
      expect(state.totalBalance, 700000);

      // 3. Arsipkan dompet Gopay (saldo 200.000) -> total berkurang sebesar saldonya (200.000) jadi 500.000
      await state.archiveWallet('w_gopay', isArchived: true);
      expect(state.totalBalance, 500000);
    });
  });

  group('Milestone NAV-2: Kriteria (c) - Perilaku Transfer pada Saldo Total', () {
    test('Transfer antar dua dompet aktif tidak mengubah total', () async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w1', name: 'BCA', initialBalance: 1000000),
          const Wallet(id: 'w2', name: 'Tunai', initialBalance: 500000),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      expect(state.totalBalance, 1500000);

      // Transfer W1 -> W2 sebesar 200.000
      await state.addTransaction(
        Transaction(
          id: 'tx_trf_1',
          type: TransactionType.transfer,
          amount: 200000,
          date: DateTime(2026, 10, 5),
          walletId: 'w1',
          targetWalletId: 'w2',
        ),
      );

      // Saldo W1: 800.000, Saldo W2: 700.000 -> total tetap 1.500.000
      expect(state.getWalletBalance('w1'), 800000);
      expect(state.getWalletBalance('w2'), 700000);
      expect(state.totalBalance, 1500000);
    });

    test('Transfer dari dompet aktif ke dompet terarsip mengurangi total sebesar nominal', () async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w1', name: 'BCA', initialBalance: 1000000),
          const Wallet(id: 'w2', name: 'Tunai', initialBalance: 500000),
          const Wallet(id: 'w_arsip', name: 'Brankas', initialBalance: 0, isArchived: true),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      expect(state.totalBalance, 1500000);

      // Transfer aktif (W1) ke terarsip (w_arsip) sebesar 300.000
      await state.addTransaction(
        Transaction(
          id: 'tx_trf_to_arch',
          type: TransactionType.transfer,
          amount: 300000,
          date: DateTime(2026, 10, 5),
          walletId: 'w1',
          targetWalletId: 'w_arsip',
        ),
      );

      // W1 berkurang 300.000 menjadi 700.000, W2 tetap 500.000 -> Total berkurang jadi 1.200.000
      expect(state.getWalletBalance('w1'), 700000);
      expect(state.totalBalance, 1200000);
    });

    test('Transfer dari dompet terarsip ke dompet aktif menambah total sebesar nominal', () async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w1', name: 'BCA', initialBalance: 1000000),
          const Wallet(id: 'w_arsip', name: 'Brankas', initialBalance: 500000, isArchived: true),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      expect(state.totalBalance, 1000000);

      // Transfer terarsip (w_arsip) ke aktif (W1) sebesar 200.000
      await state.addTransaction(
        Transaction(
          id: 'tx_trf_from_arch',
          type: TransactionType.transfer,
          amount: 200000,
          date: DateTime(2026, 10, 5),
          walletId: 'w_arsip',
          targetWalletId: 'w1',
        ),
      );

      // W1 bertambah 200.000 menjadi 1.200.000 -> Total naik jadi 1.200.000
      expect(state.getWalletBalance('w1'), 1200000);
      expect(state.totalBalance, 1200000);
    });
  });

  group('Milestone NAV-2: Kriteria (d) - Independensi Saldo Total terhadap Bulan', () {
    testWidgets('Pindah bulan mengubah Pemasukan, Pengeluaran, dan Selisih, tetapi Saldo Total TETAP sama', (tester) async {
      final state = FinanceState(
        initialWallets: defaultWallets,
        initialCategories: defaultCategories,
        initialTransactions: [
          // Oktober 2026
          Transaction(
            id: 't_oct_inc',
            type: TransactionType.income,
            amount: 1000000,
            date: DateTime(2026, 10, 5),
            walletId: 'w_bca',
            categoryId: 'c_gaji',
          ),
          Transaction(
            id: 't_oct_exp',
            type: TransactionType.expense,
            amount: 300000,
            date: DateTime(2026, 10, 6),
            walletId: 'w_bca',
            categoryId: 'c_makan',
          ),
          // September 2026
          Transaction(
            id: 't_sep_inc',
            type: TransactionType.income,
            amount: 200000,
            date: DateTime(2026, 9, 10),
            walletId: 'w_tunai',
            categoryId: 'c_gaji',
          ),
          Transaction(
            id: 't_sep_exp',
            type: TransactionType.expense,
            amount: 500000,
            date: DateTime(2026, 9, 15),
            walletId: 'w_tunai',
            categoryId: 'c_belanja',
          ),
        ],
      );

      // Saldo BCA = 1.000.000 + 1.000.000 - 300.000 = 1.700.000
      // Saldo Tunai = 500.000 + 200.000 - 500.000 = 200.000
      // Saldo Total = 1.900.000
      await tester.pumpWidget(buildTestApp(state));
      await tester.pumpAndSettle();

      // 1. Pada bulan Oktober 2026
      expect(find.text('Oktober 2026'), findsOneWidget);
      final saldoTotalTextOct = tester.widget<Text>(find.byKey(const Key('saldo_total_amount')));
      expect(saldoTotalTextOct.data, 'Rp 1.900.000');

      // Bagian bulan Oktober
      expect(
        find.descendant(
          of: find.byKey(const Key('bulan_pemasukan')),
          matching: find.text('+ Rp 1.000.000'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('bulan_pengeluaran')),
          matching: find.text('- Rp 300.000'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('bulan_selisih')),
          matching: find.text('Rp 700.000'),
        ),
        findsOneWidget,
      );

      // 2. Klik bulan sebelumnya ke September 2026
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);

      // Pemasukan, Pengeluaran, dan Selisih BERUBAH mengikuti bulan September
      expect(
        find.descendant(
          of: find.byKey(const Key('bulan_pemasukan')),
          matching: find.text('+ Rp 200.000'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('bulan_pengeluaran')),
          matching: find.text('- Rp 500.000'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('bulan_selisih')),
          matching: find.text('- Rp 300.000'),
        ),
        findsOneWidget,
      );

      // Saldo Total TIDAK BERUBAH (tetap Rp 1.900.000)
      final saldoTotalTextSep = tester.widget<Text>(find.byKey(const Key('saldo_total_amount')));
      expect(saldoTotalTextSep.data, 'Rp 1.900.000');
    });
  });

  group('Milestone NAV-2: Kriteria (e) - Saldo Total di Layar = Jumlah Kartu Dompet Aktif', () {
    testWidgets('Saldo Total di layar sama dengan penjumlahan angka di kartu dompet aktif', (tester) async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w1', name: 'BCA', initialBalance: 1250000),
          const Wallet(id: 'w2', name: 'Tunai', initialBalance: 350000),
          const Wallet(id: 'w3', name: 'OVO', initialBalance: 400000),
          const Wallet(id: 'w_arsip', name: 'Celengan', initialBalance: 888000, isArchived: true),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      // Jumlah aktif: 1.250.000 + 350.000 + 400.000 = 2.000.000
      await tester.pumpWidget(buildTestApp(state));
      await tester.pumpAndSettle();

      // Saldo total di layar
      final saldoTotalText = tester.widget<Text>(find.byKey(const Key('saldo_total_amount')));
      expect(saldoTotalText.data, 'Rp 2.000.000');

      // Kartu dompet aktif di BukuKasWalletBar
      final walletBar = find.byType(BukuKasWalletBar);
      expect(walletBar, findsOneWidget);
      expect(find.descendant(of: walletBar, matching: find.text('Rp 1.250.000')), findsOneWidget);
      expect(find.descendant(of: walletBar, matching: find.text('Rp 350.000')), findsOneWidget);
      expect(find.descendant(of: walletBar, matching: find.text('Rp 400.000')), findsOneWidget);

      // Dompet terarsip tidak tampil di baris dompet aktif
      expect(find.descendant(of: walletBar, matching: find.text('Rp 888.000')), findsNothing);
    });
  });

  group('Milestone NAV-2: Kriteria (f) - Dialog Konfirmasi Arsip Dompet', () {
    testWidgets('Arsip dompet bersaldo bukan nol memunculkan dialog konfirmasi dengan nama, saldo; Batal membatalkan', (tester) async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w_bca', name: 'BCA', initialBalance: 750000),
          const Wallet(id: 'w_nol', name: 'Dompet Kosong', initialBalance: 0),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      await tester.pumpWidget(buildTestApp(state));
      await tester.pumpAndSettle();

      // Masuk ke Pengaturan -> Kelola Dompet
      await tester.tap(find.byKey(const Key('nav_pengaturan')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kelola Dompet'));
      await tester.pumpAndSettle();
      expect(find.byType(WalletManagementScreen), findsOneWidget);

      // 1. Coba arsipkan BCA (saldo 750.000 != 0)
      await tester.tap(find.byKey(const Key('wallet_menu_w_bca')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(WalletArchiveWarningDialog);
      expect(dialogFinder, findsOneWidget);
      expect(find.text('Arsipkan Dompet?'), findsOneWidget);
      expect(find.textContaining('BCA'), findsWidgets);
      expect(find.textContaining('Rp 750.000'), findsWidgets);
      expect(find.textContaining('Saldo Total berkurang'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.byKey(const Key('confirm_archive_wallet_button')), findsOneWidget);

      // Klik "Batal"
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog tertutup dan dompet tetap aktif
      expect(find.byType(WalletArchiveWarningDialog), findsNothing);
      expect(state.wallets.firstWhere((w) => w.id == 'w_bca').isArchived, isFalse);

      // Coba arsipkan lagi dan kali ini konfirmasi "Arsipkan"
      await tester.tap(find.byKey(const Key('wallet_menu_w_bca')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_archive_wallet_button')));
      await tester.pumpAndSettle();

      // Dompet sekarang terarsip
      expect(find.byType(WalletArchiveWarningDialog), findsNothing);
      expect(state.wallets.firstWhere((w) => w.id == 'w_bca').isArchived, isTrue);

      // 2. Dompet bersaldo nol (Dompet Kosong) diarsipkan langsung TANPA dialog
      await tester.tap(find.byKey(const Key('wallet_menu_w_nol')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      expect(find.byType(WalletArchiveWarningDialog), findsNothing);
      expect(state.wallets.firstWhere((w) => w.id == 'w_nol').isArchived, isTrue);

      // 3. Memulihkan dompet dari arsip tidak menampilkan dialog
      await tester.tap(find.byKey(const Key('wallet_menu_w_nol')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buka Arsip'));
      await tester.pumpAndSettle();

      expect(find.byType(WalletArchiveWarningDialog), findsNothing);
      expect(state.wallets.firstWhere((w) => w.id == 'w_nol').isArchived, isFalse);
    });
  });

  group('Milestone NAV-2: Kriteria (g) - Saldo Negatif Tampil Merah dengan Minus', () {
    testWidgets('Saldo Total dan Selisih negatif tampil merah dengan minus', (tester) async {
      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w1', name: 'Dompet Utang', initialBalance: 0),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [
          Transaction(
            id: 't_exp',
            type: TransactionType.expense,
            amount: 250000,
            date: DateTime(2026, 10, 10),
            walletId: 'w1',
            categoryId: 'c_makan',
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(state));
      await tester.pumpAndSettle();

      // Saldo Total: - Rp 250.000 dengan warna merah
      final saldoTotalFinder = find.byKey(const Key('saldo_total_amount'));
      expect(saldoTotalFinder, findsOneWidget);
      final Text saldoTotalText = tester.widget<Text>(saldoTotalFinder);
      expect(saldoTotalText.data, '- Rp 250.000');
      expect(saldoTotalText.style?.color, AppColors.expenseRed);

      // Selisih di BukuKasMonthSection: - Rp 250.000 dengan warna merah
      final selisihFinder = find.descendant(
        of: find.byKey(const Key('bulan_selisih')),
        matching: find.text('- Rp 250.000'),
      );
      expect(selisihFinder, findsOneWidget);
      final Text selisihText = tester.widget<Text>(selisihFinder);
      expect(selisihText.style?.color, AppColors.expenseRed);
    });
  });

  group('Milestone NAV-2: Struktur Tampilan, Tipografi & Responsif Bebas Overflow', () {
    testWidgets('Urutan komponen dari atas: Header, Saldo Total, Bagian Bulan, Akun & Dompet', (tester) async {
      final state = FinanceState(
        initialWallets: defaultWallets,
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      await tester.pumpWidget(buildTestApp(state));
      await tester.pumpAndSettle();

      final headerFinder = find.byType(BukuKasHeader);
      final saldoTotalFinder = find.byKey(const Key('saldo_total_card'));
      final monthSectionFinder = find.byType(BukuKasMonthSection);
      final walletBarFinder = find.byType(BukuKasWalletBar);

      expect(headerFinder, findsOneWidget);
      expect(saldoTotalFinder, findsOneWidget);
      expect(monthSectionFinder, findsOneWidget);
      expect(walletBarFinder, findsOneWidget);

      final headerY = tester.getTopLeft(headerFinder).dy;
      final saldoTotalY = tester.getTopLeft(saldoTotalFinder).dy;
      final monthSectionY = tester.getTopLeft(monthSectionFinder).dy;
      final walletBarY = tester.getTopLeft(walletBarFinder).dy;

      expect(headerY < saldoTotalY, isTrue, reason: 'Header harus di atas Saldo Total');
      expect(saldoTotalY < monthSectionY, isTrue, reason: 'Saldo Total harus di atas Bagian Bulan');
      expect(monthSectionY < walletBarY, isTrue, reason: 'Bagian Bulan harus di atas Akun & Dompet');
    });

    testWidgets('Kartu Saldo Total memiliki label SALDO TOTAL, FittedBox scaleDown, dan subtitle minimal 12sp', (tester) async {
      final state = FinanceState(
        initialWallets: defaultWallets,
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      await tester.pumpWidget(buildTestApp(state));
      await tester.pumpAndSettle();

      expect(find.text('SALDO TOTAL'), findsOneWidget);
      final subtitleFinder = find.text('Semua dompet aktif');
      expect(subtitleFinder, findsOneWidget);

      final Text subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect((subtitleWidget.style?.fontSize ?? 0) >= 12.0, isTrue);

      final fittedBoxFinder = find.descendant(
        of: find.byKey(const Key('saldo_total_card')),
        matching: find.byType(FittedBox),
      );
      expect(fittedBoxFinder, findsOneWidget);
      final FittedBox fb = tester.widget<FittedBox>(fittedBoxFinder);
      expect(fb.fit, BoxFit.scaleDown);
    });

    testWidgets('Layar kecil 360x640 dp dengan nominal ekstrem (Rp 123.456.789.012) dan text scale 1.5 bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final state = FinanceState(
        initialWallets: [
          const Wallet(id: 'w_huge', name: 'Mega Bank', initialBalance: 123456789012),
        ],
        initialCategories: defaultCategories,
        initialTransactions: [
          Transaction(
            id: 't_huge_inc',
            type: TransactionType.income,
            amount: 98765432100,
            date: DateTime(2026, 10, 1),
            walletId: 'w_huge',
          ),
          Transaction(
            id: 't_huge_exp',
            type: TransactionType.expense,
            amount: 87654321000,
            date: DateTime(2026, 10, 2),
            walletId: 'w_huge',
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(state, physicalSize: const Size(360, 640), textScale: 1.5));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('saldo_total_card')), findsOneWidget);
      expect(find.byType(BukuKasMonthSection), findsOneWidget);
      expect(find.byKey(const Key('bulan_pemasukan')), findsOneWidget);
      expect(find.byKey(const Key('bulan_pengeluaran')), findsOneWidget);
      expect(find.byKey(const Key('bulan_selisih')), findsOneWidget);
    });

    testWidgets('Layar 411x891 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final state = FinanceState(
        initialWallets: defaultWallets,
        initialCategories: defaultCategories,
        initialTransactions: [],
      );

      await tester.pumpWidget(buildTestApp(state, physicalSize: const Size(411, 891)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
