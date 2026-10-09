import 'package:flutter/widgets.dart';

import 'app_lock_service.dart';
import 'app_lock_storage.dart';

/// Status hasil percobaan pengubahan sakelar kunci aplikasi.
enum ToggleLockStatus {
  success,
  authFailed,
  unsupported,
}

/// Hasil dari operasi toggle lock.
class ToggleLockResult {
  final ToggleLockStatus status;
  final String? message;

  const ToggleLockResult({required this.status, this.message});

  factory ToggleLockResult.success() =>
      const ToggleLockResult(status: ToggleLockStatus.success);

  factory ToggleLockResult.authFailed() => const ToggleLockResult(
        status: ToggleLockStatus.authFailed,
        message: 'Autentikasi gagal atau dibatalkan.',
      );

  factory ToggleLockResult.unsupported([String? message]) => ToggleLockResult(
        status: ToggleLockStatus.unsupported,
        message: message ??
            'Perangkat tidak memiliki layar kunci (PIN, pola, sandi, atau biometrik). '
            'Aktifkan kunci layar di pengaturan perangkat terlebih dahulu.',
      );

  bool get isSuccess => status == ToggleLockStatus.success;
}

/// Pengelola status dan siklus hidup kunci aplikasi.
///
/// Logika kunci dipisahkan dari tampilan agar dapat diuji secara terisolasi
/// dengan layanan autentikasi palsu (fake) dan penyimpanan palsu.
class AppLockManager extends ChangeNotifier with WidgetsBindingObserver {
  final AppLockAuthService _authService;
  final AppLockStorage _storage;
  final DateTime Function() _clock;
  final Duration autoLockTimeout;

  bool _isEnabled = false;
  bool _isLocked = false;
  bool _isAuthenticating = false;
  String? _deviceLockWarning;
  DateTime? _pausedAt;
  bool _isInitialized = false;
  bool _isListeningLifecycle = false;

  AppLockManager({
    AppLockAuthService? authService,
    AppLockStorage? storage,
    DateTime Function()? clock,
    this.autoLockTimeout = const Duration(seconds: 30),
  })  : _authService = authService ?? LocalAuthService(),
        _storage = storage ?? SharedPrefsAppLockStorage(),
        _clock = clock ?? DateTime.now;

  bool get isEnabled => _isEnabled;
  bool get isLocked => _isLocked;
  bool get isAuthenticating => _isAuthenticating;
  String? get deviceLockWarning => _deviceLockWarning;
  bool get isInitialized => _isInitialized;

  /// Menghapus pesan pemberitahuan layar kunci dihapus.
  void clearWarning() {
    _deviceLockWarning = null;
    notifyListeners();
  }

  /// Inisialisasi awal saat aplikasi dibuka dari kondisi tertutup (cold start).
  Future<void> initialize({bool autoAuthenticate = true}) async {
    _isEnabled = await _storage.isLockEnabled();
    if (_isEnabled) {
      final supported = await _authService.isDeviceSupported();
      if (!supported) {
        // Layar kunci perangkat telah dihapus: jangan kunci pengguna di luar datanya.
        _isLocked = false;
        _deviceLockWarning =
            'Layar kunci perangkat telah dinonaktifkan. Fitur kunci aplikasi tidak aktif.';
      } else {
        _isLocked = true;
        _deviceLockWarning = null;
        if (autoAuthenticate) {
          // Segera minta autentikasi saat app pertama kali dibuka
          unlock();
        }
      }
    } else {
      _isLocked = false;
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Membuka kunci aplikasi melalui autentikasi perangkat.
  Future<bool> unlock() async {
    if (!_isLocked) return true;
    if (_isAuthenticating) return false;

    _isAuthenticating = true;
    notifyListeners();

    try {
      final supported = await _authService.isDeviceSupported();
      if (!supported) {
        // Jika layar kunci dihapus saat kondisi terkunci, tetap izinkan pemilik masuk
        _isLocked = false;
        _deviceLockWarning =
            'Layar kunci perangkat telah dinonaktifkan. Fitur kunci aplikasi tidak aktif.';
        _isAuthenticating = false;
        notifyListeners();
        return true;
      }

      final success = await _authService.authenticate(
        localizedReason: 'Buka kunci Catatan Keuangan',
      );

      if (success) {
        _isLocked = false;
        _pausedAt = null;
      }
      return success;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  /// Mengubah sakelar kunci aplikasi di Pengaturan.
  /// Mewajibkan autentikasi berhasil baik saat mengaktifkan maupun mematikan.
  Future<ToggleLockResult> toggleLock(bool target) async {
    if (_isAuthenticating) {
      return ToggleLockResult.authFailed();
    }

    if (target) {
      // 1. Periksa apakah perangkat punya layar kunci
      final supported = await _authService.isDeviceSupported();
      if (!supported) {
        return ToggleLockResult.unsupported();
      }

      _isAuthenticating = true;
      notifyListeners();

      try {
        final success = await _authService.authenticate(
          localizedReason: 'Konfirmasi kunci layar untuk mengaktifkan kunci aplikasi',
        );

        if (success) {
          _isEnabled = true;
          _deviceLockWarning = null;
          await _storage.setLockEnabled(true);
          return ToggleLockResult.success();
        } else {
          return ToggleLockResult.authFailed();
        }
      } finally {
        _isAuthenticating = false;
        notifyListeners();
      }
    } else {
      // 2. Mematikan sakelar juga mewajibkan autentikasi
      final supported = await _authService.isDeviceSupported();
      if (!supported) {
        // Jika layar kunci di perangkat sudah tidak ada, izinkan langsung mematikan
        _isEnabled = false;
        _deviceLockWarning = null;
        await _storage.setLockEnabled(false);
        notifyListeners();
        return ToggleLockResult.success();
      }

      _isAuthenticating = true;
      notifyListeners();

      try {
        final success = await _authService.authenticate(
          localizedReason: 'Konfirmasi kunci layar untuk mematikan kunci aplikasi',
        );

        if (success) {
          _isEnabled = false;
          _deviceLockWarning = null;
          await _storage.setLockEnabled(false);
          return ToggleLockResult.success();
        } else {
          return ToggleLockResult.authFailed();
        }
      } finally {
        _isAuthenticating = false;
        notifyListeners();
      }
    }
  }

  /// Mulai memantau siklus hidup aplikasi (latar depan / latar belakang).
  void startListeningLifecycle() {
    if (!_isListeningLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _isListeningLifecycle = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isEnabled) return;
    if (_isAuthenticating) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _pausedAt = _clock();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final elapsed = _clock().difference(_pausedAt!);
        _pausedAt = null;

        // Kembali dari latar belakang di bawah 30 detik tidak mengunci,
        // di atas 30 detik mengunci.
        if (elapsed > autoLockTimeout) {
          _isLocked = true;
          notifyListeners();
          _handleResumeUnlock();
        }
      }
    }
  }

  Future<void> _handleResumeUnlock() async {
    final supported = await _authService.isDeviceSupported();
    if (!supported) {
      _isLocked = false;
      _deviceLockWarning =
          'Layar kunci perangkat telah dinonaktifkan. Fitur kunci aplikasi tidak aktif.';
      notifyListeners();
      return;
    }
    unlock();
  }

  @override
  void dispose() {
    if (_isListeningLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _isListeningLifecycle = false;
    }
    super.dispose();
  }
}
