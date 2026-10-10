import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';

// Komponen pemilih kategori cepat sesuai design/catat.html
class CatatCategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const CatatCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  String _getSelectedCategoryName() {
    final match = categories.where((c) => c.id == selectedCategoryId);
    return match.isNotEmpty ? match.first.name : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('KATEGORI CEPAT', style: AppTypography.catatSectionTitle),
            Text(_getSelectedCategoryName(), style: AppTypography.catatSelectedCategory),
          ],
        ),
        const SizedBox(height: AppDimens.spaceSm - 2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = cat.id == selectedCategoryId;
              final catStyle = CategoryStyleRegistry.resolveCategoryStyle(category: cat);

              return Padding(
                padding: const EdgeInsets.only(right: AppDimens.spaceSm),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onCategorySelected(cat.id),
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.spaceMd - 2,
                        vertical: AppDimens.spaceSm - 1,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppGradients.catatCategoryActive : null,
                        color: isSelected ? null : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.catatCategoryActiveBorder
                              : AppColors.borderFaint,
                          width: AppDimens.borderWidthThin,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            catStyle.icon,
                            size: 15,
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppDimens.spaceXs + 2),
                          Text(
                            cat.name,
                            style: isSelected
                                ? AppTypography.catatCategoryActive
                                : AppTypography.catatCategoryInactive,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
