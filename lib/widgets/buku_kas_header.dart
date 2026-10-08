import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

// Header layar Buku Kas: Judul layar 'Catatan Keuangan' dan navigasi bulan
class BukuKasHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback? onSettings;

  const BukuKasHeader({
    super.key,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bar atas: Judul layar 'Catatan Keuangan' dan ikon gerigi Pengaturan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceSm,
          ),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: AppDimens.submitButtonHeight),
              const Text('Catatan Keuangan', style: AppTypography.screenTitleSerif),
              IconButton(
                key: const Key('settings_button'),
                icon: const Icon(Icons.settings, size: AppDimens.iconMedium),
                onPressed: onSettings,
                tooltip: 'Pengaturan',
              ),
            ],
          ),
        ),

        // Bar pemilih bulan (panah kiri, bulan & tahun sans-serif, panah kanan)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceXs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: AppDimens.iconMedium),
                onPressed: onPreviousMonth,
                tooltip: 'Bulan sebelumnya',
              ),
              Text(
                FinanceCalculator.formatMonthYear(selectedMonth),
                style: AppTypography.monthSelectorText,
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
