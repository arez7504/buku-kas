import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'app_theme.dart';
import 'category_style.dart';

/// Gaya visual kotak ikon kategori (ikon, latar belakang tint, garis tepi, warna ikon)
class CategoryIconStyle {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const CategoryIconStyle({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });
}

/// Pemetaan nama kategori bawaan ke ikon Material dan palet warna tint dari HTML
class AppCategoryIcons {
  /// Resolusi terpadu ikon dan warna kategori sesuai Milestone UI-7
  static CategoryIconStyle resolve({
    Category? category,
    String? categoryName,
    String? iconKey,
    String? colorKey,
    TransactionType? type,
  }) =>
      CategoryStyleRegistry.resolveCategoryStyle(
        category: category,
        categoryName: categoryName,
        iconKey: iconKey,
        colorKey: colorKey,
        transactionType: type,
      );

  static CategoryIconStyle getStyle(String? categoryName, {TransactionType? type}) {
    if (type == TransactionType.transfer) {
      return const CategoryIconStyle(
        icon: Icons.swap_horiz,
        backgroundColor: AppColors.tintIndigoBg,
        borderColor: AppColors.tintIndigoBorder,
        iconColor: AppColors.tintIndigoText,
      );
    }

    final normalized = (categoryName ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'makanan':
      case 'makan & minum':
        return const CategoryIconStyle(
          icon: Icons.restaurant,
          backgroundColor: AppColors.tintPurpleBg,
          borderColor: AppColors.tintPurpleBorder,
          iconColor: AppColors.tintPurpleText,
        );
      case 'transportasi':
      case 'transport':
        return const CategoryIconStyle(
          icon: Icons.directions_car,
          backgroundColor: AppColors.tintCyanBg,
          borderColor: AppColors.tintCyanBorder,
          iconColor: AppColors.tintCyanText,
        );
      case 'tagihan':
        return const CategoryIconStyle(
          icon: Icons.bolt,
          backgroundColor: AppColors.tintYellowBg,
          borderColor: AppColors.tintYellowBorder,
          iconColor: AppColors.tintYellowText,
        );
      case 'belanja':
        return const CategoryIconStyle(
          icon: Icons.shopping_bag,
          backgroundColor: AppColors.tintOrangeBg,
          borderColor: AppColors.tintOrangeBorder,
          iconColor: AppColors.tintOrangeText,
        );
      case 'hiburan':
        return const CategoryIconStyle(
          icon: Icons.sports_esports,
          backgroundColor: AppColors.tintPinkBg,
          borderColor: AppColors.tintPinkBorder,
          iconColor: AppColors.tintPinkText,
        );
      case 'kesehatan':
        return const CategoryIconStyle(
          icon: Icons.medical_services,
          backgroundColor: AppColors.tintEmeraldBg,
          borderColor: AppColors.tintEmeraldBorder,
          iconColor: AppColors.tintEmeraldText,
        );
      case 'gaji':
        return const CategoryIconStyle(
          icon: Icons.payments,
          backgroundColor: AppColors.tintNeonGreenBg,
          borderColor: AppColors.tintNeonGreenBorder,
          iconColor: AppColors.tintNeonGreenText,
        );
      case 'lainnya':
        return const CategoryIconStyle(
          icon: Icons.category,
          backgroundColor: AppColors.tintSlateBg,
          borderColor: AppColors.tintSlateBorder,
          iconColor: AppColors.tintSlateText,
        );
      default:
        // Kategori kustom buatan pengguna memakai ikon umum dengan tint netral
        return const CategoryIconStyle(
          icon: Icons.label_outline,
          backgroundColor: AppColors.tintNeutralBg,
          borderColor: AppColors.tintNeutralBorder,
          iconColor: AppColors.tintNeutralText,
        );
    }
  }
}
