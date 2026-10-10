import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';
import '../theme/wallet_style.dart';

// Komponen pemilih dompet sumber dana atau transfer sesuai design/catat.html
class CatatWalletSelector extends StatelessWidget {
  final TransactionType type;
  final List<Wallet> wallets;
  final String? selectedWalletId;
  final String? selectedTargetWalletId;
  final ValueChanged<String> onWalletSelected;
  final ValueChanged<String> onTargetWalletSelected;

  const CatatWalletSelector({
    super.key,
    required this.type,
    required this.wallets,
    required this.selectedWalletId,
    required this.selectedTargetWalletId,
    required this.onWalletSelected,
    required this.onTargetWalletSelected,
  });

  Widget _buildChipRow({
    required String label,
    required String? currentSelection,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.catatSectionTitle),
        const SizedBox(width: AppDimens.spaceSm),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: wallets.map((w) {
                  final isSelected = w.id == currentSelection;
                  final style = WalletStyleRegistry.resolveWalletStyle(wallet: w);

                  return Padding(
                    padding: const EdgeInsets.only(left: AppDimens.spaceSm - 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelect(w.id),
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.spaceMd - 4,
                            vertical: AppDimens.spaceXs + 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.catatSourceActive
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.catatSourceActiveBorder
                                  : AppColors.borderFaint,
                              width: AppDimens.borderWidthThin,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.0,
                                height: 6.0,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? style.iconColor
                                      : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppDimens.spaceXs + 2),
                              Text(
                                w.name,
                                style: isSelected
                                    ? AppTypography.catatSourceActive
                                    : AppTypography.catatSourceInactive,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (type == TransactionType.transfer) {
      return Column(
        children: [
          _buildChipRow(
            label: 'DARI (SUMBER)',
            currentSelection: selectedWalletId,
            onSelect: onWalletSelected,
          ),
          const SizedBox(height: AppDimens.spaceSm),
          _buildChipRow(
            label: 'KE (TUJUAN)',
            currentSelection: selectedTargetWalletId,
            onSelect: onTargetWalletSelected,
          ),
        ],
      );
    }

    return _buildChipRow(
      label: 'SUMBER DANA',
      currentSelection: selectedWalletId,
      onSelect: onWalletSelected,
    );
  }
}
