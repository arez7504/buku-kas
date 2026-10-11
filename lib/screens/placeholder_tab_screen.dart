import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Layar sementara untuk tab Riwayat dan Statistik (Milestone NAV-1)
class PlaceholderTabScreen extends StatelessWidget {
  final String title;

  const PlaceholderTabScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTypography.headlineSm),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppDimens.placeholderIconBoxSize,
              height: AppDimens.placeholderIconBoxSize,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: AppDimens.borderWidthThin,
                ),
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: AppDimens.placeholderIconSize,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimens.spaceMd),
            Text(
              title,
              style: AppTypography.placeholderTitle,
            ),
            const SizedBox(height: AppDimens.spaceXs),
            const Text(
              'Segera hadir',
              style: AppTypography.placeholderSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
