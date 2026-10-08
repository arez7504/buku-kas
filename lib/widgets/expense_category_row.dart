import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

// Baris satu kategori pengeluaran: nama, nominal, persen, dan batang horizontal proporsional
class ExpenseCategoryRow extends StatelessWidget {
  final CategoryExpenseBreakdown item;
  final int maxAmount;
  final VoidCallback? onTap;

  const ExpenseCategoryRow({
    super.key,
    required this.item,
    required this.maxAmount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Rasio batang sebanding dengan nominal (batang terpanjang = kategori terbesar)
    final double ratio = maxAmount > 0
        ? (item.amount / maxAmount).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      // Tap baris kategori ditunda (tidak melakukan apa-apa)
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.margin,
          vertical: AppDimens.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: nama kategori, nominal, dan persen dari total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    item.categoryName,
                    style: AppTypography.bodyLg,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      FinanceCalculator.formatRupiah(item.amount),
                      style: AppTypography.amountRow,
                    ),
                    const SizedBox(width: AppDimens.spaceSm),
                    Text(
                      item.formattedPercentage,
                      style: AppTypography.bodySm,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceSm),

            // Batang horizontal proporsional (satu warna aksen untuk semua batang)
            Container(
              width: double.infinity,
              height: AppDimens.expenseBarHeight,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppDimens.expenseBarTrackRadius),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppDimens.expenseBarTrackRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
