import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/finance_calculator.dart';
import '../logic/finance_state.dart';
import '../models/wallet.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import '../theme/wallet_style.dart';

/// Layar Tambah / Ubah Dompet layar penuh sesuai Milestone UI-8
class WalletFormScreen extends StatefulWidget {
  final Wallet? wallet;
  final String? Function(String name)? onValidateName;
  final Future<void> Function(
    String name,
    int initialBalance,
    String? iconKey,
    String? colorKey,
  )? onSave;

  const WalletFormScreen({
    super.key,
    this.wallet,
    this.onValidateName,
    this.onSave,
  });

  bool get isEdit => wallet != null;

  @override
  State<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends State<WalletFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  String? _selectedIconKey;
  String? _selectedColorKey;
  String? _nameError;
  bool _userExplicitlySelectedIcon = false;
  bool _userExplicitlySelectedColor = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet != null ? widget.wallet!.initialBalance.toString() : '0',
    );

    if (widget.isEdit) {
      final w = widget.wallet!;
      final defaultKeys = WalletStyleRegistry.getDefaultKeysForName(w.name);
      _selectedIconKey = w.iconKey ?? defaultKeys?.iconKey ?? 'dompet';
      _selectedColorKey = w.colorKey ?? defaultKeys?.colorKey ?? 'violet';
      _userExplicitlySelectedIcon = true;
      _userExplicitlySelectedColor = true;
    } else {
      final defaultKeys = WalletStyleRegistry.getDefaultKeysForName(_nameController.text);
      _selectedIconKey = defaultKeys?.iconKey ?? 'dompet';
      _selectedColorKey = defaultKeys?.colorKey ?? 'violet';
    }

    _nameController.addListener(_onNameChanged);
    _balanceController.addListener(_onBalanceChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _balanceController.removeListener(_onBalanceChanged);
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {
      if (_nameError != null) {
        _nameError = null;
      }

      // Jika menambah dompet dan belum memilih manual, deteksi otomatis dari nama
      if (!widget.isEdit) {
        final defaultKeys = WalletStyleRegistry.getDefaultKeysForName(_nameController.text);
        if (defaultKeys != null) {
          if (!_userExplicitlySelectedIcon) {
            _selectedIconKey = defaultKeys.iconKey;
          }
          if (!_userExplicitlySelectedColor) {
            _selectedColorKey = defaultKeys.colorKey;
          }
        }
      }
    });
  }

  void _onBalanceChanged() {
    setState(() {});
  }

  void _onIconSelected(String key) {
    setState(() {
      _userExplicitlySelectedIcon = true;
      _selectedIconKey = key;
    });
  }

  void _onColorSelected(String key) {
    setState(() {
      _userExplicitlySelectedColor = true;
      _selectedColorKey = key;
    });
  }

  Future<void> _handleSave() async {
    final rawName = _nameController.text;
    final trimmedName = rawName.trim();

    String? error;
    if (trimmedName.isEmpty) {
      error = 'Nama dompet tidak boleh kosong';
    } else if (trimmedName.length > 30) {
      error = 'Nama dompet maksimal 30 karakter';
    } else if (widget.onValidateName != null) {
      error = widget.onValidateName!(trimmedName);
    } else {
      final state = FinanceScope.maybeOf(context);
      if (state != null) {
        error = state.validateWalletName(
          trimmedName,
          excludeWalletId: widget.wallet?.id,
        );
      }
    }

    if (error != null) {
      setState(() {
        _nameError = error;
      });
      return;
    }

    final balance = int.tryParse(_balanceController.text) ?? 0;

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.onSave != null) {
        await widget.onSave!(
          trimmedName,
          balance,
          _selectedIconKey,
          _selectedColorKey,
        );
      } else {
        final state = FinanceScope.maybeOf(context);
        if (state != null) {
          if (widget.isEdit) {
            final updated = widget.wallet!.copyWith(
              name: trimmedName,
              initialBalance: balance,
              iconKey: _selectedIconKey,
              colorKey: _selectedColorKey,
            );
            await state.updateWallet(updated);
          } else {
            final newWallet = Wallet(
              id: 'w_${DateTime.now().millisecondsSinceEpoch}',
              name: trimmedName,
              initialBalance: balance,
              iconKey: _selectedIconKey,
              colorKey: _selectedColorKey,
            );
            await state.addWallet(newWallet);
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBalance = int.tryParse(_balanceController.text) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Ubah Dompet' : 'Tambah Dompet',
          style: AppTypography.headlineSm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pratinjau langsung kartu dompet
              _WalletPreviewBox(
                name: _nameController.text.trim(),
                balance: currentBalance,
                iconKey: _selectedIconKey,
                colorKey: _selectedColorKey,
              ),
              const SizedBox(height: AppDimens.spaceLg),

              // 2. Input Nama Dompet (0/30)
              _WalletNameInput(
                controller: _nameController,
                isEdit: widget.isEdit,
                errorMessage: _nameError,
              ),
              const SizedBox(height: AppDimens.spaceMd),

              // 3. Input Saldo Awal (Rp)
              _WalletBalanceInput(
                controller: _balanceController,
                isEdit: widget.isEdit,
              ),
              const SizedBox(height: AppDimens.spaceLg),

              // 4. Grid Pilih Ikon (uang, dompet, bank)
              _WalletIconRow(
                selectedIconKey: _selectedIconKey,
                onIconSelected: _onIconSelected,
              ),
              const SizedBox(height: AppDimens.spaceLg),

              // 5. Grid Pilih Warna (12 bulatan warna)
              _WalletColorGrid(
                selectedColorKey: _selectedColorKey,
                onColorSelected: _onColorSelected,
              ),
              const SizedBox(height: AppDimens.spaceLg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.margin,
            AppDimens.spaceSm,
            AppDimens.margin,
            AppDimens.margin,
          ),
          child: _WalletSaveButton(
            isSaving: _isSaving,
            isEdit: widget.isEdit,
            onPressed: _isSaving ? null : _handleSave,
          ),
        ),
      ),
    );
  }
}

