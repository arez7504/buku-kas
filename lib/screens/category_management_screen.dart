import 'package:flutter/material.dart';
import '../logic/finance_state.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

// Layar Kelola Kategori sesuai Milestone 5:
// Daftar dikelompokkan Pemasukan/Pengeluaran, tambah, ubah nama, arsipkan, hapus bersyarat
class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  CategoryType get _currentTabType =>
      _tabController.index == 0 ? CategoryType.expense : CategoryType.income;

  void _showAddCategoryDialog(FinanceState state) {
    final nameController = TextEditingController();
    var selectedType = _currentTabType;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Tambah Kategori', style: AppTypography.headlineSm),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TIPE KATEGORI', style: AppTypography.labelCaps),
                  const SizedBox(height: AppDimens.spaceXs),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Pengeluaran')),
                          selected: selectedType == CategoryType.expense,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                selectedType = CategoryType.expense;
                                errorMessage = null;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimens.spaceSm),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Pemasukan')),
                          selected: selectedType == CategoryType.income,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                selectedType = CategoryType.income;
                                errorMessage = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.spaceMd),
                  TextField(
                    key: const Key('category_name_input'),
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                      errorText: errorMessage,
                      labelStyle: AppTypography.labelMd,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ),
                FilledButton(
                  key: const Key('category_save_button'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final validationError = state.validateCategoryName(name, selectedType);
                    if (validationError != null) {
                      setDialogState(() {
                        errorMessage = validationError;
                      });
                      return;
                    }

                    final newCategory = Category(
                      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      type: selectedType,
                    );

                    Navigator.pop(dialogContext);
                    await state.addCategory(newCategory);
                  },
                  child: const Text('Simpan', style: TextStyle(color: AppColors.onPrimary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(FinanceState state, Category category) {
    final nameController = TextEditingController(text: category.name);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Ubah Nama Kategori', style: AppTypography.headlineSm),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const Key('category_name_edit_input'),
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                      errorText: errorMessage,
                      labelStyle: AppTypography.labelMd,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ),
                FilledButton(
                  key: const Key('category_update_button'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final validationError = state.validateCategoryName(
                      name,
                      category.type,
                      excludeCategoryId: category.id,
                    );
                    if (validationError != null) {
                      setDialogState(() {
                        errorMessage = validationError;
                      });
                      return;
                    }

                    final updated = category.copyWith(name: name);

                    Navigator.pop(dialogContext);
                    await state.updateCategory(updated);
                  },
                  child: const Text('Simpan', style: TextStyle(color: AppColors.onPrimary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleDeleteOrArchive(FinanceState state, Category category) {
    final isUsed = state.isCategoryUsed(category.id);

    if (isUsed) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Tidak Dapat Dihapus', style: AppTypography.headlineSm),
            content: Text(
              'Kategori "${category.name}" sudah dipakai dalam transaksi sehingga tidak bisa dihapus permanen. Apakah Anda ingin mengarsipkannya agar tidak muncul lagi sebagai pilihan transaksi baru?',
              style: AppTypography.bodyMd,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ),
              if (!category.isArchived)
                FilledButton(
                  key: const Key('offer_archive_category_button'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(dialogContext);
                    await state.archiveCategory(category.id, isArchived: true);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Kategori "${category.name}" berhasil diarsipkan')),
                    );
                  },
                  child: const Text('Arsipkan', style: TextStyle(color: AppColors.onPrimary)),
                ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Hapus Kategori?', style: AppTypography.headlineSm),
            content: Text(
              'Apakah Anda yakin ingin menghapus kategori "${category.name}" secara permanen? Kategori ini belum memiliki transaksi apa pun.',
              style: AppTypography.bodyMd,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Batal', style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ),
              FilledButton(
                key: const Key('confirm_delete_category_button'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(dialogContext);
                  await state.deleteCategory(category.id);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Kategori "${category.name}" berhasil dihapus permanen')),
                  );
                },
                child: const Text('Hapus', style: TextStyle(color: AppColors.onPrimary)),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildCategoryList(FinanceState state, CategoryType type) {
    final list = state.categories.where((c) => c.type == type).toList();

    if (list.isEmpty) {
      return Center(
        child: Text(
          'Belum ada kategori ${type == CategoryType.income ? "pemasukan" : "pengeluaran"}',
          style: AppTypography.bodyMd,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceMd,
      ),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceSm),
      itemBuilder: (context, index) {
        final cat = list[index];

        return Container(
          decoration: BoxDecoration(
            color: cat.isArchived
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: AppDimens.borderWidthThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd,
            vertical: AppDimens.spaceSm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.spaceSm),
                decoration: BoxDecoration(
                  color: cat.isArchived
                      ? AppColors.surfaceContainerHighest
                      : (cat.type == CategoryType.income
                          ? AppColors.incomeGreen.withValues(alpha: 0.1)
                          : AppColors.expenseRed.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                ),
                child: Icon(
                  cat.type == CategoryType.income ? Icons.arrow_downward : Icons.arrow_upward,
                  size: AppDimens.iconSmall,
                  color: cat.isArchived
                      ? AppColors.onSurfaceVariant
                      : (cat.type == CategoryType.income ? AppColors.incomeGreen : AppColors.expenseRed),
                ),
              ),
              const SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: Text(
                  cat.name,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cat.isArchived ? AppColors.onSurfaceVariant : AppColors.onSurface,
                  ),
                ),
              ),
              if (cat.isArchived) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spaceXs + 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                  ),
                  child: const Text('Diarsipkan', style: AppTypography.labelCaps),
                ),
                const SizedBox(width: AppDimens.spaceSm),
              ],
              PopupMenuButton<String>(
                key: Key('category_menu_${cat.id}'),
                icon: const Icon(Icons.more_vert, size: AppDimens.iconMedium),
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEditCategoryDialog(state, cat);
                  } else if (value == 'archive') {
                    final messenger = ScaffoldMessenger.of(context);
                    await state.archiveCategory(cat.id, isArchived: !cat.isArchived);
                    if (!mounted) return;
                    final msg = cat.isArchived
                        ? 'Kategori "${cat.name}" diaktifkan kembali'
                        : 'Kategori "${cat.name}" diarsipkan';
                    messenger.showSnackBar(SnackBar(content: Text(msg)));
                  } else if (value == 'delete') {
                    _handleDeleteOrArchive(state, cat);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: AppDimens.iconSmall),
                        SizedBox(width: AppDimens.spaceSm),
                        Text('Ubah Nama', style: AppTypography.bodyMd),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          cat.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                          size: AppDimens.iconSmall,
                        ),
                        SizedBox(width: AppDimens.spaceSm),
                        Text(
                          cat.isArchived ? 'Buka Arsip' : 'Arsipkan',
                          style: AppTypography.bodyMd,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error, size: AppDimens.iconSmall),
                        SizedBox(width: AppDimens.spaceSm),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Kelola Kategori', style: AppTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            key: const Key('add_category_button'),
            icon: const Icon(Icons.add, size: AppDimens.iconLarge),
            tooltip: 'Tambah Kategori',
            onPressed: () => _showAddCategoryDialog(state),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.secondary,
          labelStyle: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTypography.labelMdInactive,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCategoryList(state, CategoryType.expense),
            _buildCategoryList(state, CategoryType.income),
          ],
        ),
      ),
    );
  }
}
