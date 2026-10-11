import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bilah navigasi bawah sesuai spesifikasi Milestone NAV-1:
/// - 4 tab: Beranda, Riwayat, Statistik, Pengaturan
/// - 1 tombol aksi Catat di tengah bergradasi token neon fintech
/// - Urutan: Beranda, Riwayat, [Catat], Statistik, Pengaturan
/// - Area sentuh minimal 48 dp, label teks minimal 12 sp, kontras WCAG AA
/// - Tab aktif ditandai ikon, warna, dan label yang berbeda
/// - Hormati safe area dan gesture bar tanpa BackdropFilter/blur
class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCatatPressed;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCatatPressed,
  });

  Widget _buildTabItem({
    required Key key,
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isActive = currentIndex == index;
    return Expanded(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          key: key,
          onTap: () => onTabSelected(index),
          splashColor: AppColors.borderSubtle,
          highlightColor: AppColors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimens.minTouchTarget,
              minWidth: AppDimens.minTouchTarget,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: AppDimens.bottomNavCatatButtonSize,
                  child: Center(
                    child: Icon(
                      isActive ? activeIcon : inactiveIcon,
                      size: AppDimens.bottomNavIconSize,
                      color: isActive
                          ? AppColors.bottomNavActive
                          : AppColors.bottomNavInactive,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.bottomNavItemSpacing),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: isActive
                        ? AppTypography.bottomNavLabelActive
                        : AppTypography.bottomNavLabelInactive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatatButton() {
    return Expanded(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          key: const Key('nav_catat'),
          onTap: onCatatPressed,
          splashColor: AppColors.borderSubtle,
          highlightColor: AppColors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimens.minTouchTarget,
              minWidth: AppDimens.minTouchTarget,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: AppDimens.bottomNavCatatButtonSize,
                  height: AppDimens.bottomNavCatatButtonSize,
                  decoration: BoxDecoration(
                    gradient: AppGradients.catatButton,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.outline,
                      width: AppDimens.borderWidthThin,
                    ),
                    boxShadow: AppShadows.bottomNavCatatButton,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: AppDimens.bottomNavCatatIconSize,
                      color: AppColors.bottomNavCatatIcon,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.bottomNavItemSpacing),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Catat',
                    maxLines: 1,
                    style: AppTypography.bottomNavLabelCatat,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomNavBg,
        border: Border(
          top: BorderSide(
            color: AppColors.bottomNavBorder,
            width: AppDimens.borderWidthThin,
          ),
        ),
        boxShadow: AppShadows.bottomNavBar,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimens.bottomNavHeight,
          child: Row(
            children: [
              _buildTabItem(
                key: const Key('nav_beranda'),
                index: 0,
                label: 'Beranda',
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
              ),
              _buildTabItem(
                key: const Key('nav_riwayat'),
                index: 1,
                label: 'Riwayat',
                activeIcon: Icons.receipt_long_rounded,
                inactiveIcon: Icons.receipt_long_outlined,
              ),
              _buildCatatButton(),
              _buildTabItem(
                key: const Key('nav_statistik'),
                index: 2,
                label: 'Statistik',
                activeIcon: Icons.bar_chart_rounded,
                inactiveIcon: Icons.bar_chart_outlined,
              ),
              _buildTabItem(
                key: const Key('nav_pengaturan'),
                index: 3,
                label: 'Pengaturan',
                activeIcon: Icons.settings_rounded,
                inactiveIcon: Icons.settings_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
