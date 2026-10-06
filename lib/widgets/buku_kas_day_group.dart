import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'buku_kas_transaction_row.dart';

// Pengelompokan transaksi per hari dengan subtotal harian sesuai design/buku_kas.html
class BukuKasDayGroup extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;
  final String Function(String) getWalletName;
  final String Function(String?) getCategoryName;
  final void Function(Transaction) onTransactionTap;

  const BukuKasDayGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.getWalletName,
    required this.getCategoryName,
    required this.onTransactionTap,
  });

  String _formatDateHeader(DateTime d) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'];
    final now = DateTime.now();
    final isToday = now.year == d.year && now.month == d.month && now.day == d.day;
    final yest = now.subtract(const Duration(days: 1));
    final isYesterday = yest.year == d.year && yest.month == d.month && yest.day == d.day;

    final base = '${d.day} ${months[d.month - 1]} ${d.year}';
    if (isToday) return 'HARI INI, $base';
    if (isYesterday) return 'KEMARIN, $base';
    return base;
  }

  @override
  Widget build(BuildContext context) {
    // Hitung subtotal: masuk - keluar, transfer tidak dihitung
    int subtotal = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        subtotal += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        subtotal -= tx.amount;
      }
    }

    final subtotalText = subtotal > 0
        ? '+ ${FinanceCalculator.formatRupiah(subtotal)}'
        : (subtotal < 0 ? '− ${FinanceCalculator.formatRupiah(subtotal.abs())}' : 'Rp 0');

    final subtotalStyle = subtotal > 0
        ? AppTypography.bodySm.copyWith(color: AppColors.incomeGreen)
        : AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar tanggal & subtotal harian
        Container(
          width: double.infinity,
          color: AppColors.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceXs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDateHeader(date), style: AppTypography.labelCaps),
              Text(subtotalText, style: subtotalStyle),
            ],
          ),
        ),

        // Daftar baris transaksi hari tersebut
        for (int i = 0; i < transactions.length; i++) ...[
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
            transaction: transactions[i],
            walletName: getWalletName(transactions[i].walletId),
            targetWalletName: transactions[i].targetWalletId != null
                ? getWalletName(transactions[i].targetWalletId!)
                : null,
            categoryName: getCategoryName(transactions[i].categoryId),
            onTap: () => onTransactionTap(transactions[i]),
          ),
        ],
        const SizedBox(height: AppDimens.spaceSm),
      ],
    );
  }
}
