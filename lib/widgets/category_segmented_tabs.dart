import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Segmented control pill untuk berpindah antara tab Pengeluaran dan Pemasukan
class CategorySegmentedTabs extends StatelessWidget {
  final TabController tabController;

  const CategorySegmentedTabs({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final activeIndex = tabController.index;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceSm,
          ),
          padding: const EdgeInsets.all(AppDimens.spaceXs),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            border: Border.all(
              color: AppColors.borderFaint,
              width: AppDimens.borderWidthThin,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: 'Pengeluaran',
                  isSelected: activeIndex == 0,
                  onTap: () => tabController.animateTo(0),
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  title: 'Pemasukan',
                  isSelected: activeIndex == 1,
                  onTap: () => tabController.animateTo(1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceSm + 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          gradient: isSelected ? AppGradients.catatTabActive : null,
          boxShadow: isSelected ? AppShadows.catatTabActive : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: isSelected
                  ? AppTypography.categoryTabActive
                  : AppTypography.categoryTabInactive,
            ),
          ),
        ),
      ),
    );
  }
}
