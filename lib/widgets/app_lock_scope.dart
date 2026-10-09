import 'package:flutter/material.dart';

import '../logic/app_lock_manager.dart';
import '../screens/lock_screen.dart';
import '../theme/app_theme.dart';

/// Provider InheritedNotifier untuk [AppLockManager].
class AppLockScope extends InheritedNotifier<AppLockManager> {
  const AppLockScope({
    super.key,
    required AppLockManager manager,
    required super.child,
  }) : super(notifier: manager);

  static AppLockManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLockScope>();
    assert(scope != null, 'No AppLockScope found in context');
    return scope!.notifier!;
  }

  static AppLockManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLockScope>()?.notifier;
  }
}

/// Pembungkus aplikasi yang mengendalikan penampilan layar kunci dan pemberitahuan.
///
/// Saat terkunci ([AppLockManager.isLocked] == true):
/// Seluruh isi aplikasi digantikan dengan layar kunci polos [LockScreen],
/// sehingga isi aplikasi tidak terlihat pada layar maupun tangkapan layar
/// aplikasi terbaru (Recent Apps).
class AppLockWrapper extends StatelessWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final manager = AppLockScope.maybeOf(context);
    if (manager == null) {
      return child;
    }

    if (manager.isLocked) {
      return LockScreen(
        onUnlockPressed: () => manager.unlock(),
      );
    }

    // Jika ada peringatan layar kunci dihapus, tampilkan banner di atas aplikasi
    if (manager.deviceLockWarning != null) {
      return Stack(
        children: [
          child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(AppDimens.spaceSm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spaceMd,
                    vertical: AppDimens.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: AppDimens.borderWidthThin,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.secondary,
                        size: AppDimens.iconMedium,
                      ),
                      const SizedBox(width: AppDimens.spaceSm),
                      Expanded(
                        child: Text(
                          manager.deviceLockWarning!,
                          style: AppTypography.bodySm,
                        ),
                      ),
                      GestureDetector(
                        key: const Key('btn_close_device_lock_warning'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => manager.clearWarning(),
                        child: const Padding(
                          padding: EdgeInsets.all(AppDimens.spaceXs),
                          child: Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}
