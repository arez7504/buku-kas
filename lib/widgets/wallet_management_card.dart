import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';
import '../theme/wallet_style.dart';

/// Kartu dompet pada layar Kelola Dompet sesuai desain gelap UI-5
class WalletManagementCard extends StatelessWidget {
  final Wallet wallet;
  final int currentBalance;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const WalletManagementCard({
    super.key,
    required this.wallet,
    required this.currentBalance,
    required this.index,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconMapping = WalletStyleRegistry.resolveWalletStyle(wallet: wallet, index: index);
    final isArchived = wallet.isArchived;

    return Container(
      decoration: BoxDecoration(
        color: isArchived
            ? AppColors.surfaceContainerLow.withValues(alpha: 0.5)
            : AppColors.walletCardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: isArchived ? AppColors.borderFaint : AppColors.borderSubtle,
          width: AppDimens.borderWidthThin,
        ),
        boxShadow: isArchived ? const [] : AppShadows.walletCard,
      ),
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      child: Row(
        children: [
          // Ikon dompet bertint dalam kotak squircle 48x48
          Container(
            width: AppDimens.walletIconBoxSize,
            height: AppDimens.walletIconBoxSize,
            decoration: BoxDecoration(
              gradient: isArchived ? null : iconMapping.gradient,
              color: isArchived ? AppColors.surfaceContainerHigh : null,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              border: Border.all(
                color: isArchived ? AppColors.borderFaint : iconMapping.borderColor,
                width: AppDimens.borderWidthThin,
              ),
              boxShadow: isArchived ? const [] : iconMapping.shadow,
            ),
            child: Icon(
              iconMapping.icon,
              size: AppDimens.walletIconInner,
              color: isArchived ? AppColors.onSurfaceVariant : iconMapping.iconColor,
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          // Rincian dompet: nama, saldo sekarang, saldo awal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.walletCardTitle.copyWith(
                          color: isArchived ? AppColors.onSurfaceVariant : AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (isArchived) ...[
                      const SizedBox(width: AppDimens.spaceSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.spaceXs + 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          border: Border.all(color: AppColors.borderFaint),
                        ),
                        child: const Text('Diarsipkan', style: AppTypography.labelCaps),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimens.spaceXs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Saldo sekarang: ',
                        style: AppTypography.walletBalanceLabel,
                      ),
                      Text(
                        FinanceCalculator.formatRupiah(currentBalance),
                        style: AppTypography.walletBalanceValue.copyWith(
                          color: isArchived
                              ? AppColors.onSurfaceVariant
                              : (currentBalance >= 0
                                  ? AppColors.onSurface
                                  : AppColors.expenseRed),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Saldo awal: ${FinanceCalculator.formatRupiah(wallet.initialBalance)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.walletInitialBalance.copyWith(
                    color: isArchived
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.7)
                        : AppColors.walletInitialBalance,
                  ),
                ),
              ],
            ),
          ),
          // Menu titik tiga (Ubah, Arsipkan/Buka Arsip, Hapus)
          PopupMenuButton<String>(
            key: Key('wallet_menu_${wallet.id}'),
            icon: const Icon(
              Icons.more_vert,
              size: AppDimens.iconMedium,
              color: AppColors.onSurfaceVariant,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'archive') {
                onArchive();
              } else if (value == 'delete') {
                onDelete();
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
                      isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                      size: AppDimens.iconSmall,
                    ),
                    SizedBox(width: AppDimens.spaceSm),
                    Text(
                      isArchived ? 'Buka Arsip' : 'Arsipkan',
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
  }
}
