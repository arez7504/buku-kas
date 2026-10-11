import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../theme/app_theme.dart';

/// Dialog konfirmasi peringatan saat mengarsipkan dompet yang memiliki saldo bukan nol (NAV-2)
class WalletArchiveWarningDialog extends StatelessWidget {
  final String walletName;
  final int balance;

  const WalletArchiveWarningDialog({
    super.key,
    required this.walletName,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final formattedBalance = FinanceCalculator.formatRupiah(balance.abs());
    final isNegative = balance < 0;
    final balanceText = isNegative ? '- $formattedBalance' : formattedBalance;

    return AlertDialog(
      title: const Text('Arsipkan Dompet?', style: AppTypography.headlineSm),
      content: Text(
        'Dompet "$walletName" memiliki saldo sebesar $balanceText. Mengarsipkan dompet ini akan menyebabkan Saldo Total berkurang sebesar nominal tersebut. Apakah Anda yakin ingin mengarsipkannya?',
        style: AppTypography.bodyMd,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Batal',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: const Key('confirm_archive_wallet_button'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Arsipkan', style: TextStyle(color: AppColors.onPrimary)),
        ),
      ],
    );
  }
}
