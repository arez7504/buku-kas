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

      // Verifikasi user_version telah dinaikkan ke versi 2
      final versionResult = await db.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.data['user_version'], equals(2));

      // 3. Verifikasi data lama tetap utuh pasca-migrasi
      final wallets = await repository.getAllWallets();
      final categories = await repository.getAllCategories();
      final transactions = await repository.getAllTransactions();

      // Memastikan dompet lama tetap ada, initialBalance tetap 500.000 dan 100.000,
      // serta nilai kolom baru isArchived terisi default false
      expect(wallets.length, equals(2));
      final bcaWallet = wallets.firstWhere((w) => w.id == 'bca');
      expect(bcaWallet.name, equals('BCA'));
      expect(bcaWallet.initialBalance, equals(500000));
      expect(bcaWallet.isArchived, isFalse);

      final tunaiWallet = wallets.firstWhere((w) => w.id == 'tunai');
      expect(tunaiWallet.name, equals('Tunai'));
      expect(tunaiWallet.initialBalance, equals(100000));
      expect(tunaiWallet.isArchived, isFalse);

      // Memastikan kategori lama tetap ada dan isArchived terisi default false
      expect(categories.length, equals(2));
      final makananCategory = categories.firstWhere((c) => c.id == 'exp_makanan');
      expect(makananCategory.name, equals('Makanan'));
      expect(makananCategory.type, equals(CategoryType.expense));
      expect(makananCategory.isArchived, isFalse);

      final gajiCategory = categories.firstWhere((c) => c.id == 'inc_gaji');
      expect(gajiCategory.name, equals('Gaji'));
      expect(gajiCategory.type, equals(CategoryType.income));
      expect(gajiCategory.isArchived, isFalse);

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
  });
}