/// 1. Komponen Pratinjau Langsung Dompet
class _WalletPreviewBox extends StatelessWidget {
  final String name;
  final int balance;
  final String? iconKey;
  final String? colorKey;

  const _WalletPreviewBox({
    required this.name,
    required this.balance,
    required this.iconKey,
    required this.colorKey,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.isNotEmpty ? name : 'Nama Dompet';
    final resolvedStyle = WalletStyleRegistry.resolveWalletStyle(
      walletName: name.isNotEmpty ? name : 'Pratinjau',
      iconKey: iconKey,
      colorKey: colorKey,
    );

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.settingsCardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.borderFaint),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.walletIconBoxSize,
            height: AppDimens.walletIconBoxSize,
            decoration: BoxDecoration(
              gradient: resolvedStyle.gradient,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              border: Border.all(
                color: resolvedStyle.borderColor,
                width: AppDimens.borderWidthMedium,
              ),
              boxShadow: resolvedStyle.shadow,
            ),
            child: Icon(
              resolvedStyle.icon,
              size: AppDimens.walletIconInner,
              color: resolvedStyle.iconColor,
            ),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: AppTypography.titleMd.copyWith(
                    color: name.isNotEmpty ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.spaceXs - 2),
                Text(
                  'Saldo: ${FinanceCalculator.formatRupiah(balance)}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Komponen Input Nama Dompet (0/30)
class _WalletNameInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isEdit;
  final String? errorMessage;

  const _WalletNameInput({
    required this.controller,
    required this.isEdit,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final charCount = controller.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('NAMA DOMPET', style: AppTypography.settingsSectionHeader),
            Text(
              '$charCount/30',
              style: TextStyle(
                fontSize: 12,
                color: charCount > 30 ? AppColors.error : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spaceSm),
        TextField(
          key: isEdit
              ? const Key('wallet_name_edit_input')
              : const Key('wallet_name_input'),
          controller: controller,
          maxLength: 30,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Contoh: BCA, Dompet Tunai',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            errorText: errorMessage,
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              borderSide: const BorderSide(color: AppColors.borderFaint),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              borderSide: const BorderSide(color: AppColors.borderFaint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// 3. Komponen Input Saldo Awal (Rp)
class _WalletBalanceInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isEdit;

  const _WalletBalanceInput({
    required this.controller,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SALDO AWAL (RP)', style: AppTypography.settingsSectionHeader),
        const SizedBox(height: AppDimens.spaceSm),
        TextField(
          key: isEdit
              ? const Key('wallet_balance_edit_input')
              : const Key('wallet_balance_input'),
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              borderSide: const BorderSide(color: AppColors.borderFaint),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              borderSide: const BorderSide(color: AppColors.borderFaint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// 4. Komponen Baris Pilih Ikon (3 ikon dalam 1 baris: uang, dompet, bank)
class _WalletIconRow extends StatelessWidget {
  final String? selectedIconKey;
  final ValueChanged<String> onIconSelected;

  const _WalletIconRow({
    required this.selectedIconKey,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconEntries = WalletStyleRegistry.icons.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PILIH IKON', style: AppTypography.settingsSectionHeader),
        const SizedBox(height: AppDimens.spaceSm),
        Container(
          padding: const EdgeInsets.all(AppDimens.spaceSm),
          decoration: BoxDecoration(
            color: AppColors.settingsCardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.borderFaint),
          ),
          child: Row(
            children: [
              for (int i = 0; i < iconEntries.length; i++) ...[
                if (i > 0) const SizedBox(width: AppDimens.spaceSm),
                Expanded(
                  child: _WalletIconTile(
                    iconKey: iconEntries[i].key,
                    iconData: iconEntries[i].value,
                    isSelected: iconEntries[i].key == selectedIconKey,
                    onTap: () => onIconSelected(iconEntries[i].key),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WalletIconTile extends StatelessWidget {
  final String iconKey;
  final IconData iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletIconTile({
    required this.iconKey,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('wallet_icon_$iconKey'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderFaint,
              width: isSelected ? AppDimens.borderWidthMedium : AppDimens.borderWidthThin,
            ),
          ),
          child: Icon(
            iconData,
            size: AppDimens.iconLarge,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 5. Komponen Grid Pilih Warna (12 bulatan warna dengan centang pada yang terpilih)
class _WalletColorGrid extends StatelessWidget {
  final String? selectedColorKey;
  final ValueChanged<String> onColorSelected;

  const _WalletColorGrid({
    required this.selectedColorKey,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorEntries = WalletStyleRegistry.colors.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PILIH WARNA', style: AppTypography.settingsSectionHeader),
        const SizedBox(height: AppDimens.spaceSm),
        Container(
          padding: const EdgeInsets.all(AppDimens.spaceSm),
          decoration: BoxDecoration(
            color: AppColors.settingsCardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.borderFaint),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - (AppDimens.spaceSm * 5)) / 6;
              return Wrap(
                spacing: AppDimens.spaceSm,
                runSpacing: AppDimens.spaceSm,
                children: [
                  for (final entry in colorEntries)
                    SizedBox(
                      width: itemWidth,
                      height: itemWidth,
                      child: _WalletColorTile(
                        colorKey: entry.key,
                        colorItem: entry.value,
                        isSelected: entry.key == selectedColorKey,
                        onTap: () => onColorSelected(entry.key),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WalletColorTile extends StatelessWidget {
  final String colorKey;
  final CategoryColorItem colorItem;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletColorTile({
    required this.colorKey,
    required this.colorItem,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('wallet_color_$colorKey'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          alignment: Alignment.center,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colorItem.gradient,
              ),
              border: Border.all(
                color: isSelected ? Colors.white : AppColors.borderFaint,
                width: isSelected ? 2.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorItem.gradient.first.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// 6. Tombol CTA Simpan
class _WalletSaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEdit;
  final VoidCallback? onPressed;

  const _WalletSaveButton({
    required this.isSaving,
    required this.isEdit,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        key: isEdit
            ? const Key('wallet_update_button')
            : const Key('wallet_save_button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Simpan',
                style: AppTypography.titleMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
