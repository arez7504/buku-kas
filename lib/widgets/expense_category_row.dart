import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';

// Baris satu kategori pengeluaran: ikon, nama, nominal, persen, dan batang horizontal proporsional
class ExpenseCategoryRow extends StatelessWidget {
  final CategoryExpenseBreakdown item;
  final int maxAmount;
  final Category? category;
  final VoidCallback? onTap;

  const ExpenseCategoryRow({
    super.key,
    required this.item,
    required this.maxAmount,
    this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Rasio batang sebanding dengan nominal (batang terpanjang = kategori terbesar)
    final double ratio = maxAmount > 0
        ? (item.amount / maxAmount).clamp(0.0, 1.0)
        : 0.0;

    final style = CategoryStyleRegistry.resolveCategoryStyle(
      category: category,
      categoryName: item.categoryName,
    );

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
            // Baris atas: ikon kategori, nama kategori, nominal, dan persen dari total
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    border: Border.all(
                      color: style.borderColor,
                      width: AppDimens.borderWidthThin,
                    ),
                  ),
                  child: Icon(
                    style.icon,
                    size: AppDimens.iconSmall,
                    color: style.iconColor,
                  ),
                ),
                const SizedBox(width: AppDimens.spaceMd),
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
