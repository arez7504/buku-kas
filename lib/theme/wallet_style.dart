import 'package:flutter/material.dart';
import '../models/wallet.dart';
import 'category_style.dart';
import 'wallet_icon_mapping.dart';

/// Registry terpusat ikon dan warna dompet sesuai Milestone UI-8.
/// Memakai ulang palet 12 warna dari UI-7 tanpa duplikasi dan menyediakan
/// pemetaan tetap 3 ikon Material Icons dengan kunci teks stabil.
class WalletStyleRegistry {
  /// Tepat 3 ikon Material Icons sebagai const IconData dalam static map
  static const Map<String, IconData> icons = {
    'uang': Icons.payments,
    'dompet': Icons.account_balance_wallet,
    'bank': Icons.account_balance,
  };

  /// Palet 12 warna yang dipakai ulang langsung dari CategoryStyleRegistry
  static const Map<String, CategoryColorItem> colors = CategoryStyleRegistry.colors;

  /// Memetakan kata kunci nama dompet ke kunci iconKey dan colorKey default
  static ({String iconKey, String colorKey})? getDefaultKeysForName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final n = name.trim().toLowerCase();
    if (n.contains('bank') ||
        n.contains('bca') ||
        n.contains('mandiri') ||
        n.contains('bni') ||
        n.contains('bri') ||
        n.contains('cimb') ||
        n.contains('seabank') ||
        n.contains('sea bank') ||
        n.contains('jago') ||
        n.contains('jenius') ||
        n.contains('permata') ||
        n.contains('bsi') ||
        n.contains('danamon') ||
        n.contains('tabungan') ||
        n.contains('rekening') ||
        n.contains('atm')) {
      return (iconKey: 'bank', colorKey: 'cyan');
    }
    if (n.contains('tunai') ||
        n.contains('cash') ||
        n.contains('kas') ||
        n.contains('uang') ||
        n.contains('saku') ||
        n.contains('dompet fisik')) {
      return (iconKey: 'uang', colorKey: 'amber');
    }
    if (n.contains('e-wallet') ||
        n.contains('ewallet') ||
        n.contains('gopay') ||
        n.contains('go-pay') ||
        n.contains('ovo') ||
        n.contains('dana') ||
        n.contains('shopeepay') ||
        n.contains('shopee pay') ||
        n.contains('linkaja') ||
        n.contains('link aja') ||
        n.contains('qris') ||
        n.contains('sakuku') ||
        n.contains('i.saku') ||
        n.contains('doku')) {
      return (iconKey: 'dompet', colorKey: 'violet');
    }
    return null;
  }

  /// Satu fungsi resolusi gaya dompet:
  /// Menghasilkan [WalletIconMappingInfo] (icon, gradient, border, iconColor, shadow).
  /// Aturan:
  /// 1. Jika iconKey valid di registry, pakai ikon tersebut.
  /// 2. Jika colorKey valid di registry, pakai warna gradasi/border/tint tersebut.
  /// 3. Untuk nilai yang null atau tidak dikenal, fallback ke AppWalletIconMapping.getMapping.
  static WalletIconMappingInfo resolveWalletStyle({
    Wallet? wallet,
    String? walletName,
    String? iconKey,
    String? colorKey,
    int index = 0,
  }) {
    final effectiveName = walletName ?? wallet?.name ?? '';
    final effectiveIconKey = iconKey ?? wallet?.iconKey;
    final effectiveColorKey = colorKey ?? wallet?.colorKey;

    final fallback = AppWalletIconMapping.getMapping(effectiveName, index: index);

    // Resolusi Ikon
    final IconData resolvedIcon;
    if (effectiveIconKey != null && icons.containsKey(effectiveIconKey)) {
      resolvedIcon = icons[effectiveIconKey]!;
    } else {
      resolvedIcon = fallback.icon;
    }

    // Resolusi Warna
    final LinearGradient resolvedGradient;
    final Color resolvedBorder;
    final Color resolvedIconColor;
    final List<BoxShadow> resolvedShadow;

    if (effectiveColorKey != null && colors.containsKey(effectiveColorKey)) {
      final colorItem = colors[effectiveColorKey]!;
      resolvedGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorItem.gradient[0].withValues(alpha: 0.25),
          colorItem.gradient[1].withValues(alpha: 0.10),
        ],
      );
      resolvedBorder = colorItem.borderTint;
      resolvedIconColor = colorItem.iconColor;
      resolvedShadow = [
        BoxShadow(
          color: colorItem.iconColor.withValues(alpha: 0.20),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      resolvedGradient = fallback.gradient;
      resolvedBorder = fallback.borderColor;
      resolvedIconColor = fallback.iconColor;
      resolvedShadow = fallback.shadow;
    }

    return WalletIconMappingInfo(
      icon: resolvedIcon,
      gradient: resolvedGradient,
      borderColor: resolvedBorder,
      iconColor: resolvedIconColor,
      shadow: resolvedShadow,
    );
  }
}
