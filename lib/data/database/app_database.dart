import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Tabel Dompet (Wallets) sesuai SPEC.md bagian 2.A
@DataClassName('DbWallet')
class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabel Kategori (Categories) sesuai SPEC.md bagian 2.B
@DataClassName('DbCategory')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'income' atau 'expense'
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabel Transaksi (Transactions) sesuai SPEC.md bagian 2.C
@DataClassName('DbTransaction')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'income', 'expense', atau 'transfer'
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()();
  @ReferenceName('sourceTransactions')
  TextColumn get walletId => text().references(Wallets, #id)();
  @ReferenceName('targetTransactions')
  TextColumn get targetWalletId => text().nullable().references(Wallets, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Wallets, Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(name: 'catatan_keuangan'));

  // Konstruktor untuk database in-memory (berguna untuk testing)
  AppDatabase.forTesting(super.executor);

  factory AppDatabase.inMemory() {
    return AppDatabase(NativeDatabase.memory());
  }

  // schemaVersion = 2 sesuai ketentuan Milestone 5
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedInitialData(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(wallets, wallets.isArchived);
          await m.addColumn(categories, categories.isArchived);
        }
      },
      beforeOpen: (details) async {
        // Aktifkan foreign key enforcement di SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Seed awal saat database pertama kali dibuat:
  // - 3 dompet: BCA, Tunai, E-Wallet (saldo awal 0)
  // - Kategori pengeluaran: Makanan, Transportasi, Tagihan, Belanja, Hiburan, Kesehatan, Lainnya
  // - Kategori pemasukan: Gaji, Lainnya
  // - TANPA transaksi
  Future<void> _seedInitialData(Migrator m) async {
    await batch((b) {
      b.insertAll(wallets, [
        WalletsCompanion.insert(id: 'bca', name: 'BCA', initialBalance: const Value(0), isArchived: const Value(false)),
        WalletsCompanion.insert(id: 'tunai', name: 'Tunai', initialBalance: const Value(0), isArchived: const Value(false)),
        WalletsCompanion.insert(id: 'ewallet', name: 'E-Wallet', initialBalance: const Value(0), isArchived: const Value(false)),
      ]);

      b.insertAll(categories, [
        // Kategori Pengeluaran
        CategoriesCompanion.insert(id: 'exp_makanan', name: 'Makanan', type: 'expense', isArchived: const Value(false)),
        CategoriesCompanion.insert(id: 'exp_transportasi', name: 'Transportasi', type: 'expense', isArchived: const Value(false)),
        CategoriesCompanion.insert(id: 'exp_tagihan', name: 'Tagihan', type: 'expense', isArchived: const Value(false)),
        CategoriesCompanion.insert(id: 'exp_belanja', name: 'Belanja', type: 'expense', isArchived: const Value(false)),
        CategoriesCompanion.insert(id: 'exp_hiburan', name: 'Hiburan', type: 'expense', isArchived: const Value(false)),
        CategoriesCompanion.insert(id: 'exp_kesehatan', name: 'Kesehatan', type: 'expense', isArchived: const Value(false)),
        CategoriesCompanion.insert(id: 'exp_lainnya', name: 'Lainnya', type: 'expense', isArchived: const Value(false)),
        // Kategori Pemasukan
        CategoriesCompanion.insert(id: 'inc_gaji', name: 'Gaji', type: 'income', isArchived: const Value(false)),
        CategoriesCompanion.insert(id: 'inc_lainnya', name: 'Lainnya', type: 'income', isArchived: const Value(false)),
      ]);
    });
  }
}
