import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'wallet_card_style.dart';

/// Informasi gaya visual ikon dan tint untuk kartu dompet berdasarkan nama
class WalletIconMappingInfo {
  final IconData icon;
  final LinearGradient gradient;
  final Color borderColor;
  final Color iconColor;
  final List<BoxShadow> shadow;

  const WalletIconMappingInfo({
    required this.icon,
    required this.gradient,
    required this.borderColor,
    required this.iconColor,
    required this.shadow,
  });
}

/// Pemetaan nama dompet ke ikon Material dan tint sesuai desain Kelola Dompet UI-5
class AppWalletIconMapping {
  static WalletIconMappingInfo getMapping(String walletName, {int index = 0}) {
    final normalized = walletName.trim().toLowerCase();

    // 1. Kata kunci Bank
    if (_isBank(normalized)) {
      final style = AppWalletStyles.palette[1]; // Cyan tint
      return WalletIconMappingInfo(
        icon: Icons.account_balance,
        gradient: AppGradients.walletBankIcon,
        borderColor: style.borderColor,
        iconColor: style.accentColor,
        shadow: AppShadows.walletIconBank,
      );
    }

    // 2. Kata kunci Tunai / Kas / Dompet Fisik
    if (_isCash(normalized)) {
      final style = AppWalletStyles.palette[3]; // Orange/Amber tint
      return WalletIconMappingInfo(
        icon: Icons.payments,
        gradient: AppGradients.walletCashIcon,
        borderColor: style.borderColor,
        iconColor: style.accentColor,
        shadow: AppShadows.walletIconCash,
      );
    }

    // 3. Kata kunci E-Wallet / Dompet Digital
    if (_isEWallet(normalized)) {
      final style = AppWalletStyles.palette[0]; // Purple tint
      return WalletIconMappingInfo(
        icon: Icons.account_balance_wallet,
        gradient: AppGradients.walletEWalletIcon,
        borderColor: style.borderColor,
        iconColor: style.accentColor,
        shadow: AppShadows.walletIconEWallet,
      );
    }

    // 4. Fallback umum dompet
    final style = AppWalletStyles.getStyleForIndex(index);
    return WalletIconMappingInfo(
      icon: Icons.account_balance_wallet,
      gradient: AppGradients.walletGeneralIcon,
      borderColor: style.borderColor,
      iconColor: style.accentColor,
      shadow: AppShadows.walletIconGeneral,
    );
  }

  static bool _isBank(String name) {
    return name.contains('bank') ||
        name.contains('bca') ||
        name.contains('mandiri') ||
        name.contains('bni') ||
        name.contains('bri') ||
        name.contains('cimb') ||
        name.contains('seabank') ||
        name.contains('sea bank') ||
        name.contains('jago') ||
        name.contains('jenius') ||
        name.contains('permata') ||
        name.contains('bsi') ||
        name.contains('danamon') ||
        name.contains('tabungan') ||
        name.contains('rekening') ||
        name.contains('atm');
  }

  static bool _isCash(String name) {
    return name.contains('tunai') ||
        name.contains('cash') ||
        name.contains('dompet fisik') ||
        name.contains('kas') ||
        name.contains('saku') ||
        name.contains('uang');
  }

  static bool _isEWallet(String name) {
    return name.contains('e-wallet') ||
        name.contains('ewallet') ||
        name.contains('gopay') ||
        name.contains('go-pay') ||
        name.contains('ovo') ||
        name.contains('dana') ||
        name.contains('shopeepay') ||
        name.contains('shopee pay') ||
        name.contains('linkaja') ||
        name.contains('link aja') ||
        name.contains('qris') ||
        name.contains('sakuku') ||
        name.contains('i.saku') ||
        name.contains('doku');
  }
}
