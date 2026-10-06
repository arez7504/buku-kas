import '../models/transaction.dart';
import '../models/wallet.dart';

// Model penyimpan hasil kalkulasi ringkasan bulanan
class MonthlySummary {
  final int totalIncome;
  final int totalExpense;
  final int netCashFlow; // Selisih / Arus Kas Bersih (Pemasukan - Pengeluaran)

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
  });
}

// Logika murni perhitungan keuangan dan filter (dapat diuji tanpa layar Flutter)
class FinanceCalculator {
  /// Menghitung saldo terkini sebuah dompet berdasarkan:
  /// Saldo Dompet = Saldo Awal + Total Pemasukan - Total Pengeluaran - Total Transfer Keluar + Total Transfer Masuk
  static int calculateWalletBalance(Wallet wallet, List<Transaction> transactions) {
    int balance = wallet.initialBalance;

    for (final t in transactions) {
      if (t.walletId == wallet.id) {
        switch (t.type) {
          case TransactionType.income:
            balance += t.amount;
            break;
          case TransactionType.expense:
            balance -= t.amount;
            break;
          case TransactionType.transfer:
            // Mengurangi saldo dompet asal
            balance -= t.amount;
            break;
        }
      }

      // Menambah saldo dompet tujuan jika ada transfer masuk
      if (t.type == TransactionType.transfer && t.targetWalletId == wallet.id) {
        balance += t.amount;
      }
    }

    return balance;
  }

  /// Menghitung saldo untuk seluruh daftar dompet sekaligus.
  /// Mengembalikan Map dengan key: wallet.id dan value: saldo akhir.
  static Map<String, int> calculateAllWalletBalances(
    List<Wallet> wallets,
    List<Transaction> transactions,
  ) {
    final result = <String, int>{};
    for (final wallet in wallets) {
      result[wallet.id] = calculateWalletBalance(wallet, transactions);
    }
    return result;
  }

  /// Menghitung ringkasan bulanan (total pemasukan, pengeluaran, selisih).
  /// Sesuai SPEC.md: Transaksi transfer TIDAK DIHITUNG ke dalam pemasukan maupun pengeluaran.
  static MonthlySummary calculateMonthlySummary(
    List<Transaction> transactions,
    int year,
    int month,
  ) {
    int income = 0;
    int expense = 0;

    for (final t in transactions) {
      if (t.date.year == year && t.date.month == month) {
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else if (t.type == TransactionType.expense) {
          expense += t.amount;
        }
        // TransactionType.transfer tidak mempengaruhi ringkasan bulanan
      }
    }

    return MonthlySummary(
      totalIncome: income,
      totalExpense: expense,
      netCashFlow: income - expense,
    );
  }

  /// Menyaring daftar transaksi berdasarkan bulan & tahun terpilih,
  /// diurutkan dari yang terbaru (tanggal terbesar) ke yang terlama.
  static List<Transaction> filterTransactionsByMonth(
    List<Transaction> transactions,
    int year,
    int month,
  ) {
    final filtered = transactions
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  /// Helper format mata uang Rupiah integer: 1000000 -> "Rp 1.000.000"
  static String formatRupiah(int amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final str = absAmount.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    final formatted = buffer.toString().split('').reversed.join('');
    return '${isNegative ? "-Rp " : "Rp "}$formatted';
  }

  /// Helper nama bulan Bahasa Indonesia
  static String formatMonthYear(DateTime date) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }
}
