import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

// Data dompet palsu sesuai spesifikasi
final List<Wallet> dummyWallets = [
  const Wallet(
    id: 'bca',
    name: 'BCA',
    initialBalance: 1000000,
  ),
  const Wallet(
    id: 'tunai',
    name: 'Tunai',
    initialBalance: 200000,
  ),
  const Wallet(
    id: 'ewallet',
    name: 'E-Wallet',
    initialBalance: 150000,
  ),
];

// Data kategori palsu
final List<Category> dummyCategories = [
  // Kategori Pemasukan
  const Category(
    id: 'c_gaji',
    name: 'Gaji',
    type: CategoryType.income,
  ),
  const Category(
    id: 'c_bonus',
    name: 'Bonus',
    type: CategoryType.income,
  ),
  // Kategori Pengeluaran
  const Category(
    id: 'c_makanan',
    name: 'Makanan',
    type: CategoryType.expense,
  ),
  const Category(
    id: 'c_transport',
    name: 'Transportasi',
    type: CategoryType.expense,
  ),
  const Category(
    id: 'c_tagihan',
    name: 'Tagihan',
    type: CategoryType.expense,
  ),
  const Category(
    id: 'c_belanja',
    name: 'Belanja',
    type: CategoryType.expense,
  ),
];

// Data transaksi palsu minimal 2 bulan (Oktober 2026 dan September 2026)
final List<Transaction> dummyTransactions = [
  // --- Bulan Oktober 2026 ---
  Transaction(
    id: 't_oct_1',
    type: TransactionType.income,
    amount: 5000000,
    date: DateTime(2026, 10, 1),
    walletId: 'bca',
    categoryId: 'c_gaji',
    note: 'Gaji bulanan masuk',
  ),
  Transaction(
    id: 't_oct_2',
    type: TransactionType.expense,
    amount: 35000,
    date: DateTime(2026, 10, 2),
    walletId: 'tunai',
    categoryId: 'c_makanan',
    note: 'Makan siang nasi padang',
  ),
  Transaction(
    id: 't_oct_3',
    type: TransactionType.transfer,
    amount: 300000,
    date: DateTime(2026, 10, 3),
    walletId: 'bca',
    targetWalletId: 'tunai',
    note: 'Tarik tunai ATM',
  ),
  Transaction(
    id: 't_oct_4',
    type: TransactionType.expense,
    amount: 50000,
    date: DateTime(2026, 10, 4),
    walletId: 'ewallet',
    categoryId: 'c_transport',
    note: 'Beli bensin motor',
  ),
  Transaction(
    id: 't_oct_5',
    type: TransactionType.expense,
    amount: 120000,
    date: DateTime(2026, 10, 5),
    walletId: 'bca',
    categoryId: 'c_tagihan',
    note: 'Langganan internet',
  ),

  // --- Bulan September 2026 ---
  Transaction(
    id: 't_sep_1',
    type: TransactionType.income,
    amount: 4500000,
    date: DateTime(2026, 9, 1),
    walletId: 'bca',
    categoryId: 'c_gaji',
    note: 'Gaji September',
  ),
  Transaction(
    id: 't_sep_2',
    type: TransactionType.expense,
    amount: 85000,
    date: DateTime(2026, 9, 5),
    walletId: 'tunai',
    categoryId: 'c_belanja',
    note: 'Beli perlengkapan rumah',
  ),
  Transaction(
    id: 't_sep_3',
    type: TransactionType.transfer,
    amount: 200000,
    date: DateTime(2026, 9, 10),
    walletId: 'bca',
    targetWalletId: 'ewallet',
    note: 'Top up saldo e-wallet',
  ),
  Transaction(
    id: 't_sep_4',
    type: TransactionType.expense,
    amount: 150000,
    date: DateTime(2026, 9, 15),
    walletId: 'bca',
    categoryId: 'c_tagihan',
    note: 'Tagihan listrik',
  ),
];

// Helper untuk mendapatkan nama dompet berdasarkan ID
String getWalletName(String walletId) {
  final match = dummyWallets.where((w) => w.id == walletId);
  return match.isNotEmpty ? match.first.name : walletId;
}

// Helper untuk mendapatkan nama kategori berdasarkan ID
String getCategoryName(String? categoryId) {
  if (categoryId == null) return 'Tanpa Kategori';
  final match = dummyCategories.where((c) => c.id == categoryId);
  return match.isNotEmpty ? match.first.name : 'Tanpa Kategori';
}
