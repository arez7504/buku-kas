import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

// Baris transaksi individual sesuai design/buku_kas.html
class BukuKasTransactionRow extends StatelessWidget {
  final Transaction transaction;
  final String walletName;
  final String? targetWalletName;
  final String categoryName;
  final VoidCallback onTap;

  const BukuKasTransactionRow({
    super.key,
    required this.transaction,
    required this.walletName,
    this.targetWalletName,
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTransfer = transaction.type == TransactionType.transfer;
    final isIncome = transaction.type == TransactionType.income;

    // Judul: catatan jika ada, jika kosong nama kategori
    final titleText = isTransfer
        ? 'Transfer: $walletName → ${targetWalletName ?? '-'}'
        : (transaction.note != null && transaction.note!.trim().isNotEmpty
            ? transaction.note!
            : categoryName);

    // Keterangan dompet
    final subtitleText = isTransfer
        ? '$walletName ➔ ${targetWalletName ?? '-'}'
        : '$walletName • ${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}';

    // Nominal dan gaya warna
    final String amountText;
    final TextStyle amountStyle;
    final String categoryTag;

    if (isTransfer) {
      amountText = FinanceCalculator.formatRupiah(transaction.amount);
      amountStyle = AppTypography.amountRow;
      categoryTag = 'TRANSFER';
    } else if (isIncome) {
      amountText = '+ ${FinanceCalculator.formatRupiah(transaction.amount)}';
      amountStyle = AppTypography.amountRowGreen;
      categoryTag = categoryName.toUpperCase();
    } else {
      amountText = '− ${FinanceCalculator.formatRupiah(transaction.amount)}';
      amountStyle = AppTypography.amountRowRed;
      categoryTag = categoryName.toUpperCase();
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.margin,
          vertical: AppDimens.spaceMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.spaceXs / 2),
                  Text(subtitleText, style: AppTypography.bodySm),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.spaceMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amountText, style: amountStyle),
                const SizedBox(height: AppDimens.spaceXs / 2),
                Text(categoryTag, style: AppTypography.labelCaps),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
