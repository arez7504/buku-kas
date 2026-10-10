import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dialog konfirmasi penolakan hapus dan penawaran arsip
class WalletCannotDeleteDialog extends StatelessWidget {
  final String walletName;
  final bool isArchived;
  final VoidCallback onArchive;

  const WalletCannotDeleteDialog({
    super.key,
    required this.walletName,
    required this.isArchived,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tidak Dapat Dihapus', style: AppTypography.headlineSm),
      content: Text(
        'Dompet "$walletName" sudah dipakai dalam transaksi sehingga tidak bisa dihapus permanen. Apakah Anda ingin mengarsipkannya agar tidak muncul lagi sebagai pilihan transaksi baru?',
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
        if (!isArchived)
          FilledButton(
            key: const Key('offer_archive_wallet_button'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
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

/// Dialog konfirmasi hapus dompet permanen
class WalletConfirmDeleteDialog extends StatelessWidget {
  final String walletName;
  final VoidCallback onConfirmDelete;

  const WalletConfirmDeleteDialog({
    super.key,
    required this.walletName,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Dompet?', style: AppTypography.headlineSm),
      content: Text(
        'Apakah Anda yakin ingin menghapus dompet "$walletName" secara permanen? Dompet ini belum memiliki transaksi apa pun.',
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
          key: const Key('confirm_delete_wallet_button'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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
