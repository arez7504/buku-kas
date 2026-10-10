import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../theme/category_icon_mapping.dart';
import '../theme/category_style.dart';

/// Kartu representasi kategori pada layar Kelola Kategori bertema gelap
class CategoryManagementCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;
  final bool isArchived;

  const CategoryManagementCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onArchiveToggle,
    required this.onDelete,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveArchived = isArchived || category.isArchived;
    final iconStyle = CategoryStyleRegistry.resolveCategoryStyle(category: category);

    return Container(
      decoration: BoxDecoration(
        color: effectiveArchived
            ? AppColors.surfaceContainerLow.withValues(alpha: 0.6)
            : AppColors.settingsCardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: effectiveArchived
              ? AppColors.borderFaint.withValues(alpha: 0.5)
              : AppColors.borderFaint,
          width: AppDimens.borderWidthThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceMd - 2,
      ),
      child: Row(
        children: [
          _buildIconBox(iconStyle, effectiveArchived),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.categoryCardTitle.copyWith(
                color: effectiveArchived
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface,
              ),
            ),
          ),
          if (effectiveArchived) ...[
            _buildArchivedBadge(),
            const SizedBox(width: AppDimens.spaceSm),
          ],
          _buildPopupMenu(),
        ],
      ),
    );
  }

  Widget _buildIconBox(CategoryIconStyle iconStyle, bool isArchived) {
    return Container(
      width: AppDimens.categoryIconBoxSize,
      height: AppDimens.categoryIconBoxSize,
      decoration: BoxDecoration(
        color: isArchived
            ? AppColors.surfaceContainerHighest
            : iconStyle.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isArchived ? AppColors.borderFaint : iconStyle.borderColor,
          width: AppDimens.borderWidthThin,
        ),
      ),
      child: Center(
        child: Icon(
          iconStyle.icon,
          size: AppDimens.categoryIconInner,
          color: isArchived ? AppColors.onSurfaceVariant : iconStyle.iconColor,
        ),
      ),
    );
  }

  Widget _buildArchivedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceSm,
        vertical: AppDimens.spaceXs - 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: const Text('Diarsipkan', style: AppTypography.labelCaps),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      key: Key('category_menu_${category.id}'),
      icon: const Icon(
        Icons.more_horiz,
        size: AppDimens.iconMedium,
        color: AppColors.onSurfaceVariant,
      ),
      color: AppColors.settingsCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        side: const BorderSide(color: AppColors.borderFaint),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'archive') {
          onArchiveToggle();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: AppDimens.iconSmall, color: AppColors.onSurface),
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
                category.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                size: AppDimens.iconSmall,
                color: AppColors.onSurface,
              ),
              SizedBox(width: AppDimens.spaceSm),
              Text(
                category.isArchived ? 'Buka Arsip' : 'Arsipkan',
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
    );
  }
}
