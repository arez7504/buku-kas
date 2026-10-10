import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

/// Dialog bertema gelap saat kategori tidak dapat dihapus permanen karena sudah dipakai transaksi
class CategoryCannotDeleteDialog extends StatelessWidget {
  final Category category;
  final VoidCallback onArchive;

  const CategoryCannotDeleteDialog({
    super.key,
    required this.category,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.settingsCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius2Xl),
        side: const BorderSide(color: AppColors.borderFaint),
      ),
      title: const Text('Tidak Dapat Dihapus', style: AppTypography.headlineSm),
      content: Text(
        'Kategori "${category.name}" sudah dipakai dalam transaksi sehingga tidak bisa dihapus permanen. '
        'Apakah Anda ingin mengarsipkannya agar tidak muncul lagi sebagai pilihan transaksi baru?',
        style: AppTypography.bodyMd,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        if (!category.isArchived)
          FilledButton(
            key: const Key('offer_archive_category_button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onArchive();
            },
            child: const Text('Arsipkan', style: TextStyle(color: AppColors.onPrimary)),
          ),
      ],
    );
  }
}

/// Dialog bertema gelap saat mengonfirmasi penghapusan permanen kategori tanpa transaksi
class CategoryConfirmDeleteDialog extends StatelessWidget {
  final Category category;
  final VoidCallback onConfirmDelete;

  const CategoryConfirmDeleteDialog({
    super.key,
    required this.category,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.settingsCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius2Xl),
        side: const BorderSide(color: AppColors.borderFaint),
      ),
      title: const Text('Hapus Kategori?', style: AppTypography.headlineSm),
      content: Text(
        'Apakah Anda yakin ingin menghapus kategori "${category.name}" secara permanen? '
        'Kategori ini belum memiliki transaksi apa pun.',
        style: AppTypography.bodyMd,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: const Key('confirm_delete_category_button'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirmDelete();
          },
          child: const Text('Hapus', style: TextStyle(color: AppColors.onPrimary)),
        ),
      ],
    );
  }
}
