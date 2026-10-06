import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Tombol simpan transaksi warna terracotta sesuai design/catat.html
class CatatSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onSubmit;

  const CatatSubmitButton({
    super.key,
    required this.label,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.submitButtonHeight,
      child: Material(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: InkWell(
          onTap: onSubmit,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTypography.bodyLgButton),
              const SizedBox(width: AppDimens.spaceSm),
              const Icon(
                Icons.check,
                size: AppDimens.iconSmall + 2,
                color: AppColors.onSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
