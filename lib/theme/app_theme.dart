import 'package:flutter/material.dart';

// Definisi warna sesuai design/catat.html dan design/catat.png
class AppColors {
  static const Color surface = Color(0xFFFAF9F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F0);
  static const Color surfaceContainer = Color(0xFFEFEEEB);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E5);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);

  static const Color primary = Color(0xFF07080A);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFA13F23); // Terracotta
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF45474A);

  static const Color outline = Color(0xFF76777B);
  static const Color outlineVariant = Color(0xFFC6C6CA);

  static const Color error = Color(0xFFBA1A1A);
  static const Color incomeGreen = Color(0xFF2E7D32);
  static const Color expenseRed = Color(0xFFC62828);

  static const Color transparent = Colors.transparent;
}

// Nama font lokal yang telah didaftarkan di pubspec.yaml
class AppFonts {
  static const String newsreader = 'Newsreader';
  static const String hankenGrotesk = 'HankenGrotesk';
}

// Tipografi terpusat sesuai design/catat.html
class AppTypography {
  static const TextStyle headlineHeroMobile = TextStyle(
    fontFamily: AppFonts.newsreader,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.9,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: AppFonts.newsreader,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    color: AppColors.onSurface,
  );

  static const TextStyle amountPrefix = TextStyle(
    fontFamily: AppFonts.newsreader,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.88,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle labelMdActive = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
  );

  static const TextStyle labelMdInactive = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLgButton = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onSecondary,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle keypadDigit = TextStyle(
    fontFamily: AppFonts.newsreader,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle keypadZeros = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSmItalic = TextStyle(
    fontFamily: AppFonts.newsreader,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.2,
    color: AppColors.onSurface,
  );

  static const TextStyle amountRow = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.17,
    color: AppColors.onSurface,
  );

  static const TextStyle amountRowGreen = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.17,
    color: AppColors.incomeGreen,
  );

  static const TextStyle amountRowRed = TextStyle(
    fontFamily: AppFonts.hankenGrotesk,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.17,
    color: AppColors.expenseRed,
  );

  static const TextStyle hiddenTestHelper = TextStyle(
    fontSize: 1,
    color: AppColors.surface,
  );
}

// Ukuran, margin, padding, radius, dan dimensi terpusat
class AppDimens {
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 40.0;
  static const double margin = 20.0;

  static const double radiusDefault = 4.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radiusFull = 9999.0;

  static const double borderWidthThin = 1.0;
  static const double borderWidthIndicator = 2.0;
  static const double caretWidth = 2.0;
  static const double caretHeight = 32.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;

  static const double keypadKeyHeight = 48.0;
  static const double keypadSpacing = 6.0;
  static const double submitButtonHeight = 48.0;
  static const double appBarHeight = 56.0;
  static const double bottomListPadding = 88.0;
}

// Konfigurasi ThemeData global
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
      ),
      fontFamily: AppFonts.hankenGrotesk,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
    );
  }
}
