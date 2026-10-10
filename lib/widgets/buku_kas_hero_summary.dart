import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

/// Kartu Hero Utama: Pengeluaran bulan ini (nominal besar) dan kartu kecil Pemasukan & Selisih
class BukuKasHeroSummary extends StatelessWidget {
  final MonthlySummary summary;
  final VoidCallback? onViewDetails;

  const BukuKasHeroSummary({
    super.key,
    required this.summary,
    this.onViewDetails,
  });

  Widget _buildIncomeCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spaceMd - 4),
        decoration: BoxDecoration(
          color: AppColors.borderFaint,
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Pemasukan',
                    style: AppTypography.cardSubLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_downward,
                  size: AppDimens.iconSmall,
                  color: AppColors.incomeGreen,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceXs + 2),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '+ ${FinanceCalculator.formatRupiah(summary.totalIncome)}',
                  style: AppTypography.cardSubAmount.copyWith(
                    color: AppColors.incomeGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelisihCard() {
    final isNegative = summary.netCashFlow < 0;
    final selisihText = isNegative
        ? '- ${FinanceCalculator.formatRupiah(summary.netCashFlow.abs())}'
        : FinanceCalculator.formatRupiah(summary.netCashFlow);
    final selisihColor = isNegative ? AppColors.expenseRed : AppColors.selisihTeal;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spaceMd - 4),
        decoration: BoxDecoration(
          color: AppColors.borderFaint,
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Selisih',
                    style: AppTypography.cardSubLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.savings_outlined,
                  size: AppDimens.iconSmall,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceXs + 2),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  selisihText,
                  style: AppTypography.cardSubAmount.copyWith(
                    color: selisihColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        key: const Key('lihat_rincian_link'),
        onTap: onViewDetails,
        behavior: HitTestBehavior.opaque,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Lihat rincian',
                style: AppTypography.labelSmLink,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                ' pengeluaran',
                style: AppTypography.labelSmLink,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppDimens.spaceXs / 2),
            Icon(
              Icons.chevron_right,
              size: AppDimens.iconTiny,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm,
      ),
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label Pengeluaran Bulan Ini
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.neonPurple,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              const Text(
                'PENGELUARAN BULAN INI',
                style: AppTypography.heroLabel,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),

          // Nominal besar
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                FinanceCalculator.formatRupiah(summary.totalExpense),
                style: AppTypography.heroAmount,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),

          // Dua kartu kecil berdampingan: Pemasukan dan Selisih
          Row(
            children: [
              _buildIncomeCard(),
              const SizedBox(width: AppDimens.spaceSm + 2),
              _buildSelisihCard(),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm + 2),

          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderFaint,
          ),
          const SizedBox(height: AppDimens.spaceSm),

          // Tautan rincian pengeluaran
          _buildFooterLink(),
        ],
      ),
    );
  }
}
