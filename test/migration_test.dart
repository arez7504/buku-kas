import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/data/database/app_database.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/models/category.dart';

void main() {
  group('Database Schema Migration Test (Milestone 5)', () {
    test('Migrasi schemaVersion 1 ke 2: Menambahkan kolom isArchived dan menjaga data lama tetap ada', () async {
      // 1. Siapkan database SQLite murni dengan skema v1 dan isi data awal sebelum AppDatabase v2 dibuka
      final executor = NativeDatabase.memory(setup: (rawDb) {
        // Tandai skema awal sebagai versi 1
        rawDb.execute('PRAGMA user_version = 1;');

        // Tabel versi 1: tanpa kolom is_archived
        rawDb.execute('''
          CREATE TABLE wallets (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            initial_balance INTEGER NOT NULL DEFAULT 0
          );
        ''');
        rawDb.execute('''
          CREATE TABLE categories (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL
          );
        ''');
        rawDb.execute('''
          CREATE TABLE transactions (
            id TEXT NOT NULL PRIMARY KEY,
            type TEXT NOT NULL,
            amount INTEGER NOT NULL,
            date INTEGER NOT NULL,
            wallet_id TEXT NOT NULL REFERENCES wallets (id),
            target_wallet_id TEXT REFERENCES wallets (id),
            category_id TEXT REFERENCES categories (id),
            note TEXT
          );
        ''');

        // Masukkan data v1 yang sudah ada di aplikasi pengguna
        rawDb.execute('''
          INSERT INTO wallets (id, name, initial_balance)
          VALUES ('bca', 'BCA', 500000), ('tunai', 'Tunai', 100000);
        ''');
        rawDb.execute('''
          INSERT INTO categories (id, name, type)
          VALUES ('exp_makanan', 'Makanan', 'expense'), ('inc_gaji', 'Gaji', 'income');
        ''');
        rawDb.execute('''
          INSERT INTO transactions (id, type, amount, date, wallet_id, category_id, note)
          VALUES ('tx_v1_1', 'expense', 45000, 1728100000, 'tunai', 'exp_makanan', 'Makan siang');
        ''');
      });

      // 2. Buka database menggunakan AppDatabase (schemaVersion = 2).
      // Drift akan mendeteksi user_version = 1 dan mengeksekusi onUpgrade(m, 1, 2) secara otomatis.
      final db = AppDatabase.forTesting(executor);
      final repository = FinanceRepository(db);

      // Verifikasi user_version telah dinaikkan ke versi 4
      final versionResult = await db.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.data['user_version'], equals(4));

      // 3. Verifikasi data lama tetap utuh pasca-migrasi
      final wallets = await repository.getAllWallets();
      final categories = await repository.getAllCategories();
      final transactions = await repository.getAllTransactions();

      // Memastikan dompet lama tetap ada, initialBalance tetap 500.000 dan 100.000,
      // serta nilai kolom baru isArchived terisi default false, iconKey & colorKey null
      expect(wallets.length, equals(2));
      final bcaWallet = wallets.firstWhere((w) => w.id == 'bca');
      expect(bcaWallet.name, equals('BCA'));
      expect(bcaWallet.initialBalance, equals(500000));
      expect(bcaWallet.isArchived, isFalse);
      expect(bcaWallet.iconKey, isNull);
      expect(bcaWallet.colorKey, isNull);

      final tunaiWallet = wallets.firstWhere((w) => w.id == 'tunai');
      expect(tunaiWallet.name, equals('Tunai'));
      expect(tunaiWallet.initialBalance, equals(100000));
      expect(tunaiWallet.isArchived, isFalse);
      expect(tunaiWallet.iconKey, isNull);
      expect(tunaiWallet.colorKey, isNull);

      // Memastikan kategori lama tetap ada dan isArchived terisi default false, iconKey & colorKey null
      expect(categories.length, equals(2));
      final makananCategory = categories.firstWhere((c) => c.id == 'exp_makanan');
      expect(makananCategory.name, equals('Makanan'));
      expect(makananCategory.type, equals(CategoryType.expense));
      expect(makananCategory.isArchived, isFalse);
      expect(makananCategory.iconKey, isNull);
      expect(makananCategory.colorKey, isNull);

      final gajiCategory = categories.firstWhere((c) => c.id == 'inc_gaji');
      expect(gajiCategory.name, equals('Gaji'));
      expect(gajiCategory.type, equals(CategoryType.income));
      expect(gajiCategory.isArchived, isFalse);
      expect(gajiCategory.iconKey, isNull);
      expect(gajiCategory.colorKey, isNull);

      // Memastikan transaksi lama tetap utuh
      expect(transactions.length, equals(1));
      expect(transactions.first.id, equals('tx_v1_1'));
      expect(transactions.first.amount, equals(45000));
      expect(transactions.first.walletId, equals('tunai'));
      expect(transactions.first.categoryId, equals('exp_makanan'));
      expect(transactions.first.note, equals('Makan siang'));

      // 4. Verifikasi bahwa kolom baru isArchived berfungsi penuh pada operasi update
      await repository.updateWallet(bcaWallet.copyWith(isArchived: true));
      final updatedWallets = await repository.getAllWallets();
      expect(updatedWallets.firstWhere((w) => w.id == 'bca').isArchived, isTrue);

      await repository.updateCategory(makananCategory.copyWith(isArchived: true));
      final updatedCategories = await repository.getAllCategories();
      expect(updatedCategories.firstWhere((c) => c.id == 'exp_makanan').isArchived, isTrue);

      await repository.close();
    });

    test('Migrasi 2 ke 4: database v2 berisi data, setelah migrasi data utuh dan kolom baru NULL', () async {
      // 1. Buat database skema v2 secara langsung menggunakan sqlite3
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

        // Masukkan data versi 2
        rawDb.execute('''
          INSERT INTO wallets (id, name, initial_balance, is_archived)
          VALUES ('w_mandiri', 'Mandiri', 750000, 0), ('w_lama', 'Lama', 50000, 1);
        ''');
        rawDb.execute('''
          INSERT INTO categories (id, name, type, is_archived)
          VALUES ('c_transport', 'Transportasi', 'expense', 0), ('c_bonus', 'Bonus', 'income', 1);
        ''');
        rawDb.execute('''
          INSERT INTO transactions (id, type, amount, date, wallet_id, category_id, note)
          VALUES ('tx_v2_1', 'expense', 20000, 1728200000, 'w_mandiri', 'c_transport', 'Bensin');
        ''');
      });

      // 2. Buka database menggunakan AppDatabase (schemaVersion = 4).
      // Drift mendeteksi user_version = 2 dan menjalankan onUpgrade(m, 2, 4)
      final db = AppDatabase.forTesting(executor);
      final repository = FinanceRepository(db);

      // Verifikasi user_version naik menjadi 4
      final versionResult = await db.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.data['user_version'], equals(4));

      // 3. Verifikasi data lama tetap utuh
      final wallets = await repository.getAllWallets();
      expect(wallets.length, equals(2));
      final mandiri = wallets.firstWhere((w) => w.id == 'w_mandiri');
      expect(mandiri.initialBalance, equals(750000));
      expect(mandiri.isArchived, isFalse);
      expect(mandiri.iconKey, isNull);
      expect(mandiri.colorKey, isNull);

      final lama = wallets.firstWhere((w) => w.id == 'w_lama');
      expect(lama.isArchived, isTrue);
      expect(lama.iconKey, isNull);
      expect(lama.colorKey, isNull);

      final categories = await repository.getAllCategories();
      expect(categories.length, equals(2));
      final transport = categories.firstWhere((c) => c.id == 'c_transport');
      expect(transport.name, equals('Transportasi'));
      expect(transport.type, equals(CategoryType.expense));
      expect(transport.isArchived, isFalse);
      expect(transport.iconKey, isNull);
      expect(transport.colorKey, isNull);

      final bonus = categories.firstWhere((c) => c.id == 'c_bonus');
      expect(bonus.name, equals('Bonus'));
      expect(bonus.type, equals(CategoryType.income));
      expect(bonus.isArchived, isTrue);
      expect(bonus.iconKey, isNull);
      expect(bonus.colorKey, isNull);

      final transactions = await repository.getAllTransactions();
      expect(transactions.length, equals(1));
      expect(transactions.first.amount, equals(20000));
      expect(transactions.first.categoryId, equals('c_transport'));

      // 4. Verifikasi bahwa kolom baru iconKey dan colorKey dapat disimpan dan diperbarui
      await repository.updateCategory(transport.copyWith(
        iconKey: 'mobil',
        colorKey: 'cyan',
      ));
      final updatedCategories = await repository.getAllCategories();
      final updatedTransport = updatedCategories.firstWhere((c) => c.id == 'c_transport');
      expect(updatedTransport.iconKey, equals('mobil'));
      expect(updatedTransport.colorKey, equals('cyan'));

      await repository.close();
    });

    test('Migrasi 3 ke 4: database v3 berisi data, setelah migrasi data utuh dan kolom baru wallets NULL', () async {
      // 1. Buat database skema v3 secara langsung menggunakan sqlite3
      final executor = NativeDatabase.memory(setup: (rawDb) {
        rawDb.execute('PRAGMA user_version = 3;');
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
            is_archived INTEGER NOT NULL DEFAULT 0,
            icon_key TEXT,
            color_key TEXT
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

        // Masukkan data versi 3
        rawDb.execute('''
          INSERT INTO wallets (id, name, initial_balance, is_archived)
          VALUES ('w_bca', 'BCA Prioritas', 15000000, 0), ('w_kas', 'Kas Kecil', 250000, 0);
        ''');
        rawDb.execute('''
          INSERT INTO categories (id, name, type, is_archived, icon_key, color_key)
          VALUES ('c_kuliner', 'Kuliner', 'expense', 0, 'makan', 'violet');
        ''');
        rawDb.execute('''
          INSERT INTO transactions (id, type, amount, date, wallet_id, category_id, note)
          VALUES ('tx_v3_1', 'expense', 50000, 1728300000, 'w_kas', 'c_kuliner', 'Makan malam');
        ''');
      });

      // 2. Buka database menggunakan AppDatabase (schemaVersion = 4).
      // Drift mendeteksi user_version = 3 dan menjalankan onUpgrade(m, 3, 4)
      final db = AppDatabase.forTesting(executor);
      final repository = FinanceRepository(db);

      // Verifikasi user_version naik menjadi 4
      final versionResult = await db.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.data['user_version'], equals(4));

      // 3. Verifikasi data lama tetap utuh dan kolom baru wallets (iconKey & colorKey) bernilai NULL
      final wallets = await repository.getAllWallets();
      expect(wallets.length, equals(2));
      final bca = wallets.firstWhere((w) => w.id == 'w_bca');
      expect(bca.name, equals('BCA Prioritas'));
      expect(bca.initialBalance, equals(15000000));
      expect(bca.isArchived, isFalse);
      expect(bca.iconKey, isNull);
      expect(bca.colorKey, isNull);

      final kas = wallets.firstWhere((w) => w.id == 'w_kas');
      expect(kas.name, equals('Kas Kecil'));
      expect(kas.initialBalance, equals(250000));
      expect(kas.isArchived, isFalse);
      expect(kas.iconKey, isNull);
      expect(kas.colorKey, isNull);

      // Kategori tetap utuh dengan icon_key dan color_key dari v3
      final categories = await repository.getAllCategories();
      expect(categories.length, equals(1));
      final kuliner = categories.firstWhere((c) => c.id == 'c_kuliner');
      expect(kuliner.iconKey, equals('makan'));
      expect(kuliner.colorKey, equals('violet'));

      // 4. Verifikasi bahwa dompet dapat diupdate dengan iconKey dan colorKey baru
      await repository.updateWallet(bca.copyWith(
        iconKey: 'bank',
        colorKey: 'cyan',
      ));
      final updatedWallets = await repository.getAllWallets();
      final updatedBca = updatedWallets.firstWhere((w) => w.id == 'w_bca');
      expect(updatedBca.iconKey, equals('bank'));
      expect(updatedBca.colorKey, equals('cyan'));

      await repository.close();
    });
  });
}
