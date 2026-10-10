import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palet warna tema gelap modern fintech sesuai design/buku_kas.html
class AppColors {
  // Latar belakang dan hierarki surface
  static const Color surface = Color(0xFF0C0C14);
  static const Color background = Color(0xFF0B0B13);
  static const Color surfaceContainerLowest = Color(0xFF07070B);
  static const Color surfaceContainerLow = Color(0xFF13131E);
  static const Color surfaceContainer = Color(0xFF181826);
  static const Color surfaceContainerHigh = Color(0xFF222234);
  static const Color surfaceContainerHighest = Color(0xFF2D2D42);

  // Teks dan konten (WCAG AA kontras tinggi)
  static const Color onSurface = Color(0xFFF1F0F7);
  static const Color onSurfaceVariant = Color(0xFF9A98AA);

  // Aksen utama (Primary lavender)
  static const Color primary = Color(0xFFD0BCFF);
  static const Color onPrimary = Color(0xFF381E72);
  static const Color primaryContainer = Color(0xFF7A44F5);

  // Aksen kedua (Secondary cyan)
  static const Color secondary = Color(0xFF4CD7F6);
  static const Color onSecondary = Color(0xFF003640);
  static const Color secondaryContainer = Color(0xFF03B5D3);

  // Aksen ketiga (Tertiary peach)
  static const Color tertiary = Color(0xFFFF9E6C);

  // Warna neon fintech
  static const Color neonGreen = Color(0xFF20E396);
  static const Color neonCyan = Color(0xFF38E1FF);
  static const Color neonPurple = Color(0xFFA855F7);

  // Garis tepi dan pemisah
  static const Color outline = Color(0x33FFFFFF);
  static const Color outlineVariant = Color(0x1AFFFFFF);
  static const Color borderSubtle = Color(0x0FFFFFFF);
  static const Color borderFaint = Color(0x0AFFFFFF);

  // Status fungsional
  static const Color error = Color(0xFFF87171);
  static const Color incomeGreen = Color(0xFF20E396);
  static const Color expenseRed = Color(0xFFF87171);
  static const Color expenseRedSoft = Color(0x26F87171);
  static const Color incomeGreenSoft = Color(0x2620E396);
  static const Color transferBlue = Color(0xFF818CF8);
  static const Color transferBlueSoft = Color(0x26818CF8);
  static const Color selisihTeal = Color(0xFF4CD7F6);

  // Palet tint kategori
  static const Color tintPurpleBg = Color(0x26A855F7);
  static const Color tintPurpleBorder = Color(0x40A855F7);
  static const Color tintPurpleText = Color(0xFFD8B4FE);

  static const Color tintCyanBg = Color(0x2606B6D4);
  static const Color tintCyanBorder = Color(0x4006B6D4);
  static const Color tintCyanText = Color(0xFF67E8F9);

  static const Color tintYellowBg = Color(0x26EAB308);
  static const Color tintYellowBorder = Color(0x40EAB308);
  static const Color tintYellowText = Color(0xFFFDE047);

  static const Color tintOrangeBg = Color(0x26F97316);
  static const Color tintOrangeBorder = Color(0x40F97316);
  static const Color tintOrangeText = Color(0xFFFB923C);

  static const Color tintPinkBg = Color(0x26EC4899);
  static const Color tintPinkBorder = Color(0x40EC4899);
  static const Color tintPinkText = Color(0xFFF472B6);

  static const Color tintEmeraldBg = Color(0x2610B981);
  static const Color tintEmeraldBorder = Color(0x4010B981);
  static const Color tintEmeraldText = Color(0xFF6EE7B7);

  static const Color tintNeonGreenBg = Color(0x3320E396);
  static const Color tintNeonGreenBorder = Color(0x6620E396);
  static const Color tintNeonGreenText = Color(0xFF20E396);

  static const Color tintSlateBg = Color(0x2694A3B8);
  static const Color tintSlateBorder = Color(0x4094A3B8);
  static const Color tintSlateText = Color(0xFFCBD5E1);

