import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Keypad angka buatan sendiri (1-9, 000, 0, hapus) sesuai design/catat.html
// Tanpa huruf ABC/DEF/dst pada tombol angka.
class CatatNumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onQuickZeros;
  final VoidCallback onBackspace;

  const CatatNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onQuickZeros,
    required this.onBackspace,
  });

  Widget _buildKey({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: AppDimens.keypadKeyHeight,
        margin: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: AppColors.catatKeypadKey,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: AppColors.borderFaint,
            width: AppDimens.borderWidthThin,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.catatKeypadBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: AppColors.borderFaint,
          width: AppDimens.borderWidthThin,
        ),
        boxShadow: AppShadows.catatKeypad,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey(child: const Text('1', style: AppTypography.keypadDigit), onTap: () => onDigit('1')),
              _buildKey(child: const Text('2', style: AppTypography.keypadDigit), onTap: () => onDigit('2')),
              _buildKey(child: const Text('3', style: AppTypography.keypadDigit), onTap: () => onDigit('3')),
            ],
          ),
          Row(
            children: [
              _buildKey(child: const Text('4', style: AppTypography.keypadDigit), onTap: () => onDigit('4')),
              _buildKey(child: const Text('5', style: AppTypography.keypadDigit), onTap: () => onDigit('5')),
              _buildKey(child: const Text('6', style: AppTypography.keypadDigit), onTap: () => onDigit('6')),
            ],
          ),
          Row(
            children: [
              _buildKey(child: const Text('7', style: AppTypography.keypadDigit), onTap: () => onDigit('7')),
              _buildKey(child: const Text('8', style: AppTypography.keypadDigit), onTap: () => onDigit('8')),
              _buildKey(child: const Text('9', style: AppTypography.keypadDigit), onTap: () => onDigit('9')),
            ],
          ),
          Row(
            children: [
              _buildKey(child: const Text('000', style: AppTypography.keypadZeros), onTap: onQuickZeros),
              _buildKey(child: const Text('0', style: AppTypography.keypadDigit), onTap: () => onDigit('0')),
              _buildKey(
                child: const Icon(
                  Icons.backspace_outlined,
                  size: AppDimens.iconMedium,
                  color: AppColors.onSurface,
                ),
                onTap: onBackspace,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
