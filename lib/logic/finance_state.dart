import 'package:flutter/widgets.dart';
import '../data/finance_repository.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import 'finance_calculator.dart';

// State bersama pengelolaan data keuangan menggunakan ChangeNotifier bawaan Flutter
class FinanceState extends ChangeNotifier {
  static const List<Wallet> defaultSeedWallets = [
    Wallet(id: 'bca', name: 'BCA', initialBalance: 0),
    Wallet(id: 'tunai', name: 'Tunai', initialBalance: 0),
    Wallet(id: 'ewallet', name: 'E-Wallet', initialBalance: 0),
  ];

  static const List<Category> defaultSeedCategories = [
    // Kategori Pengeluaran
    Category(id: 'exp_makanan', name: 'Makanan', type: CategoryType.expense),
    Category(id: 'exp_transportasi', name: 'Transportasi', type: CategoryType.expense),
    Category(id: 'exp_tagihan', name: 'Tagihan', type: CategoryType.expense),
    Category(id: 'exp_belanja', name: 'Belanja', type: CategoryType.expense),
    Category(id: 'exp_hiburan', name: 'Hiburan', type: CategoryType.expense),
    Category(id: 'exp_kesehatan', name: 'Kesehatan', type: CategoryType.expense),
    Category(id: 'exp_lainnya', name: 'Lainnya', type: CategoryType.expense),
    // Kategori Pemasukan
    Category(id: 'inc_gaji', name: 'Gaji', type: CategoryType.income),
    Category(id: 'inc_lainnya', name: 'Lainnya', type: CategoryType.income),
  ];

  final FinanceRepository? _repository;
  List<Wallet> _wallets;
  List<Category> _categories;
  List<Transaction> _transactions;
  String? _lastSelectedWalletId;
  bool _isLoading = false;

  FinanceState({
    FinanceRepository? repository,
    List<Wallet>? initialWallets,
    List<Category>? initialCategories,
    List<Transaction>? initialTransactions,
  })  : _repository = repository,
        _wallets = List.from(initialWallets ?? defaultSeedWallets),
        _categories = List.from(initialCategories ?? defaultSeedCategories),
        _transactions = List.from(initialTransactions ?? []);

  FinanceRepository? get repository => _repository;
  List<Wallet> get wallets => List.unmodifiable(_wallets);
  List<Wallet> get activeWallets => List.unmodifiable(_wallets.where((w) => !w.isArchived));
  List<Category> get categories => List.unmodifiable(_categories);
  List<Category> get activeCategories => List.unmodifiable(_categories.where((c) => !c.isArchived));
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String? get lastSelectedWalletId => _lastSelectedWalletId;
  bool get isLoading => _isLoading;

  set lastSelectedWalletId(String? walletId) {
    _lastSelectedWalletId = walletId;
    notifyListeners();
  }

  /// Membaca data secara asinkron dari repository database
  Future<void> loadData() async {
    if (_repository == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final wallets = await _repository.getAllWallets();
      final categories = await _repository.getAllCategories();
      final transactions = await _repository.getAllTransactions();

      _wallets = wallets.isNotEmpty ? wallets : List.from(defaultSeedWallets);
      _categories = categories.isNotEmpty ? categories : List.from(defaultSeedCategories);
      _transactions = transactions;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validasi aturan form transaksi sesuai Milestone 3:
  /// - Nominal harus > 0
  /// - Transfer tidak boleh dompet asal = tujuan
  /// - Kategori wajib untuk pemasukan/pengeluaran
  static String? validate({
    required int amount,
    required TransactionType type,
    required String walletId,
    String? targetWalletId,
    String? categoryId,
  }) {
    if (amount <= 0) {
      return 'Nominal harus lebih besar dari 0';
    }
    if (type == TransactionType.transfer) {
      if (targetWalletId == null || targetWalletId.trim().isEmpty) {
        return 'Dompet tujuan transfer harus dipilih';
      }
      if (walletId == targetWalletId) {
        return 'Dompet asal dan tujuan tidak boleh sama';
      }
    } else {
      if (categoryId == null || categoryId.trim().isEmpty) {
        return 'Kategori wajib dipilih untuk ${type == TransactionType.income ? "pemasukan" : "pengeluaran"}';
      }
    }
    return null;
  }

  /// Validasi nama dompet: tidak boleh kosong dan tidak boleh kembar (abaikan huruf besar-kecil)
  String? validateWalletName(String name, {String? excludeWalletId}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Nama dompet tidak boleh kosong';
    }
    final lower = trimmed.toLowerCase();
    final duplicate = _wallets.any(
      (w) => w.id != excludeWalletId && w.name.trim().toLowerCase() == lower,
    );
    if (duplicate) {
      return 'Nama dompet sudah digunakan';
    }
    return null;
  }

  /// Validasi nama kategori: tidak boleh kosong dan tidak boleh kembar dalam kelompok yang sama
  String? validateCategoryName(String name, CategoryType type, {String? excludeCategoryId}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Nama kategori tidak boleh kosong';
    }
    final lower = trimmed.toLowerCase();
    final duplicate = _categories.any(
      (c) =>
          c.type == type &&
          c.id != excludeCategoryId &&
          c.name.trim().toLowerCase() == lower,
    );
    if (duplicate) {
      return 'Nama kategori sudah digunakan dalam kelompok ini';
    }
    return null;
  }

