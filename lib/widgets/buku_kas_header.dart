import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Header layar Buku Kas: ikon dompet bulat bertint gradasi dan judul "Buku Kas" (Milestone NAV-2)
class BukuKasHeader extends StatelessWidget {
  final DateTime? selectedMonth;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onSettings;

  const BukuKasHeader({
    super.key,
    this.selectedMonth,
    this.onPreviousMonth,
    this.onNextMonth,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWalletTitle(),
        ],
      ),
    );
  }
}
