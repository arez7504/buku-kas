import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

// Header layar Buku Kas: judul editorial dan navigasi bulan sesuai design/buku_kas.html
class BukuKasHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const BukuKasHeader({
    super.key,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bar atas: Judul editorial Buku Kas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceSm,
          ),
          color: AppColors.surface,
          alignment: Alignment.centerLeft,
          child: const Text('Buku Kas', style: AppTypography.headlineSmItalic),
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
                  const Text('BUKU UTAMA PRIBADI', style: AppTypography.labelCaps),
                ],
              ),
              IconButton(
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
