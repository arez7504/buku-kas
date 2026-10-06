import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

// Komponen penampil nominal dan chip tanggal sesuai design/catat.html
class CatatAmountDisplay extends StatelessWidget {
  final TransactionType type;
  final String formattedAmount;
  final String dateText;
  final VoidCallback onDateTap;

  const CatatAmountDisplay({
    super.key,
    required this.type,
    required this.formattedAmount,
    required this.dateText,
    required this.onDateTap,
  });

  String _getLabelText() {
    switch (type) {
      case TransactionType.expense:
        return 'NOMINAL PENGELUARAN';
      case TransactionType.income:
        return 'NOMINAL PEMASUKAN';
      case TransactionType.transfer:
        return 'NOMINAL TRANSFER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceMd,
      ),
      child: Column(
        children: [
          Text(_getLabelText(), style: AppTypography.labelCaps),
          const SizedBox(height: AppDimens.spaceXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Rp ', style: AppTypography.amountPrefix),
              Text(formattedAmount, style: AppTypography.headlineHeroMobile),
              Container(
                width: AppDimens.caretWidth,
                height: AppDimens.caretHeight,
                margin: const EdgeInsets.only(left: AppDimens.spaceXs),
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),
          InkWell(
            onTap: onDateTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceMd,
                vertical: AppDimens.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: AppDimens.iconSmall,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimens.spaceXs),
                  Text(dateText, style: AppTypography.bodySm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