  static const Color tintNeutralBg = Color(0x14FFFFFF);
  static const Color tintNeutralBorder = Color(0x26FFFFFF);
  static const Color tintNeutralText = Color(0xFF9A98AA);

  static const Color tintIndigoBg = Color(0x266366F1);
  static const Color tintIndigoBorder = Color(0x406366F1);
  static const Color tintIndigoText = Color(0xFFA5B4FC);

  // Palet kartu dompet
  static const Color walletBorderPurple = Color(0x33A855F7);
  static const Color walletAccentPurple = Color(0xFFD8B4FE);

  static const Color walletBorderCyan = Color(0x3306B6D4);
  static const Color walletAccentCyan = Color(0xFF67E8F9);

  static const Color walletBorderPink = Color(0x33EC4899);
  static const Color walletAccentPink = Color(0xFFF472B6);

  static const Color walletBorderOrange = Color(0x33F97316);
  static const Color walletAccentOrange = Color(0xFFFDBA74);

  static const Color walletBorderGreen = Color(0x3310B981);
  static const Color walletAccentGreen = Color(0xFF6EE7B7);

  // Token Catat Transaksi UI-4
  static const Color catatSourceActive = Color(0xFF2A293B);
  static const Color catatKeypadKey = Color(0xFF1D1D2B);
  static const Color catatKeypadBg = Color(0xFF14141E);
  static const Color catatDateChipBg = Color(0xCC20202E);
  static const Color catatCategoryActiveBorder = Color(0x80D0BCFF);
  static const Color catatSourceActiveBorder = Color(0x66D0BCFF);
  static const Color catatCardBorder = Color(0x14FFFFFF);
  static const Color catatDateChipBorder = Color(0x12FFFFFF);
  static const Color secondaryFixed = Color(0xFFACEDFF);

  // Token Pengaturan & Kelola Dompet UI-5
  static const Color settingsCardBg = Color(0xFF141422);
  static const Color switchTrackActive = Color(0xFF7A44F5);
  static const Color walletInitialBalance = Color(0xFFA5A3B5);
  static const Color walletCardBg = Color(0xFF141422);

  // 12 Warna Palet Kategori Milestone UI-7
  static const Color catVioletGradStart = Color(0xFFA855F7);
  static const Color catVioletGradEnd = Color(0xFF7E22CE);
  static const Color catVioletBg = Color(0x26A855F7);
  static const Color catVioletBorder = Color(0x40A855F7);
  static const Color catVioletIcon = Color(0xFFD8B4FE);

  static const Color catCyanGradStart = Color(0xFF06B6D4);
  static const Color catCyanGradEnd = Color(0xFF0E7490);
  static const Color catCyanBg = Color(0x2606B6D4);
  static const Color catCyanBorder = Color(0x4006B6D4);
  static const Color catCyanIcon = Color(0xFF67E8F9);

  static const Color catEmeraldGradStart = Color(0xFF10B981);
  static const Color catEmeraldGradEnd = Color(0xFF047857);
  static const Color catEmeraldBg = Color(0x2610B981);
  static const Color catEmeraldBorder = Color(0x4010B981);
  static const Color catEmeraldIcon = Color(0xFF6EE7B7);

  static const Color catAmberGradStart = Color(0xFFF59E0B);
  static const Color catAmberGradEnd = Color(0xFFB45309);
  static const Color catAmberBg = Color(0x26F59E0B);
  static const Color catAmberBorder = Color(0x40F59E0B);
  static const Color catAmberIcon = Color(0xFFFCD34D);

  static const Color catRoseGradStart = Color(0xFFF43F5E);
  static const Color catRoseGradEnd = Color(0xFFBE123C);
  static const Color catRoseBg = Color(0x26F43F5E);
  static const Color catRoseBorder = Color(0x40F43F5E);
  static const Color catRoseIcon = Color(0xFFFDA4AF);

