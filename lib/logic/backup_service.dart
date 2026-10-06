import 'dart:convert';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

/// Exception khusus untuk kegagalan validasi berkas cadangan (backup)
class BackupValidationException implements Exception {
  final String message;

  const BackupValidationException(this.message);

  @override
  String toString() => message;
}

/// Model pembungkus data hasil ekspor / impor cadangan
class BackupData {
  final int formatVersion;
  final DateTime exportedAt;
  final List<Wallet> wallets;
  final List<Category> categories;
  final List<Transaction> transactions;

  const BackupData({
    required this.formatVersion,
    required this.exportedAt,
    required this.wallets,
    required this.categories,
    required this.transactions,
  });

  BackupSummary get summary => BackupService.getSummary(this);
}

/// Ringkasan isi berkas cadangan untuk ditampilkan kepada pengguna sebelum konfirmasi pemulihan
class BackupSummary {
  final int walletCount;
  final int categoryCount;
  final int transactionCount;
  final DateTime? earliestDate;
  final DateTime? latestDate;

  const BackupSummary({
    required this.walletCount,
    required this.categoryCount,
    required this.transactionCount,
    this.earliestDate,
    this.latestDate,
  });

  String get dateRangeText {
    if (earliestDate == null || latestDate == null) {
      return 'Tidak ada transaksi';
    }
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (earliestDate!.year == latestDate!.year &&
        earliestDate!.month == latestDate!.month &&
        earliestDate!.day == latestDate!.day) {
      return fmt(earliestDate!);
    }
    return '${fmt(earliestDate!)} - ${fmt(latestDate!)}';
  }
}

/// Layanan murni serialisasi dan validasi data cadangan (tanpa ketergantungan UI atau DB)
class BackupService {
  static const int currentFormatVersion = 1;

  /// Menghasilkan nama berkas cadangan berformat: catatan_keuangan_YYYY-MM-DD.json
  static String generateBackupFileName([DateTime? date]) {
    final d = date ?? DateTime.now();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return 'catatan_keuangan_$y-$m-$day.json';
  }

