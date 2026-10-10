import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Gaya visual kartu dompet pada deretan horizontal AKUN & DOMPET
class WalletCardStyle {
  final LinearGradient gradient;
  final Color borderColor;
  final Color accentColor;
  final IconData icon;

  const WalletCardStyle({
    required this.gradient,
    required this.borderColor,
    required this.accentColor,
    required this.icon,
  });
}

/// Palet tint kartu dompet bergilir sesuai dengan desain HTML
class AppWalletStyles {
  static const List<WalletCardStyle> palette = [
    WalletCardStyle(
      gradient: AppGradients.walletCardPurple,
      borderColor: AppColors.walletBorderPurple,
      accentColor: AppColors.walletAccentPurple,
      icon: Icons.account_balance,
    ),
    WalletCardStyle(
      gradient: AppGradients.walletCardCyan,
      borderColor: AppColors.walletBorderCyan,
      accentColor: AppColors.walletAccentCyan,
      icon: Icons.payments,
    ),
    WalletCardStyle(
      gradient: AppGradients.walletCardPink,
      borderColor: AppColors.walletBorderPink,
      accentColor: AppColors.walletAccentPink,
      icon: Icons.account_balance_wallet,
    ),
    WalletCardStyle(
      gradient: AppGradients.walletCardOrange,
      borderColor: AppColors.walletBorderOrange,
      accentColor: AppColors.walletAccentOrange,
      icon: Icons.credit_card,
    ),
    WalletCardStyle(
      gradient: AppGradients.walletCardGreen,
      borderColor: AppColors.walletBorderGreen,
      accentColor: AppColors.walletAccentGreen,
      icon: Icons.savings,
    ),
  ];

  static WalletCardStyle getStyleForIndex(int index) {
    return palette[index % palette.length];
  }
}
