import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/app_lock_manager.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/lock_screen.dart';
import 'package:catatan_keuangan/screens/placeholder_tab_screen.dart';
import 'package:catatan_keuangan/screens/riwayat_screen.dart';
import 'package:catatan_keuangan/screens/settings_screen.dart';
import 'package:catatan_keuangan/screens/transaction_form_screen.dart';
import 'package:catatan_keuangan/screens/wallet_management_screen.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/widgets/main_bottom_nav_bar.dart';
import 'app_lock_test.dart';

void main() {
  final sampleWallets = [
    const Wallet(id: 'w_bca', name: 'BCA', initialBalance: 1500000),
    const Wallet(id: 'w_tunai', name: 'Tunai', initialBalance: 200000),
  ];

  final sampleCategories = [
    const Category(id: 'c_makan', name: 'Makanan', type: CategoryType.expense),
    const Category(id: 'c_gaji', name: 'Gaji', type: CategoryType.income),
  ];

  final sampleTransactions = [
    Transaction(
      id: 'tx_1',
      type: TransactionType.expense,
      amount: 45000,
      date: DateTime(2026, 10, 10, 12, 0),
      walletId: 'w_bca',
      categoryId: 'c_makan',
      note: 'Makan Siang',
    ),
  ];

  Widget buildTestApp({
    FinanceState? state,
    AppLockManager? lockManager,
    int initialNavIndex = 0,
  }) {
    final effectiveState = state ??
        FinanceState(
          initialWallets: sampleWallets,
          initialCategories: sampleCategories,
          initialTransactions: sampleTransactions,
        );
    return MyApp(
      initialState: effectiveState,
      lockManager: lockManager,
      initialNavIndex: initialNavIndex,
    );
  }

  group('Milestone NAV-1: Kerangka Navigasi Bilah Bawah', () {
    testWidgets('(a) Bilah tampil dengan empat tab dan tombol Catat; mengetuk tab berpindah layar', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Memastikan bilah navigasi utama hadir
      expect(find.byType(MainBottomNavBar), findsOneWidget);

      // Memastikan 5 key tab hadir
      final berandaKey = find.byKey(const Key('nav_beranda'));
      final riwayatKey = find.byKey(const Key('nav_riwayat'));
      final catatKey = find.byKey(const Key('nav_catat'));
      final statistikKey = find.byKey(const Key('nav_statistik'));
      final pengaturanKey = find.byKey(const Key('nav_pengaturan'));

      expect(berandaKey, findsOneWidget);
      expect(riwayatKey, findsOneWidget);
      expect(catatKey, findsOneWidget);
      expect(statistikKey, findsOneWidget);
      expect(pengaturanKey, findsOneWidget);

      // Verifikasi urutan horizontal (kiri ke kanan)
      final xBeranda = tester.getCenter(berandaKey).dx;
      final xRiwayat = tester.getCenter(riwayatKey).dx;
      final xCatat = tester.getCenter(catatKey).dx;
      final xStatistik = tester.getCenter(statistikKey).dx;
      final xPengaturan = tester.getCenter(pengaturanKey).dx;

      expect(xBeranda < xRiwayat, isTrue);
      expect(xRiwayat < xCatat, isTrue);
      expect(xCatat < xStatistik, isTrue);
      expect(xStatistik < xPengaturan, isTrue);

      // Default awal berada di Beranda (Buku Kas)
      expect(find.text('Buku Kas'), findsOneWidget);

      // Pindah ke tab Riwayat
      await tester.tap(riwayatKey);
      await tester.pumpAndSettle();
      // Alasan pembaruan Milestone NAV-3: Layar sementara 'Segera hadir' pada tab Riwayat
      // telah digantikan oleh layar RiwayatScreen sesuai spesifikasi Bagian B.
      expect(find.byType(RiwayatScreen), findsOneWidget);
      expect(find.text('Riwayat'), findsWidgets);

      // Pindah ke tab Statistik
      await tester.tap(statistikKey);
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderTabScreen), findsOneWidget);
      expect(find.text('Statistik'), findsWidgets);
      expect(find.text('Segera hadir'), findsOneWidget);

      // Pindah ke tab Pengaturan
      await tester.tap(pengaturanKey);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Pengaturan')), findsOneWidget);
      expect(find.text('Kelola Dompet'), findsOneWidget);

      // Kembali ke tab Beranda
      await tester.tap(berandaKey);
      await tester.pumpAndSettle();
      expect(find.text('Buku Kas'), findsOneWidget);
    });

    testWidgets('(b) Catat membuka form tanpa bilah; setelah menutup form, bilah kembali ke tab asal', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Pindah ke tab Riwayat terlebih dahulu
      await tester.tap(find.byKey(const Key('nav_riwayat')));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat'), findsWidgets);

      // Ketuk tombol Catat di bilah bawah
      await tester.tap(find.byKey(const Key('nav_catat')));
      await tester.pumpAndSettle();

      // Layar form Catat Transaksi terbuka penuh
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      expect(find.text('Tambah Transaksi'), findsOneWidget);

      // Bilah bawah tidak boleh terlihat (karena tertutup layar penuh)
      // MainBottomNavBar berada di route bawah, tidak tampil di atas TransactionFormScreen
      final catatInFormFinder = find.descendant(
        of: find.byType(TransactionFormScreen),
        matching: find.byType(MainBottomNavBar),
      );
      expect(catatInFormFinder, findsNothing);

      // Tutup form Catat Transaksi via tombol kembali di header
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Form tertutup, kembali ke tab asal (Riwayat) dan bilah navigasi kembali terlihat
      expect(find.byType(TransactionFormScreen), findsNothing);
      expect(find.byType(MainBottomNavBar), findsOneWidget);
      expect(find.byType(RiwayatScreen), findsOneWidget);
      expect(find.text('Riwayat'), findsWidgets);
    });

    testWidgets('(c) Tombol back Android: dari tab selain Beranda kembali ke Beranda; dari Beranda menutup aplikasi', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));

      // 1. Dari tab Riwayat -> Back kembali ke Beranda
      await tester.tap(find.byKey(const Key('nav_riwayat')));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat'), findsWidgets);

      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Buku Kas'), findsOneWidget);

      // 2. Dari tab Statistik -> Back kembali ke Beranda
      await tester.tap(find.byKey(const Key('nav_statistik')));
      await tester.pumpAndSettle();
      expect(find.text('Statistik'), findsWidgets);

      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Buku Kas'), findsOneWidget);

      // 3. Dari tab Pengaturan -> Back kembali ke Beranda
      await tester.tap(find.byKey(const Key('nav_pengaturan')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Buku Kas'), findsOneWidget);

      // 4. Sub-layar dibuka lewat push: Pengaturan -> Kelola Dompet -> Back menutup Kelola Dompet dulu
      await tester.tap(find.byKey(const Key('nav_pengaturan')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kelola Dompet'));
      await tester.pumpAndSettle();
      expect(find.byType(WalletManagementScreen), findsOneWidget);

      // Back pertama menutup sub-layar Kelola Dompet
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(WalletManagementScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Back kedua kembali dari Pengaturan ke Beranda
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Buku Kas'), findsOneWidget);
    });

    testWidgets('(d) Bulan terpilih di Beranda bertahan setelah pindah ke tab lain dan kembali', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Bulan awal adalah Oktober 2026
      expect(find.text('Oktober 2026'), findsOneWidget);

      // Geser bulan ke September 2026 via tombol panah kiri di header
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('September 2026'), findsOneWidget);

      // Pindah ke tab Statistik
      await tester.tap(find.byKey(const Key('nav_statistik')));
      await tester.pumpAndSettle();
      expect(find.text('Statistik'), findsWidgets);

      // Pindah ke tab Pengaturan
      await tester.tap(find.byKey(const Key('nav_pengaturan')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Kembali ke tab Beranda
      await tester.tap(find.byKey(const Key('nav_beranda')));
      await tester.pumpAndSettle();

      // Bulan terpilih tetap September 2026 (state bertahan via IndexedStack)
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('Oktober 2026'), findsNothing);
    });

    testWidgets('(e) Pengaturan sebagai tab tidak punya panah kembali; membuka Kelola Dompet menyembunyikan bilah', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Buka tab Pengaturan
      await tester.tap(find.byKey(const Key('nav_pengaturan')));
      await tester.pumpAndSettle();

      // Memastikan SettingsScreen tampil
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Memastikan TIDAK ADA panah kembali di AppBar SettingsScreen saat menjadi tab
      final appBarFinder = find.descendant(
        of: find.byType(SettingsScreen),
        matching: find.byType(AppBar),
      );
      final arrowBackInAppBar = find.descendant(
        of: appBarFinder,
        matching: find.byIcon(Icons.arrow_back),
      );
      expect(arrowBackInAppBar, findsNothing);

      // Buka sub-layar Kelola Dompet
      await tester.tap(find.text('Kelola Dompet'));
      await tester.pumpAndSettle();
      expect(find.byType(WalletManagementScreen), findsOneWidget);

      // Sub-layar dibuka lewat push: bilah bawah tertutup layar penuh
      final navBarInWalletScreen = find.descendant(
        of: find.byType(WalletManagementScreen),
        matching: find.byType(MainBottomNavBar),
      );
      expect(navBarInWalletScreen, findsNothing);

      // Tekan tombol kembali di Kelola Dompet
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Kembali ke tab Pengaturan dan bilah bawah tampak kembali
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(MainBottomNavBar), findsOneWidget);
    });

    testWidgets('(f) Uji responsivitas bebas overflow pada 360x640 dp dan 411x891 dp serta tombol Catat tidak menutupi label', (tester) async {
      // 1. Layar kecil 360x640 dp
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verifikasi tombol Catat tidak menutupi label Riwayat dan Statistik di 360 dp
      final riwayatRect = tester.getRect(find.text('Riwayat'));
      final catatRect = tester.getRect(find.byKey(const Key('nav_catat')));
      final statistikRect = tester.getRect(find.text('Statistik'));

      // Rect label Riwayat berada di sebelah kiri batas kiri tombol Catat
      expect(riwayatRect.right <= catatRect.left + 8, isTrue);
      // Rect label Statistik berada di sebelah kanan batas kanan tombol Catat
      expect(statistikRect.left >= catatRect.right - 8, isTrue);

      // 2. Layar modern 411x891 dp
      tester.view.physicalSize = const Size(411, 891);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('(g) Layar kunci membungkus seluruh kerangka (bilah bawah dan tab tersembunyi saat terkunci)', (tester) async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: true);
      final storage = FakeAppLockStorage(enabled: true);
      final lockManager = AppLockManager(authService: auth, storage: storage);
      await lockManager.initialize(autoAuthenticate: false);

      await tester.pumpWidget(buildTestApp(lockManager: lockManager));
      await tester.pumpAndSettle();

      // Saat terkunci, bilah navigasi bawah dan isi tab TIDAK boleh terlihat
      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text('Buka'), findsOneWidget);
      expect(find.byType(MainBottomNavBar), findsNothing);
      expect(find.text('Buku Kas'), findsNothing);

      // Buka kunci
      await tester.tap(find.byKey(const Key('btn_buka_kunci')));
      await tester.pumpAndSettle();

      // Setelah dibuka, bilah bawah dan isi tab kembali terlihat
      expect(find.byType(LockScreen), findsNothing);
      expect(find.byType(MainBottomNavBar), findsOneWidget);
      expect(find.text('Buku Kas'), findsOneWidget);
    });

    testWidgets('Karakteristik visual bilah navigasi: token ukuran, font >= 12 sp, dan touch target >= 48 dp', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Periksa ukuran font minimal 12 sp
      expect(AppTypography.bottomNavLabelActive.fontSize! >= 12, isTrue);
      expect(AppTypography.bottomNavLabelInactive.fontSize! >= 12, isTrue);
      expect(AppTypography.bottomNavLabelCatat.fontSize! >= 12, isTrue);

      // Periksa area sentuh minimal 48 dp
      final berandaSize = tester.getSize(find.byKey(const Key('nav_beranda')));
      final riwayatSize = tester.getSize(find.byKey(const Key('nav_riwayat')));
      final catatSize = tester.getSize(find.byKey(const Key('nav_catat')));
      final statistikSize = tester.getSize(find.byKey(const Key('nav_statistik')));
      final pengaturanSize = tester.getSize(find.byKey(const Key('nav_pengaturan')));

      expect(berandaSize.height >= AppDimens.minTouchTarget, isTrue);
      expect(berandaSize.width >= AppDimens.minTouchTarget, isTrue);

      expect(riwayatSize.height >= AppDimens.minTouchTarget, isTrue);
      expect(riwayatSize.width >= AppDimens.minTouchTarget, isTrue);

      expect(catatSize.height >= AppDimens.minTouchTarget, isTrue);
      expect(catatSize.width >= AppDimens.minTouchTarget, isTrue);

      expect(statistikSize.height >= AppDimens.minTouchTarget, isTrue);
      expect(statistikSize.width >= AppDimens.minTouchTarget, isTrue);

      expect(pengaturanSize.height >= AppDimens.minTouchTarget, isTrue);
      expect(pengaturanSize.width >= AppDimens.minTouchTarget, isTrue);
    });
  });
}