  /// Mengekspor seluruh data ke dalam string JSON terformat rapi
  static String exportToJson({
    required List<Wallet> wallets,
    required List<Category> categories,
    required List<Transaction> transactions,
    DateTime? exportTime,
  }) {
    final now = exportTime ?? DateTime.now();

    final data = {
      'formatVersion': currentFormatVersion,
      'exportedAt': now.toIso8601String(),
      'wallets': wallets
          .map((w) => {
                'id': w.id,
                'name': w.name,
                'initialBalance': w.initialBalance,
                'isArchived': w.isArchived,
              })
          .toList(),
      'categories': categories
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'type': c.type.name,
                'isArchived': c.isArchived,
              })
          .toList(),
      'transactions': transactions
          .map((t) => {
                'id': t.id,
                'type': t.type.name,
                'amount': t.amount,
                'date': t.date.toIso8601String(),
                'walletId': t.walletId,
                'targetWalletId': t.targetWalletId,
                'categoryId': t.categoryId,
                'note': t.note,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Memvalidasi string JSON dan memparsing menjadi BackupData.
  /// Menolak dengan melempar BackupValidationException jika ada aturan yang dilanggar.
  static BackupData parseAndValidate(String jsonContent) {
    if (jsonContent.trim().isEmpty) {
      throw const BackupValidationException('Berkas cadangan kosong');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(jsonContent);
    } catch (_) {
      throw const BackupValidationException('Format JSON tidak valid atau berkas rusak');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const BackupValidationException('Format berkas cadangan harus berupa objek JSON');
    }

    // 1. Validasi formatVersion
    if (!decoded.containsKey('formatVersion')) {
      throw const BackupValidationException('Field "formatVersion" wajib ada dalam berkas cadangan');
    }
    final rawVersion = decoded['formatVersion'];
    if (rawVersion is! int) {
      throw const BackupValidationException('Field "formatVersion" harus berupa bilangan bulat (integer)');
    }
    if (rawVersion != currentFormatVersion) {
      throw BackupValidationException(
        'Format versi berkas ($rawVersion) tidak dikenal atau tidak didukung (versi yang didukung: $currentFormatVersion)',
      );
    }

    // 2. Validasi exportedAt
    if (!decoded.containsKey('exportedAt') || decoded['exportedAt'] == null) {
      throw const BackupValidationException('Field tanggal ekspor "exportedAt" wajib ada');
    }
    final exportedAt = DateTime.tryParse(decoded['exportedAt'].toString());
    if (exportedAt == null) {
      throw const BackupValidationException('Format tanggal ekspor "exportedAt" tidak valid');
    }

    // 3. Validasi Wallets
    if (!decoded.containsKey('wallets') || decoded['wallets'] is! List) {
      throw const BackupValidationException('Field "wallets" wajib ada dan harus berupa daftar (array)');
    }
    final rawWallets = decoded['wallets'] as List;
    final parsedWallets = <Wallet>[];
    final walletIds = <String>{};

    for (int i = 0; i < rawWallets.length; i++) {
      final w = rawWallets[i];
      if (w is! Map) {
        throw BackupValidationException('Data dompet pada baris ${i + 1} harus berupa objek');
      }
      final id = w['id']?.toString().trim();
      final name = w['name']?.toString().trim();
      final initialBalance = w['initialBalance'];
      final isArchived = w['isArchived'];

      if (id == null || id.isEmpty) {
        throw BackupValidationException('ID dompet pada baris ${i + 1} tidak boleh kosong');
      }
      if (walletIds.contains(id)) {
        throw BackupValidationException('ID dompet duplikat ditemukan: "$id"');
      }
      walletIds.add(id);

      if (name == null || name.isEmpty) {
        throw BackupValidationException('Nama dompet pada ID "$id" tidak boleh kosong');
      }
      if (initialBalance is! int) {
        throw BackupValidationException(
          'Saldo awal pada dompet "$name" harus berupa bilangan bulat (integer), bukan pecahan atau teks',
        );
      }
      if (isArchived != null && isArchived is! bool) {
        throw BackupValidationException('Status arsip pada dompet "$name" harus berupa boolean');
      }

      parsedWallets.add(
        Wallet(
          id: id,
          name: name,
          initialBalance: initialBalance,
          isArchived: isArchived == true,
        ),
      );
    }

    // 4. Validasi Categories
    if (!decoded.containsKey('categories') || decoded['categories'] is! List) {
      throw const BackupValidationException('Field "categories" wajib ada dan harus berupa daftar (array)');
    }
    final rawCategories = decoded['categories'] as List;
    final parsedCategories = <Category>[];
    final categoryIds = <String>{};

    for (int i = 0; i < rawCategories.length; i++) {
      final c = rawCategories[i];
      if (c is! Map) {
        throw BackupValidationException('Data kategori pada baris ${i + 1} harus berupa objek');
      }
      final id = c['id']?.toString().trim();
      final name = c['name']?.toString().trim();
      final typeStr = c['type']?.toString().trim().toLowerCase();
      final isArchived = c['isArchived'];

      if (id == null || id.isEmpty) {
        throw BackupValidationException('ID kategori pada baris ${i + 1} tidak boleh kosong');
      }
      if (categoryIds.contains(id)) {
        throw BackupValidationException('ID kategori duplikat ditemukan: "$id"');
      }
      categoryIds.add(id);

      if (name == null || name.isEmpty) {
        throw BackupValidationException('Nama kategori pada ID "$id" tidak boleh kosong');
      }
      if (typeStr != 'income' && typeStr != 'expense') {
        throw BackupValidationException(
          'Tipe kategori "$name" tidak valid: "$typeStr" (harus "income" atau "expense")',
        );
      }
      if (isArchived != null && isArchived is! bool) {
        throw BackupValidationException('Status arsip pada kategori "$name" harus berupa boolean');
      }

      parsedCategories.add(
        Category(
          id: id,
          name: name,
          type: typeStr == 'income' ? CategoryType.income : CategoryType.expense,
          isArchived: isArchived == true,
        ),
      );
    }

    // 5. Validasi Transactions
    if (!decoded.containsKey('transactions') || decoded['transactions'] is! List) {
      throw const BackupValidationException('Field "transactions" wajib ada dan harus berupa daftar (array)');
    }
    final rawTransactions = decoded['transactions'] as List;
    final parsedTransactions = <Transaction>[];
    final transactionIds = <String>{};

    for (int i = 0; i < rawTransactions.length; i++) {
      final t = rawTransactions[i];
      if (t is! Map) {
        throw BackupValidationException('Data transaksi pada baris ${i + 1} harus berupa objek');
      }
      final id = t['id']?.toString().trim();
      final typeStr = t['type']?.toString().trim().toLowerCase();
      final amount = t['amount'];
      final dateRaw = t['date'];
      final walletId = t['walletId']?.toString().trim();
      final targetWalletId = t['targetWalletId']?.toString().trim();
      final categoryId = t['categoryId']?.toString().trim();
      final note = t['note']?.toString();

      if (id == null || id.isEmpty) {
        throw BackupValidationException('ID transaksi pada baris ${i + 1} tidak boleh kosong');
      }
      if (transactionIds.contains(id)) {
        throw BackupValidationException('ID transaksi duplikat ditemukan: "$id"');
      }
      transactionIds.add(id);

      TransactionType txType;
      switch (typeStr) {
        case 'income':
          txType = TransactionType.income;
          break;
        case 'expense':
          txType = TransactionType.expense;
          break;
        case 'transfer':
          txType = TransactionType.transfer;
          break;
        default:
          throw BackupValidationException(
            'Tipe transaksi pada ID "$id" tidak valid: "$typeStr" (harus income, expense, atau transfer)',
          );
      }

      if (amount is! int) {
        throw BackupValidationException(
          'Nominal pada transaksi ID "$id" harus berupa bilangan bulat (integer), bukan pecahan atau teks',
        );
      }
      if (amount <= 0) {
        throw BackupValidationException('Nominal pada transaksi ID "$id" harus lebih besar dari 0');
      }

      DateTime? date;
      if (dateRaw is int) {
        date = DateTime.fromMillisecondsSinceEpoch(dateRaw);
      } else if (dateRaw != null) {
        date = DateTime.tryParse(dateRaw.toString());
      }
      if (date == null) {
        throw BackupValidationException('Format tanggal pada transaksi ID "$id" tidak valid');
      }

      // Validasi relasi walletId
      if (walletId == null || walletId.isEmpty) {
        throw BackupValidationException('Dompet sumber pada transaksi ID "$id" wajib diisi');
      }
      if (!walletIds.contains(walletId)) {
        throw BackupValidationException(
          'Dompet sumber "$walletId" pada transaksi ID "$id" tidak ditemukan dalam daftar dompet berkas ini',
        );
      }

      // Validasi transfer
      if (txType == TransactionType.transfer) {
        if (targetWalletId == null || targetWalletId.isEmpty) {
          throw BackupValidationException('Dompet tujuan pada transaksi transfer ID "$id" wajib diisi');
        }
        if (!walletIds.contains(targetWalletId)) {
          throw BackupValidationException(
            'Dompet tujuan "$targetWalletId" pada transaksi ID "$id" tidak ditemukan dalam daftar dompet berkas ini',
          );
        }
        if (walletId == targetWalletId) {
          throw BackupValidationException(
            'Dompet sumber dan tujuan pada transaksi transfer ID "$id" tidak boleh sama',
          );
        }
      } else {
        // Validasi pemasukan / pengeluaran wajib categoryId
        if (categoryId == null || categoryId.isEmpty) {
          throw BackupValidationException(
            'Kategori pada transaksi ${txType.name} ID "$id" wajib diisi',
          );
        }
        if (!categoryIds.contains(categoryId)) {
          throw BackupValidationException(
            'Kategori "$categoryId" pada transaksi ID "$id" tidak ditemukan dalam daftar kategori berkas ini',
          );
        }
      }

      parsedTransactions.add(
        Transaction(
          id: id,
          type: txType,
          amount: amount,
          date: date,
          walletId: walletId,
          targetWalletId: txType == TransactionType.transfer ? targetWalletId : null,
          categoryId: txType != TransactionType.transfer ? categoryId : null,
          note: (note != null && note.trim().isNotEmpty) ? note : null,
        ),
      );
    }

    return BackupData(
      formatVersion: rawVersion,
      exportedAt: exportedAt,
      wallets: parsedWallets,
      categories: parsedCategories,
      transactions: parsedTransactions,
    );
  }

  /// Menghitung ringkasan data cadangan
  static BackupSummary getSummary(BackupData data) {
    DateTime? earliest;
    DateTime? latest;

    for (final tx in data.transactions) {
      if (earliest == null || tx.date.isBefore(earliest)) {
        earliest = tx.date;
      }
      if (latest == null || tx.date.isAfter(latest)) {
        latest = tx.date;
      }
    }

    return BackupSummary(
      walletCount: data.wallets.length,
      categoryCount: data.categories.length,
      transactionCount: data.transactions.length,
      earliestDate: earliest,
      latestDate: latest,
    );
  }
}
