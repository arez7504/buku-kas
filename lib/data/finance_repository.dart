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

  /// Helper untuk menyisipkan dompet (misalnya saat penyiapan data awal/test)
  Future<void> insertWallet(Wallet wallet) async {
    await _db.into(_db.wallets).insert(
          WalletsCompanion.insert(
            id: wallet.id,
            name: wallet.name,
            initialBalance: Value(wallet.initialBalance),
          ),
        );
  }

  /// Helper untuk menyisipkan kategori (misalnya saat penyiapan data awal/test)
  Future<void> insertCategory(Category category) async {
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: category.id,
            name: category.name,
            type: category.type == CategoryType.income ? 'income' : 'expense',
          ),
        );
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
