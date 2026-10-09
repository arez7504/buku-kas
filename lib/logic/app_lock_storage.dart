import 'package:shared_preferences/shared_preferences.dart';

/// Abstraksi penyimpanan pengaturan sakelar kunci aplikasi.
abstract class AppLockStorage {
  Future<bool> isLockEnabled();
  Future<void> setLockEnabled(bool enabled);
}

/// Implementasi penyimpanan permanen menggunakan `shared_preferences`.
class SharedPrefsAppLockStorage implements AppLockStorage {
  static const String _key = 'is_app_lock_enabled';

  @override
  Future<bool> isLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
