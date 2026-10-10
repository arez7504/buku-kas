import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:catatan_keuangan/data/database/app_database.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/logic/backup_service.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/screens/category_form_screen.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/theme/category_style.dart';

void main() {
  group('Milestone UI-7 Test Suite', () {
    // -------------------------------------------------------------------------
    // 1. Migrasi 2 ke 3
    // -------------------------------------------------------------------------
    test('1. Migrasi 2 ke 3: database v2 berisi data, setelah migrasi data utuh dan kolom baru NULL', () async {
      final executor = NativeDatabase.memory(setup: (rawDb) {
        rawDb.execute('PRAGMA user_version = 2;');
        rawDb.execute('''
          CREATE TABLE wallets (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            initial_balance INTEGER NOT NULL,
            is_archived INTEGER NOT NULL DEFAULT 0
          );
        ''');
        rawDb.execute('''
          CREATE TABLE categories (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            is_archived INTEGER NOT NULL DEFAULT 0
          );
        ''');
        rawDb.execute('''
          CREATE TABLE transactions (
            id TEXT NOT NULL PRIMARY KEY,
            type TEXT NOT NULL,
            amount INTEGER NOT NULL,
            date INTEGER NOT NULL,
            wallet_id TEXT NOT NULL,
            target_wallet_id TEXT,
            category_id TEXT,
            note TEXT
          );
        ''');

        // Isi data v2
        rawDb.execute('''
          INSERT INTO wallets (id, name, initial_balance, is_archived)
          VALUES ('w1', 'BCA', 1000000, 0);
        ''');
        rawDb.execute('''
          INSERT INTO categories (id, name, type, is_archived)
          VALUES ('c_food', 'Kuliner', 'expense', 0), ('c_salary', 'Gaji Pokok', 'income', 0);
        ''');
        rawDb.execute('''
          INSERT INTO transactions (id, type, amount, date, wallet_id, category_id, note)
          VALUES ('t1', 'expense', 50000, 1728300000, 'w1', 'c_food', 'Makan malam');
        ''');
      });

      final db = AppDatabase.forTesting(executor);
      final repo = FinanceRepository(db);

      // Pastikan versi skema sekarang minimal 3
      final versionResult = await db.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.data['user_version'], greaterThanOrEqualTo(3));

      // Verifikasi data lama tetap utuh
      final wallets = await repo.getAllWallets();
      expect(wallets.length, equals(1));
      expect(wallets.first.name, equals('BCA'));

      final categories = await repo.getAllCategories();
      expect(categories.length, equals(2));

      final food = categories.firstWhere((c) => c.id == 'c_food');
      expect(food.name, equals('Kuliner'));
      expect(food.type, equals(CategoryType.expense));
      expect(food.iconKey, isNull);
      expect(food.colorKey, isNull);

      final salary = categories.firstWhere((c) => c.id == 'c_salary');
      expect(salary.name, equals('Gaji Pokok'));
      expect(salary.type, equals(CategoryType.income));
      expect(salary.iconKey, isNull);
      expect(salary.colorKey, isNull);

      final txs = await repo.getAllTransactions();
      expect(txs.length, equals(1));
      expect(txs.first.note, equals('Makan malam'));

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 2. Round-trip backup
    // -------------------------------------------------------------------------
    test('2. Round-trip backup: ekspor lalu impor ke database kosong mempertahankan iconKey dan colorKey', () async {
      final repo1 = FinanceRepository.inMemory();
      final state1 = FinanceState(repository: repo1);
      await state1.loadData();

      // Tambah kategori dengan iconKey & colorKey
      await state1.addCategory(const Category(
        id: 'cat_custom_cafe',
        name: 'Kopi Santai',
        type: CategoryType.expense,
        iconKey: 'kafe',
        colorKey: 'orange',
      ));
      await state1.addCategory(const Category(
        id: 'cat_custom_bonus',
        name: 'Bonus Tahunan',
        type: CategoryType.income,
        iconKey: 'hadiah',
        colorKey: 'amber',
      ));

      // Ekspor ke JSON
      final jsonString = BackupService.exportToJson(
        wallets: state1.wallets,
        categories: state1.categories,
        transactions: state1.transactions,
      );

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['formatVersion'], greaterThanOrEqualTo(2));

      // Impor ke database kosong
      final repo2 = FinanceRepository.inMemory();
      final state2 = FinanceState(repository: repo2);
      await state2.loadData();

      final backupData = BackupService.parseAndValidate(jsonString);

      await state2.restoreData(
        wallets: backupData.wallets,
        categories: backupData.categories,
        transactions: backupData.transactions,
      );

      final restoredCafe = state2.categories.firstWhere((c) => c.id == 'cat_custom_cafe');
      expect(restoredCafe.name, equals('Kopi Santai'));
      expect(restoredCafe.iconKey, equals('kafe'));
      expect(restoredCafe.colorKey, equals('orange'));

      final restoredBonus = state2.categories.firstWhere((c) => c.id == 'cat_custom_bonus');
      expect(restoredBonus.name, equals('Bonus Tahunan'));
      expect(restoredBonus.iconKey, equals('hadiah'));
      expect(restoredBonus.colorKey, equals('amber'));

      await repo1.close();
      await repo2.close();
    });

    // -------------------------------------------------------------------------
    // 3. File backup formatVersion 1 tetap bisa dipulihkan
    // -------------------------------------------------------------------------
    test('3. File backup formatVersion 1 (tanpa kolom baru) tetap bisa dipulihkan', () async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      final v1Json = jsonEncode({
        'formatVersion': 1,
        'exportedAt': '2026-03-01T10:00:00.000Z',
        'wallets': [
          {'id': 'w_v1', 'name': 'Dompet Saku', 'initialBalance': 250000, 'isArchived': false}
        ],
        'categories': [
          {'id': 'c_v1_1', 'name': 'Belanja Pasar', 'type': 'expense', 'isArchived': false},
          {'id': 'c_v1_2', 'name': 'Honor Proyek', 'type': 'income', 'isArchived': false}
        ],
        'transactions': []
      });

      final backupData = BackupService.parseAndValidate(v1Json);

      await state.restoreData(
        wallets: backupData.wallets,
        categories: backupData.categories,
        transactions: backupData.transactions,
      );

      final c1 = state.categories.firstWhere((c) => c.id == 'c_v1_1');
      expect(c1.name, equals('Belanja Pasar'));
      expect(c1.iconKey, isNull);
      expect(c1.colorKey, isNull);

      final c2 = state.categories.firstWhere((c) => c.id == 'c_v1_2');
      expect(c2.name, equals('Honor Proyek'));
      expect(c2.iconKey, isNull);
      expect(c2.colorKey, isNull);

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 4. Kunci ikon tidak dikenal memakai fallback tanpa error
    // -------------------------------------------------------------------------
    test('4. Kunci ikon/warna tidak dikenal memakai fallback tanpa error', () async {
      // 4a. Backup restore sanitizes unknown keys to null
      final jsonWithUnknownKeys = jsonEncode({
        'formatVersion': 2,
        'exportedAt': '2026-03-01T10:00:00.000Z',
        'wallets': [
          {'id': 'w_test', 'name': 'Kas', 'initialBalance': 50000, 'isArchived': false}
        ],
        'categories': [
          {
            'id': 'c_weird',
            'name': 'Hobi Aneh',
            'type': 'expense',
            'isArchived': false,
            'iconKey': 'unknown_alien_icon',
            'colorKey': 'unknown_alien_color',
          }
        ],
        'transactions': []
      });

      final backupData = BackupService.parseAndValidate(jsonWithUnknownKeys);
      // Sanitized to null
      final restoredCat = backupData.categories.first;
      expect(restoredCat.iconKey, isNull);
      expect(restoredCat.colorKey, isNull);

      // 4b. Registry resolveCategoryStyle with unknown keys falls back safely
      final style = CategoryStyleRegistry.resolveCategoryStyle(
        categoryName: 'Hobi Aneh',
        iconKey: 'unknown_icon_xyz',
        colorKey: 'unknown_color_xyz',
      );
      expect(style.icon, isNotNull);
      expect(style.backgroundColor, isNotNull);
      expect(style.borderColor, isNotNull);
      expect(style.iconColor, isNotNull);
    });

    // -------------------------------------------------------------------------
    // 5. Fungsi resolusi: kunci terisi mengalahkan pemetaan nama; kosong memakai pemetaan nama
    // -------------------------------------------------------------------------
    test('5. Fungsi resolusi: kunci terisi mengalahkan pemetaan nama; kosong memakai pemetaan nama', () {
      // Kasus 1: Kunci terisi mengalahkan pemetaan nama
      // Nama 'Makanan' normalnya restaurant & orange, tetapi jika iconKey 'pesawat' & colorKey 'cyan',
      // resolusi HARUS menggunakan icon flight dan color cyan.
      final overrideStyle = CategoryStyleRegistry.resolveCategoryStyle(
        categoryName: 'Makanan',
        iconKey: 'pesawat',
        colorKey: 'cyan',
      );
      expect(overrideStyle.icon, equals(Icons.flight));
      expect(overrideStyle.iconColor, equals(AppColors.catCyanIcon));
      expect(overrideStyle.backgroundColor, equals(AppColors.catCyanBg));

      // Kasus 2: Kunci null memakai pemetaan nama yang sudah ada
      final fallbackStyle = CategoryStyleRegistry.resolveCategoryStyle(
        categoryName: 'Makanan',
        iconKey: null,
        colorKey: null,
      );
      expect(fallbackStyle.icon, equals(Icons.restaurant));

      // Kasus 3: Kategori tidak dikenal dan kunci null -> fallback ke pemetaan nama bawaan (label_outline)
      final unknownNameStyle = CategoryStyleRegistry.resolveCategoryStyle(
        categoryName: 'Zzz Custom Random',
        iconKey: null,
        colorKey: null,
      );
      expect(unknownNameStyle.icon, equals(Icons.label_outline));
      expect(unknownNameStyle.iconColor, equals(AppColors.tintNeutralText));

      // Kasus 4: Tipe transaksi transfer menghasilkan swap_horiz
      final transferStyle = CategoryStyleRegistry.resolveCategoryStyle(
        categoryName: 'Transfer Saldo',
        iconKey: null,
        colorKey: null,
        transactionType: TransactionType.transfer,
      );
      expect(transferStyle.icon, equals(Icons.swap_horiz));
    });

    // -------------------------------------------------------------------------
    // 6. Widget Tests
    // -------------------------------------------------------------------------
    testWidgets('6a. Widget: Responsivitas Layar Tambah Kategori di 360x640 dan 411x891 bebas overflow', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      // 360x640 dp
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tambah Kategori'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsWidgets);
      expect(find.text('Pemasukan'), findsWidgets);

      // 411x891 dp
      tester.view.physicalSize = const Size(411, 891);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await repo.close();
    });

    testWidgets('6b. Widget: Pilih ikon dan warna lalu Simpan menyimpan keduanya', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Masukkan nama kategori
      await tester.enterText(find.byKey(const Key('category_name_input')), 'Gym & Fitnes');
      await tester.pumpAndSettle();

      // Pilih ikon (key 'category_icon_olahraga')
      await tester.ensureVisible(find.byKey(const Key('category_icon_olahraga')));
      await tester.tap(find.byKey(const Key('category_icon_olahraga')));
      await tester.pumpAndSettle();

      // Pilih warna (key 'category_color_emerald')
      await tester.ensureVisible(find.byKey(const Key('category_color_emerald')));
      await tester.tap(find.byKey(const Key('category_color_emerald')));
      await tester.pumpAndSettle();

      // Simpan
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();

      // Verifikasi di state
      final saved = state.categories.firstWhere((c) => c.name == 'Gym & Fitnes');
      expect(saved.type, equals(CategoryType.expense));
      expect(saved.iconKey, equals('olahraga'));
      expect(saved.colorKey, equals('emerald'));

      await repo.close();
    });

    testWidgets('6c. Widget: Layar ubah memuat pilihan lama & tipe tidak bisa diganti saat ubah', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      const existingCategory = Category(
        id: 'cat_edit_test',
        name: 'Netflix & Spotify',
        type: CategoryType.expense,
        iconKey: 'film',
        colorKey: 'rose',
      );
      await state.addCategory(existingCategory);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(category: existingCategory),
        ),
      ));
      await tester.pumpAndSettle();

      // Judul layar adalah 'Ubah Kategori'
      expect(find.text('Ubah Kategori'), findsOneWidget);

      // Tipe tampil sebagai teks bukan tombol pilihan
      expect(find.text('Pengeluaran'), findsWidgets);
      // Tombol switcher tipe tidak boleh ada saat ubah (tidak ada opsi Pemasukan untuk dipilih)
      expect(find.text('Pemasukan'), findsNothing);

      // Kolom nama memuat nama lama
      final textField = tester.widget<TextField>(find.byKey(const Key('category_name_input')));
      expect(textField.controller?.text, equals('Netflix & Spotify'));

      // Ubah ikon ke musik dan warna ke blue
      await tester.ensureVisible(find.byKey(const Key('category_icon_musik')));
      await tester.tap(find.byKey(const Key('category_icon_musik')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('category_color_blue')));
      await tester.tap(find.byKey(const Key('category_color_blue')));
      await tester.pumpAndSettle();

      // Simpan
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();

      final updated = state.categories.firstWhere((c) => c.id == 'cat_edit_test');
      expect(updated.iconKey, equals('musik'));
      expect(updated.colorKey, equals('blue'));

      await repo.close();
    });

    testWidgets('6d. Widget: Nama 31 karakter dan nama kembar ditolak dengan pesan yang tepat', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Tes 1: Nama kosong
      await tester.enterText(find.byKey(const Key('category_name_input')), '   ');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Nama kategori tidak boleh kosong'), findsOneWidget);

      // Tes 2: Nama kembar (Makanan sudah ada di seed default)
      await tester.enterText(find.byKey(const Key('category_name_input')), 'makanan');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Nama kategori sudah digunakan dalam kelompok ini'), findsOneWidget);

      // Tes 3: Nama 31 karakter
      const char31 = '1234567890123456789012345678901';
      expect(char31.length, equals(31));
      await tester.enterText(find.byKey(const Key('category_name_input')), char31);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Nama kategori maksimal 30 karakter'), findsOneWidget);

      await repo.close();
    });
  });
}
