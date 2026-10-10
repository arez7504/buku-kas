import 'package:flutter/material.dart';
import '../logic/backup_service.dart';
import '../theme/app_theme.dart';

/// Dialog pratinjau ringkasan pemulihan data JSON di layar Pengaturan
class RestorePreviewDialog extends StatelessWidget {
  final BackupSummary summary;

  const RestorePreviewDialog({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pulihkan Data?', style: AppTypography.headlineSm),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seluruh data saat ini akan DIGANTI dengan isi berkas cadangan berikut:',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppDimens.spaceMd),
            Container(
              padding: const EdgeInsets.all(AppDimens.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                border: Border.all(color: AppColors.borderFaint),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Tanggal Ekspor', summary.exportedAtText),
                  const Divider(height: 12, color: AppColors.borderFaint),
                  _buildSummaryRow('Dompet', '${summary.walletCount} dompet'),
                  const Divider(height: 12, color: AppColors.borderFaint),
                  _buildSummaryRow('Kategori', '${summary.categoryCount} kategori'),
                  const Divider(height: 12, color: AppColors.borderFaint),
                  _buildSummaryRow('Transaksi', '${summary.transactionCount} transaksi'),
                  const Divider(height: 12, color: AppColors.borderFaint),
                  _buildSummaryRow('Rentang Tanggal', summary.dateRangeText),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spaceMd),
            Text(
              'Peringatan: Tindakan ini tidak dapat dibatalkan. Pastikan data saat ini sudah dicadangkan jika masih diperlukan.',
              style: AppTypography.bodySm.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Batal',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onPrimary,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Ganti Seluruh Data'),
        ),
      ],
    );
  }

  static Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: AppDimens.spaceSm),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
