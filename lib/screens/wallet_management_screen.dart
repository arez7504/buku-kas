import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/finance_calculator.dart';
import '../logic/finance_state.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';

// Layar Kelola Dompet sesuai Milestone 5
class WalletManagementScreen extends StatefulWidget {
  const WalletManagementScreen({super.key});

  @override
  State<WalletManagementScreen> createState() => _WalletManagementScreenState();
}

class _WalletManagementScreenState extends State<WalletManagementScreen> {
  void _showAddWalletDialog(FinanceState state) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Tambah Dompet', style: AppTypography.headlineSm),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const Key('wallet_name_input'),
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nama Dompet',
                      errorText: errorMessage,
                      labelStyle: AppTypography.labelMd,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceMd),
                  TextField(
                    key: const Key('wallet_balance_input'),
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Saldo Awal (Rp)',
                      labelStyle: AppTypography.labelMd,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ),
                FilledButton(
                  key: const Key('wallet_save_button'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final validationError = state.validateWalletName(name);
                    if (validationError != null) {
                      setDialogState(() {
                        errorMessage = validationError;
                      });
                      return;
                    }

                    final initialBalance = int.tryParse(balanceController.text.trim()) ?? 0;
                    final newWallet = Wallet(
                      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      initialBalance: initialBalance,
                    );

                    Navigator.pop(dialogContext);
                    await state.addWallet(newWallet);
                  },
                  child: const Text('Simpan', style: TextStyle(color: AppColors.onPrimary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditWalletDialog(FinanceState state, Wallet wallet) {
    final nameController = TextEditingController(text: wallet.name);
    final balanceController = TextEditingController(text: wallet.initialBalance.toString());
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Ubah Dompet', style: AppTypography.headlineSm),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const Key('wallet_name_edit_input'),
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nama Dompet',
                      errorText: errorMessage,
                      labelStyle: AppTypography.labelMd,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceMd),
                  TextField(
                    key: const Key('wallet_balance_edit_input'),
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Saldo Awal (Rp)',
                      labelStyle: AppTypography.labelMd,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ),
                FilledButton(
                  key: const Key('wallet_update_button'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final validationError = state.validateWalletName(name, excludeWalletId: wallet.id);
                    if (validationError != null) {
                      setDialogState(() {
                        errorMessage = validationError;
                      });
                      return;
                    }

                    final initialBalance = int.tryParse(balanceController.text.trim()) ?? 0;
                    final updated = wallet.copyWith(
                      name: name,
                      initialBalance: initialBalance,
                    );

                    Navigator.pop(dialogContext);
                    await state.updateWallet(updated);
                  },
                  child: const Text('Simpan', style: TextStyle(color: AppColors.onPrimary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleDeleteOrArchive(FinanceState state, Wallet wallet) {
    final isUsed = state.isWalletUsed(wallet.id);

    if (isUsed) {
      // Jika sudah dipakai transaksi: tampilkan pesan dan tawarkan arsip
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Tidak Dapat Dihapus', style: AppTypography.headlineSm),
            content: Text(
              'Dompet "${wallet.name}" sudah dipakai dalam transaksi sehingga tidak bisa dihapus permanen. Apakah Anda ingin mengarsipkannya agar tidak muncul lagi sebagai pilihan transaksi baru?',
              style: AppTypography.bodyMd,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ),
              if (!wallet.isArchived)
                FilledButton(
                  key: const Key('offer_archive_wallet_button'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(dialogContext);
                    await state.archiveWallet(wallet.id, isArchived: true);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Dompet "${wallet.name}" berhasil diarsipkan')),
                    );
                  },
                  child: const Text('Arsipkan', style: TextStyle(color: AppColors.onPrimary)),
                ),
            ],
          );
        },
      );
    } else {
      // Jika belum pernah dipakai transaksi: konfirmasi hapus permanen
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Hapus Dompet?', style: AppTypography.headlineSm),
            content: Text(
              'Apakah Anda yakin ingin menghapus dompet "${wallet.name}" secara permanen? Dompet ini belum memiliki transaksi apa pun.',
              style: AppTypography.bodyMd,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ),
              FilledButton(
                key: const Key('confirm_delete_wallet_button'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(dialogContext);
                  await state.deleteWallet(wallet.id);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Dompet "${wallet.name}" berhasil dihapus permanen')),
                  );
                },
                child: const Text('Hapus', style: TextStyle(color: AppColors.onPrimary)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);
    final wallets = state.wallets;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Kelola Dompet', style: AppTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            key: const Key('add_wallet_button'),
            icon: const Icon(Icons.add, size: AppDimens.iconLarge),
            tooltip: 'Tambah Dompet',
            onPressed: () => _showAddWalletDialog(state),
          ),
        ],
      ),
      body: SafeArea(
        child: wallets.isEmpty
            ? Center(
                child: Text('Belum ada dompet', style: AppTypography.bodyMd),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.margin,
                  vertical: AppDimens.spaceMd,
                ),
                itemCount: wallets.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceSm),
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  final currentBalance = state.getWalletBalance(wallet.id);

                  return Container(
                    decoration: BoxDecoration(
                      color: wallet.isArchived
                          ? AppColors.surfaceContainerHigh
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                      border: Border.all(
                        color: wallet.isArchived
                            ? AppColors.outlineVariant
                            : AppColors.outlineVariant,
                        width: AppDimens.borderWidthThin,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppDimens.spaceMd),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ikon dompet
                        Container(
                          padding: const EdgeInsets.all(AppDimens.spaceSm),
                          decoration: BoxDecoration(
                            color: wallet.isArchived
                                ? AppColors.surfaceContainerHighest
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: wallet.isArchived
                                ? AppColors.onSurfaceVariant
                                : AppColors.primary,
                            size: AppDimens.iconMedium,
                          ),
                        ),
                        const SizedBox(width: AppDimens.spaceMd),
                        // Detail dompet: nama, saldo sekarang, saldo awal, status arsip
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      wallet.name,
                                      style: AppTypography.bodyLg.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: wallet.isArchived
                                            ? AppColors.onSurfaceVariant
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (wallet.isArchived)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimens.spaceXs + 2,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                                      ),
                                      child: const Text('Diarsipkan', style: AppTypography.labelCaps),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppDimens.spaceXs),
                              Row(
                                children: [
                                  Text('Saldo sekarang: ', style: AppTypography.bodySm),
                                  Text(
                                    FinanceCalculator.formatRupiah(currentBalance),
                                    style: AppTypography.bodySm.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: currentBalance >= 0
                                          ? AppColors.onSurface
                                          : AppColors.expenseRed,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Saldo awal: ${FinanceCalculator.formatRupiah(wallet.initialBalance)}',
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        // Menu aksi (Ubah, Arsipkan/Buka Arsip, Hapus)
                        PopupMenuButton<String>(
                          key: Key('wallet_menu_${wallet.id}'),
                          icon: const Icon(Icons.more_vert, size: AppDimens.iconMedium),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _showEditWalletDialog(state, wallet);
                            } else if (value == 'archive') {
                              final messenger = ScaffoldMessenger.of(context);
                              await state.archiveWallet(wallet.id, isArchived: !wallet.isArchived);
                              if (!mounted) return;
                              final msg = wallet.isArchived
                                  ? 'Dompet "${wallet.name}" diaktifkan kembali'
                                  : 'Dompet "${wallet.name}" diarsipkan';
                              messenger.showSnackBar(SnackBar(content: Text(msg)));
                            } else if (value == 'delete') {
                              _handleDeleteOrArchive(state, wallet);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: AppDimens.iconSmall),
                                  SizedBox(width: AppDimens.spaceSm),
                                  Text('Ubah', style: AppTypography.bodyMd),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'archive',
                              child: Row(
                                children: [
                                  Icon(
                                    wallet.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                                    size: AppDimens.iconSmall,
                                  ),
                                  const SizedBox(width: AppDimens.spaceSm),
                                  Text(
                                    wallet.isArchived ? 'Buka Arsip' : 'Arsipkan',
                                    style: AppTypography.bodyMd,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.error, size: AppDimens.iconSmall),
                                  SizedBox(width: AppDimens.spaceSm),
                                  Text('Hapus', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
