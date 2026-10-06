import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

// Komponen pemilih kategori cepat dengan kontras yang ditingkatkan
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
            const Text('KATEGORI CEPAT', style: AppTypography.labelCaps),
            Text(_getSelectedCategoryName(), style: AppTypography.bodySm),
          ],
        ),
        const SizedBox(height: AppDimens.spaceSm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = cat.id == selectedCategoryId;

              return Padding(
                padding: const EdgeInsets.only(right: AppDimens.spaceSm),
                child: InkWell(
                  onTap: () => onCategorySelected(cat.id),
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.spaceMd,
                      vertical: AppDimens.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: AppDimens.borderWidthThin,
                      ),
                    ),
                    child: Text(
                      cat.name,
                      style: isSelected
                          ? AppTypography.labelMd.copyWith(color: AppColors.onPrimary)
                          : AppTypography.labelMd.copyWith(color: AppColors.onSurface),
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
