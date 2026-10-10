import 'package:flutter/material.dart';
import '../logic/finance_state.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';
import '../widgets/wallet_delete_dialog.dart';
import '../widgets/wallet_management_card.dart';
import 'wallet_form_screen.dart';

/// Layar Kelola Dompet sesuai spesifikasi visual Milestone UI-5:
/// - Header: panah kembali, judul, tombol tambah (+) melingkar bertint neon
/// - Kartu dompet: squircle bertint gradasi dari nama, saldo sekarang & saldo awal
/// - Bagian diarsipkan: kartu redup yang dapat dipulihkan
class WalletManagementScreen extends StatefulWidget {
  const WalletManagementScreen({super.key});

  @override
  State<WalletManagementScreen> createState() => _WalletManagementScreenState();
}

class _WalletManagementScreenState extends State<WalletManagementScreen> {
  void _showAddWalletDialog(FinanceState state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletFormScreen(),
      ),
    );
  }

  void _showEditWalletDialog(FinanceState state, Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletFormScreen(wallet: wallet),
      ),
    );
  }

  void _handleDeleteOrArchive(FinanceState state, Wallet wallet) {
    final isUsed = state.isWalletUsed(wallet.id);

    if (isUsed) {
      showDialog(
        context: context,
        builder: (_) => WalletCannotDeleteDialog(
          walletName: wallet.name,
          isArchived: wallet.isArchived,
          onArchive: () async {
            final messenger = ScaffoldMessenger.of(context);
            await state.archiveWallet(wallet.id, isArchived: true);
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Dompet "${wallet.name}" berhasil diarsipkan')),
            );
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => WalletConfirmDeleteDialog(
          walletName: wallet.name,
          onConfirmDelete: () async {
            final messenger = ScaffoldMessenger.of(context);
            await state.deleteWallet(wallet.id);
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Dompet "${wallet.name}" berhasil dihapus permanen')),
            );
          },
        ),
      );
    }
  }

  Future<void> _toggleArchive(FinanceState state, Wallet wallet) async {
    final messenger = ScaffoldMessenger.of(context);
    await state.archiveWallet(wallet.id, isArchived: !wallet.isArchived);
    if (!mounted) return;
    final msg = wallet.isArchived
        ? 'Dompet "${wallet.name}" diaktifkan kembali'
        : 'Dompet "${wallet.name}" diarsipkan';
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);
    final wallets = state.wallets;
    final activeWallets = wallets.where((w) => !w.isArchived).toList();
    final archivedWallets = wallets.where((w) => w.isArchived).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Dompet', style: AppTypography.headlineSm),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            width: AppDimens.addButtonSize,
            height: AppDimens.addButtonSize,
            margin: const EdgeInsets.only(right: AppDimens.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: AppDimens.borderWidthThin,
              ),
              boxShadow: AppShadows.walletAddButton,
            ),
            child: IconButton(
              key: const Key('add_wallet_button'),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 22, color: AppColors.primary),
              tooltip: 'Tambah Dompet',
              onPressed: () => _showAddWalletDialog(state),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: wallets.isEmpty
            ? Center(
                child: Text('Belum ada dompet', style: AppTypography.bodyMd),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.margin,
                  vertical: AppDimens.spaceMd,
                ),
                itemCount: activeWallets.length +
                    (archivedWallets.isEmpty ? 0 : 1 + archivedWallets.length),
                itemBuilder: (context, index) {
                  if (index < activeWallets.length) {
                    final wallet = activeWallets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.spaceSm + 2),
                      child: WalletManagementCard(
                        wallet: wallet,
                        currentBalance: state.getWalletBalance(wallet.id),
                        index: index,
                        onEdit: () => _showEditWalletDialog(state, wallet),
                        onArchive: () => _toggleArchive(state, wallet),
                        onDelete: () => _handleDeleteOrArchive(state, wallet),
                      ),
                    );
                  }

                  if (index == activeWallets.length) {
                    return const Padding(
                      padding: EdgeInsets.only(
                        left: 4.0,
                        top: AppDimens.spaceMd,
                        bottom: AppDimens.spaceSm,
                      ),
                      child: Text(
                        'DIARSIPKAN',
                        style: AppTypography.settingsSectionHeader,
                      ),
                    );
                  }

                  final archivedIndex = index - activeWallets.length - 1;
                  final wallet = archivedWallets[archivedIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.spaceSm + 2),
                    child: WalletManagementCard(
                      wallet: wallet,
                      currentBalance: state.getWalletBalance(wallet.id),
                      index: archivedIndex,
                      onEdit: () => _showEditWalletDialog(state, wallet),
                      onArchive: () => _toggleArchive(state, wallet),
                      onDelete: () => _handleDeleteOrArchive(state, wallet),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