  static const Color catBlueGradStart = Color(0xFF3B82F6);
  static const Color catBlueGradEnd = Color(0xFF1D4ED8);
  static const Color catBlueBg = Color(0x263B82F6);
  static const Color catBlueBorder = Color(0x403B82F6);
  static const Color catBlueIcon = Color(0xFF93C5FD);

  static const Color catOrangeGradStart = Color(0xFFF97316);
  static const Color catOrangeGradEnd = Color(0xFFC2410C);
  static const Color catOrangeBg = Color(0x26F97316);
  static const Color catOrangeBorder = Color(0x40F97316);
  static const Color catOrangeIcon = Color(0xFFFDBA74);

  static const Color catPinkGradStart = Color(0xFFEC4899);
  static const Color catPinkGradEnd = Color(0xFFBE185D);
  static const Color catPinkBg = Color(0x26EC4899);
  static const Color catPinkBorder = Color(0x40EC4899);
  static const Color catPinkIcon = Color(0xFFF472B6);

  static const Color catIndigoGradStart = Color(0xFF6366F1);
  static const Color catIndigoGradEnd = Color(0xFF4338CA);
  static const Color catIndigoBg = Color(0x266366F1);
  static const Color catIndigoBorder = Color(0x406366F1);
  static const Color catIndigoIcon = Color(0xFFA5B4FC);

  static const Color catTealGradStart = Color(0xFF14B8A6);
  static const Color catTealGradEnd = Color(0xFF0F766E);
  static const Color catTealBg = Color(0x2614B8A6);
  static const Color catTealBorder = Color(0x4014B8A6);
  static const Color catTealIcon = Color(0xFF5EEAD4);

  static const Color catLimeGradStart = Color(0xFF84CC16);
  static const Color catLimeGradEnd = Color(0xFF4D7C0F);
  static const Color catLimeBg = Color(0x2684CC16);
  static const Color catLimeBorder = Color(0x4084CC16);
  static const Color catLimeIcon = Color(0xFFBEF264);

  static const Color catSlateGradStart = Color(0xFF64748B);
  static const Color catSlateGradEnd = Color(0xFF334155);
  static const Color catSlateBg = Color(0x2664748B);
  static const Color catSlateBorder = Color(0x4064748B);
  static const Color catSlateIcon = Color(0xFFCBD5E1);

  // Kompatibilitas
  static const Color transparent = Colors.transparent;
}

/// Definisi gradasi sesuai desain HTML
class AppGradients {
  static const LinearGradient heroCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D1933),
      Color(0xFF131322),
      Color(0xFF0E0F1D),
    ],
  );

  static const LinearGradient catatButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF9333EA),
      Color(0xFF4F46E5),
      Color(0xFF06B6D4),
    ],
  );

  static const LinearGradient walletIconHeader = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0x33A855F7),
      Color(0x3306B6D4),
    ],
  );

  static const LinearGradient walletCardPurple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B1C2E), Color(0xFF121320)],
  );

  static const LinearGradient walletCardCyan = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C2229), Color(0xFF11161D)],
  );

  static const LinearGradient walletCardPink = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF251A2E), Color(0xFF16101D)],
  );

  static const LinearGradient walletCardOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF291D18), Color(0xFF18110E)],
  );

  static const LinearGradient walletCardGreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF14231B), Color(0xFF0D1611)],
  );

  // Gradasi Catat Transaksi UI-4
  static const LinearGradient catatTabActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF9B51E0),
      Color(0xFF7928CA),
      Color(0xFF2575FC),
    ],
  );

  static const LinearGradient catatAmountCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF181826),
      Color(0xFF12121E),
    ],
  );

  static const LinearGradient catatCursor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4CD7F6),
      Color(0xFFA078FF),
    ],
  );

  static const LinearGradient catatCategoryActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x4D9333EA),
      Color(0x4D06B6D4),
    ],
  );

  static const LinearGradient catatSubmitButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF9B51E0),
      Color(0xFF7928CA),
      Color(0xFF2575FC),
    ],
  );

  // Gradasi Pengaturan UI-5
  static const LinearGradient settingsWalletIcon = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFF9333EA), Color(0xFF6366F1)],
  );

  static const LinearGradient settingsCategoryIcon = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFF06B6D4), Color(0xFF2DD4BF)],
  );

  static const LinearGradient settingsSecurityIcon = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
  );

  static const LinearGradient settingsBackupIcon = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFF14B8A6), Color(0xFF34D399)],
  );

  static const LinearGradient settingsRestoreIcon = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFF7C3AED), Color(0xFFC084FC)],
  );

  // Gradasi Ikon Dompet UI-5
  static const LinearGradient walletBankIcon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x4014B8A6), Color(0x1A06B6D4)],
  );

  static const LinearGradient walletCashIcon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x40F59E0B), Color(0x1AF97316)],
  );

  static const LinearGradient walletEWalletIcon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x40A855F7), Color(0x1A7C3AED)],
  );

  static const LinearGradient walletGeneralIcon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x406366F1), Color(0x1A4F46E5)],
  );
}

