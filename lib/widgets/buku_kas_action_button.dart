import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Tombol aksi Catat Pengeluaran Baru berwarna terracotta sesuai design/buku_kas.html
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
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        ),
        icon: const Icon(Icons.edit_note, size: AppDimens.iconMedium),
        label: const Text('Catat Transaksi', style: AppTypography.bodyLgButton),
      ),
    );
  }
}
