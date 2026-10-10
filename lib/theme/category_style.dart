import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'app_theme.dart';
import 'category_icon_mapping.dart';

/// Model token warna kategori dengan pasangan gradasi untuk pemilih dan tint tampilan
class CategoryColorItem {
  final String key;
  final String label;
  final List<Color> gradient;
  final Color bgTint;
  final Color borderTint;
  final Color iconColor;

  const CategoryColorItem({
    required this.key,
    required this.label,
    required this.gradient,
    required this.bgTint,
    required this.borderTint,
    required this.iconColor,
  });
}

/// Registry terpusat ikon dan warna kategori sesuai Milestone UI-7
class CategoryStyleRegistry {
  /// Daftar tetap ~40 ikon Material Icons dengan kunci teks stabil.
  /// Semua IconData ditulis sebagai const untuk memastikan icon tree-shaking Flutter bersih.
  static const Map<String, IconData> icons = {
    'makan': Icons.restaurant,
    'kafe': Icons.local_cafe,
    'mobil': Icons.directions_car,
    'motor': Icons.two_wheeler,
    'pesawat': Icons.flight,
    'kereta': Icons.train,
    'bus': Icons.directions_bus,
    'belanja': Icons.shopping_bag,
    'keranjang': Icons.shopping_cart,
    'bensin': Icons.local_gas_station,
    'tagihan': Icons.receipt_long,
    'listrik': Icons.bolt,
    'internet': Icons.wifi,
    'air': Icons.water_drop,
    'pulsa': Icons.phone_android,
    'pendidikan': Icons.school,
    'buku': Icons.menu_book,
    'kesehatan': Icons.medical_services,
    'obat': Icons.medication,
    'olahraga': Icons.fitness_center,
    'bola': Icons.sports_soccer,
    'hiburan': Icons.sports_esports,
    'film': Icons.movie,
    'musik': Icons.music_note,
    'hewan': Icons.pets,
    'rumah': Icons.home,
    'hadiah': Icons.card_giftcard,
    'gaji': Icons.payments,
    'investasi': Icons.trending_up,
    'tabungan': Icons.savings,
    'kerja': Icons.work,
    'toko': Icons.storefront,
    'keluarga': Icons.family_restroom,
    'anak': Icons.child_care,
    'pakaian': Icons.checkroom,
    'kecantikan': Icons.spa,
    'gadget': Icons.devices,
    'pajak': Icons.account_balance,
    'donasi': Icons.volunteer_activism,
    'koper': Icons.luggage,
    'kategori': Icons.category,
  };

  /// Palet tetap 12 warna bergradasi dengan kunci teks stabil
  static const Map<String, CategoryColorItem> colors = {
    'violet': CategoryColorItem(
      key: 'violet',
      label: 'Violet',
      gradient: [AppColors.catVioletGradStart, AppColors.catVioletGradEnd],
      bgTint: AppColors.catVioletBg,
      borderTint: AppColors.catVioletBorder,
      iconColor: AppColors.catVioletIcon,
    ),
    'cyan': CategoryColorItem(
      key: 'cyan',
      label: 'Cyan',
      gradient: [AppColors.catCyanGradStart, AppColors.catCyanGradEnd],
      bgTint: AppColors.catCyanBg,
      borderTint: AppColors.catCyanBorder,
      iconColor: AppColors.catCyanIcon,
    ),
    'emerald': CategoryColorItem(
      key: 'emerald',
      label: 'Emerald',
      gradient: [AppColors.catEmeraldGradStart, AppColors.catEmeraldGradEnd],
      bgTint: AppColors.catEmeraldBg,
      borderTint: AppColors.catEmeraldBorder,
      iconColor: AppColors.catEmeraldIcon,
    ),
    'amber': CategoryColorItem(
      key: 'amber',
      label: 'Amber',
      gradient: [AppColors.catAmberGradStart, AppColors.catAmberGradEnd],
      bgTint: AppColors.catAmberBg,
      borderTint: AppColors.catAmberBorder,
      iconColor: AppColors.catAmberIcon,
    ),
    'rose': CategoryColorItem(
      key: 'rose',
      label: 'Rose',
      gradient: [AppColors.catRoseGradStart, AppColors.catRoseGradEnd],
      bgTint: AppColors.catRoseBg,
      borderTint: AppColors.catRoseBorder,
      iconColor: AppColors.catRoseIcon,
    ),
    'blue': CategoryColorItem(
      key: 'blue',
      label: 'Blue',
      gradient: [AppColors.catBlueGradStart, AppColors.catBlueGradEnd],
      bgTint: AppColors.catBlueBg,
      borderTint: AppColors.catBlueBorder,
      iconColor: AppColors.catBlueIcon,
    ),
    'orange': CategoryColorItem(
      key: 'orange',
      label: 'Orange',
      gradient: [AppColors.catOrangeGradStart, AppColors.catOrangeGradEnd],
      bgTint: AppColors.catOrangeBg,
      borderTint: AppColors.catOrangeBorder,
      iconColor: AppColors.catOrangeIcon,
    ),
    'pink': CategoryColorItem(
      key: 'pink',
      label: 'Pink',
      gradient: [AppColors.catPinkGradStart, AppColors.catPinkGradEnd],
      bgTint: AppColors.catPinkBg,
      borderTint: AppColors.catPinkBorder,
      iconColor: AppColors.catPinkIcon,
    ),
    'indigo': CategoryColorItem(
      key: 'indigo',
      label: 'Indigo',
      gradient: [AppColors.catIndigoGradStart, AppColors.catIndigoGradEnd],
      bgTint: AppColors.catIndigoBg,
      borderTint: AppColors.catIndigoBorder,
      iconColor: AppColors.catIndigoIcon,
    ),
    'teal': CategoryColorItem(
      key: 'teal',
      label: 'Teal',
      gradient: [AppColors.catTealGradStart, AppColors.catTealGradEnd],
      bgTint: AppColors.catTealBg,
      borderTint: AppColors.catTealBorder,
      iconColor: AppColors.catTealIcon,
    ),
    'lime': CategoryColorItem(
      key: 'lime',
      label: 'Lime',
      gradient: [AppColors.catLimeGradStart, AppColors.catLimeGradEnd],
      bgTint: AppColors.catLimeBg,
      borderTint: AppColors.catLimeBorder,
      iconColor: AppColors.catLimeIcon,
    ),
    'slate': CategoryColorItem(
      key: 'slate',
      label: 'Slate',
      gradient: [AppColors.catSlateGradStart, AppColors.catSlateGradEnd],
      bgTint: AppColors.catSlateBg,
      borderTint: AppColors.catSlateBorder,
      iconColor: AppColors.catSlateIcon,
    ),
  };

