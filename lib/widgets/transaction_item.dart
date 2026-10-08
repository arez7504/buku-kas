import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

// TransactionItem: Komponen kartu baris untuk satu transaksi (kompatibilitas)
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final String walletName;
  final String? targetWalletName;
  final String categoryName;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.walletName,
    this.targetWalletName,
    required this.categoryName,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    final Color bgColor;
    final String prefix;
    final TextStyle amountStyle;

    switch (transaction.type) {
      case TransactionType.income:
        icon = Icons.arrow_downward;
        iconColor = AppColors.incomeGreen;
        bgColor = AppColors.incomeGreenSoft;
        prefix = '+ ';
        amountStyle = AppTypography.transactionAmountIncome;
        break;
      case TransactionType.expense:
        icon = Icons.arrow_upward;
        iconColor = AppColors.expenseRed;
        bgColor = AppColors.expenseRedSoft;
        prefix = '- ';
        amountStyle = AppTypography.transactionAmountExpense;
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        iconColor = AppColors.transferBlue;
        bgColor = AppColors.transferBlueSoft;
        prefix = '';
        amountStyle = AppTypography.transactionAmountTransfer;
        break;
    }

    final String titleText = transaction.type == TransactionType.transfer
        ? 'Transfer: $walletName ➔ ${targetWalletName ?? '-'}'
        : categoryName;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: AppDimens.borderWidthThin,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spaceMd),
            child: Row(
              children: [
                Container(
                  width: AppDimens.transactionBadgeSize,
                  height: AppDimens.transactionBadgeSize,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppDimens.iconMedium,
                  ),
                ),
                const SizedBox(width: AppDimens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleText,
                        style: AppTypography.transactionTitle,
                      ),
                      const SizedBox(height: AppDimens.spaceXs / 2),
                      Text(
                        '${_formatDate(transaction.date)} • $walletName',
                        style: AppTypography.transactionSubtitle,
                      ),
                      if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                        const SizedBox(height: AppDimens.spaceXs / 4),
                        Text(
                          transaction.note!,
                          style: AppTypography.transactionNote,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                Text(
                  '$prefix${FinanceCalculator.formatRupiah(transaction.amount)}',
                  style: amountStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
