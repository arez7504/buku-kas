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

  IconData _getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.arrow_downward;
      case TransactionType.income:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.sync_alt;
    }
  }

  Widget _buildTabItem(TransactionType type, String label) {
    final isSelected = selectedType == type;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTypeChanged(type),
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
            decoration: BoxDecoration(
              gradient: isSelected ? AppGradients.catatTabActive : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              boxShadow: isSelected ? AppShadows.catatTabActive : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(type),
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimens.spaceXs),
                  Text(
                    label,
                    style: isSelected
                        ? AppTypography.catatTabActive
                        : AppTypography.catatTabInactive,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          _buildTabItem(TransactionType.expense, 'Pengeluaran'),
          _buildTabItem(TransactionType.income, 'Pemasukan'),
          _buildTabItem(TransactionType.transfer, 'Transfer'),
        ],
      ),
    );
  }
}
