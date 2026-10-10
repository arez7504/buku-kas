import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Tombol simpan transaksi bergradasi sesuai design/catat.html
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
    return Container(
      width: double.infinity,
      height: 52.0,
      decoration: BoxDecoration(
        gradient: AppGradients.catatSubmitButton,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        boxShadow: AppShadows.catatSubmitButton,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSubmit,
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTypography.catatSubmit),
              const SizedBox(width: AppDimens.spaceSm),
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
