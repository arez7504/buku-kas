import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

/// Kartu Hero Utama Baru: "Saldo Total" (Milestone NAV-2)
class BukuKasSaldoTotalCard extends StatelessWidget {
  final int totalBalance;

  const BukuKasSaldoTotalCard({
    super.key,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = totalBalance < 0;
    final amountText = isNegative
        ? '- ${FinanceCalculator.formatRupiah(totalBalance.abs())}'
        : FinanceCalculator.formatRupiah(totalBalance);
    final amountStyle = isNegative
        ? AppTypography.saldoTotalAmountNegative
        : AppTypography.saldoTotalAmount;

    return Container(
      key: const Key('saldo_total_card'),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceXs,
      ),
      padding: const EdgeInsets.all(AppDimens.spaceSm + 4),
      decoration: BoxDecoration(
        gradient: AppGradients.saldoTotalCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.saldoTotalDot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              const Text(
                'SALDO TOTAL',
                style: AppTypography.saldoTotalLabel,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceXs + 2),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amountText,
                key: const Key('saldo_total_amount'),
                style: amountStyle,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spaceXs),
          const Text(
            'Semua dompet aktif',
            style: AppTypography.saldoTotalSubtitle,
          ),
        ],
      ),
    );
  }
}
