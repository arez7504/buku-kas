import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';

// Kartu Saldo Dompet: Kotak terpisah per dompet yang bisa digeser horizontal
class BukuKasWalletBar extends StatelessWidget {
  final List<Wallet> wallets;
  final Map<String, int> walletBalances;

  const BukuKasWalletBar({
    super.key,
    required this.wallets,
    required this.walletBalances,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm,
      ),
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: AppDimens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header kartu Saldo Dompet
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: AppDimens.iconMedium,
                color: AppColors.secondary,
              ),
              SizedBox(width: AppDimens.spaceSm),
              Text(
                'Saldo Dompet',
                style: AppTypography.cardSectionTitle,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),
          const Divider(
            height: AppDimens.borderWidthThin,
            thickness: AppDimens.borderWidthThin,
            color: AppColors.surfaceContainerHigh,
          ),
          const SizedBox(height: AppDimens.spaceSm),

          // Kotak-kotak saldo tiap dompet yang dapat digeser horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final wallet in wallets) ...[
                  Container(
                    margin: const EdgeInsets.only(right: AppDimens.spaceSm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.walletBoxPaddingH,
                      vertical: AppDimens.walletBoxPaddingV,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: AppDimens.borderWidthThin,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wallet.name,
                          style: AppTypography.walletBoxName,
                        ),
                        const SizedBox(height: AppDimens.spaceXs),
                        Text(
                          FinanceCalculator.formatRupiah(
                            walletBalances[wallet.id] ?? wallet.initialBalance,
                          ),
                          style: AppTypography.walletBoxBalance,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
