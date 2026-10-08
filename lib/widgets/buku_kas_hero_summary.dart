import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

// Hero Ringkasan Pengeluaran, Pemasukan, dan Selisih sesuai design/buku_kas.html
class BukuKasHeroSummary extends StatelessWidget {
  final MonthlySummary summary;
  final VoidCallback? onViewDetails;

  const BukuKasHeroSummary({
    super.key,
    required this.summary,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final netColor = summary.netCashFlow >= 0
        ? AppColors.onSurface
        : AppColors.expenseRed;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.margin,
        right: AppDimens.margin,
        top: AppDimens.spaceLg,
        bottom: AppDimens.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PENGELUARAN BULAN INI', style: AppTypography.labelCaps),
          const SizedBox(height: AppDimens.spaceXs),
          Text(
            FinanceCalculator.formatRupiah(summary.totalExpense),
            style: AppTypography.headlineHeroMobile,
          ),
          const SizedBox(height: AppDimens.spaceXs),
          GestureDetector(
            key: const Key('lihat_rincian_link'),
            onTap: onViewDetails,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Lihat rincian',
                  style: AppTypography.labelMdActive,
                ),
                const SizedBox(width: AppDimens.spaceXs / 2),
                const Icon(
                  Icons.chevron_right,
                  size: AppDimens.iconSmall,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),

          // Sub-ringkasan dua kolom: Pemasukan dan Selisih
          Container(
            color: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.all(AppDimens.spaceMd),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PEMASUKAN', style: AppTypography.labelCaps),
                      const SizedBox(height: AppDimens.spaceXs / 2),
                      Text(
                        '+ ${FinanceCalculator.formatRupiah(summary.totalIncome)}',
                        style: AppTypography.amountRowGreen,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(AppDimens.spaceSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SELISIH', style: AppTypography.labelCaps),
                        const SizedBox(height: AppDimens.spaceXs / 2),
                        Text(
                          FinanceCalculator.formatRupiah(summary.netCashFlow),
                          style: AppTypography.amountRow.copyWith(color: netColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
