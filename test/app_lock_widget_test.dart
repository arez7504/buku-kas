import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catatan_keuangan/logic/app_lock_manager.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/lock_screen.dart';
import 'package:catatan_keuangan/screens/settings_screen.dart';
import 'app_lock_test.dart';

void main() {
  final testWallets = [
    Wallet(id: 'w_bca', name: 'BCA', initialBalance: 500000),
  ];

  final testCategories = [
    Category(id: 'c_makan', name: 'Makanan', type: CategoryType.expense),
  ];

  final testTransactions = [
    Transaction(
      id: 'tx_1',
      type: TransactionType.expense,
      amount: 45000,
      date: DateTime(2026, 10, 8, 10, 0),
      walletId: 'w_bca',
      categoryId: 'c_makan',
      note: 'Makan Siang',
    ),
  ];

  Widget buildTestApp({
    required FinanceState state,
    required AppLockManager lockManager,
  }) {
    return MyApp(
      initialState: state,
      lockManager: lockManager,
    );
  }

  group('App Lock Widget Tests', () {
    testWidgets('Saat terkunci, isi aplikasi tidak terlihat; menampilkan LockScreen polos dengan tombol Buka', (tester) async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: true);
      final lockManager = AppLockManager(authService: auth, storage: storage);
      await lockManager.initialize(autoAuthenticate: false);

      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: testTransactions,
      );

      await tester.pumpWidget(buildTestApp(state: state, lockManager: lockManager));
      await tester.pumpAndSettle();

      // Layar kunci tampil
      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text('Aplikasi Terkunci'), findsOneWidget);
      expect(find.byKey(const Key('btn_buka_kunci')), findsOneWidget);
      expect(find.text('Buka'), findsOneWidget);

      // Seluruh isi data keuangan TIDAK terlihat di layar
      expect(find.text('Makan Siang'), findsNothing);
      expect(find.text('Makanan'), findsNothing);
      expect(find.text('BCA'), findsNothing);
      expect(find.text('Rp 45.000'), findsNothing);
      expect(find.text('Buku Kas'), findsNothing);
    });

    testWidgets('Autentikasi gagal tetap menampilkan LockScreen; sukses membuka dan menampilkan isi aplikasi', (tester) async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: true);
      final lockManager = AppLockManager(authService: auth, storage: storage);
      await lockManager.initialize(autoAuthenticate: false);

      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: testTransactions,
      );

      await tester.pumpWidget(buildTestApp(state: state, lockManager: lockManager));
      await tester.pumpAndSettle();

      // 1. Tekan tombol Buka saat autentikasi gagal
      await tester.tap(find.byKey(const Key('btn_buka_kunci')));
      await tester.pumpAndSettle();

      // Masih terkunci
      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text('Makan Siang'), findsNothing);

      // 2. Sekarang autentikasi disimulasikan berhasil
      auth.authSuccess = true;
      await tester.tap(find.byKey(const Key('btn_buka_kunci')));
      await tester.pumpAndSettle();

      // Terbuka, LockScreen hilang, isi buku kas tampil
      expect(find.byType(LockScreen), findsNothing);
      expect(find.text('Makan Siang'), findsOneWidget);
      expect(find.text('BCA'), findsWidgets);
    });

    testWidgets('Layar Pengaturan memuat sakelar Kunci aplikasi; mengaktifkan mewajibkan autentikasi berhasil', (tester) async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: false);
      final lockManager = AppLockManager(authService: auth, storage: storage);
      await lockManager.initialize(autoAuthenticate: false);

      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: testTransactions,
      );

      await tester.pumpWidget(buildTestApp(state: state, lockManager: lockManager));
      await tester.pumpAndSettle();

      // Buka Pengaturan via tombol gerigi di header
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('KEAMANAN'), findsOneWidget);
      expect(find.text('Kunci aplikasi'), findsOneWidget);

      final switchFinder = find.byKey(const Key('switch_kunci_aplikasi'));
      expect(switchFinder, findsOneWidget);

      final Switch switchWidgetBefore = tester.widget<Switch>(switchFinder);
      expect(switchWidgetBefore.value, isFalse);

      // Coba aktifkan sakelar saat autentikasi gagal
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Sakelar harus tetap mati
      final Switch switchWidgetAfterFail = tester.widget<Switch>(switchFinder);
      expect(switchWidgetAfterFail.value, isFalse);
      expect(find.text('Autentikasi gagal atau dibatalkan.'), findsOneWidget);

      // Coba aktifkan sakelar saat autentikasi berhasil
      auth.authSuccess = true;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Sakelar sekarang menyala dan tersimpan di storage
      final Switch switchWidgetAfterSuccess = tester.widget<Switch>(switchFinder);
      expect(switchWidgetAfterSuccess.value, isTrue);
      expect(storage.enabled, isTrue);

      // Coba matikan sakelar saat autentikasi gagal
      auth.authSuccess = false;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Sakelar harus tetap menyala
      final Switch switchWidgetAfterOffFail = tester.widget<Switch>(switchFinder);
      expect(switchWidgetAfterOffFail.value, isTrue);

      // Coba matikan sakelar saat autentikasi berhasil
      auth.authSuccess = true;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Sakelar berhasil mati
      final Switch switchWidgetAfterOffSuccess = tester.widget<Switch>(switchFinder);
      expect(switchWidgetAfterOffSuccess.value, isFalse);
      expect(storage.enabled, isFalse);
    });

    testWidgets('Perangkat tanpa layar kunci: sakelar tidak bisa aktif dan menampilkan pesan jelas', (tester) async {
      final auth = FakeAppLockAuthService(isSupported: false);
      final storage = FakeAppLockStorage(enabled: false);
      final lockManager = AppLockManager(authService: auth, storage: storage);
      await lockManager.initialize(autoAuthenticate: false);

      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: testTransactions,
      );

      await tester.pumpWidget(buildTestApp(state: state, lockManager: lockManager));
      await tester.pumpAndSettle();

      // Buka Pengaturan
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();

      final switchFinder = find.byKey(const Key('switch_kunci_aplikasi'));
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Sakelar tetap false
      final Switch switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);

      // SnackBar muncul dengan pesan jelas
      expect(find.textContaining('tidak memiliki layar kunci'), findsOneWidget);
    });

    testWidgets('Layar kunci perangkat dihapus saat sakelar aktif: aplikasi tetap terbuka dan menampilkan pemberitahuan', (tester) async {
      final auth = FakeAppLockAuthService(isSupported: false);
      final storage = FakeAppLockStorage(enabled: true);
      final lockManager = AppLockManager(authService: auth, storage: storage);
      await lockManager.initialize(autoAuthenticate: false);

      final state = FinanceState(
        initialWallets: testWallets,
        initialCategories: testCategories,
        initialTransactions: testTransactions,
      );

      await tester.pumpWidget(buildTestApp(state: state, lockManager: lockManager));
      await tester.pumpAndSettle();

      // Aplikasi TIDAK menampilkan LockScreen (pemilik tidak terkunci)
      expect(find.byType(LockScreen), findsNothing);
      expect(find.text('Makan Siang'), findsOneWidget);

      // Menampilkan banner pemberitahuan
      expect(find.textContaining('Layar kunci perangkat telah dinonaktifkan'), findsOneWidget);
      expect(find.byKey(const Key('btn_close_device_lock_warning')), findsOneWidget);

      // Tutup pemberitahuan
      await tester.tap(find.byKey(const Key('btn_close_device_lock_warning')));
      await tester.pumpAndSettle();

      // Banner hilang dan aplikasi tetap normal
      expect(find.textContaining('Layar kunci perangkat telah dinonaktifkan'), findsNothing);
      expect(find.text('Makan Siang'), findsOneWidget);
    });
  });
}
