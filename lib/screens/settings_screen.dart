import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../logic/app_lock_manager.dart';
import '../logic/backup_service.dart';
import '../logic/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_lock_scope.dart';
import '../widgets/restore_preview_dialog.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_item_tile.dart';
import '../widgets/settings_switch_tile.dart';
import 'category_management_screen.dart';
import 'wallet_management_screen.dart';

/// Layar Pengaturan sesuai spesifikasi visual Milestone UI-5:
/// - Master Data: Kelola Dompet, Kelola Kategori
/// - Keamanan: Kunci aplikasi (autentikasi perangkat)
/// - Cadangan & Pemulihan: Cadangkan data, Pulihkan data
class SettingsScreen extends StatelessWidget {
  final Future<void> Function(String fileName, String jsonString)? shareOverride;
  final Future<String?> Function()? filePickerOverride;
  final AppLockManager? lockManagerOverride;

  const SettingsScreen({
    super.key,
    this.shareOverride,
    this.filePickerOverride,
    this.lockManagerOverride,
  });

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);
    final lockManager = lockManagerOverride ?? AppLockScope.maybeOf(context);
    final isLockedEnabled = lockManager?.isEnabled ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan', style: AppTypography.headlineSm),
        centerTitle: true,
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
            SettingsGroupCard(
              title: 'Master Data',
              children: [
                SettingsItemTile(
                  title: 'Kelola Dompet',
                  subtitle: 'Daftar dompet, saldo awal, dan pengarsipan',
                  icon: Icons.account_balance_wallet,
                  iconGradient: AppGradients.settingsWalletIcon,
                  iconShadow: AppShadows.settingsIconPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletManagementScreen()),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.borderFaint),
                SettingsItemTile(
                  title: 'Kelola Kategori',
                  subtitle: 'Kategori pemasukan dan pengeluaran',
                  icon: Icons.category,
                  iconGradient: AppGradients.settingsCategoryIcon,
                  iconShadow: AppShadows.settingsIconCyan,
                  iconColor: const Color(0xFF021B24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceLg),
            SettingsGroupCard(
              title: 'Keamanan',
              children: [
                SettingsSwitchTile(
                  title: 'Kunci aplikasi',
                  subtitle: 'Minta autentikasi perangkat saat membuka aplikasi',
                  icon: Icons.lock,
                  iconGradient: AppGradients.settingsSecurityIcon,
                  iconShadow: AppShadows.settingsIconAmber,
                  value: isLockedEnabled,
                  switchKey: const Key('switch_kunci_aplikasi'),
                  onChanged: lockManager == null
                      ? null
                      : (val) => _handleToggleLock(context, lockManager, val),
                  onTap: lockManager == null
                      ? null
                      : () => _handleToggleLock(context, lockManager, !isLockedEnabled),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceLg),
            SettingsGroupCard(
              title: 'Cadangan & Pemulihan',
              children: [
                SettingsItemTile(
                  title: 'Cadangkan data',
                  subtitle: 'Simpan file JSON ke penyimpanan atau bagikan',
                  icon: Icons.cloud_upload,
                  iconGradient: AppGradients.settingsBackupIcon,
                  iconShadow: AppShadows.settingsIconTeal,
                  iconColor: const Color(0xFF021B24),
                  onTap: () => _handleBackup(context, state),
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.borderFaint),
                SettingsItemTile(
                  title: 'Pulihkan data',
                  subtitle: 'Ganti seluruh data dari berkas cadangan JSON',
                  icon: Icons.settings_backup_restore,
                  iconGradient: AppGradients.settingsRestoreIcon,
                  iconShadow: AppShadows.settingsIconViolet,
                  onTap: () => _handleRestore(context, state),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleLock(
    BuildContext context,
    AppLockManager lockManager,
    bool targetValue,
  ) async {
    final result = await lockManager.toggleLock(targetValue);
    if (!context.mounted) return;
    if (!result.isSuccess && result.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            fileNameOverrides: [fileName],
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
            content: Text(
              'Terjadi kesalahan saat membuat cadangan: $e',
              style: AppTypography.bodyMd,
            ),
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
      type: FileType.any,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final pickedFile = result.files.single;

    if (pickedFile.size > BackupService.maxFileSizeBytes) {
      throw const BackupValidationException(
        'Ukuran berkas melebihi batas maksimal 20 MB',
      );
    }

    if (pickedFile.bytes != null) {
      return utf8.decode(pickedFile.bytes!);
    }
    if (pickedFile.path != null) {
      final file = File(pickedFile.path!);
      if (await file.exists()) {
        final length = await file.length();
        if (length > BackupService.maxFileSizeBytes) {
          throw const BackupValidationException(
            'Ukuran berkas melebihi batas maksimal 20 MB',
          );
        }
        return await file.readAsString();
      }
    }
    throw const FormatException('Tidak dapat membaca isi berkas yang dipilih');
  }

  Future<void> _handleRestore(BuildContext context, FinanceState state) async {
    try {
      final jsonContent = await _pickFileContent(context);
      if (jsonContent == null) {
        return;
      }

      if (utf8.encode(jsonContent).length > BackupService.maxFileSizeBytes) {
        throw const BackupValidationException(
          'Ukuran berkas melebihi batas maksimal 20 MB',
        );
      }

      final backupData = BackupService.parseAndValidate(jsonContent);
      final summary = backupData.summary;

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => RestorePreviewDialog(summary: summary),
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
            content: Text(
              'Terjadi kesalahan saat memproses data: $e',
              style: AppTypography.bodyMd,
            ),
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
}
