import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Komponen input catatan transaksi sesuai design/catat.html
class CatatNoteInput extends StatelessWidget {
  final TextEditingController controller;

  const CatatNoteInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        border: Border.all(
          color: AppColors.surfaceContainerHigh,
          width: AppDimens.borderWidthThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd,
        vertical: AppDimens.spaceXs,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_note,
            size: AppDimens.iconMedium,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimens.spaceSm),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyMd,
              decoration: const InputDecoration(
                hintText: 'Catatan opsional (cth: Kopi pagi)...',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.hankenGrotesk,
                  fontSize: 14,
                  color: AppColors.outline,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
