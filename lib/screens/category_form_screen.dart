import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/finance_state.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';

/// Layar Tambah / Ubah Kategori layar penuh sesuai Milestone UI-7
class CategoryFormScreen extends StatefulWidget {
  final Category? category;
  final CategoryType initialType;
  final String? Function(String name, CategoryType type)? onValidate;
  final Future<void> Function(
    String name,
    CategoryType type,
    String? iconKey,
    String? colorKey,
  )? onSave;

  const CategoryFormScreen({
    super.key,
    this.category,
    this.initialType = CategoryType.expense,
    this.onValidate,
    this.onSave,
  });

  bool get isEditing => category != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  late TextEditingController _nameController;
  late PageController _pageController;
  late CategoryType _selectedType;
  String? _selectedIconKey;
  String? _selectedColorKey;
  String? _errorMessage;
  int _currentPage = 0;
  bool _userExplicitlySelectedIcon = false;
  bool _userExplicitlySelectedColor = false;
  bool _isSaving = false;

  int _getPageIndexForIcon(String? iconKey) {
    if (iconKey == null) return 0;
    final keys = CategoryStyleRegistry.icons.keys.toList();
    final index = keys.indexOf(iconKey);
    if (index < 0) return 0;
    return index ~/ 12;
  }

  @override
  void initState() {
    super.initState();
    _selectedType = widget.category?.type ?? widget.initialType;
    _nameController = TextEditingController(text: widget.category?.name ?? '');

    if (widget.isEditing) {
      _selectedIconKey = widget.category!.iconKey ??
          CategoryStyleRegistry.getDefaultKeysForName(widget.category!.name)?.iconKey ??
          'makan';
      _selectedColorKey = widget.category!.colorKey ??
          CategoryStyleRegistry.getDefaultKeysForName(widget.category!.name)?.colorKey ??
          'violet';
      _userExplicitlySelectedIcon = true;
      _userExplicitlySelectedColor = true;
    } else {
      final defaultKeys = CategoryStyleRegistry.getDefaultKeysForName(_nameController.text);
      _selectedIconKey = defaultKeys?.iconKey ?? (_selectedType == CategoryType.income ? 'gaji' : 'makan');
      _selectedColorKey = defaultKeys?.colorKey ?? 'violet';
    }

    final initialPage = _getPageIndexForIcon(_selectedIconKey);
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
    _pageController.addListener(_onPageControllerScrolled);

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _pageController.removeListener(_onPageControllerScrolled);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageControllerScrolled() {
    if (!mounted || !_pageController.hasClients) return;
    final page = _pageController.page;
    if (page != null) {
      final round = page.round();
      if (round != _currentPage) {
        setState(() {
          _currentPage = round;
        });
      }
    }
  }

  void _scrollToIconPage(String? iconKey) {
    if (iconKey == null || !_pageController.hasClients) return;
    final targetPage = _getPageIndexForIcon(iconKey);
    if (targetPage != _currentPage) {
      final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (disableAnimations) {
        _pageController.jumpToPage(targetPage);
      } else {
        _pageController.animateToPage(
          targetPage,
          duration: AppDurations.pageTransition,
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _onNameChanged() {
    setState(() {
      if (_errorMessage != null) {
        _errorMessage = null;
      }

      // Jika pengguna belum memilih ikon/warna manual saat tambah, sesuaikan otomatis dari nama
      if (!widget.isEditing) {
        final defaultKeys = CategoryStyleRegistry.getDefaultKeysForName(_nameController.text);
        if (defaultKeys != null) {
          if (!_userExplicitlySelectedIcon) {
            _selectedIconKey = defaultKeys.iconKey;
            _scrollToIconPage(defaultKeys.iconKey);
          }
          if (!_userExplicitlySelectedColor) {
            _selectedColorKey = defaultKeys.colorKey;
          }
        }
      }
    });
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
      error = 'Nama kategori tidak boleh kosong';
    } else if (trimmedName.length > 30) {
      error = 'Nama kategori maksimal 30 karakter';
    } else if (widget.onValidate != null) {
      error = widget.onValidate!(trimmedName, _selectedType);
    } else {
      final state = FinanceScope.maybeOf(context);
      if (state != null) {
        error = state.validateCategoryName(
          trimmedName,
          _selectedType,
          excludeCategoryId: widget.category?.id,
        );
      }
    }

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.onSave != null) {
        await widget.onSave!(
          trimmedName,
          _selectedType,
          _selectedIconKey,
          _selectedColorKey,
        );
      } else {
        final state = FinanceScope.maybeOf(context);
        if (state != null) {
          if (widget.isEditing) {
            final updated = widget.category!.copyWith(
              name: trimmedName,
              iconKey: _selectedIconKey,
              colorKey: _selectedColorKey,
            );
            await state.updateCategory(updated);
          } else {
            final newCategory = Category(
              id: 'c_${DateTime.now().millisecondsSinceEpoch}',
              name: trimmedName,
              type: _selectedType,
              iconKey: _selectedIconKey,
              colorKey: _selectedColorKey,
            );
            await state.addCategory(newCategory);
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
    final title = widget.isEditing ? 'Ubah Kategori' : 'Tambah Kategori';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(title, style: AppTypography.headlineSm),
        leading: IconButton(
          key: const Key('category_back_button'),
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            key: const Key('category_cancel_button'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariant)),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Pratinjau Kecil
              _CategoryPreviewBox(
                name: _nameController.text.trim(),
                iconKey: _selectedIconKey,
                colorKey: _selectedColorKey,
                type: _selectedType,
              ),
              const SizedBox(height: AppDimens.spaceLg),

              // 2. Pilihan Tipe
              _CategoryTypeSelector(
                isEditing: widget.isEditing,
                selectedType: _selectedType,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedType = type;
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: AppDimens.spaceLg),

              // 3. Kolom Nama Kategori
              _CategoryNameField(
                controller: _nameController,
                errorMessage: _errorMessage,
                isEditing: widget.isEditing,
              ),
              const SizedBox(height: AppDimens.spaceLg),

              // 4. Pemilih Ikon Geser (Paged)
              CategoryPagedIconPicker(
                pageController: _pageController,
                pageCount: (CategoryStyleRegistry.icons.length / 12).ceil(),
                currentPage: _currentPage,
                selectedIconKey: _selectedIconKey,
                onIconSelected: _onIconSelected,
              ),
              const SizedBox(height: AppDimens.spaceLg),

              // 5. Grid Pilih Warna
              _CategoryColorGrid(
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
          child: _CategorySaveButton(
            isSaving: _isSaving,
            isEditing: widget.isEditing,
            onPressed: _isSaving ? null : _handleSave,
          ),
        ),
      ),
    );
  }
}

/// 1. Komponen Pratinjau Kecil (Ikon + Warna + Nama yang sedang diketik)
class _CategoryPreviewBox extends StatelessWidget {
  final String name;
  final String? iconKey;
  final String? colorKey;
  final CategoryType type;

  const _CategoryPreviewBox({
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyleRegistry.resolveCategoryStyle(
      categoryName: name.isNotEmpty ? name : 'Pratinjau',
      iconKey: iconKey,
      colorKey: colorKey,
    );

    final displayName = name.isNotEmpty ? name : 'Nama Kategori';

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
            width: AppDimens.categoryIconBoxSize,
            height: AppDimens.categoryIconBoxSize,
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              border: Border.all(
                color: style.borderColor,
                width: AppDimens.borderWidthMedium,
              ),
            ),
            child: Icon(
              style.icon,
              size: AppDimens.iconMedium,
              color: style.iconColor,
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
                  type == CategoryType.income ? 'Pemasukan' : 'Pengeluaran',
                  style: AppTypography.bodySm.copyWith(
                    color: type == CategoryType.income
                        ? AppColors.incomeGreen
                        : AppColors.expenseRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Komponen Pilihan Tipe (Pengeluaran | Pemasukan)
class _CategoryTypeSelector extends StatelessWidget {
  final bool isEditing;
  final CategoryType selectedType;
  final ValueChanged<CategoryType> onTypeChanged;

  const _CategoryTypeSelector({
    required this.isEditing,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final label = selectedType == CategoryType.income ? 'Pemasukan' : 'Pengeluaran';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TIPE KATEGORI', style: AppTypography.settingsSectionHeader),
          const SizedBox(height: AppDimens.spaceSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceMd - 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              border: Border.all(color: AppColors.borderFaint),
            ),
            child: Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                color: selectedType == CategoryType.income
                    ? AppColors.incomeGreen
                    : AppColors.expenseRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TIPE KATEGORI', style: AppTypography.settingsSectionHeader),
        const SizedBox(height: AppDimens.spaceSm),
        Row(
          children: [
            Expanded(
              child: _TypeChipButton(
                title: 'Pengeluaran',
                isSelected: selectedType == CategoryType.expense,
                activeColor: AppColors.expenseRed,
                onTap: () => onTypeChanged(CategoryType.expense),
              ),
            ),
            const SizedBox(width: AppDimens.spaceMd),
            Expanded(
              child: _TypeChipButton(
                title: 'Pemasukan',
                isSelected: selectedType == CategoryType.income,
                activeColor: AppColors.incomeGreen,
                onTap: () => onTypeChanged(CategoryType.income),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeChipButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeChipButton({
    required this.title,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceSm),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.15)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.borderFaint,
              width: isSelected ? AppDimens.borderWidthMedium : AppDimens.borderWidthThin,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3. Komponen Kolom Nama Kategori (dengan penghitung 0/30 dan batas 30 karakter)
class _CategoryNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;
  final bool isEditing;

  const _CategoryNameField({
    required this.controller,
    required this.errorMessage,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NAMA KATEGORI', style: AppTypography.settingsSectionHeader),
        const SizedBox(height: AppDimens.spaceSm),
        TextField(
          key: const Key('category_name_input'),
          controller: controller,
          maxLength: 30,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Contoh: Makanan, Transportasi',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            errorText: errorMessage,
            errorMaxLines: 2,
            counterStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
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

/// 4. Komponen Pemilih Ikon Geser (Paged 3 baris x 4 kolom = 12 ikon per halaman)
class CategoryPagedIconPicker extends StatelessWidget {
  final PageController pageController;
  final int pageCount;
  final int currentPage;
  final String? selectedIconKey;
  final ValueChanged<String> onIconSelected;

  const CategoryPagedIconPicker({
    super.key,
    required this.pageController,
    required this.pageCount,
    required this.currentPage,
    required this.selectedIconKey,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconEntries = CategoryStyleRegistry.icons.entries.toList();

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppDimens.categoryPickerGridSpacing;
              // 4 kolom -> 3 jeda pemisah
              final itemWidth = (constraints.maxWidth - (spacing * 3)) / 4;
              // 3 baris -> 2 jeda pemisah
              final pageHeight = (itemWidth * 3) + (spacing * 2);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: pageHeight,
                    child: PageView.builder(
                      key: const Key('category_icon_page_view'),
                      controller: pageController,
                      itemCount: pageCount,
                      itemBuilder: (context, pageIndex) {
                        final startIndex = pageIndex * 12;
                        return CategoryIconPage(
                          startIndex: startIndex,
                          iconEntries: iconEntries,
                          selectedIconKey: selectedIconKey,
                          onIconSelected: onIconSelected,
                          spacing: spacing,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceSm),
                  CategoryPageIndicatorDots(
                    pageCount: pageCount,
                    currentPage: currentPage,
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

class CategoryIconPage extends StatelessWidget {
  final int startIndex;
  final List<MapEntry<String, IconData>> iconEntries;
  final String? selectedIconKey;
  final ValueChanged<String> onIconSelected;
  final double spacing;

  const CategoryIconPage({
    super.key,
    required this.startIndex,
    required this.iconEntries,
    required this.selectedIconKey,
    required this.onIconSelected,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 3; row++) ...[
          if (row > 0) SizedBox(height: spacing),
          Expanded(
            child: Row(
              children: [
                for (int col = 0; col < 4; col++) ...[
                  if (col > 0) SizedBox(width: spacing),
                  Expanded(
                    child: _buildTileOrPlaceholder(row * 4 + col),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTileOrPlaceholder(int slotOffset) {
    final entryIndex = startIndex + slotOffset;
    if (entryIndex < iconEntries.length) {
      final entry = iconEntries[entryIndex];
      return CategoryIconGridTile(
        iconKey: entry.key,
        iconData: entry.value,
        isSelected: entry.key == selectedIconKey,
        onTap: () => onIconSelected(entry.key),
      );
    }
    // Slot kosong di halaman terakhir tetap mengisi ruang agar tinggi halaman identik
    return const SizedBox.shrink();
  }
}

class CategoryIconGridTile extends StatelessWidget {
  final String iconKey;
  final IconData iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryIconGridTile({
    super.key,
    required this.iconKey,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ikon $iconKey',
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('category_icon_$iconKey'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: AppDimens.minTouchTarget,
              minHeight: AppDimens.minTouchTarget,
            ),
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
              size: AppDimens.iconMedium,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Indikator titik di bawah PageView (hanya titik, tanpa teks angka halaman)
class CategoryPageIndicatorDots extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const CategoryPageIndicatorDots({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      label: 'Halaman ${currentPage + 1} dari $pageCount',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < pageCount; i++) ...[
            if (i > 0) const SizedBox(width: AppDimens.categoryPickerDotSpacing),
            CategoryDotItem(
              isActive: i == currentPage,
              index: i,
            ),
          ],
        ],
      ),
    );
  }
}

class CategoryDotItem extends StatelessWidget {
  final bool isActive;
  final int index;

  const CategoryDotItem({
    super.key,
    required this.isActive,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final width = isActive
        ? AppDimens.categoryPickerDotWidthActive
        : AppDimens.categoryPickerDotWidthInactive;
    final color = isActive
        ? AppColors.categoryPickerDotActive
        : AppColors.categoryPickerDotInactive;

    return ExcludeSemantics(
      child: AnimatedContainer(
        key: Key('category_picker_dot_$index'),
        duration: disableAnimations ? Duration.zero : AppDurations.fast,
        curve: Curves.easeInOut,
        width: width,
        height: AppDimens.categoryPickerDotHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimens.categoryPickerDotHeight / 2),
        ),
      ),
    );
  }
}

/// 5. Komponen Grid Pilih Warna (12 bulatan warna dengan centang pada yang terpilih)
class _CategoryColorGrid extends StatelessWidget {
  final String? selectedColorKey;
  final ValueChanged<String> onColorSelected;

  const _CategoryColorGrid({
    required this.selectedColorKey,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorEntries = CategoryStyleRegistry.colors.entries.toList();

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
                      child: _ColorGridTile(
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

class _ColorGridTile extends StatelessWidget {
  final String colorKey;
  final CategoryColorItem colorItem;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorGridTile({
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
        key: Key('category_color_$colorKey'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppDimens.minTouchTarget,
            minHeight: AppDimens.minTouchTarget,
          ),
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
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// 6. Komponen Tombol Simpan
class _CategorySaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback? onPressed;

  const _CategorySaveButton({
    required this.isSaving,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        key: const Key('category_save_button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          ),
          elevation: 0,
        ),
        child: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Simpan',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
