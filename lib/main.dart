import 'package:flutter/material.dart';
import 'data/finance_repository.dart';
import 'logic/app_lock_manager.dart';
import 'logic/finance_state.dart';
import 'screens/history_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_lock_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FinanceRepository();
  final state = FinanceState(repository: repository);
  await state.loadData();

  final lockManager = AppLockManager();
  await lockManager.initialize();
  lockManager.startListeningLifecycle();

  runApp(MyApp(
    initialState: state,
    lockManager: lockManager,
  ));
}

class MyApp extends StatefulWidget {
  final FinanceState? initialState;
  final AppLockManager? lockManager;

  const MyApp({
    super.key,
    this.initialState,
    this.lockManager,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FinanceState _state;
  late final AppLockManager _lockManager;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState ?? FinanceState();
    _lockManager = widget.lockManager ?? AppLockManager();
    if (widget.lockManager == null) {
      _lockManager.initialize();
      _lockManager.startListeningLifecycle();
    }
  }

  @override
  void dispose() {
    if (widget.initialState == null) {
      _state.dispose();
    }
    if (widget.lockManager == null) {
      _lockManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLockScope(
      manager: _lockManager,
      child: FinanceScope(
        state: _state,
        child: MaterialApp(
          title: 'Catatan Keuangan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          builder: (context, child) {
            return AppLockWrapper(
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const HistoryScreen(),
        ),
      ),
    );
  }
}
