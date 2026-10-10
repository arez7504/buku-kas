import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tombol aksi Catat Transaksi dengan gradasi neon fintech menggantikan bilah navigasi
class BukuKasActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BukuKasActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.margin),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.catatButton,
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          border: Border.all(color: AppColors.outline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66A855F7),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          key: const Key('catat_transaksi_button'),
          onPressed: onPressed,
          backgroundColor: AppColors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          hoverElevation: 0,
          focusElevation: 0,
          splashColor: AppColors.borderSubtle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          ),
          icon: const Icon(Icons.add, size: AppDimens.iconMedium),
          label: const Text('Catat Transaksi', style: AppTypography.catatButton),
        ),
      ),
    );
  }
}
