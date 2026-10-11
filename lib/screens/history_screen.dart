import 'package:flutter/material.dart';
import '../logic/finance_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/buku_kas_header.dart';
import '../widgets/buku_kas_month_section.dart';
import '../widgets/buku_kas_saldo_total_card.dart';
import '../widgets/buku_kas_transaction_row.dart';
import '../widgets/buku_kas_wallet_bar.dart';
import 'expense_breakdown_screen.dart';
import 'main_navigation_screen.dart';
import 'transaction_form_screen.dart';

/// Layar Beranda Buku Kas sesuai Milestone NAV-3:
/// - Bagian atas tetap: Header, Saldo Total, Bulan, Dompet
/// - Daftar per hari digantikan bagian "Transaksi Terbaru": 5 transaksi terbaru secara keseluruhan
/// - Tautan "Lihat semua" berpindah ke tab Riwayat (memakai cara pindah tab navigasi, bukan push)
/// - Jika < 5 tampilkan semua; jika kosong tampilkan pesan kosong
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onViewAllRiwayat;

  const HistoryScreen({super.key, this.onViewAllRiwayat});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedMonth = DateTime(2026, 10, 1);

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  void _openTransactionForm([Transaction? transaction]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  void _openExpenseBreakdown() async {
    final updatedMonth = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseBreakdownScreen(
          selectedMonth: _selectedMonth,
          onMonthChanged: (newMonth) {
            setState(() {
              _selectedMonth = newMonth;
            });
          },
        ),
      ),
    );
    if (updatedMonth != null && mounted) {
      setState(() {
        _selectedMonth = updatedMonth;
      });
    }
  }

  void _onViewAll() {
    if (widget.onViewAllRiwayat != null) {
      widget.onViewAllRiwayat!();
    } else {
      MainNavigationScope.navigateToTab(context, 1);
    }
  }

  Widget _buildRecentHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Text(
              'Transaksi Terbaru',
              style: AppTypography.sectionTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          GestureDetector(
            key: const Key('beranda_lihat_semua'),
            behavior: HitTestBehavior.opaque,
            onTap: _onViewAll,
            child: Container(
              constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceSm,
                vertical: AppDimens.spaceXs,
              ),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat semua',
                    style: AppTypography.recentTransactionsViewAll,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList(List<Transaction> recentTransactions, FinanceState state) {
    if (recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.spaceXl,
          horizontal: AppDimens.margin,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_stories,
                size: AppDimens.iconLarge * 1.5,
                color: AppColors.outlineVariant,
              ),
              const SizedBox(height: AppDimens.spaceSm),
              Text(
                'Belum ada transaksi',
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.margin),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (int i = 0; i < recentTransactions.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderFaint,
                  indent: AppDimens.spaceMd,
                  endIndent: AppDimens.spaceMd,
                ),
              BukuKasTransactionRow(
                transaction: recentTransactions[i],
                walletName: state.getWalletName(recentTransactions[i].walletId),
                targetWalletName: recentTransactions[i].targetWalletId != null
                    ? state.getWalletName(recentTransactions[i].targetWalletId!)
                    : null,
                categoryName: state.getCategoryName(recentTransactions[i].categoryId),
                category: state.getCategoryById(recentTransactions[i].categoryId),
                onTap: () => _openTransactionForm(recentTransactions[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);
    final walletBalances = state.walletBalances;
    final summary = state.getMonthlySummary(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final recentTransactions = state.getRecentTransactions(limit: 5);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          key: const Key('history_scroll_view'),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BukuKasHeader(),
                  BukuKasSaldoTotalCard(
                    totalBalance: state.totalBalance,
                  ),
                  BukuKasMonthSection(
                    selectedMonth: _selectedMonth,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                    summary: summary,
                    onViewDetails: _openExpenseBreakdown,
                  ),
                  BukuKasWalletBar(
                    wallets: state.activeWallets,
                    walletBalances: walletBalances,
                  ),
                  _buildRecentHeader(),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXl),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.secondary),
                      ),
                    )
                  else
                    _buildRecentTransactionsList(recentTransactions, state),
                  const SizedBox(height: AppDimens.bottomListPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
