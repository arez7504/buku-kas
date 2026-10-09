import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Layar kunci polos yang ditampilkan saat aplikasi dalam status terkunci.
///
/// Menyembunyikan seluruh isi data aplikasi dan hanya menampilkan tombol "Buka"
/// untuk meminta autentikasi perangkat (biometrik / PIN / pola / sandi).
class LockScreen extends StatelessWidget {
  final VoidCallback? onUnlockPressed;

  const LockScreen({super.key, this.onUnlockPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: AppDimens.borderWidthThin,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppDimens.spaceLg),
                const Text(
                  'Aplikasi Terkunci',
                  style: AppTypography.headlineSm,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.spaceSm),
                Text(
                  'Buka menggunakan sidik jari, wajah, atau kunci layar perangkat Anda.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.spaceXl),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    key: const Key('btn_buka_kunci'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                      ),
                    ),
                    onPressed: onUnlockPressed,
                    child: Text(
                      'Buka',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
