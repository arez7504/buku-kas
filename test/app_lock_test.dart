import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catatan_keuangan/logic/app_lock_manager.dart';
import 'package:catatan_keuangan/logic/app_lock_service.dart';
import 'package:catatan_keuangan/logic/app_lock_storage.dart';

/// Fake implementation of [AppLockAuthService] for testing.
class FakeAppLockAuthService implements AppLockAuthService {
  bool isSupported;
  bool canCheckBio;
  bool authSuccess;
  int authenticateCallCount = 0;
  String? lastLocalizedReason;

  FakeAppLockAuthService({
    this.isSupported = true,
    this.canCheckBio = true,
    this.authSuccess = true,
  });

  @override
  Future<bool> isDeviceSupported() async => isSupported;

  @override
  Future<bool> canCheckBiometrics() async => canCheckBio;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticateCallCount++;
    lastLocalizedReason = localizedReason;
    return authSuccess;
  }
}

/// Fake implementation of [AppLockStorage] for testing.
class FakeAppLockStorage implements AppLockStorage {
  bool enabled;
  int setCallCount = 0;

  FakeAppLockStorage({this.enabled = false});

  @override
  Future<bool> isLockEnabled() async => enabled;

  @override
  Future<void> setLockEnabled(bool value) async {
    setCallCount++;
    enabled = value;
  }
}

void main() {
  group('AppLockManager - Logika Penguncian Aplikasi', () {
    test('(1) Sakelar aktif membuat aplikasi terkunci saat dibuka dari kondisi tertutup', () async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: true);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
      );

      // Inisialisasi tanpa langsung auto-unlock agar status awal terkunci dapat diverifikasi
      await manager.initialize(autoAuthenticate: false);

      expect(manager.isEnabled, isTrue);
      expect(manager.isLocked, isTrue);
      expect(manager.deviceLockWarning, isNull);
    });

    test('(2) Autentikasi gagal: aplikasi tetap terkunci', () async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: true);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
      );

      await manager.initialize(autoAuthenticate: false);
      expect(manager.isLocked, isTrue);

      // Percobaan buka kunci gagal
      final unlocked = await manager.unlock();

      expect(unlocked, isFalse);
      expect(manager.isLocked, isTrue);
      expect(auth.authenticateCallCount, equals(1));
    });

    test('(3) Autentikasi sukses: aplikasi berhasil dibuka', () async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: true);
      final storage = FakeAppLockStorage(enabled: true);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
      );

      await manager.initialize(autoAuthenticate: false);
      expect(manager.isLocked, isTrue);

      // Percobaan buka kunci berhasil
      final unlocked = await manager.unlock();

      expect(unlocked, isTrue);
      expect(manager.isLocked, isFalse);
      expect(auth.authenticateCallCount, equals(1));
    });

    test('(4) Kembali dari latar belakang di bawah 30 detik tidak mengunci', () async {
      var currentTime = DateTime(2026, 10, 8, 12, 0, 0);
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: true);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
        clock: () => currentTime,
      );

      // Mulai dengan aplikasi sudah terbuka
      await manager.initialize(autoAuthenticate: false);
      auth.authSuccess = true;
      await manager.unlock();
      expect(manager.isLocked, isFalse);

      // Aplikasi masuk ke latar belakang
      manager.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Kembali setelah 25 detik (< 30 detik)
      currentTime = currentTime.add(const Duration(seconds: 25));
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(manager.isLocked, isFalse);

      // Uji persis 30 detik: tidak mengunci (kriteria: di bawah / sampai 30 detik tidak mengunci)
      manager.didChangeAppLifecycleState(AppLifecycleState.paused);
      currentTime = currentTime.add(const Duration(seconds: 30));
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(manager.isLocked, isFalse);
    });

    test('(5) Kembali dari latar belakang di atas 30 detik mengunci aplikasi', () async {
      var currentTime = DateTime(2026, 10, 8, 12, 0, 0);
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: true);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
        clock: () => currentTime,
      );

      await manager.initialize(autoAuthenticate: false);
      auth.authSuccess = true;
      await manager.unlock();
      expect(manager.isLocked, isFalse);

      // Masuk latar belakang
      manager.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Kembali setelah 31 detik (> 30 detik)
      currentTime = currentTime.add(const Duration(seconds: 31));
      auth.authSuccess = false; // simulasi pengguna belum autentikasi
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Aplikasi harus terkunci
      expect(manager.isLocked, isTrue);
    });

    test('(6) Perangkat tanpa layar kunci tidak bisa mengaktifkan sakelar', () async {
      final auth = FakeAppLockAuthService(isSupported: false);
      final storage = FakeAppLockStorage(enabled: false);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
      );

      await manager.initialize(autoAuthenticate: false);
      expect(manager.isEnabled, isFalse);

      final result = await manager.toggleLock(true);

      expect(result.status, equals(ToggleLockStatus.unsupported));
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('tidak memiliki layar kunci'));
      expect(manager.isEnabled, isFalse);
      expect(storage.enabled, isFalse);
      expect(auth.authenticateCallCount, equals(0)); // tidak memanggil autentikasi jika perangkat tidak didukung
    });

    test('(7) Mengaktifkan sakelar mewajibkan autentikasi berhasil dulu', () async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: false);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
      );

      await manager.initialize(autoAuthenticate: false);

      // Autentikasi gagal saat ingin mengaktifkan
      final failResult = await manager.toggleLock(true);
      expect(failResult.status, equals(ToggleLockStatus.authFailed));
      expect(manager.isEnabled, isFalse);
      expect(storage.enabled, isFalse);

      // Autentikasi berhasil
      auth.authSuccess = true;
      final successResult = await manager.toggleLock(true);
      expect(successResult.status, equals(ToggleLockStatus.success));
      expect(manager.isEnabled, isTrue);
      expect(storage.enabled, isTrue);
    });

    test('(8) Mematikan sakelar juga mewajibkan autentikasi berhasil dulu', () async {
      final auth = FakeAppLockAuthService(isSupported: true, authSuccess: false);
      final storage = FakeAppLockStorage(enabled: true);
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
      );

      await manager.initialize(autoAuthenticate: false);
      expect(manager.isEnabled, isTrue);

      // Autentikasi gagal saat ingin mematikan
      final failResult = await manager.toggleLock(false);
      expect(failResult.status, equals(ToggleLockStatus.authFailed));
      expect(manager.isEnabled, isTrue);
      expect(storage.enabled, isTrue);

      // Autentikasi berhasil
      auth.authSuccess = true;
      final successResult = await manager.toggleLock(false);
      expect(successResult.status, equals(ToggleLockStatus.success));
      expect(manager.isEnabled, isFalse);
      expect(storage.enabled, isFalse);
    });

    test('(9) Sakelar sudah aktif lalu layar kunci perangkat dihapus: aplikasi tetap terbuka & menampilkan pemberitahuan', () async {
      final auth = FakeAppLockAuthService(isSupported: false); // layar kunci dihapus di OS
      final storage = FakeAppLockStorage(enabled: true); // sakelar masih aktif
      final manager = AppLockManager(
        authService: auth,
        storage: storage,
      );

      await manager.initialize(autoAuthenticate: false);

      // Aplikasi TIDAK terkunci agar pemilik tidak terkunci di luar datanya sendiri
      expect(manager.isLocked, isFalse);
      expect(manager.deviceLockWarning, isNotNull);
      expect(manager.deviceLockWarning, contains('Layar kunci perangkat telah dinonaktifkan'));

      // Pembersihan pemberitahuan
      manager.clearWarning();
      expect(manager.deviceLockWarning, isNull);
    });
  });
}
