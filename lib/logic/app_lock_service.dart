import 'package:local_auth/local_auth.dart';

/// Abstraksi layanan autentikasi lokal perangkat (sidik jari, wajah, PIN/pola/sandi).
/// Memungkinkan pengujian unit/widget secara terisolasi menggunakan fake/mock.
abstract class AppLockAuthService {
  /// Memeriksa apakah perangkat memiliki kemampuan autentikasi
  /// (layar kunci seperti PIN/pola/sandi atau biometrik).
  Future<bool> isDeviceSupported();

  /// Memeriksa apakah perangkat memiliki perangkat keras biometrik.
  Future<bool> canCheckBiometrics();

  /// Melakukan autentikasi pengguna dengan layar kunci perangkat atau biometrik.
  Future<bool> authenticate({required String localizedReason});
}

/// Implementasi nyata menggunakan package `local_auth`.
class LocalAuthService implements AppLockAuthService {
  final LocalAuthentication _auth;

  LocalAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false, // Memungkinkan cadangan PIN, pola, atau sandi layar kunci
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true, // Melanjutkan autentikasi jika app berpindah ke latar depan
      );
    } catch (_) {
      return false;
    }
  }
}
