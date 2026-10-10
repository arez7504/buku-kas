import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Dialog tambah dan ubah dompet bertema gelap sesuai UI-5
class WalletFormDialog extends StatefulWidget {
  final bool isEdit;
  final String initialName;
  final int initialBalance;
  final String? Function(String name) onValidateName;
  final Future<void> Function(String name, int initialBalance) onSave;

  const WalletFormDialog({
    super.key,
    required this.isEdit,
    this.initialName = '',
    this.initialBalance = 0,
    required this.onValidateName,
    required this.onSave,
  });

  @override
  State<WalletFormDialog> createState() => _WalletFormDialogState();
}

class _WalletFormDialogState extends State<WalletFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _balanceController = TextEditingController(
      text: widget.initialBalance.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final error = widget.onValidateName(name);
    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return;
    }

    final balance = int.tryParse(_balanceController.text.trim()) ?? 0;
    Navigator.pop(context);
    await widget.onSave(name, balance);
  }

  @override
  Widget build(BuildContext context) {
    final nameKey = widget.isEdit
        ? const Key('wallet_name_edit_input')
        : const Key('wallet_name_input');
    final balanceKey = widget.isEdit
        ? const Key('wallet_balance_edit_input')
        : const Key('wallet_balance_input');
    final buttonKey = widget.isEdit
        ? const Key('wallet_update_button')
        : const Key('wallet_save_button');

    return AlertDialog(
      title: Text(
        widget.isEdit ? 'Ubah Dompet' : 'Tambah Dompet',
        style: AppTypography.headlineSm,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: nameKey,
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nama Dompet',
              errorText: _errorMessage,
              labelStyle: AppTypography.labelMd,
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),
          TextField(
            key: balanceKey,
            controller: _balanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Saldo Awal (Rp)',
              labelStyle: AppTypography.labelMd,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        FilledButton(
          key: buttonKey,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _submit,
          child: const Text('Simpan', style: TextStyle(color: AppColors.onPrimary)),
        ),
      ],
    );
  }
}
