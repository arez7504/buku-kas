import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';

/// Modal Bottom Sheet untuk memilih filter kategori di Tab Riwayat
class RiwayatCategoryBottomSheet extends StatelessWidget {
  final String? selectedCategoryId;
  final TransactionFilterType filterType;
  final List<Category> categories;
  final ValueChanged<String?> onCategorySelected;

  const RiwayatCategoryBottomSheet({
    super.key,
    required this.selectedCategoryId,
    required this.filterType,
    required this.categories,
    required this.onCategorySelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String? selectedCategoryId,
    required TransactionFilterType filterType,
    required List<Category> categories,
  }) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      builder: (ctx) => RiwayatCategoryBottomSheet(
        selectedCategoryId: selectedCategoryId,
        filterType: filterType,
        categories: categories,
        onCategorySelected: (catId) {
          Navigator.pop(ctx, catId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Saring kategori berdasarkan filterType
    final List<Category> expenseCategories;
    final List<Category> incomeCategories;

    switch (filterType) {
      case TransactionFilterType.all:
        expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();
        incomeCategories = categories.where((c) => c.type == CategoryType.income).toList();
        break;
      case TransactionFilterType.expense:
        expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();
        incomeCategories = const [];
        break;
      case TransactionFilterType.income:
        expenseCategories = const [];
        incomeCategories = categories.where((c) => c.type == CategoryType.income).toList();
        break;
      case TransactionFilterType.transfer:
        expenseCategories = const [];
        incomeCategories = const [];
        break;
    }

    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppDimens.spaceSm, bottom: AppDimens.spaceXs),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.margin,
                vertical: AppDimens.spaceSm,
              ),
              child: Row(
                children: [
                  const Text(
                    'Pilih Kategori',
                    style: AppTypography.categorySheetTitle,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            // Daftar Kategori Scrollable
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.margin,
                  vertical: AppDimens.spaceSm,
                ),
                children: [
                  // Opsi Semua Kategori (Reset)
                  _buildAllCategoriesTile(context),
                  const SizedBox(height: AppDimens.spaceXs),

                  // Kategori Pengeluaran
                  if (expenseCategories.isNotEmpty) ...[
                    if (filterType == TransactionFilterType.all) ...[
                      const SizedBox(height: AppDimens.spaceSm),
                      _buildSectionHeader('PENGELUARAN'),
                      const SizedBox(height: AppDimens.spaceXs),
                    ],
                    for (final cat in expenseCategories)
                      _buildCategoryTile(context, cat, showType: filterType == TransactionFilterType.all),
                  ],

                  // Kategori Pemasukan
                  if (incomeCategories.isNotEmpty) ...[
                    if (filterType == TransactionFilterType.all) ...[
                      const SizedBox(height: AppDimens.spaceSm),
                      _buildSectionHeader('PEMASUKAN'),
                      const SizedBox(height: AppDimens.spaceXs),
                    ],
                    for (final cat in incomeCategories)
                      _buildCategoryTile(context, cat, showType: filterType == TransactionFilterType.all),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.categorySheetHeader,
    );
  }

  Widget _buildAllCategoriesTile(BuildContext context) {
    final isSelected = selectedCategoryId == null;
    return Material(
      color: isSelected ? AppColors.tintPurpleBg : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: () => onCategorySelected(null),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd,
            vertical: AppDimens.spaceSm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 20,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: Text(
                  'Semua Kategori',
                  style: isSelected
                      ? AppTypography.categoryItemNameActive
                      : AppTypography.categoryItemName,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category, {required bool showType}) {
    final isSelected = selectedCategoryId == category.id;
    final isArchived = category.isArchived;

    final resolvedStyle = CategoryStyleRegistry.resolveCategoryStyle(
      category: category,
      categoryName: category.name,
      transactionType: category.type == CategoryType.income
          ? TransactionType.income
          : TransactionType.expense,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spaceXs),
      child: Material(
        color: isSelected
            ? AppColors.tintPurpleBg
            : (isArchived
                ? AppColors.surfaceContainerLowest.withValues(alpha: 0.5)
                : AppColors.surfaceContainerLowest),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: InkWell(
          onTap: () => onCategorySelected(category.id),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceMd,
              vertical: AppDimens.spaceSm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Squircle icon
                Opacity(
                  opacity: isArchived ? 0.5 : 1.0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: resolvedStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      border: Border.all(color: resolvedStyle.borderColor),
                    ),
                    child: Icon(
                      resolvedStyle.icon,
                      size: 20,
                      color: resolvedStyle.iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              category.name,
                              style: (isSelected
                                      ? AppTypography.categoryItemNameActive
                                      : AppTypography.categoryItemName)
                                  .copyWith(
                                color: isArchived
                                    ? AppColors.onSurfaceVariant.withValues(alpha: 0.6)
                                    : (isSelected ? AppColors.primary : AppColors.onSurface),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isArchived) ...[
                            const SizedBox(width: AppDimens.spaceXs),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                              ),
                              child: Text(
                                'diarsipkan',
                                style: AppTypography.categoryItemArchivedBadge.copyWith(
                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (showType) ...[
                        const SizedBox(height: 2),
                        Text(
                          category.type == CategoryType.income ? 'Pemasukan' : 'Pengeluaran',
                          style: TextStyle(
                            fontFamily: AppFonts.plusJakartaSans,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: category.type == CategoryType.income
                                ? AppColors.incomeGreen
                                : AppColors.expenseRed,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