  /// Menambah transaksi baru dan mengingat dompet yang dipilih
  Future<void> addTransaction(Transaction transaction) async {
    final error = validate(
      amount: transaction.amount,
      type: transaction.type,
      walletId: transaction.walletId,
      targetWalletId: transaction.targetWalletId,
      categoryId: transaction.categoryId,
    );
    if (error != null) {
      throw ArgumentError(error);
    }

    if (_repository != null) {
      await _repository.addTransaction(transaction);
    }
    _transactions.add(transaction);
    _lastSelectedWalletId = transaction.walletId;
    notifyListeners();
  }

  /// Mengubah transaksi yang sudah ada berdasarkan ID
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index == -1) {
      throw ArgumentError('Transaksi dengan ID ${updatedTransaction.id} tidak ditemukan');
    }

    final error = validate(
      amount: updatedTransaction.amount,
      type: updatedTransaction.type,
      walletId: updatedTransaction.walletId,
      targetWalletId: updatedTransaction.targetWalletId,
      categoryId: updatedTransaction.categoryId,
    );
    if (error != null) {
      throw ArgumentError(error);
    }

    if (_repository != null) {
      await _repository.updateTransaction(updatedTransaction);
    }
    _transactions[index] = updatedTransaction;
    _lastSelectedWalletId = updatedTransaction.walletId;
    notifyListeners();
  }

  /// Menghapus transaksi berdasarkan ID
  Future<void> deleteTransaction(String id) async {
    if (_repository != null) {
      await _repository.deleteTransaction(id);
    }
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Menambah dompet baru
  Future<void> addWallet(Wallet wallet) async {
    final error = validateWalletName(wallet.name);
    if (error != null) {
      throw ArgumentError(error);
    }
    if (_repository != null) {
      await _repository.addWallet(wallet);
    }
    _wallets.add(wallet);
    notifyListeners();
  }

  /// Mengubah nama dan/atau saldo awal dompet
  Future<void> updateWallet(Wallet updatedWallet) async {
    final index = _wallets.indexWhere((w) => w.id == updatedWallet.id);
    if (index == -1) {
      throw ArgumentError('Dompet dengan ID ${updatedWallet.id} tidak ditemukan');
    }
    final error = validateWalletName(updatedWallet.name, excludeWalletId: updatedWallet.id);
    if (error != null) {
      throw ArgumentError(error);
    }
    if (_repository != null) {
      await _repository.updateWallet(updatedWallet);
    }
    _wallets[index] = updatedWallet;
    notifyListeners();
  }

  /// Mengarsipkan atau mengaktifkan kembali dompet
  Future<void> archiveWallet(String walletId, {bool isArchived = true}) async {
    final index = _wallets.indexWhere((w) => w.id == walletId);
    if (index == -1) {
      throw ArgumentError('Dompet dengan ID $walletId tidak ditemukan');
    }
    final updated = _wallets[index].copyWith(isArchived: isArchived);
    if (_repository != null) {
      await _repository.updateWallet(updated);
    }
    _wallets[index] = updated;
    notifyListeners();
  }

  /// Memeriksa apakah dompet pernah dipakai transaksi
  bool isWalletUsed(String walletId) {
    return _transactions.any((t) => t.walletId == walletId || t.targetWalletId == walletId);
  }

  /// Menghapus dompet secara permanen (hanya jika belum pernah dipakai transaksi)
  Future<void> deleteWallet(String walletId) async {
    if (isWalletUsed(walletId)) {
      throw StateError('Dompet tidak dapat dihapus permanen karena sudah dipakai transaksi');
    }
    if (_repository != null) {
      await _repository.deleteWallet(walletId);
    }
    _wallets.removeWhere((w) => w.id == walletId);
    if (_lastSelectedWalletId == walletId) {
      _lastSelectedWalletId = null;
    }
    notifyListeners();
  }

  /// Menambah kategori baru
  Future<void> addCategory(Category category) async {
    final error = validateCategoryName(category.name, category.type);
    if (error != null) {
      throw ArgumentError(error);
    }
    if (_repository != null) {
      await _repository.addCategory(category);
    }
    _categories.add(category);
    notifyListeners();
  }

  /// Mengubah nama kategori
  Future<void> updateCategory(Category updatedCategory) async {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index == -1) {
      throw ArgumentError('Kategori dengan ID ${updatedCategory.id} tidak ditemukan');
    }
    final error = validateCategoryName(
      updatedCategory.name,
      updatedCategory.type,
      excludeCategoryId: updatedCategory.id,
    );
    if (error != null) {
      throw ArgumentError(error);
    }
    if (_repository != null) {
      await _repository.updateCategory(updatedCategory);
    }
    _categories[index] = updatedCategory;
    notifyListeners();
  }

  /// Mengarsipkan atau mengaktifkan kembali kategori
  Future<void> archiveCategory(String categoryId, {bool isArchived = true}) async {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index == -1) {
      throw ArgumentError('Kategori dengan ID $categoryId tidak ditemukan');
    }
    final updated = _categories[index].copyWith(isArchived: isArchived);
    if (_repository != null) {
      await _repository.updateCategory(updated);
    }
    _categories[index] = updated;
    notifyListeners();
  }

  /// Memeriksa apakah kategori pernah dipakai transaksi
  bool isCategoryUsed(String categoryId) {
    return _transactions.any((t) => t.categoryId == categoryId);
  }

  /// Menghapus kategori secara permanen (hanya jika belum pernah dipakai transaksi)
  Future<void> deleteCategory(String categoryId) async {
    if (isCategoryUsed(categoryId)) {
      throw StateError('Kategori tidak dapat dihapus permanen karena sudah dipakai transaksi');
    }
    if (_repository != null) {
      await _repository.deleteCategory(categoryId);
    }
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  /// Mengganti seluruh data (dompet, kategori, transaksi) secara atomik dari cadangan
  Future<void> restoreData({
    required List<Wallet> wallets,
    required List<Category> categories,
    required List<Transaction> transactions,
  }) async {
    if (_repository != null) {
      await _repository.restoreData(
        wallets: wallets,
        categories: categories,
        transactions: transactions,
      );
    }
    _wallets = List.from(wallets);
    _categories = List.from(categories);
    _transactions = List.from(transactions);
    _lastSelectedWalletId = null;
    notifyListeners();
  }

  /// Mengambil saldo terkini untuk seluruh dompet
  Map<String, int> get walletBalances =>
      FinanceCalculator.calculateAllWalletBalances(_wallets, _transactions);

  /// Mengambil saldo satu dompet tertentu
  int getWalletBalance(String walletId) {
    final wallet = _wallets.firstWhere(
      (w) => w.id == walletId,
      orElse: () => Wallet(id: walletId, name: walletId, initialBalance: 0),
    );
    return FinanceCalculator.calculateWalletBalance(wallet, _transactions);
  }

  /// Mengambil ringkasan keuangan pada bulan & tahun tertentu
  MonthlySummary getMonthlySummary(int year, int month) =>
      FinanceCalculator.calculateMonthlySummary(_transactions, year, month);

  /// Mengambil rincian pengeluaran per kategori pada bulan & tahun tertentu
  ExpenseBreakdownResult getExpenseBreakdown(int year, int month) =>
      FinanceCalculator.calculateExpenseBreakdown(
        _transactions,
        _categories,
        year,
        month,
      );

  /// Mengambil transaksi yang difilter per bulan & tahun
  List<Transaction> getTransactionsByMonth(int year, int month) =>
      FinanceCalculator.filterTransactionsByMonth(_transactions, year, month);

  /// Mengambil kelompok transaksi per hari dengan subtotal harian pada bulan & tahun tertentu
  List<DailyTransactionGroup> getDailyTransactionGroups(int year, int month) =>
      FinanceCalculator.groupTransactionsByDay(_transactions, year, month);

  /// Helper untuk mengambil nama dompet dari ID
  String getWalletName(String walletId) {
    final match = _wallets.where((w) => w.id == walletId);
    return match.isNotEmpty ? match.first.name : walletId;
  }

  /// Helper untuk mengambil nama kategori dari ID
  String getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Tanpa Kategori';
    final match = _categories.where((c) => c.id == categoryId);
    return match.isNotEmpty ? match.first.name : 'Tanpa Kategori';
  }

  /// Helper untuk mengambil kategori dari ID
  Category? getCategoryById(String? categoryId) {
    if (categoryId == null) return null;
    final match = _categories.where((c) => c.id == categoryId);
    return match.isNotEmpty ? match.first : null;
  }

  /// Mengambil daftar kategori yang cocok dengan tipe transaksi (opsi penyaringan arsip)
  List<Category> getCategoriesByType(TransactionType type, {bool includeArchived = false}) {
    if (type == TransactionType.transfer) return [];
    final targetCategoryType =
        type == TransactionType.income ? CategoryType.income : CategoryType.expense;
    return _categories
        .where((c) => c.type == targetCategoryType && (includeArchived || !c.isArchived))
        .toList();
  }
}

// Widget Scope bawaan Flutter untuk mendistribusikan FinanceState ke seluruh tree
class FinanceScope extends InheritedNotifier<FinanceState> {
  const FinanceScope({
    super.key,
    required FinanceState state,
    required super.child,
  }) : super(notifier: state);

  static FinanceState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FinanceScope>();
    assert(scope != null, 'FinanceScope tidak ditemukan di BuildContext');
    return scope!.notifier!;
  }

  static FinanceState? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FinanceScope>();
    return scope?.notifier;
  }
}