  /// Memetakan nama default ke kunci iconKey dan colorKey bawaan
  static ({String iconKey, String colorKey})? getDefaultKeysForName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final n = name.trim().toLowerCase();
    switch (n) {
      case 'makanan':
      case 'makan & minum':
        return (iconKey: 'makan', colorKey: 'violet');
      case 'transportasi':
      case 'transport':
        return (iconKey: 'mobil', colorKey: 'cyan');
      case 'tagihan':
        return (iconKey: 'listrik', colorKey: 'amber');
      case 'belanja':
        return (iconKey: 'belanja', colorKey: 'orange');
      case 'hiburan':
        return (iconKey: 'hiburan', colorKey: 'pink');
      case 'kesehatan':
        return (iconKey: 'kesehatan', colorKey: 'emerald');
      case 'gaji':
        return (iconKey: 'gaji', colorKey: 'lime');
      case 'lainnya':
        return (iconKey: 'kategori', colorKey: 'slate');
      default:
        return null;
    }
  }

  /// Satu fungsi resolusi tunggal:
  /// Menghasilkan [CategoryIconStyle] dari sebuah [Category] atau parameter opsionalnya.
  /// Aturan:
  /// 1. Jika tipe transaksi adalah transfer, kembalikan gaya transfer standar.
  /// 2. Jika iconKey/colorKey terisi dan dikenal, pakai nilai tersebut.
  /// 3. Jika kosong atau tidak dikenal, fallback ke pemetaan berdasarkan nama (category_icon_mapping.dart).
  static CategoryIconStyle resolveCategoryStyle({
    Category? category,
    String? categoryName,
    String? iconKey,
    String? colorKey,
    TransactionType? transactionType,
  }) {
    if (transactionType == TransactionType.transfer) {
      return const CategoryIconStyle(
        icon: Icons.swap_horiz,
        backgroundColor: AppColors.tintIndigoBg,
        borderColor: AppColors.tintIndigoBorder,
        iconColor: AppColors.tintIndigoText,
      );
    }

    final effectiveName = categoryName ?? category?.name;
    final effectiveIconKey = iconKey ?? category?.iconKey;
    final effectiveColorKey = colorKey ?? category?.colorKey;

    final fallback = AppCategoryIcons.getStyle(effectiveName);

    // Resolusi Ikon
    final IconData resolvedIcon;
    if (effectiveIconKey != null && icons.containsKey(effectiveIconKey)) {
      resolvedIcon = icons[effectiveIconKey]!;
    } else {
      resolvedIcon = fallback.icon;
    }

    // Resolusi Warna (latar, bingkai, warna ikon)
    final Color resolvedBg;
    final Color resolvedBorder;
    final Color resolvedIconColor;
    if (effectiveColorKey != null && colors.containsKey(effectiveColorKey)) {
      final colorItem = colors[effectiveColorKey]!;
      resolvedBg = colorItem.bgTint;
      resolvedBorder = colorItem.borderTint;
      resolvedIconColor = colorItem.iconColor;
    } else {
      resolvedBg = fallback.backgroundColor;
      resolvedBorder = fallback.borderColor;
      resolvedIconColor = fallback.iconColor;
    }

    return CategoryIconStyle(
      icon: resolvedIcon,
      backgroundColor: resolvedBg,
      borderColor: resolvedBorder,
      iconColor: resolvedIconColor,
    );
  }
}
