import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';

// Baris pembagian saldo semua dompet (BCA, Tunai, E-Wallet) sesuai design/buku_kas.html
class BukuKasWalletBar extends StatelessWidget {
  final List<Wallet> wallets;
  final Map<String, int> walletBalances;

  const BukuKasWalletBar({
    super.key,
    required this.wallets,
    required this.walletBalances,
  });

  IconData _getWalletIcon(String walletId) {
    switch (walletId.toLowerCase()) {
      case 'bca':
        return Icons.account_balance;
      case 'tunai':
        return Icons.payments;
      case 'ewallet':
        return Icons.wallet;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainer,
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.margin),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd,
        vertical: AppDimens.spaceSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < wallets.length; i++) ...[
              if (i > 0)
                Container(
                  height: AppDimens.spaceMd - AppDimens.spaceXs,
                  width: AppDimens.borderWidthThin,
                  color: AppColors.outlineVariant,
                  margin: const EdgeInsets.symmetric(horizontal: AppDimens.spaceSm),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getWalletIcon(wallets[i].id),
                    size: AppDimens.iconSmall,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimens.spaceXs),
                  Text(
                    wallets[i].name,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppDimens.spaceXs),
                  Text(
                    FinanceCalculator.formatRupiah(
                      walletBalances[wallets[i].id] ?? wallets[i].initialBalance,
                    ),
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
