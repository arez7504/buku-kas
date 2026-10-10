import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kartu pengelompokan item menu di layar Pengaturan sesuai acuan UI-5
class SettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0, bottom: AppDimens.spaceSm),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.settingsSectionHeader,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.settingsCardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: AppDimens.borderWidthThin,
            ),
            boxShadow: AppShadows.settingsCard,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
