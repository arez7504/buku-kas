import 'package:flutter/material.dart';
import '../logic/finance_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/buku_kas_action_button.dart';
import '../widgets/buku_kas_day_group.dart';
import '../widgets/buku_kas_header.dart';
import '../widgets/buku_kas_hero_summary.dart';
import '../widgets/buku_kas_wallet_bar.dart';
import 'expense_breakdown_screen.dart';
import 'settings_screen.dart';
import 'transaction_form_screen.dart';

/// Layar utama Buku Kas sesuai desain tema gelap fintech baru (UI-3)
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.spaceXl,
        horizontal: AppDimens.margin,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.auto_stories,
              size: AppDimens.iconLarge * 1.5,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: AppDimens.spaceSm),
            Text(
              'Belum ada transaksi di bulan ini',
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.margin,
        vertical: AppDimens.spaceSm + 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text(
              'Transaksi Terkini',
              style: AppTypography.sectionTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceSm,
              vertical: AppDimens.spaceXs / 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.tintPurpleBg,
              border: Border.all(color: AppColors.tintPurpleBorder),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              '$count Catatan',
              style: AppTypography.sectionBadge,
            ),
          ),
        ],
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
    final filteredTransactions = state.getTransactionsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final dailyGroups = state.getDailyTransactionGroups(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BukuKasActionButton(
        onPressed: () => _openTransactionForm(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BukuKasHeader(
                    selectedMonth: _selectedMonth,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                    onSettings: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  BukuKasWalletBar(
                    wallets: state.activeWallets,
                    walletBalances: walletBalances,
                  ),
                  BukuKasHeroSummary(
                    summary: summary,
                    onViewDetails: _openExpenseBreakdown,
                  ),
                  _buildSectionHeader(filteredTransactions.length),
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
            else if (dailyGroups.isEmpty)
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
}
