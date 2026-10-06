import 'package:drift/drift.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import 'database/app_database.dart';

/// Repository data terpusat untuk akses SQLite via Drift sesuai ketentuan Milestone 4.
/// Memisahkan akses database dari layer UI / tampilan layar.
class FinanceRepository {
  final AppDatabase _db;

  FinanceRepository([AppDatabase? db]) : _db = db ?? AppDatabase();

  factory FinanceRepository.inMemory() => FinanceRepository(AppDatabase.inMemory());

  AppDatabase get db => _db;

  /// Mengambil semua dompet dari database
  Future<List<Wallet>> getAllWallets() async {
    final rows = await _db.select(_db.wallets).get();
    return rows
        .map(
          (w) => Wallet(
            id: w.id,
            name: w.name,
            initialBalance: w.initialBalance,
            isArchived: w.isArchived,
          ),
        )
        .toList();
  }

  /// Mengambil semua kategori dari database
  Future<List<Category>> getAllCategories() async {
    final rows = await _db.select(_db.categories).get();
    return rows
        .map(
          (c) => Category(
            id: c.id,
            name: c.name,
            type: c.type == 'income' ? CategoryType.income : CategoryType.expense,
            isArchived: c.isArchived,
          ),
        )
        .toList();
  }

  /// Mengambil semua transaksi dari database (diurutkan berdasarkan tanggal terbaru)
  Future<List<Transaction>> getAllTransactions() async {
    final query = _db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final rows = await query.get();
    return rows.map((t) => _mapDbTransactionToDomain(t)).toList();
  }

  /// Menambah transaksi baru ke database
  Future<void> addTransaction(Transaction tx) async {
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: tx.id,
            type: tx.type.name,
            amount: tx.amount,
            date: tx.date,
            walletId: tx.walletId,
            targetWalletId: Value(tx.targetWalletId),
            categoryId: Value(tx.categoryId),
            note: Value(tx.note),
          ),
        );
  }

  /// Memperbarui transaksi yang ada di database
  Future<void> updateTransaction(Transaction tx) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            type: Value(tx.type.name),
            amount: Value(tx.amount),
            date: Value(tx.date),
            walletId: Value(tx.walletId),
            targetWalletId: Value(tx.targetWalletId),
            categoryId: Value(tx.categoryId),
            note: Value(tx.note),
          ),
        );
  }

  /// Menghapus transaksi berdasarkan ID dari database
  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Menambah dompet baru ke database
  Future<void> addWallet(Wallet wallet) async {
    await _db.into(_db.wallets).insert(
          WalletsCompanion.insert(
            id: wallet.id,
            name: wallet.name,
            initialBalance: Value(wallet.initialBalance),
            isArchived: Value(wallet.isArchived),
          ),
        );
  }

  /// Memperbarui dompet yang ada di database (nama, saldo awal, atau status arsip)
  Future<void> updateWallet(Wallet wallet) async {
    await (_db.update(_db.wallets)..where((w) => w.id.equals(wallet.id))).write(
          WalletsCompanion(
            name: Value(wallet.name),
            initialBalance: Value(wallet.initialBalance),
            isArchived: Value(wallet.isArchived),
          ),
        );
  }

  /// Menghapus dompet secara permanen dari database
  Future<void> deleteWallet(String id) async {
    await (_db.delete(_db.wallets)..where((w) => w.id.equals(id))).go();
  }

  /// Memeriksa apakah dompet pernah dipakai dalam transaksi apa pun
  Future<bool> isWalletUsed(String walletId) async {
    final query = _db.select(_db.transactions)
      ..where((t) => t.walletId.equals(walletId) | t.targetWalletId.equals(walletId));
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  /// Menambah kategori baru ke database
  Future<void> addCategory(Category category) async {
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: category.id,
            name: category.name,
            type: category.type == CategoryType.income ? 'income' : 'expense',
            isArchived: Value(category.isArchived),
          ),
        );
  }

  /// Memperbarui kategori yang ada di database (nama atau status arsip)
  Future<void> updateCategory(Category category) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id))).write(
          CategoriesCompanion(
            name: Value(category.name),
            type: Value(category.type == CategoryType.income ? 'income' : 'expense'),
            isArchived: Value(category.isArchived),
          ),
        );
  }

  /// Menghapus kategori secara permanen dari database
  Future<void> deleteCategory(String id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  /// Memeriksa apakah kategori pernah dipakai dalam transaksi apa pun
  Future<bool> isCategoryUsed(String categoryId) async {
    final query = _db.select(_db.transactions)
      ..where((t) => t.categoryId.equals(categoryId));
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  /// Helper untuk menyisipkan dompet (misalnya saat penyiapan data awal/test)
  Future<void> insertWallet(Wallet wallet) async {
    await addWallet(wallet);
  }

  /// Helper untuk menyisipkan kategori (misalnya saat penyiapan data awal/test)
  Future<void> insertCategory(Category category) async {
    await addCategory(category);
  }

  /// Mengganti seluruh data (dompet, kategori, transaksi) secara atomik dalam satu transaksi database.
  /// Jika terjadi kegagalan di tengah jalan, seluruh perubahan akan di-rollback sehingga data lama tidak berubah.
  Future<void> restoreData({
    required List<Wallet> wallets,
    required List<Category> categories,
    required List<Transaction> transactions,
  }) async {
    await _db.transaction(() async {
      // 1. Hapus transaksi terlebih dahulu (menghormati foreign key)
      await _db.delete(_db.transactions).go();
      // 2. Hapus kategori dan dompet lama
      await _db.delete(_db.categories).go();
      await _db.delete(_db.wallets).go();

      // 3. Masukkan dompet baru
      for (final w in wallets) {
        await addWallet(w);
      }

      // 4. Masukkan kategori baru
      for (final c in categories) {
        await addCategory(c);
      }

      // 5. Masukkan transaksi baru
      for (final tx in transactions) {
        await addTransaction(tx);
      }
    });
  }

  /// Menutup koneksi database
  Future<void> close() async {
    await _db.close();
  }

  static Transaction _mapDbTransactionToDomain(DbTransaction t) {
    TransactionType txType;
    switch (t.type) {
      case 'income':
        txType = TransactionType.income;
        break;
      case 'transfer':
        txType = TransactionType.transfer;
        break;
      case 'expense':
      default:
        txType = TransactionType.expense;
        break;
    }
    return Transaction(
      id: t.id,
      type: txType,
      amount: t.amount,
      date: t.date,
      walletId: t.walletId,
      targetWalletId: t.targetWalletId,
      categoryId: t.categoryId,
      note: t.note,
    );
  }
}
