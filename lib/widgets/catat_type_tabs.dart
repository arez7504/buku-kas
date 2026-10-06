import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

// Komponen tab bar Pengeluaran | Pemasukan | Transfer sesuai design/catat.html
class CatatTypeTabs extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const CatatTypeTabs({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Widget _buildTabItem(TransactionType type, String label) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeChanged(type),
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.spaceSm),
              child: Text(
                label,
                style: isSelected
                    ? AppTypography.labelMdActive
                    : AppTypography.labelMdInactive,
              ),
            ),
            Container(
              height: AppDimens.borderWidthIndicator,
              width: AppDimens.spaceXl,
              color: isSelected ? AppColors.secondary : AppColors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(top: AppDimens.spaceXs),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.surfaceContainerHigh,
              width: AppDimens.borderWidthThin,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabItem(TransactionType.expense, 'Pengeluaran'),
            _buildTabItem(TransactionType.income, 'Pemasukan'),
            _buildTabItem(TransactionType.transfer, 'Transfer'),
          ],
        ),
      ),
    );
  }
}
