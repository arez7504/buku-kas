import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'buku_kas_transaction_row.dart';

/// Kelompok transaksi per hari dalam bentuk kartu modern sesuai desain HTML
class BukuKasDayGroup extends StatelessWidget {
  final DailyTransactionGroup group;
  final String Function(String) getWalletName;
  final String Function(String?) getCategoryName;
  final Category? Function(String?)? getCategory;
  final void Function(Transaction) onTransactionTap;
  final DateTime? now;

  const BukuKasDayGroup({
    super.key,
    required this.group,
    required this.getWalletName,
    required this.getCategoryName,
    this.getCategory,
    required this.onTransactionTap,
    this.now,
  });

  Color _getDotColor(DateTime groupDate) {
    final ref = (now ?? DateTime.now()).toLocal();
    final localDate = groupDate.toLocal();
    final todayDate = DateTime(ref.year, ref.month, ref.day);
    final targetDate = DateTime(localDate.year, localDate.month, localDate.day);
    final yesterdayDate = DateTime(ref.year, ref.month, ref.day - 1);

    if (targetDate == todayDate) return AppColors.neonCyan;
    if (targetDate == yesterdayDate) return AppColors.transferBlue;
    return AppColors.neonGreen;
  }

  Widget _buildGroupHeader() {
    final subtotalText = FinanceCalculator.formatDailySubtotal(group.subtotal);
    final TextStyle subtotalStyle;
    if (group.subtotal != null && group.subtotal! > 0) {
      subtotalStyle = AppTypography.dayGroupSubtotalGreen;
    } else if (group.subtotal != null && group.subtotal! < 0) {
      subtotalStyle = AppTypography.dayGroupSubtotalRed;
    } else {
      subtotalStyle = AppTypography.dayGroupSubtotalNeutral;
    }

    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd,
        vertical: AppDimens.spaceSm + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getDotColor(group.date),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                Flexible(
                  child: Text(
                    FinanceCalculator.formatDayGroupHeader(group.date, now: now),
                    style: AppTypography.dayGroupDate,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          if (subtotalText != null)
            Text(
              subtotalText,
              style: subtotalStyle,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceXs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupHeader(),
          for (int i = 0; i < group.transactions.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderFaint,
                indent: AppDimens.spaceMd,
                endIndent: AppDimens.spaceMd,
              ),
            BukuKasTransactionRow(
              transaction: group.transactions[i],
              walletName: getWalletName(group.transactions[i].walletId),
              targetWalletName: group.transactions[i].targetWalletId != null
                  ? getWalletName(group.transactions[i].targetWalletId!)
                  : null,
              categoryName: getCategoryName(group.transactions[i].categoryId),
              category: getCategory?.call(group.transactions[i].categoryId),
              onTap: () => onTransactionTap(group.transactions[i]),
            ),
          ],
        ],
      ),
    );
  }
}
