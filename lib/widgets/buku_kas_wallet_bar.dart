import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';
import '../theme/wallet_card_style.dart';
import '../theme/wallet_style.dart';

/// Seksi AKUN & DOMPET: jumlah dompet aktif dan kartu dompet horizontal dengan palet tint bergilir
class BukuKasWalletBar extends StatelessWidget {
  final List<Wallet> wallets;
  final Map<String, int> walletBalances;

  const BukuKasWalletBar({
    super.key,
    required this.wallets,
    required this.walletBalances,
  });

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceXs + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'AKUN & DOMPET',
            style: AppTypography.heroLabel,
          ),
          Text(
            '${wallets.length} Akun Aktif',
            style: AppTypography.labelSmLink,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(Wallet wallet, int index) {
    final resolved = WalletStyleRegistry.resolveWalletStyle(wallet: wallet, index: index);
    final fallbackStyle = AppWalletStyles.getStyleForIndex(index);
    final balance = walletBalances[wallet.id] ?? wallet.initialBalance;

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: AppDimens.spaceSm + 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.walletBoxPaddingH,
        vertical: AppDimens.walletBoxPaddingV,
      ),
      decoration: BoxDecoration(
        gradient: fallbackStyle.gradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: resolved.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                resolved.icon,
                size: AppDimens.iconSmall,
                color: resolved.iconColor,
              ),
              const SizedBox(width: AppDimens.spaceXs),
              Expanded(
                child: Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.walletCardName.copyWith(
                    color: resolved.iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                FinanceCalculator.formatRupiah(balance),
                maxLines: 1,
                style: AppTypography.walletCardBalance,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppDimens.spaceXs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.margin),
          child: Row(
            children: [
              for (int i = 0; i < wallets.length; i++)
                _buildWalletCard(wallets[i], i),
            ],
          ),
        ),
      ],
    );
  }
}
