import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Komponen input catatan transaksi sesuai design/catat.html
// SATU kolom dengan satu tepi (tidak ada kotak bersarang berlapis garis tepi).
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: AppColors.borderFaint,
          width: AppDimens.borderWidthThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd - 2,
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
              style: AppTypography.bodyMd.copyWith(
                fontSize: 13,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Catatan opsional (cth: Kopi pagi)...',
                hintStyle: AppTypography.catatNoteHint,
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
