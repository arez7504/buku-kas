import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

// Header layar Rincian Pengeluaran: tombol kembali, judul editorial, dan navigasi bulan
class ExpenseBreakdownHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onBack;

  const ExpenseBreakdownHeader({
    super.key,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bar atas: Tombol kembali dan judul editorial
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceSm,
          ),
          color: AppColors.surface,
          child: Row(
            children: [
              IconButton(
                key: const Key('expense_breakdown_back_button'),
                icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
                onPressed: onBack,
                tooltip: 'Kembali',
              ),
              const SizedBox(width: AppDimens.spaceSm),
              const Text('Rincian Pengeluaran', style: AppTypography.headlineSmItalic),
            ],
          ),
        ),

        // Bar pemilih bulan (panah kiri, bulan & tahun, panah kanan)
        Container(
          width: double.infinity,
          color: AppColors.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('expense_breakdown_prev_month'),
                icon: const Icon(Icons.chevron_left, size: AppDimens.iconMedium),
                onPressed: onPreviousMonth,
                tooltip: 'Bulan sebelumnya',
              ),
              Column(
                children: [
                  Text(
                    FinanceCalculator.formatMonthYear(selectedMonth),
                    style: AppTypography.headlineSmItalic,
                  ),
                  const SizedBox(height: AppDimens.spaceXs / 2),
                  const Text('DISTRIBUSI PENGELUARAN', style: AppTypography.labelCaps),
                ],
              ),
              IconButton(
                key: const Key('expense_breakdown_next_month'),
                icon: const Icon(Icons.chevron_right, size: AppDimens.iconMedium),
                onPressed: onNextMonth,
                tooltip: 'Bulan berikutnya',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
