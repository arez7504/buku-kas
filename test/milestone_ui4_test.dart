import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/transaction_form_screen.dart';
import 'package:catatan_keuangan/widgets/catat_amount_display.dart';
import 'package:catatan_keuangan/widgets/catat_category_selector.dart';
import 'package:catatan_keuangan/widgets/catat_note_input.dart';
import 'package:catatan_keuangan/widgets/catat_numeric_keypad.dart';
import 'package:catatan_keuangan/widgets/catat_submit_button.dart';
import 'package:catatan_keuangan/widgets/catat_type_tabs.dart';
import 'package:catatan_keuangan/widgets/catat_wallet_selector.dart';

void main() {
  final sampleWallets = [
    const Wallet(id: 'w_bca', name: 'BCA', initialBalance: 3850000),
    const Wallet(id: 'w_tunai', name: 'Tunai', initialBalance: 385000),
    const Wallet(id: 'w_ewallet', name: 'E-Wallet', initialBalance: 300000),
  ];

  final sampleCategories = [
    const Category(id: 'c_makanan', name: 'Makan & Minum', type: CategoryType.expense),
    const Category(id: 'c_belanja', name: 'Belanja', type: CategoryType.expense),
    const Category(id: 'c_gaji', name: 'Gaji', type: CategoryType.income),
  ];

  Widget createCatatScreen({
    Transaction? transaction,
    FinanceState? state,
  }) {
    final effectiveState = state ??
        FinanceState(
          initialWallets: sampleWallets,
          initialCategories: sampleCategories,
          initialTransactions: const [],
        );

    return MaterialApp(
      home: FinanceScope(
        state: effectiveState,
        child: TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  group('Milestone UI-4: Responsivitas Layar Catat Transaksi', () {
    testWidgets('Layar 360x640 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.byType(CatatTypeTabs), findsOneWidget);
      expect(find.byType(CatatAmountDisplay), findsOneWidget);
      expect(find.byType(CatatCategorySelector), findsOneWidget);
      expect(find.byType(CatatWalletSelector), findsOneWidget);
      expect(find.byType(CatatNoteInput), findsOneWidget);
      expect(find.byType(CatatNumericKeypad), findsOneWidget);
      expect(find.byType(CatatSubmitButton), findsOneWidget);
    });

    testWidgets('Layar 411x891 dp bebas overflow dan pembagian ruang fleksibel', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.byType(CatatTypeTabs), findsOneWidget);
      expect(find.byType(CatatAmountDisplay), findsOneWidget);
      expect(find.byType(CatatSubmitButton), findsOneWidget);
    });
  });

  group('Milestone UI-4: Header & Navigasi', () {
    testWidgets('Header memiliki panah kembali dan judul tanpa tombol "..."', (tester) async {
      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });
  });

  group('Milestone UI-4: Tab Tipe & Mode Transfer', () {
    testWidgets('Tab tipe memiliki ikon dan pil aktif bergradasi', (tester) async {
      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.sync_alt), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('Pindah ke tab Transfer menyembunyikan kategori dan memunculkan Dari/Ke', (tester) async {
      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      // Default adalah Pengeluaran
      expect(find.text('NOMINAL PENGELUARAN'), findsOneWidget);
      expect(find.byType(CatatCategorySelector), findsOneWidget);
      expect(find.text('SUMBER DANA'), findsOneWidget);
      expect(find.text('Simpan Pengeluaran'), findsOneWidget);

      // Tap tab Transfer
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('NOMINAL TRANSFER'), findsOneWidget);
      expect(find.byType(CatatCategorySelector), findsNothing);
      expect(find.text('DARI (SUMBER)'), findsOneWidget);
      expect(find.text('KE (TUJUAN)'), findsOneWidget);
      expect(find.text('Simpan Transfer'), findsOneWidget);

      // Tap tab Pemasukan
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      expect(find.text('NOMINAL PEMASUKAN'), findsOneWidget);
      expect(find.byType(CatatCategorySelector), findsOneWidget);
      expect(find.text('SUMBER DANA'), findsOneWidget);
      expect(find.text('Simpan Pemasukan'), findsOneWidget);
    });
  });

  group('Milestone UI-4: Kartu Nominal & Kursor', () {
    testWidgets('Kartu nominal menampilkan label, prefix Rp, kursor dan chip tanggal', (tester) async {
      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      expect(find.text('NOMINAL PENGELUARAN'), findsOneWidget);
      expect(find.text('Rp'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.byKey(const Key('catat_cursor_fade')), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('Tap chip tanggal membuka dialog pemilih tanggal', (tester) async {
      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('Milestone UI-4: Kategori Cepat & Nama Kategori Terpilih', () {
    testWidgets('Kategori cepat menampilkan ikon dan nama kategori terpilih di kanan label', (tester) async {
      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      expect(find.text('KATEGORI CEPAT'), findsOneWidget);
      // Kategori terpilih pertama adalah Makan & Minum
      expect(find.text('Makan & Minum'), findsWidgets);

      // Tap kategori Belanja
      await tester.tap(find.text('Belanja'));
      await tester.pumpAndSettle();

      // Sekarang Belanja terpilih
      final belanjaFinder = find.text('Belanja');
      expect(belanjaFinder, findsNWidgets(2)); // Satu di kanan label, satu di chip
    });
  });

  group('Milestone UI-4: Keypad Angka Tanpa Huruf ABC/DEF', () {
    testWidgets('Keypad hanya menampilkan angka dan tombol 000, tanpa huruf ABC/DEF', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCatatScreen());
      await tester.pumpAndSettle();

      expect(find.text('ABC'), findsNothing);
      expect(find.text('DEF'), findsNothing);
      expect(find.text('GHI'), findsNothing);
      expect(find.text('JKL'), findsNothing);
      expect(find.text('000'), findsOneWidget);
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Input nominal 25000
      await tester.tap(find.widgetWithText(InkWell, '2'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, '5'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, '000'));
      await tester.pump();

      expect(find.text('25.000'), findsOneWidget);

      // Hapus satu digit dengan backspace
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(find.text('2.500'), findsOneWidget);
    });
  });

  group('Milestone UI-4: Penyimpanan Transaksi', () {
    testWidgets('Menyimpan pengeluaran sukses dan menutup layar', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final state = FinanceState(
        initialWallets: sampleWallets,
        initialCategories: sampleCategories,
        initialTransactions: const [],
      );

      await tester.pumpWidget(createCatatScreen(state: state));
      await tester.pumpAndSettle();

      // Input nominal 50000
      await tester.tap(find.widgetWithText(InkWell, '5'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, '0'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, '000'));
      await tester.pump();

      // Input catatan
      await tester.enterText(find.byType(TextField), 'Makan Siang');
      await tester.pump();

      // Simpan
      await tester.tap(find.text('Simpan Pengeluaran'));
      await tester.pumpAndSettle();

      expect(state.transactions.length, 1);
      expect(state.transactions.first.amount, 50000);
      expect(state.transactions.first.note, 'Makan Siang');
      expect(state.transactions.first.type, TransactionType.expense);
    });
  });
}
