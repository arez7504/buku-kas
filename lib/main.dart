import 'package:flutter/material.dart';
import 'data/finance_repository.dart';
import 'logic/finance_state.dart';
import 'screens/history_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FinanceRepository();
  final state = FinanceState(repository: repository);
  await state.loadData();
  runApp(MyApp(initialState: state));
}

class MyApp extends StatefulWidget {
  final FinanceState? initialState;

  const MyApp({super.key, this.initialState});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FinanceState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState ?? FinanceState();
  }

  @override
  void dispose() {
    if (widget.initialState == null) {
      _state.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FinanceScope(
      state: _state,
      child: MaterialApp(
        title: 'Catatan Keuangan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HistoryScreen(),
      ),
    );
  }
}
