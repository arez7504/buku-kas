import 'package:flutter/material.dart';
import '../logic/finance_state.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../widgets/category_delete_dialog.dart';
import '../widgets/category_management_card.dart';
import '../widgets/category_segmented_tabs.dart';

import 'category_form_screen.dart';

/// Layar Kelola Kategori bertema gelap sesuai Milestone UI-6 dan UI-7
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

  void _openAddCategory(FinanceState state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(
          initialType: _currentTabType,
          onValidate: (name, type) => state.validateCategoryName(name, type),
          onSave: (name, type, iconKey, colorKey) async {
            final newCategory = Category(
              id: 'c_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              type: type,
              iconKey: iconKey,
              colorKey: colorKey,
            );
            await state.addCategory(newCategory);
          },
        ),
      ),
    );
  }

  void _openEditCategory(FinanceState state, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(
          category: category,
          onValidate: (name, type) => state.validateCategoryName(
            name,
            category.type,
            excludeCategoryId: category.id,
          ),
          onSave: (newName, type, iconKey, colorKey) async {
            final updated = category.copyWith(
              name: newName,
              iconKey: iconKey,
              colorKey: colorKey,
            );
            await state.updateCategory(updated);
          },
        ),
      ),
    );
  }

  void _handleDeleteOrArchive(FinanceState state, Category category) {
    final isUsed = state.isCategoryUsed(category.id);

    if (isUsed) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return CategoryCannotDeleteDialog(
            category: category,
            onArchive: () async {
              final messenger = ScaffoldMessenger.of(context);
              await state.archiveCategory(category.id, isArchived: true);
              if (!mounted) return;
              _showSnackBar(messenger, 'Kategori "${category.name}" berhasil diarsipkan');
            },
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return CategoryConfirmDeleteDialog(
            category: category,
            onConfirmDelete: () async {
              final messenger = ScaffoldMessenger.of(context);
              await state.deleteCategory(category.id);
              if (!mounted) return;
              _showSnackBar(messenger, 'Kategori "${category.name}" berhasil dihapus permanen');
            },
          );
        },
      );
    }
  }

  void _showSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.onSurface)),
        backgroundColor: AppColors.settingsCardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          side: const BorderSide(color: AppColors.borderFaint),
        ),
      ),
    );
  }

  Widget _buildCategoryList(FinanceState state, CategoryType type) {
    final all = state.categories.where((c) => c.type == type).toList();
    final active = all.where((c) => !c.isArchived).toList();
    final archived = all.where((c) => c.isArchived).toList();

    if (all.isEmpty) {
      return Center(
        child: Text(
          'Belum ada kategori ${type == CategoryType.income ? "pemasukan" : "pengeluaran"}',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    final totalItems = active.length + (archived.isNotEmpty ? 1 + archived.length : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceMd,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index < active.length) {
          final cat = active[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spaceSm + 4),
            child: CategoryManagementCard(
              category: cat,
              onEdit: () => _openEditCategory(state, cat),
              onArchiveToggle: () async {
                final messenger = ScaffoldMessenger.of(context);
                await state.archiveCategory(cat.id, isArchived: true);
                if (!mounted) return;
                _showSnackBar(messenger, 'Kategori "${cat.name}" diarsipkan');
              },
              onDelete: () => _handleDeleteOrArchive(state, cat),
            ),
          );
        }

        if (index == active.length) {
          return Padding(
            padding: const EdgeInsets.only(
              top: AppDimens.spaceSm,
              bottom: AppDimens.spaceSm,
            ),
            child: Text(
              'DIARSIPKAN',
              style: AppTypography.settingsSectionHeader.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          );
        }

        final archivedIndex = index - active.length - 1;
        final cat = archived[archivedIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.spaceSm + 4),
          child: CategoryManagementCard(
            category: cat,
            isArchived: true,
            onEdit: () => _openEditCategory(state, cat),
            onArchiveToggle: () async {
              final messenger = ScaffoldMessenger.of(context);
              await state.archiveCategory(cat.id, isArchived: false);
              if (!mounted) return;
              _showSnackBar(messenger, 'Kategori "${cat.name}" diaktifkan kembali');
            },
            onDelete: () => _handleDeleteOrArchive(state, cat),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(FinanceState state) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: const Text('Kelola Kategori', style: AppTypography.headlineSm),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          width: AppDimens.addButtonSize,
          height: AppDimens.addButtonSize,
          margin: const EdgeInsets.only(right: AppDimens.spaceSm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: AppDimens.borderWidthThin,
            ),
            boxShadow: AppShadows.walletAddButton,
          ),
          child: IconButton(
            key: const Key('add_category_button'),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, size: 22, color: AppColors.primary),
            tooltip: 'Tambah Kategori',
            onPressed: () => _openAddCategory(state),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: SafeArea(
        child: Column(
          children: [
            CategorySegmentedTabs(tabController: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryList(state, CategoryType.expense),
                  _buildCategoryList(state, CategoryType.income),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
