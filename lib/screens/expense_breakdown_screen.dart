import 'package:flutter/material.dart';
import '../logic/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_breakdown_empty.dart';
import '../widgets/expense_breakdown_header.dart';
import '../widgets/expense_breakdown_hero.dart';
import '../widgets/expense_category_row.dart';

// Layar Rincian Pengeluaran per kategori sesuai Tahap 2, Fitur 1
class ExpenseBreakdownScreen extends StatefulWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime>? onMonthChanged;

  const ExpenseBreakdownScreen({
    super.key,
    required this.selectedMonth,
    this.onMonthChanged,
  });

  @override
  State<ExpenseBreakdownScreen> createState() => _ExpenseBreakdownScreenState();
}

class _ExpenseBreakdownScreenState extends State<ExpenseBreakdownScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    widget.onMonthChanged?.call(_currentMonth);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    widget.onMonthChanged?.call(_currentMonth);
  }

  void _onBack() {
    Navigator.pop(context, _currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceScope.of(context);
    final breakdown = state.getExpenseBreakdown(
      _currentMonth.year,
      _currentMonth.month,
    );
    final maxAmount = breakdown.items.isNotEmpty ? breakdown.items.first.amount : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _currentMonth);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppDimens.bottomListPadding),
            children: [
              // 1. Header navigasi bulan & tombol kembali
              ExpenseBreakdownHeader(
                selectedMonth: _currentMonth,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
                onBack: _onBack,
              ),

              // 2. Hero total pengeluaran angka besar
              ExpenseBreakdownHero(
                totalExpense: breakdown.totalExpense,
                categoryCount: breakdown.items.length,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.margin,
                  vertical: AppDimens.spaceSm,
                ),
                child: Divider(
                  height: AppDimens.borderWidthThin,
                  thickness: AppDimens.borderWidthThin,
                  color: AppColors.surfaceContainerHigh,
                ),
              ),

              // 3. Daftar kategori atau pesan kondisi kosong yang jelas
              if (breakdown.items.isEmpty)
                const ExpenseBreakdownEmpty()
              else
                for (int i = 0; i < breakdown.items.length; i++) ...[
                  ExpenseCategoryRow(
                    item: breakdown.items[i],
                    category: state.getCategoryById(breakdown.items[i].categoryId),
                    maxAmount: maxAmount,
                  ),
                  if (i < breakdown.items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimens.margin),
                      child: Divider(
                        height: AppDimens.borderWidthThin,
                        thickness: AppDimens.borderWidthThin,
                        color: AppColors.surfaceContainerHigh,
                      ),
                    ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
