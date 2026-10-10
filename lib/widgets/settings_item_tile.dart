import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Item baris navigasi menu Pengaturan sesuai desain visual UI-5
class SettingsItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient iconGradient;
  final List<BoxShadow> iconShadow;
  final Color iconColor;
  final VoidCallback onTap;

  const SettingsItemTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconGradient,
    required this.iconShadow,
    this.iconColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd,
            vertical: AppDimens.spaceMd,
          ),
          child: Row(
            children: [
              Container(
                width: AppDimens.settingsIconBoxSize,
                height: AppDimens.settingsIconBoxSize,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(
                    color: AppColors.outline,
                    width: AppDimens.borderWidthThin,
                  ),
                  boxShadow: iconShadow,
                ),
                child: Icon(
                  icon,
                  size: AppDimens.settingsIconInner,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.settingsItemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.settingsItemSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
                size: AppDimens.iconMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
