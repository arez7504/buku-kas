import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

// Baris transaksi individual: baris flat dengan ikon bulat berwarna di kiri sesuai tipe
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
    final IconData badgeIcon;
    final Color badgeIconColor;
    final Color badgeBgColor;
    final String amountPrefix;
    final TextStyle amountStyle;

    switch (transaction.type) {
      case TransactionType.expense:
        badgeIcon = Icons.arrow_upward;
        badgeIconColor = AppColors.expenseRed;
        badgeBgColor = AppColors.expenseRedSoft;
        amountPrefix = '- ';
        amountStyle = AppTypography.transactionAmountExpense;
        break;
      case TransactionType.income:
        badgeIcon = Icons.arrow_downward;
        badgeIconColor = AppColors.incomeGreen;
        badgeBgColor = AppColors.incomeGreenSoft;
        amountPrefix = '+ ';
        amountStyle = AppTypography.transactionAmountIncome;
        break;
      case TransactionType.transfer:
        badgeIcon = Icons.swap_horiz;
        badgeIconColor = AppColors.transferBlue;
        badgeBgColor = AppColors.transferBlueSoft;
        amountPrefix = '';
        amountStyle = AppTypography.transactionAmountTransfer;
        break;
    }

    final titleText = transaction.type == TransactionType.transfer
        ? 'Transfer: $walletName ➔ ${targetWalletName ?? '-'}'
        : (categoryName.isNotEmpty ? categoryName : 'Lainnya');

    // Subtitle hanya menampilkan nama dompet karena tanggal sudah tertera di judul kelompok
    final subtitleText = walletName;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceMd - 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon bulat berwarna di kiri sesuai tipe
              Container(
                width: AppDimens.transactionBadgeSize,
                height: AppDimens.transactionBadgeSize,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badgeIcon,
                  color: badgeIconColor,
                  size: AppDimens.iconMedium,
                ),
              ),
              const SizedBox(width: AppDimens.spaceMd),
              // Informasi teks transaksi di tengah (teks utama >= 16 sp, pendukung >= 13 sp)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      style: AppTypography.transactionTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimens.spaceXs / 2),
                    Text(
                      subtitleText,
                      style: AppTypography.transactionSubtitle,
                    ),
                    if (transaction.note != null && transaction.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppDimens.spaceXs / 4),
                      Text(
                        transaction.note!.trim(),
                        style: AppTypography.transactionNote,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              // Nominal angka di kanan dalam sans-serif
              Text(
                '$amountPrefix${FinanceCalculator.formatRupiah(transaction.amount)}',
                style: amountStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
