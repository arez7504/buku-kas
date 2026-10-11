import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

/// Bagian Bulan (Milestone NAV-2):
/// Pemilih bulan, dua kartu berdampingan Pemasukan & Pengeluaran, baris Selisih,
/// dan tautan "Lihat rincian pengeluaran".
class BukuKasMonthSection extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final MonthlySummary summary;
  final VoidCallback? onViewDetails;

  const BukuKasMonthSection({
    super.key,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.summary,
    this.onViewDetails,
  });

  Widget _buildMonthPill() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            onTap: onPreviousMonth,
            child: const Padding(
              padding: EdgeInsets.all(AppDimens.spaceXs),
              child: Icon(
                Icons.chevron_left,
                size: AppDimens.iconSmall,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceSm),
            child: Text(
              FinanceCalculator.formatMonthYear(selectedMonth),
              style: AppTypography.monthPicker,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            onTap: onNextMonth,
            child: const Padding(
              padding: EdgeInsets.all(AppDimens.spaceXs),
              child: Icon(
                Icons.chevron_right,
                size: AppDimens.iconSmall,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Expanded(
      child: Container(
        key: const Key('bulan_pemasukan'),
        padding: const EdgeInsets.all(AppDimens.spaceSm + 2),
        decoration: BoxDecoration(
          color: AppColors.monthCardBg,
          border: Border.all(color: AppColors.monthCardBorder),
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
                    style: AppTypography.monthCardLabel,
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
            const SizedBox(height: AppDimens.spaceXs),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '+ ${FinanceCalculator.formatRupiah(summary.totalIncome)}',
                  style: AppTypography.monthCardAmount.copyWith(
                    color: AppColors.incomeGreen,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard() {
    return Expanded(
      child: Container(
        key: const Key('bulan_pengeluaran'),
        padding: const EdgeInsets.all(AppDimens.spaceSm + 2),
        decoration: BoxDecoration(
          color: AppColors.monthCardBg,
          border: Border.all(color: AppColors.monthCardBorder),
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
                    'Pengeluaran',
                    style: AppTypography.monthCardLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_upward,
                  size: AppDimens.iconSmall,
                  color: AppColors.expenseRed,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceXs),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '- ${FinanceCalculator.formatRupiah(summary.totalExpense)}',
                  style: AppTypography.monthCardAmount.copyWith(
                    color: AppColors.expenseRed,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelisihRow() {
    final isNegative = summary.netCashFlow < 0;
    final selisihText = isNegative
        ? '- ${FinanceCalculator.formatRupiah(summary.netCashFlow.abs())}'
        : FinanceCalculator.formatRupiah(summary.netCashFlow);
    final selisihColor = isNegative ? AppColors.expenseRed : AppColors.selisihTeal;

    return Container(
      key: const Key('bulan_selisih'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceSm + 4,
        vertical: AppDimens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.monthSelisihBg,
        border: Border.all(color: AppColors.monthSelisihBorder),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.savings_outlined,
                size: AppDimens.iconSmall,
                color: AppColors.secondary,
              ),
              SizedBox(width: AppDimens.spaceSm),
              Text(
                'Selisih',
                style: AppTypography.monthSelisihLabel,
              ),
            ],
          ),
          const SizedBox(width: AppDimens.spaceSm),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                selisihText,
                style: AppTypography.monthSelisihAmount.copyWith(
                  color: selisihColor,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
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
        vertical: AppDimens.spaceXs,
      ),
      padding: const EdgeInsets.all(AppDimens.spaceSm + 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pemilih bulan yang jelas di bagian atas
          Center(
            child: _buildMonthPill(),
          ),
          const SizedBox(height: AppDimens.spaceSm + 2),

          // Dua kartu sejajar lebar sama: Pemasukan dan Pengeluaran
          Row(
            children: [
              _buildIncomeCard(),
              const SizedBox(width: AppDimens.spaceSm),
              _buildExpenseCard(),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),

          // Baris tipis Selisih
          _buildSelisihRow(),
          const SizedBox(height: AppDimens.spaceSm),

          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderFaint,
          ),
          const SizedBox(height: AppDimens.spaceSm),

          // Tautan lihat rincian pengeluaran
          _buildFooterLink(),
        ],
      ),
    );
  }
}
