import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';

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
        Text(label, style: AppTypography.labelCaps),
        Row(
          children: wallets.map((w) {
            final isSelected = w.id == currentSelection;

            return Padding(
              padding: const EdgeInsets.only(left: AppDimens.spaceXs),
              child: InkWell(
                onTap: () => onSelect(w.id),
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spaceSm + AppDimens.spaceXs,
                    vertical: AppDimens.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.surfaceContainerHighest
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.outlineVariant
                          : AppColors.transparent,
                      width: AppDimens.borderWidthThin,
                    ),
                  ),
                  child: Text(
                    w.name,
                    style: isSelected
                        ? AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)
                        : AppTypography.labelMdInactive,
                  ),
                ),
              ),
            );
          }).toList(),
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
