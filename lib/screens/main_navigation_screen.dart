import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/main_bottom_nav_bar.dart';
import 'history_screen.dart';
import 'placeholder_tab_screen.dart';
import 'riwayat_screen.dart';
import 'settings_screen.dart';
import 'transaction_form_screen.dart';

/// Scope untuk mengakses dan mengubah tab aktif pada kerangka navigasi utama
class MainNavigationScope extends InheritedWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  const MainNavigationScope({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required super.child,
  });

  static MainNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainNavigationScope>();
  }

  static void navigateToTab(BuildContext context, int index) {
    final scope = maybeOf(context);
    scope?.onSelectTab(index);
  }

  @override
  bool updateShouldNotify(MainNavigationScope oldWidget) {
    return currentIndex != oldWidget.currentIndex;
  }
}

/// Kerangka navigasi utama aplikasi dengan bilah bawah sesuai Milestone NAV-1:
/// - 4 Tab: Beranda, Riwayat, Statistik, Pengaturan
/// - 1 Tombol Catat di tengah (urutan: Beranda, Riwayat, [Catat], Statistik, Pengaturan)
/// - Mempertahankan state tab (IndexedStack)
/// - Android Back Button: dari tab selain Beranda kembali ke Beranda; dari Beranda menutup aplikasi
/// - Sub-layar dibuka di atas kerangka lewat push dan menyembunyikan bilah bawah
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _openCatatForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigationScope(
      currentIndex: _currentIndex,
      onSelectTab: _onTabSelected,
      child: PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HistoryScreen(
                onViewAllRiwayat: () => _onTabSelected(1),
              ),
              const RiwayatScreen(),
              const PlaceholderTabScreen(title: 'Statistik'),
              const SettingsScreen(showBackButton: false),
            ],
          ),
          bottomNavigationBar: MainBottomNavBar(
            currentIndex: _currentIndex,
            onTabSelected: _onTabSelected,
            onCatatPressed: _openCatatForm,
          ),
        ),
      ),
    );
  }
}
