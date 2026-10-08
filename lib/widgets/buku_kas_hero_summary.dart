import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

// Kartu Ringkasan: Pemasukan, Pengeluaran, dan Selisih dalam tiga kolom sejajar berlebar sama
class BukuKasHeroSummary extends StatelessWidget {
  final MonthlySummary summary;
  final VoidCallback? onViewDetails;

  const BukuKasHeroSummary({
    super.key,
    required this.summary,
    this.onViewDetails,
  });

  Widget _buildSummaryColumn({
    required String label,
    required String amountText,
    required TextStyle amountStyle,
  }) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.summaryColumnLabel,
              maxLines: 1,
            ),
            const SizedBox(height: AppDimens.spaceXs),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amountText,
                  maxLines: 1,
                  style: amountStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = summary.netCashFlow < 0;
    final selisihText = isNegative
        ? '- ${FinanceCalculator.formatRupiah(summary.netCashFlow.abs())}'
        : FinanceCalculator.formatRupiah(summary.netCashFlow);
    final selisihStyle = isNegative
        ? AppTypography.summaryAmountExpense
        : AppTypography.summaryAmountSelisih;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: AppDimens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tiga kolom dengan lebar SAMA dan pemisah vertikal tinggi penuh
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.summaryCardPadding),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryColumn(
                    label: 'Pemasukan',
                    amountText: '+ ${FinanceCalculator.formatRupiah(summary.totalIncome)}',
                    amountStyle: AppTypography.summaryAmountIncome,
                  ),
                  Container(
                    width: AppDimens.borderWidthThin,
                    color: AppColors.outlineVariant,
                  ),
                  _buildSummaryColumn(
                    label: 'Pengeluaran',
                    amountText: FinanceCalculator.formatRupiah(summary.totalExpense),
                    amountStyle: AppTypography.summaryAmountExpense,
                  ),
                  Container(
                    width: AppDimens.borderWidthThin,
                    color: AppColors.outlineVariant,
                  ),
                  _buildSummaryColumn(
                    label: 'Selisih',
                    amountText: selisihText,
                    amountStyle: selisihStyle,
                  ),
                ],
              ),
            ),
          ),

          // Garis tipis horizontal pemisah tautan
          const Divider(
            height: AppDimens.borderWidthThin,
            thickness: AppDimens.borderWidthThin,
            color: AppColors.outlineVariant,
          ),

          // Baris tersendiri di bawah ketiga kolom, rata kanan: "Lihat rincian pengeluaran"
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceSm + 2,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                key: const Key('lihat_rincian_link'),
                onTap: onViewDetails,
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lihat rincian', style: AppTypography.labelSmLink),
                    Text(' pengeluaran', style: AppTypography.labelSmLink),
                    SizedBox(width: AppDimens.spaceXs / 2),
                    Icon(
                      Icons.chevron_right,
                      size: AppDimens.iconTiny,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
