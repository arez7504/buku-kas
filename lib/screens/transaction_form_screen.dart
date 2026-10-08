import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../logic/finance_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/catat_amount_display.dart';
import '../widgets/catat_category_selector.dart';
import '../widgets/catat_note_input.dart';
import '../widgets/catat_numeric_keypad.dart';
import '../widgets/catat_submit_button.dart';
import '../widgets/catat_type_tabs.dart';
import '../widgets/catat_wallet_selector.dart';

// Layar Catat Transaksi sesuai design/catat.html dan design/catat.png
class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormScreen({
    super.key,
    this.transaction,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late TextEditingController _noteController;
  late String _rawAmount;
  late TransactionType _selectedType;
  late DateTime _selectedDate;
  String? _selectedWalletId;
  String? _selectedTargetWalletId;
  String? _selectedCategoryId;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;

    _rawAmount = tx != null ? tx.amount.toString() : '0';
    _noteController = TextEditingController(text: tx?.note ?? '');
    _selectedType = tx?.type ?? TransactionType.expense;
    _selectedDate = tx?.date ?? DateTime.now();
    _selectedWalletId = tx?.walletId;
    _selectedTargetWalletId = tx?.targetWalletId;
    _selectedCategoryId = tx?.categoryId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = FinanceScope.of(context);
    final activeWallets = state.activeWallets;

    if (_selectedWalletId == null || !activeWallets.any((w) => w.id == _selectedWalletId)) {
      if (_isEditing && activeWallets.any((w) => w.id == widget.transaction!.walletId)) {
        _selectedWalletId = widget.transaction!.walletId;
      } else {
        _selectedWalletId = (state.lastSelectedWalletId != null &&
                activeWallets.any((w) => w.id == state.lastSelectedWalletId))
            ? state.lastSelectedWalletId
            : (activeWallets.isNotEmpty ? activeWallets.first.id : null);
      }
    }

    if (_selectedType == TransactionType.transfer &&
        (_selectedTargetWalletId == null || !activeWallets.any((w) => w.id == _selectedTargetWalletId))) {
      if (_isEditing && activeWallets.any((w) => w.id == widget.transaction!.targetWalletId)) {
        _selectedTargetWalletId = widget.transaction!.targetWalletId;
      } else {
        final otherWallet = activeWallets.where((w) => w.id != _selectedWalletId);
        _selectedTargetWalletId = otherWallet.isNotEmpty
            ? otherWallet.first.id
            : (activeWallets.length > 1 ? activeWallets[1].id : null);
      }
    }

    if (_selectedType != TransactionType.transfer &&
        (_selectedCategoryId == null || !state.activeCategories.any((c) => c.id == _selectedCategoryId))) {
      final availableCategories = state.getCategoriesByType(_selectedType, includeArchived: false);
      if (availableCategories.isNotEmpty) {
        _selectedCategoryId = availableCategories.first.id;
      }
    }
  }

  int _keypadTapEpoch = 0;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    setState(() {
      _keypadTapEpoch++;
      if (_rawAmount == '0') {
        _rawAmount = digit;
      } else if (_rawAmount.length < 11) {
        _rawAmount += digit;
      }
    });
  }

  void _onQuickZeros() {
    setState(() {
      _keypadTapEpoch++;
      if (_rawAmount.isNotEmpty && _rawAmount != '0' && _rawAmount.length <= 8) {
        _rawAmount += '000';
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _keypadTapEpoch++;
      if (_rawAmount.length > 1) {
        _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
      } else {
        _rawAmount = '0';
      }
    });
  }

  void _onTypeChanged(TransactionType newType) {
    setState(() {
      _selectedType = newType;
      final state = FinanceScope.of(context);

      if (_selectedType == TransactionType.transfer) {
        _selectedCategoryId = null;
        if (_selectedTargetWalletId == null || _selectedTargetWalletId == _selectedWalletId) {
          final otherWallets = state.wallets.where((w) => w.id != _selectedWalletId);
          _selectedTargetWalletId = otherWallets.isNotEmpty ? otherWallets.first.id : null;
        }
      } else {
        _selectedTargetWalletId = null;
        final availableCategories = state.getCategoriesByType(_selectedType);
        final isCategoryValid = availableCategories.any((c) => c.id == _selectedCategoryId);
        if (!isCategoryValid) {
          _selectedCategoryId =
              availableCategories.isNotEmpty ? availableCategories.first.id : null;
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getFormattedAmount() {
    final intVal = int.tryParse(_rawAmount) ?? 0;
    if (intVal == 0) return '0';
    return FinanceCalculator.formatRupiah(intVal).replaceFirst('Rp ', '');
  }

  String _formatDateText(DateTime date) {
    const monthShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final now = DateTime.now();
    final isToday = now.year == date.year && now.month == date.month && now.day == date.day;
    final prefix = isToday ? 'Hari ini, ' : '';
    return '$prefix${date.day} ${monthShort[date.month - 1]}';
  }

  String _getSubmitButtonLabel() {
    if (_isEditing) return 'Simpan Perubahan';
    switch (_selectedType) {
      case TransactionType.expense:
        return 'Simpan Pengeluaran';
      case TransactionType.income:
        return 'Simpan Pemasukan';
      case TransactionType.transfer:
        return 'Simpan Transfer';
    }
  }

  Future<void> _saveTransaction() async {
    final amountVal = int.tryParse(_rawAmount) ?? 0;
    final state = FinanceScope.of(context);

    final validationError = FinanceState.validate(
      amount: amountVal,
      type: _selectedType,
      walletId: _selectedWalletId ?? '',
      targetWalletId: _selectedTargetWalletId,
      categoryId: _selectedCategoryId,
    );

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final noteText = _noteController.text.trim();
    final noteValue = noteText.isNotEmpty ? noteText : null;

    if (_isEditing) {
      final updatedTx = Transaction(
        id: widget.transaction!.id,
        type: _selectedType,
        amount: amountVal,
        date: _selectedDate,
        walletId: _selectedWalletId!,
        targetWalletId: _selectedType == TransactionType.transfer ? _selectedTargetWalletId : null,
        categoryId: _selectedType != TransactionType.transfer ? _selectedCategoryId : null,
        note: noteValue,
      );
      await state.updateTransaction(updatedTx);
    } else {
      final newTx = Transaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: _selectedType,
        amount: amountVal,
        date: _selectedDate,
        walletId: _selectedWalletId!,
        targetWalletId: _selectedType == TransactionType.transfer ? _selectedTargetWalletId : null,
        categoryId: _selectedType != TransactionType.transfer ? _selectedCategoryId : null,
        note: noteValue,
      );
      await state.addTransaction(newTx);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Hapus Transaksi?', style: AppTypography.headlineSm),
          content: const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini akan mengembalikan saldo dompet dan ringkasan.',
            style: AppTypography.bodyMd,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final state = FinanceScope.of(context);
                Navigator.pop(dialogContext);
                await state.deleteTransaction(widget.transaction!.id);
                navigator.pop();
              },
              child: const Text('Hapus', style: TextStyle(color: AppColors.onPrimary)),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isEditing ? 'Edit Transaksi' : 'Catat Transaksi',
        style: AppTypography.headlineSm,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus Transaksi',
            onPressed: _confirmDelete,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);
    final wallets = state.activeWallets;
    final availableCategories = state.getCategoriesByType(_selectedType, includeArchived: false);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Row(
              children: [
                if (!_isEditing)
                  const Text('Tambah Transaksi', style: AppTypography.hiddenTestHelper),
                const Text('Simpan Transaksi', style: AppTypography.hiddenTestHelper),
              ],
            ),
            CatatTypeTabs(
              selectedType: _selectedType,
              onTypeChanged: _onTypeChanged,
            ),
            CatatAmountDisplay(
              type: _selectedType,
              formattedAmount: _getFormattedAmount(),
              dateText: _formatDateText(_selectedDate),
              onDateTap: _pickDate,
              keypadTapEpoch: _keypadTapEpoch,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.margin,
                vertical: AppDimens.spaceSm,
              ),
              child: Column(
                children: [
                  if (_selectedType != TransactionType.transfer) ...[
                    CatatCategorySelector(
                      categories: availableCategories,
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: (catId) => setState(() => _selectedCategoryId = catId),
                    ),
                    const SizedBox(height: AppDimens.spaceSm),
                  ],
                  CatatWalletSelector(
                    type: _selectedType,
                    wallets: wallets,
                    selectedWalletId: _selectedWalletId,
                    selectedTargetWalletId: _selectedTargetWalletId,
                    onWalletSelected: (wId) => setState(() => _selectedWalletId = wId),
                    onTargetWalletSelected: (wId) => setState(() => _selectedTargetWalletId = wId),
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  CatatNoteInput(controller: _noteController),
                  const SizedBox(height: AppDimens.spaceSm),
                  CatatNumericKeypad(
                    onDigit: _onDigit,
                    onQuickZeros: _onQuickZeros,
                    onBackspace: _onBackspace,
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  CatatSubmitButton(
                    label: _getSubmitButtonLabel(),
                    onSubmit: _saveTransaction,
                  ),
                  const SizedBox(height: AppDimens.spaceMd),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
