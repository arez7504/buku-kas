import 'package:flutter/material.dart';
import '../logic/finance_state.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/buku_kas_action_button.dart';
import '../widgets/buku_kas_header.dart';
import '../widgets/buku_kas_hero_summary.dart';
import '../widgets/buku_kas_day_group.dart';
import '../widgets/buku_kas_wallet_bar.dart';
import 'expense_breakdown_screen.dart';
import 'settings_screen.dart';
import 'transaction_form_screen.dart';

// HistoryScreen: Layar utama Buku Kas sesuai revisi keterbacaan
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
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppDimens.bottomListPadding),
          children: [
            // 1. Header judul layar 'Catatan Keuangan' dan navigasi bulan
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

            // 2. Saldo tiap dompet sebagai kotak terpisah horizontal
            BukuKasWalletBar(
              wallets: state.activeWallets,
              walletBalances: walletBalances,
            ),

            // 3. Ringkasan Pemasukan, Pengeluaran, Selisih dalam satu kartu (tiga kolom sejajar)
            BukuKasHeroSummary(
              summary: summary,
              onViewDetails: _openExpenseBreakdown,
            ),

            // 4. Judul seksi Riwayat Transaksi + counter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.margin,
                vertical: AppDimens.spaceSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Transaksi', style: AppTypography.sectionHeaderTitle),
                  Text(
                    '${filteredTransactions.length} transaksi',
                    style: AppTypography.sectionHeaderCount,
                  ),
                ],
              ),
            ),

            // 5. Daftar transaksi dikelompokkan per hari atau status memuat / pesan kosong
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXl),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              )
            else if (dailyGroups.isEmpty)
              _buildEmptyState()
            else
              for (final group in dailyGroups)
                BukuKasDayGroup(
                  group: group,
                  getWalletName: state.getWalletName,
                  getCategoryName: state.getCategoryName,
                  onTransactionTap: (tx) => _openTransactionForm(tx),
                ),
          ],
        ),
      ),
    );
  }
}
