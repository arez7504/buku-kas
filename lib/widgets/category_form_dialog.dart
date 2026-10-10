import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

/// Dialog bertema gelap untuk menambah kategori baru
class CategoryAddDialog extends StatefulWidget {
  final CategoryType initialType;
  final String? Function(String name, CategoryType type) onValidate;
  final void Function(String name, CategoryType type) onSave;

  const CategoryAddDialog({
    super.key,
    required this.initialType,
    required this.onValidate,
    required this.onSave,
  });

  @override
  State<CategoryAddDialog> createState() => _CategoryAddDialogState();
}

class _CategoryAddDialogState extends State<CategoryAddDialog> {
  late final TextEditingController _nameController;
  late CategoryType _selectedType;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final validationError = widget.onValidate(name, _selectedType);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    widget.onSave(name, _selectedType);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.settingsCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius2Xl),
        side: const BorderSide(color: AppColors.borderFaint),
      ),
      title: const Text('Tambah Kategori', style: AppTypography.headlineSm),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TIPE KATEGORI', style: AppTypography.labelCaps),
            const SizedBox(height: AppDimens.spaceSm),
            _buildTypeSelector(),
            const SizedBox(height: AppDimens.spaceMd),
            TextField(
              key: const Key('category_name_input'),
              controller: _nameController,
              autofocus: true,
              style: AppTypography.bodyLg,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                errorText: _errorMessage,
                labelStyle: AppTypography.labelMd,
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                  borderSide: const BorderSide(color: AppColors.borderFaint),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
              ),
              onSubmitted: (_) => _handleSave(),
            ),
          ],
        ),
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
          key: const Key('category_save_button'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            ),
          ),
          onPressed: _handleSave,
          child: const Text('Simpan', style: TextStyle(color: AppColors.onPrimary)),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Center(child: Text('Pengeluaran')),
            selected: _selectedType == CategoryType.expense,
            selectedColor: AppColors.primaryContainer,
            backgroundColor: AppColors.surfaceContainerLow,
            labelStyle: AppTypography.labelMd.copyWith(
              color: _selectedType == CategoryType.expense
                  ? Colors.white
                  : AppColors.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              side: BorderSide(
                color: _selectedType == CategoryType.expense
                    ? AppColors.primary
                    : AppColors.borderFaint,
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedType = CategoryType.expense;
                  _errorMessage = null;
                });
              }
            },
          ),
        ),
        const SizedBox(width: AppDimens.spaceSm),
        Expanded(
          child: ChoiceChip(
            label: const Center(child: Text('Pemasukan')),
            selected: _selectedType == CategoryType.income,
            selectedColor: AppColors.primaryContainer,
            backgroundColor: AppColors.surfaceContainerLow,
            labelStyle: AppTypography.labelMd.copyWith(
              color: _selectedType == CategoryType.income
                  ? Colors.white
                  : AppColors.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              side: BorderSide(
                color: _selectedType == CategoryType.income
                    ? AppColors.primary
                    : AppColors.borderFaint,
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedType = CategoryType.income;
                  _errorMessage = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Dialog bertema gelap untuk mengubah nama kategori
class CategoryEditDialog extends StatefulWidget {
  final Category category;
  final String? Function(String name) onValidate;
  final void Function(String newName) onSave;

  const CategoryEditDialog({
    super.key,
    required this.category,
    required this.onValidate,
    required this.onSave,
  });

  @override
  State<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<CategoryEditDialog> {
  late final TextEditingController _nameController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final validationError = widget.onValidate(name);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    widget.onSave(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.settingsCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius2Xl),
        side: const BorderSide(color: AppColors.borderFaint),
      ),
      title: const Text('Ubah Nama Kategori', style: AppTypography.headlineSm),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('category_name_edit_input'),
            controller: _nameController,
            autofocus: true,
            style: AppTypography.bodyLg,
            decoration: InputDecoration(
              labelText: 'Nama Kategori',
              errorText: _errorMessage,
              labelStyle: AppTypography.labelMd,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                borderSide: const BorderSide(color: AppColors.borderFaint),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
            onSubmitted: (_) => _handleSave(),
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
          key: const Key('category_update_button'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            ),
          ),
          onPressed: _handleSave,
          child: const Text('Simpan', style: TextStyle(color: AppColors.onPrimary)),
        ),
      ],
    );
  }
}
