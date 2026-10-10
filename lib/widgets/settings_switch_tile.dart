import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Item baris sakelar (switch) di layar Pengaturan untuk Kunci Aplikasi
class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient iconGradient;
  final List<BoxShadow> iconShadow;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final Key switchKey;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconGradient,
    required this.iconShadow,
    required this.value,
    required this.onChanged,
    required this.onTap,
    required this.switchKey,
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
                  color: Colors.white,
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
              Switch(
                key: switchKey,
                value: value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.switchTrackActive,
                inactiveThumbColor: AppColors.onSurfaceVariant,
                inactiveTrackColor: AppColors.surfaceContainerHigh,
                trackOutlineColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.transparent
                      : AppColors.outlineVariant,
                ),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
