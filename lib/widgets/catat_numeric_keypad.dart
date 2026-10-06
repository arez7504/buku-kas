import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Keypad angka buatan sendiri (1-9, 000, 0, hapus) sesuai design/catat.html
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
        margin: const EdgeInsets.all(AppDimens.spaceXs / 2),
        child: Material(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceXs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
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
                child: const Icon(Icons.backspace_outlined, size: AppDimens.iconMedium, color: AppColors.onSurface),
                onTap: onBackspace,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
