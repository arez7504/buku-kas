import 'package:flutter/material.dart';
import '../logic/finance_calculator.dart';
import '../logic/finance_state.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/buku_kas_day_group.dart';
import '../widgets/riwayat_category_bottom_sheet.dart';
import 'transaction_form_screen.dart';

/// Layar Tab Riwayat dengan filter jenis, kategori dinamis, ringkasan hasil, dan pengelompokan harian
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late DateTime _selectedMonth;
  TransactionFilterType _filterType = TransactionFilterType.all;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  void _onFilterTypeChanged(TransactionFilterType newType) {
    if (_filterType == newType) return;
    setState(() {
      _filterType = newType;
      // Aturan (e): Saat jenis diganti dan kategori terpilih tidak cocok dengan jenis baru,
      // pilihan kategori otomatis kembali ke "Semua kategori" (null).
      if (_selectedCategoryId != null) {
        final state = FinanceScope.of(context);
        final cat = state.getCategoryById(_selectedCategoryId);
        if (newType == TransactionFilterType.transfer) {
          _selectedCategoryId = null;
        } else if (newType == TransactionFilterType.income && cat?.type != CategoryType.income) {
          _selectedCategoryId = null;
        } else if (newType == TransactionFilterType.expense && cat?.type != CategoryType.expense) {
          _selectedCategoryId = null;
        }
      }
    });
  }

  void _openCategoryFilter(FinanceState state) async {
    final selectedId = await RiwayatCategoryBottomSheet.show(
      context,
      selectedCategoryId: _selectedCategoryId,
      filterType: _filterType,
      categories: state.categories,
    );

    // Jika user memilih item (atau null untuk reset ke semua)
    if (mounted && selectedId != _selectedCategoryId) {
      setState(() {
        _selectedCategoryId = selectedId;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _filterType = TransactionFilterType.all;
      _selectedCategoryId = null;
    });
  }

  void _openTransactionForm(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);

    // Ambil transaksi tersaring
    final filteredTransactions = state.getFilteredTransactions(
      year: _selectedMonth.year,
      month: _selectedMonth.month,
      type: _filterType,
      categoryId: _selectedCategoryId,
    );

    // Ambil ringkasan
    final summary = state.getFilteredSummary(filteredTransactions);

    // Kelompokkan per hari
    final dailyGroups = state.groupTransactions(filteredTransactions);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          key: const PageStorageKey('riwayat_scroll_view'),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildMonthSelector(),
                  _buildFilterRow(state),
                  _buildSummaryRow(summary),
                ],
              ),
            ),
            if (state.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXl),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  ),
                ),
              )
            else if (filteredTransactions.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: AppDimens.bottomListPadding),
                sliver: SliverList.builder(
                  itemCount: dailyGroups.length,
                  itemBuilder: (context, index) {
                    return BukuKasDayGroup(
                      group: dailyGroups[index],
                      getWalletName: state.getWalletName,
                      getCategoryName: state.getCategoryName,
                      getCategory: state.getCategoryById,
                      onTransactionTap: (tx) => _openTransactionForm(tx),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm,
      ),
      child: Text(
        'Riwayat',
        style: AppTypography.riwayatScreenTitle,
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceXs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceSm,
          vertical: AppDimens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _previousMonth,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                child: const Padding(
                  padding: EdgeInsets.all(AppDimens.spaceSm),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.onSurface,
                    size: AppDimens.iconMedium,
                  ),
                ),
              ),
            ),
            Text(
              FinanceCalculator.formatMonthYear(_selectedMonth),
              style: AppTypography.riwayatMonthSelector,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _nextMonth,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                child: const Padding(
                  padding: EdgeInsets.all(AppDimens.spaceSm),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurface,
                    size: AppDimens.iconMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(FinanceState state) {
    final isTransfer = _filterType == TransactionFilterType.transfer;
    final selectedCategoryName = _selectedCategoryId != null
        ? state.getCategoryName(_selectedCategoryId)
        : null;

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.spaceSm, bottom: AppDimens.spaceXs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Filter Jenis Transaksi (Horizontal scroll jika layar sempit)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.margin),
            child: Row(
              children: [
                _buildTypeChip(
                  key: const Key('riwayat_filter_semua'),
                  label: 'Semua',
                  isSelected: _filterType == TransactionFilterType.all,
                  onTap: () => _onFilterTypeChanged(TransactionFilterType.all),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                _buildTypeChip(
                  key: const Key('riwayat_filter_pemasukan'),
                  label: 'Pemasukan',
                  isSelected: _filterType == TransactionFilterType.income,
                  onTap: () => _onFilterTypeChanged(TransactionFilterType.income),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                _buildTypeChip(
                  key: const Key('riwayat_filter_pengeluaran'),
                  label: 'Pengeluaran',
                  isSelected: _filterType == TransactionFilterType.expense,
                  onTap: () => _onFilterTypeChanged(TransactionFilterType.expense),
                ),
                const SizedBox(width: AppDimens.spaceSm),
                _buildTypeChip(
                  key: const Key('riwayat_filter_transfer'),
                  label: 'Transfer',
                  isSelected: _filterType == TransactionFilterType.transfer,
                  onTap: () => _onFilterTypeChanged(TransactionFilterType.transfer),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceSm),

          // Baris 2: Kontrol Filter Kategori
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.margin),
            child: _buildCategoryControl(
              isTransfer: isTransfer,
              selectedCategoryName: selectedCategoryName,
              onTap: () => _openCategoryFilter(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required Key key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.tintPurpleBg : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd,
            vertical: AppDimens.spaceSm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: isSelected
                    ? AppTypography.riwayatFilterChipActive
                    : AppTypography.riwayatFilterChipInactive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryControl({
    required bool isTransfer,
    required String? selectedCategoryName,
    required VoidCallback onTap,
  }) {
    if (isTransfer) {
      return Container(
        constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceMd,
          vertical: AppDimens.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(color: AppColors.borderFaint),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(width: AppDimens.spaceSm),
            Flexible(
              child: Text(
                'Transfer tidak punya kategori',
                style: TextStyle(
                  fontFamily: AppFonts.plusJakartaSans,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final hasSelectedCategory = selectedCategoryName != null;

    return Material(
      color: hasSelectedCategory ? AppColors.tintPurpleBg : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: InkWell(
        key: const Key('riwayat_filter_kategori'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd,
            vertical: AppDimens.spaceSm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            border: Border.all(
              color: hasSelectedCategory ? AppColors.primary : AppColors.borderSubtle,
              width: hasSelectedCategory ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasSelectedCategory ? Icons.category_rounded : Icons.tune_rounded,
                size: 14,
                color: hasSelectedCategory ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimens.spaceSm),
              Flexible(
                child: Text(
                  hasSelectedCategory ? selectedCategoryName : 'Kategori',
                  style: hasSelectedCategory
                      ? AppTypography.riwayatFilterChipActive
                      : AppTypography.riwayatFilterChipInactive,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimens.spaceXs),
              if (hasSelectedCategory)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(FilteredTransactionsSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm,
      ),
      child: Container(
        key: const Key('riwayat_ringkasan'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceMd,
          vertical: AppDimens.spaceSm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // Jumlah transaksi
            Text(
              '${summary.transactionCount} transaksi',
              style: AppTypography.riwayatSummaryCount,
            ),
            const SizedBox(width: AppDimens.spaceSm),
            // Nominal sesuai filter jenis
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _buildSummaryAmounts(summary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryAmounts(FilteredTransactionsSummary summary) {
    switch (_filterType) {
      case TransactionFilterType.income:
        return Text(
          '+ ${FinanceCalculator.formatRupiah(summary.totalIncome)}',
          style: AppTypography.riwayatSummaryAmountIncome,
        );

      case TransactionFilterType.expense:
        return Text(
          '- ${FinanceCalculator.formatRupiah(summary.totalExpense)}',
          style: AppTypography.riwayatSummaryAmountExpense,
        );

      case TransactionFilterType.all:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+ ${FinanceCalculator.formatRupiah(summary.totalIncome)}',
              style: AppTypography.riwayatSummaryAmountIncome,
            ),
            const SizedBox(width: AppDimens.spaceSm),
            Text(
              '- ${FinanceCalculator.formatRupiah(summary.totalExpense)}',
              style: AppTypography.riwayatSummaryAmountExpense,
            ),
          ],
        );

      case TransactionFilterType.transfer:
        // Transfer tidak punya pemasukan / pengeluaran
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      key: const Key('riwayat_kosong'),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.spaceXl * 1.5,
        horizontal: AppDimens.margin,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: AppDimens.iconLarge * 1.5,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: AppDimens.spaceMd),
            const Text(
              'Tidak ada transaksi yang cocok',
              style: AppTypography.riwayatEmptyTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spaceMd),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Atur ulang filter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHigh,
                foregroundColor: AppColors.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spaceMd,
                  vertical: AppDimens.spaceSm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
