import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/transaction.dart';

// TransactionItem: Komponen kartu baris untuk satu transaksi
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final String walletName;
  final String? targetWalletName;
  final String categoryName;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.walletName,
    this.targetWalletName,
    required this.categoryName,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String prefix;

    switch (transaction.type) {
      case TransactionType.income:
        icon = Icons.arrow_downward;
        color = Colors.green.shade700;
        prefix = '+ ';
        break;
      case TransactionType.expense:
        icon = Icons.arrow_upward;
        color = Colors.red.shade700;
        prefix = '- ';
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        color = Colors.blue.shade700;
        prefix = '';
        break;
    }

    final String titleText = transaction.type == TransactionType.transfer
        ? 'Transfer: $walletName ➔ ${targetWalletName ?? '-'}'
        : categoryName;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0.8,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          titleText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${_formatDate(transaction.date)} • $walletName'),
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                transaction.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          '$prefix${FinanceCalculator.formatRupiah(transaction.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
