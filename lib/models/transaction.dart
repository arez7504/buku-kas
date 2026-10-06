// Enum tipe transaksi sesuai SPEC.md
enum TransactionType {
  income,
  expense,
  transfer,
}

// Model Transaction sesuai SPEC.md bagian 2.C
class Transaction {
  final String id;
  final TransactionType type;
  
  // Nominal uang dalam bentuk integer (int) untuk mencegah floating-point error
  final int amount;
  
  final DateTime date;
  
  // ID dompet yang terlibat / dompet asal jika transfer
  final String walletId;
  
  // ID dompet tujuan jika bertipe transfer (opsional)
  final String? targetWalletId;
  
  // ID kategori jika bertipe income atau expense (opsional)
  final String? categoryId;
  
  // Catatan singkat transaksi (opsional)
  final String? note;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.walletId,
    this.targetWalletId,
    this.categoryId,
    this.note,
  });
}
