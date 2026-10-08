import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Pesan kondisi kosong yang jelas jika tidak ada transaksi pengeluaran pada bulan terpilih
class ExpenseBreakdownEmpty extends StatelessWidget {
  const ExpenseBreakdownEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.spaceXl,
        horizontal: AppDimens.margin,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.pie_chart_outline,
              size: AppDimens.iconLarge * 1.5,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: AppDimens.spaceSm),
            Text(
              'Tidak ada pengeluaran di bulan ini',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimens.spaceXs),
            Text(
              'Belum ada transaksi pengeluaran tercatat pada periode ini.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
