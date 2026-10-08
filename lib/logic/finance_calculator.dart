import '../models/category.dart';
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

// Model penyimpan satu baris rincian pengeluaran per kategori
class CategoryExpenseBreakdown {
  final String categoryId;
  final String categoryName;
  final int amount;
  final double percentage;
  final String percentageText; // contoh: '58,5'
  final String formattedPercentage; // contoh: '58,5%'

  const CategoryExpenseBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.percentageText,
    required this.formattedPercentage,
  });
}

// Model penyimpan hasil rincian pengeluaran bulanan
class ExpenseBreakdownResult {
  final int totalExpense;
  final List<CategoryExpenseBreakdown> items;

  const ExpenseBreakdownResult({
    required this.totalExpense,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
  CategoryExpenseBreakdown operator [](int index) => items[index];
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

  /// Menghitung rincian pengeluaran per kategori pada bulan & tahun tertentu.
  /// Aturan perhitungan sesuai SPEC.md:
  /// - Hanya transaksi bertipe pengeluaran (transfer dan pemasukan tidak dihitung).
  /// - Kategori yang diarsipkan tetap dihitung dan tampil dengan namanya.
  /// - Nominal tetap integer. Persen dihitung dari integer, ditampilkan dengan satu desimal.
  /// - Total semua baris sama persis dengan 'Pengeluaran bulan ini' di Buku Kas.
  /// - Diurutkan dari nominal terbesar ke terkecil.
  static ExpenseBreakdownResult calculateExpenseBreakdown(
    List<Transaction> transactions,
    List<Category> categories,
    int year,
    int month,
  ) {
    // 1. Saring transaksi pengeluaran pada bulan dan tahun terpilih
    final expenseTransactions = transactions
        .where((t) =>
            t.date.year == year &&
            t.date.month == month &&
            t.type == TransactionType.expense)
        .toList();

    if (expenseTransactions.isEmpty) {
      return const ExpenseBreakdownResult(
        totalExpense: 0,
        items: [],
      );
    }

    // 2. Akumulasi nominal integer per categoryId
    final Map<String, int> categoryAmounts = {};
    int totalExpense = 0;

    for (final t in expenseTransactions) {
      final catId = t.categoryId ?? '';
      categoryAmounts[catId] = (categoryAmounts[catId] ?? 0) + t.amount;
      totalExpense += t.amount;
    }

    // Peta nama kategori (termasuk kategori terarsip)
    final Map<String, String> categoryNames = {
      for (final c in categories) c.id: c.name,
    };

    // 3. Konversi menjadi daftar CategoryExpenseBreakdown
    final List<CategoryExpenseBreakdown> items = [];

    categoryAmounts.forEach((catId, amount) {
      final name =
          categoryNames[catId] ?? (catId.isEmpty ? 'Tanpa Kategori' : catId);

      // Hitung persentase dari integer: (amount * 1000 / totalExpense).round()
      final tenths = totalExpense > 0
          ? ((amount * 1000) / totalExpense).round()
          : 0;
      final integerPart = tenths ~/ 10;
      final decimalPart = tenths % 10;
      final percentageText = '$integerPart,$decimalPart';
      final formattedPercentage = '$percentageText%';
      final percentage = tenths / 10.0;

      items.add(CategoryExpenseBreakdown(
        categoryId: catId,
        categoryName: name,
        amount: amount,
        percentage: percentage,
        percentageText: percentageText,
        formattedPercentage: formattedPercentage,
      ));
    });

    // 4. Urutkan dari pengeluaran terbesar ke terkecil
    items.sort((a, b) {
      final cmp = b.amount.compareTo(a.amount);
      if (cmp != 0) return cmp;
      return a.categoryName.compareTo(b.categoryName);
    });

    return ExpenseBreakdownResult(
      totalExpense: totalExpense,
      items: List.unmodifiable(items),
    );
  }
}
