import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../logic/backup_service.dart';
import '../logic/finance_state.dart';
import '../theme/app_theme.dart';
import 'category_management_screen.dart';
import 'wallet_management_screen.dart';

/// Layar Pengaturan:
/// - Kelola Dompet
/// - Kelola Kategori
/// - Cadangkan data (ekspor ke JSON dan bagikan)
/// - Pulihkan data (impor dari JSON dengan validasi & pratinjau ringkasan)
class SettingsScreen extends StatelessWidget {
  final Future<void> Function(String fileName, String jsonString)? shareOverride;
  final Future<String?> Function()? filePickerOverride;

  const SettingsScreen({
    super.key,
    this.shareOverride,
    this.filePickerOverride,
  });

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Pengaturan', style: AppTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceMd,
          ),
          children: [
            _buildSectionHeader('Master Data'),
            _buildMenuItem(
              context: context,
              title: 'Kelola Dompet',
              subtitle: 'Daftar dompet, saldo awal, dan pengarsipan',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletManagementScreen()),
                );
              },
            ),
            const SizedBox(height: AppDimens.spaceSm),
            _buildMenuItem(
              context: context,
              title: 'Kelola Kategori',
              subtitle: 'Kategori pemasukan dan pengeluaran',
              icon: Icons.category_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                );
              },
            ),
            const SizedBox(height: AppDimens.spaceLg),
            _buildSectionHeader('Cadangan & Pemulihan'),
            _buildMenuItem(
              context: context,
              title: 'Cadangkan data',
              subtitle: 'Simpan file JSON ke penyimpanan atau bagikan',
              icon: Icons.cloud_upload_outlined,
              onTap: () => _handleBackup(context, state),
            ),
            const SizedBox(height: AppDimens.spaceSm),
            _buildMenuItem(
              context: context,
              title: 'Pulihkan data',
              subtitle: 'Ganti seluruh data dari berkas cadangan JSON',
              icon: Icons.settings_backup_restore_outlined,
              onTap: () => _handleRestore(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppDimens.spaceSm),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelMd.copyWith(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: AppDimens.borderWidthThin,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceMd,
          vertical: AppDimens.spaceXs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDimens.spaceSm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppDimens.iconMedium),
        ),
        title: Text(
          title,
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySm,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.onSurfaceVariant,
          size: AppDimens.iconMedium,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context, FinanceState state) async {
    try {
      final jsonString = BackupService.exportToJson(
        wallets: state.wallets,
        categories: state.categories,
        transactions: state.transactions,
      );
      final fileName = BackupService.generateBackupFileName();

      if (shareOverride != null) {
        await shareOverride!(fileName, jsonString);
      } else {
        final bytes = Uint8List.fromList(utf8.encode(jsonString));
        final xFile = XFile.fromData(
          bytes,
          mimeType: 'application/json',
          name: fileName,
        );
        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            subject: fileName,
          ),
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File cadangan siap dibagikan'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal Mencadangkan', style: AppTypography.headlineSm),
            content: Text('Terjadi kesalahan saat membuat cadangan: $e', style: AppTypography.bodyMd),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<String?> _pickFileContent(BuildContext context) async {
    if (filePickerOverride != null) {
      return await filePickerOverride!();
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final pickedFile = result.files.single;
    if (pickedFile.bytes != null) {
      return utf8.decode(pickedFile.bytes!);
    }
    if (pickedFile.path != null) {
      final file = File(pickedFile.path!);
      if (await file.exists()) {
        return await file.readAsString();
      }
    }
    throw const FormatException('Tidak dapat membaca isi berkas yang dipilih');
  }

  Future<void> _handleRestore(BuildContext context, FinanceState state) async {
    try {
      final jsonContent = await _pickFileContent(context);
      if (jsonContent == null) {
        return; // Dibatalkan oleh pengguna
      }

      final backupData = BackupService.parseAndValidate(jsonContent);
      final summary = backupData.summary;

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
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
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Dompet', '${summary.walletCount} dompet'),
                      const Divider(height: 12),
                      _buildSummaryRow('Kategori', '${summary.categoryCount} kategori'),
                      const Divider(height: 12),
                      _buildSummaryRow('Transaksi', '${summary.transactionCount} transaksi'),
                      const Divider(height: 12),
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
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onPrimary,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ganti Seluruh Data'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await state.restoreData(
        wallets: backupData.wallets,
        categories: backupData.categories,
        transactions: backupData.transactions,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dipulihkan'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on BackupValidationException catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Berkas Ditolak', style: AppTypography.headlineSm),
            content: Text(e.message, style: AppTypography.bodyMd),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal Memulihkan Data', style: AppTypography.headlineSm),
            content: Text('Terjadi kesalahan saat memproses data: $e', style: AppTypography.bodyMd),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    }
  }

  static Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
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
