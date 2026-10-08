import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

// Hero bagian atas layar Rincian Pengeluaran: menampilkan total pengeluaran sebagai angka besar
class ExpenseBreakdownHero extends StatelessWidget {
  final int totalExpense;
  final int categoryCount;

  const ExpenseBreakdownHero({
    super.key,
    required this.totalExpense,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL PENGELUARAN', style: AppTypography.labelCaps),
          const SizedBox(height: AppDimens.spaceXs),
          Text(
            FinanceCalculator.formatRupiah(totalExpense),
            style: AppTypography.headlineHeroMobile,
          ),
          const SizedBox(height: AppDimens.spaceXs),
          Text(
            totalExpense > 0
                ? '$categoryCount KATEGORI PENGELUARAN'
                : 'TIDAK ADA TRANSAKSI',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