/// Definisi efek bayangan (shadow / glow) sesuai desain HTML
class AppShadows {
  static const List<BoxShadow> catatTabActive = [
    BoxShadow(
      color: Color(0x66A078FF),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> catatAmountCard = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> catatKeypad = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> catatSubmitButton = [
    BoxShadow(
      color: Color(0x73A078FF),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x594CD7F6),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // Bayangan Pengaturan & Kelola Dompet UI-5
  static const List<BoxShadow> settingsCard = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> settingsIconPurple = [
    BoxShadow(
      color: Color(0x409333EA),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> settingsIconCyan = [
    BoxShadow(
      color: Color(0x4006B6D4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> settingsIconAmber = [
    BoxShadow(
      color: Color(0x40F59E0B),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> settingsIconTeal = [
    BoxShadow(
      color: Color(0x4014B8A6),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> settingsIconViolet = [
    BoxShadow(
      color: Color(0x407C3AED),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> walletIconBank = [
    BoxShadow(
      color: Color(0x334CD7F6),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> walletIconCash = [
    BoxShadow(
      color: Color(0x33FFB690),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> walletIconEWallet = [
    BoxShadow(
      color: Color(0x33D0BCFF),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> walletIconGeneral = [
    BoxShadow(
      color: Color(0x33818CF8),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> walletAddButton = [
    BoxShadow(
      color: Color(0x33D0BCFF),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> walletCard = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}

/// Nama font lokal
class AppFonts {
  static const String plusJakartaSans = 'PlusJakartaSans';
  static const String hankenGrotesk = 'HankenGrotesk';
  static const String newsreader = 'Newsreader';
}

/// Ukuran dimensi, margin, padding, radius
class AppDimens {
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 40.0;
  static const double margin = 16.0;
  static const double marginWide = 20.0;

  static const double radiusDefault = 8.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2Xl = 24.0;
  static const double radiusFull = 9999.0;

  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;
  static const double borderWidthIndicator = 2.0;
  static const double caretWidth = 2.0;
  static const double caretHeight = 32.0;

  static const double iconTiny = 12.0;
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;

  static const double keypadKeyHeight = 48.0;
  static const double keypadSpacing = 6.0;
  static const double submitButtonHeight = 48.0;
  static const double appBarHeight = 56.0;
  static const double bottomListPadding = 110.0;
  static const double expenseBarHeight = 8.0;
  static const double expenseBarTrackRadius = 4.0;

  static const double transactionBadgeSize = 40.0;
  static const double walletBoxPaddingH = 12.0;
  static const double walletBoxPaddingV = 10.0;
  static const double summaryCardPadding = 16.0;

  // Dimensi Pengaturan, Kelola Dompet & Kategori UI-5 & UI-6
  static const double settingsIconBoxSize = 44.0;
  static const double settingsIconInner = 22.0;
  static const double walletIconBoxSize = 48.0;
  static const double walletIconInner = 24.0;
  static const double categoryIconBoxSize = 44.0;
  static const double categoryIconInner = 22.0;
  static const double addButtonSize = 40.0;
}

/// Tipografi terpusat menggunakan Plus Jakarta Sans dengan tabular figures untuk nominal
class AppTypography {
  // Layar Buku Kas UI-3
  static const TextStyle heroAmount = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle heroLabel = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle cardSubAmount = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle cardSubLabel = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0x99FFFFFF),
  );

  static const TextStyle headerTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle monthPicker = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle sectionBadge = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFFD8B4FE),
  );

  static const TextStyle walletCardName = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle walletCardBalance = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle transactionTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle transactionSubtitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle transactionAmountExpense = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.expenseRed,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle transactionAmountIncome = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.incomeGreen,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle transactionAmountNeutral = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle transactionCategoryBadge = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle dayGroupDate = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle dayGroupSubtotalGreen = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.incomeGreen,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle dayGroupSubtotalRed = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.expenseRed,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle dayGroupSubtotalNeutral = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurfaceVariant,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle catatButton = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle labelSmLink = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  // Layar Catat Transaksi UI-4
  static const TextStyle catatTabActive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle catatTabInactive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle catatNominalLabel = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: Color(0xCCCDC4D6),
  );

  static const TextStyle catatAmount = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle catatAmountPrefix = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Color(0x99CDC4D6),
  );

  static const TextStyle catatDateChip = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle catatSectionTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: Color(0xB3CDC4D6),
  );

  static const TextStyle catatSelectedCategory = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static const TextStyle catatCategoryActive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle catatCategoryInactive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle catatSourceActive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle catatSourceInactive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle catatNoteHint = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0x80958EA0),
  );

  static const TextStyle catatSubmit = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Tipografi Pengaturan & Kelola Dompet UI-5
  static const TextStyle settingsSectionHeader = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle settingsItemTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle settingsItemSubtitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle walletCardTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle walletBalanceLabel = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle walletBalanceValue = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle walletInitialBalance = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.walletInitialBalance,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Tipografi Kelola Kategori UI-6
  static const TextStyle categoryCardTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle categoryTabActive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle categoryTabInactive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  // Kompatibilitas dengan layar-layar yang ada
  static const TextStyle headlineHeroMobile = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSmItalic = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.onSurface,
  );

  static const TextStyle amountPrefix = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle labelMdActive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
  );

  static const TextStyle labelMdInactive = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLgButton = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle keypadDigit = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle keypadZeros = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.secondaryFixed,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountRow = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountRowGreen = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.incomeGreen,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountRowRed = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.expenseRed,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle hiddenTestHelper = TextStyle(
    fontSize: 1,
    color: AppColors.surface,
  );

  static const TextStyle screenTitleSerif = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle monthSelectorText = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle cardSectionTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle sectionHeaderTitle = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle sectionHeaderCount = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle walletBoxName = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle walletBoxBalance = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle summaryColumnLabel = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle summaryAmountIncome = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.incomeGreen,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle summaryAmountExpense = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.expenseRed,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle summaryAmountSelisih = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.selisihTeal,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle transactionNote = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle transactionAmountTransfer = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle dayGroupHeaderDate = TextStyle(
    fontFamily: AppFonts.plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );
}

/// Konfigurasi ThemeData global gelap tunggal
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surfaceContainerLow,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onSurface,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSurface,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      fontFamily: AppFonts.plusJakartaSans,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface),
        titleTextStyle: AppTypography.headlineSm,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headlineSm,
        contentTextStyle: AppTypography.bodyMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: AppTypography.bodyMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceContainer,
        headerBackgroundColor: AppColors.surfaceContainerHigh,
        headerForegroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.surfaceContainerLow,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        labelStyle: AppTypography.labelMd,
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  // Tema gelap menjadi satu-satunya tema di aplikasi
  static ThemeData get lightTheme => darkTheme;
}
