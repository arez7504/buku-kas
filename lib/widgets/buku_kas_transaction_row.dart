import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';

/// Baris transaksi individual di dalam kelompok harian
class BukuKasTransactionRow extends StatelessWidget {
  final Transaction transaction;
  final String walletName;
  final String? targetWalletName;
  final String categoryName;
  final Category? category;
  final VoidCallback onTap;

  const BukuKasTransactionRow({
    super.key,
    required this.transaction,
    required this.walletName,
    this.targetWalletName,
    required this.categoryName,
    this.category,
    required this.onTap,
  });

  String _formatSubtitle() {
    final hasMeaningfulTime =
        transaction.date.hour != 0 || transaction.date.minute != 0;
    if (hasMeaningfulTime) {
      final hour = transaction.date.hour.toString().padLeft(2, '0');
      final minute = transaction.date.minute.toString().padLeft(2, '0');
      return '$walletName • $hour:$minute';
    }
    return walletName;
  }

  @override
  Widget build(BuildContext context) {
    final iconStyle = CategoryStyleRegistry.resolveCategoryStyle(
      category: category,
      categoryName: categoryName,
      transactionType: transaction.type,
    );

    final titleText = transaction.note != null &&
            transaction.note!.trim().isNotEmpty
        ? transaction.note!.trim()
        : (transaction.type == TransactionType.transfer
            ? 'Transfer: $walletName → ${targetWalletName ?? '-'}'
            : (categoryName.isNotEmpty ? categoryName : 'Lainnya'));

    final String amountText;
    final TextStyle amountStyle;
    switch (transaction.type) {
      case TransactionType.expense:
        amountText = '- ${FinanceCalculator.formatRupiah(transaction.amount)}';
        amountStyle = AppTypography.transactionAmountExpense;
        break;
      case TransactionType.income:
        amountText = '+ ${FinanceCalculator.formatRupiah(transaction.amount)}';
        amountStyle = AppTypography.transactionAmountIncome;
        break;
      case TransactionType.transfer:
        amountText = FinanceCalculator.formatRupiah(transaction.amount);
        amountStyle = AppTypography.transactionAmountNeutral;
        break;
    }

    final categoryBadge = transaction.type == TransactionType.transfer
        ? 'TRANSFER'
        : (categoryName.isNotEmpty ? categoryName.toUpperCase() : 'LAINNYA');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceMd,
          vertical: AppDimens.spaceSm + 2,
        ),
        child: Row(
          children: [
            // Kotak ikon kategori bertint
            Container(
              width: AppDimens.transactionBadgeSize,
              height: AppDimens.transactionBadgeSize,
              decoration: BoxDecoration(
                color: iconStyle.backgroundColor,
                border: Border.all(color: iconStyle.borderColor),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: Icon(
                iconStyle.icon,
                size: AppDimens.iconMedium,
                color: iconStyle.iconColor,
              ),
            ),
            const SizedBox(width: AppDimens.spaceMd),

            // Judul dan nama dompet / jam
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    style: AppTypography.transactionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.spaceXs / 2),
                  Text(
                    _formatSubtitle(),
                    style: AppTypography.transactionSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.spaceSm),

            // Nominal angka dan kategori huruf kapital kecil di kanan
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amountText,
                  style: amountStyle,
                ),
                const SizedBox(height: AppDimens.spaceXs / 2),
                Text(
                  categoryBadge,
                  style: AppTypography.transactionCategoryBadge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
