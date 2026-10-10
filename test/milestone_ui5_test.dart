import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/logic/app_lock_manager.dart';
import 'package:catatan_keuangan/logic/app_lock_service.dart';
import 'package:catatan_keuangan/logic/app_lock_storage.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/settings_screen.dart';
import 'package:catatan_keuangan/screens/wallet_management_screen.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/theme/wallet_icon_mapping.dart';

class _FakeAuthService implements AppLockAuthService {
  bool authSuccess = true;
  @override
  Future<bool> isDeviceSupported() async => true;
  @override
  Future<bool> canCheckBiometrics() async => true;
  @override
  Future<bool> authenticate({required String localizedReason}) async => authSuccess;
}

class _FakeStorage implements AppLockStorage {
  bool enabled = false;
  @override
  Future<bool> isLockEnabled() async => enabled;
  @override
  Future<void> setLockEnabled(bool value) async => enabled = value;
}

void main() {
  group('Milestone UI-5 Tests: Layar Pengaturan & Kelola Dompet Bertema Gelap', () {
    late FinanceRepository repository;
    late FinanceState state;
    late _FakeAuthService auth;
    late _FakeStorage storage;
    late AppLockManager lockManager;

    setUp(() async {
      repository = FinanceRepository.inMemory();
      state = FinanceState(repository: repository);
      await state.loadData();

      auth = _FakeAuthService();
      storage = _FakeStorage();
      lockManager = AppLockManager(authService: auth, storage: storage);
      await lockManager.initialize();
    });

    tearDown(() async {
      lockManager.dispose();
      await repository.close();
    });

    Widget createSettingsScreen() {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: SettingsScreen(
            lockManagerOverride: lockManager,
          ),
        ),
      );
    }

    Widget createWalletManagementScreen() {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const WalletManagementScreen(),
        ),
      );
    }

    testWidgets('Responsivitas Layar Pengaturan 360x640 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('Responsivitas Layar Pengaturan 411x891 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('Responsivitas Layar Kelola Dompet 360x640 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWalletManagementScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(WalletManagementScreen), findsOneWidget);
    });

    testWidgets('Responsivitas Layar Kelola Dompet 411x891 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWalletManagementScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(WalletManagementScreen), findsOneWidget);
    });

    testWidgets('Nama dompet panjang tidak merusak kartu (ellipsis satu baris)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await state.addWallet(
        const Wallet(
          id: 'w_very_long',
          name: 'Rekening Tabungan Utama Sangat Panjang Sekali Tanpa Batas',
          initialBalance: 987654321,
        ),
      );

      await tester.pumpWidget(createWalletManagementScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final textFinder = find.text('Rekening Tabungan Utama Sangat Panjang Sekali Tanpa Batas');
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('Pengaturan: Struktur kelompok visual dan fungsional lengkap', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('MASTER DATA'), findsOneWidget);
      expect(find.text('KEAMANAN'), findsOneWidget);
      expect(find.text('CADANGAN & PEMULIHAN'), findsOneWidget);

      expect(find.text('Kelola Dompet'), findsOneWidget);
      expect(find.text('Kelola Kategori'), findsOneWidget);
      expect(find.text('Kunci aplikasi'), findsOneWidget);
      expect(find.text('Cadangkan data'), findsOneWidget);
      expect(find.text('Pulihkan data'), findsOneWidget);

      // Verifikasi sakelar kunci aplikasi
      final switchFinder = find.byKey(const Key('switch_kunci_aplikasi'));
      expect(switchFinder, findsOneWidget);
      final Switch switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
    });

    testWidgets('Kelola Dompet: Header memiliki tombol tambah melingkar bertint', (tester) async {
      await tester.pumpWidget(createWalletManagementScreen());
      await tester.pumpAndSettle();

      expect(find.text('Kelola Dompet'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      final addBtnFinder = find.byKey(const Key('add_wallet_button'));
      expect(addBtnFinder, findsOneWidget);

      // Tap tambah dompet membuka dialog
      await tester.tap(addBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text('Tambah Dompet'), findsOneWidget);
      expect(find.byKey(const Key('wallet_name_input')), findsOneWidget);
      expect(find.byKey(const Key('wallet_balance_input')), findsOneWidget);
      expect(find.byKey(const Key('wallet_save_button')), findsOneWidget);
    });

    testWidgets('Kelola Dompet: Pemetaan ikon berdasarkan kata kunci nama dompet', (tester) async {
      expect(AppWalletIconMapping.getMapping('Seabank').icon, Icons.account_balance);
      expect(AppWalletIconMapping.getMapping('BCA').icon, Icons.account_balance);
      expect(AppWalletIconMapping.getMapping('Bank Mandiri').icon, Icons.account_balance);
      expect(AppWalletIconMapping.getMapping('Tunai').icon, Icons.payments);
      expect(AppWalletIconMapping.getMapping('Kas Dompet').icon, Icons.payments);
      expect(AppWalletIconMapping.getMapping('E-Wallet').icon, Icons.account_balance_wallet);
      expect(AppWalletIconMapping.getMapping('GoPay').icon, Icons.account_balance_wallet);
      expect(AppWalletIconMapping.getMapping('Koleksi Koin').icon, Icons.account_balance_wallet);
    });

    testWidgets('Kelola Dompet: Dompet yang diarsipkan tampil di seksi DIARSIPKAN dan dapat dipulihkan', (tester) async {
      // Arsipkan dompet BCA
      await state.archiveWallet('bca', isArchived: true);

      await tester.pumpWidget(createWalletManagementScreen());
      await tester.pumpAndSettle();

      // Seksi DIARSIPKAN tampil
      expect(find.text('DIARSIPKAN'), findsOneWidget);
      expect(find.text('BCA'), findsOneWidget);
      expect(find.text('Diarsipkan'), findsOneWidget);

      // Buka menu BCA dan pulihkan (Buka Arsip)
      await tester.tap(find.byKey(const Key('wallet_menu_bca')));
      await tester.pumpAndSettle();

      expect(find.text('Buka Arsip'), findsOneWidget);
      await tester.tap(find.text('Buka Arsip'));
      await tester.pumpAndSettle();

      // Seksi DIARSIPKAN hilang karena sudah tidak ada dompet terarsip
      expect(find.text('DIARSIPKAN'), findsNothing);
      expect(find.text('Dompet "BCA" diaktifkan kembali'), findsOneWidget);
    });

    testWidgets('Tipografi minimal 12 sp dan Saldo awal kontras tinggi', (tester) async {
      expect(AppTypography.walletInitialBalance.fontSize, greaterThanOrEqualTo(12.0));
      expect(AppTypography.walletBalanceLabel.fontSize, greaterThanOrEqualTo(12.0));
      expect(AppTypography.walletBalanceValue.fontSize, greaterThanOrEqualTo(12.0));
      expect(AppTypography.settingsItemSubtitle.fontSize, greaterThanOrEqualTo(12.0));
      expect(AppTypography.settingsSectionHeader.fontSize, greaterThanOrEqualTo(12.0));

      // Warna saldo awal adalah AppColors.walletInitialBalance (0xFFA5A3B5)
      expect(AppTypography.walletInitialBalance.color, AppColors.walletInitialBalance);
    });
  });
}
