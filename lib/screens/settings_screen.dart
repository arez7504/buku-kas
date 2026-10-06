import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'category_management_screen.dart';
import 'wallet_management_screen.dart';

// Layar Pengaturan: berisi dua menu utama Kelola Dompet dan Kelola Kategori
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Pengaturan', style: AppTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.margin,
            vertical: AppDimens.spaceMd,
          ),
          children: [
            _buildMenuItem(
              context: context,
              title: 'Kelola Dompet',
              subtitle: 'Daftar dompet, saldo awal, dan pengarsipan',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletManagementScreen()),
                );
              },
            ),
            const SizedBox(height: AppDimens.spaceSm),
            _buildMenuItem(
              context: context,
              title: 'Kelola Kategori',
              subtitle: 'Kategori pemasukan dan pengeluaran',
              icon: Icons.category_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: AppDimens.borderWidthThin,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceMd,
          vertical: AppDimens.spaceXs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDimens.spaceSm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppDimens.iconMedium),
        ),
        title: Text(
          title,
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySm,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.onSurfaceVariant,
          size: AppDimens.iconMedium,
        ),
        onTap: onTap,
      ),
    );
  }
}
