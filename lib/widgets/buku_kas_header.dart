import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

/// Header layar Buku Kas: ikon dompet, judul tunggal "Buku Kas", pemilih bulan berbentuk pil, dan tombol pengaturan
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

  Widget _buildWalletTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.walletIconHeader,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            size: AppDimens.iconSmall,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimens.spaceSm),
        const Text(
          'Buku Kas',
          style: AppTypography.headerTitle,
        ),
      ],
    );
  }

  Widget _buildMonthPill() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
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
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceXs),
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

  Widget _buildSettingsButton() {
    return InkWell(
      key: const Key('settings_button'),
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      onTap: onSettings,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(color: AppColors.borderSubtle),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.settings_outlined,
          size: AppDimens.iconSmall,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWalletTitle(),
              _buildSettingsButton(),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),
          Center(
            child: _buildMonthPill(),
          ),
        ],
      ),
    );
  }
}
