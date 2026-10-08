import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'buku_kas_transaction_row.dart';

// Pengelompokan transaksi per hari dengan subtotal harian
class BukuKasDayGroup extends StatelessWidget {
  final DailyTransactionGroup group;
  final String Function(String) getWalletName;
  final String Function(String?) getCategoryName;
  final void Function(Transaction) onTransactionTap;
  final DateTime? now;

  const BukuKasDayGroup({
    super.key,
    required this.group,
    required this.getWalletName,
    required this.getCategoryName,
    required this.onTransactionTap,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    final subtotalText = FinanceCalculator.formatDailySubtotal(group.subtotal);
    final TextStyle subtotalStyle;
    if (group.subtotal != null && group.subtotal! > 0) {
      subtotalStyle = AppTypography.dayGroupSubtotalGreen;
    } else if (group.subtotal != null && group.subtotal! < 0) {
      subtotalStyle = AppTypography.dayGroupSubtotalRed;
    } else {
      subtotalStyle = AppTypography.dayGroupSubtotalNeutral;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar judul kelompok: lebar penuh, latar sedikit berbeda, tinggi ringkas
        Container(
          width: double.infinity,
          color: AppColors.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceXs + 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                FinanceCalculator.formatDayGroupHeader(group.date, now: now),
                style: AppTypography.dayGroupHeaderDate,
              ),
              if (subtotalText != null)
                Text(
                  subtotalText,
                  style: subtotalStyle,
                ),
            ],
          ),
        ),

        // Daftar baris transaksi dipisahkan dengan garis tipis antar baris
        for (int i = 0; i < group.transactions.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.margin),
              child: Divider(
                height: AppDimens.borderWidthThin,
                thickness: AppDimens.borderWidthThin,
                color: AppColors.surfaceContainerHigh,
              ),
            ),
          BukuKasTransactionRow(
            transaction: group.transactions[i],
            walletName: getWalletName(group.transactions[i].walletId),
            targetWalletName: group.transactions[i].targetWalletId != null
                ? getWalletName(group.transactions[i].targetWalletId!)
                : null,
            categoryName: getCategoryName(group.transactions[i].categoryId),
            onTap: () => onTransactionTap(group.transactions[i]),
          ),
        ],
        const SizedBox(height: AppDimens.spaceSm),
      ],
    );
  }
}
