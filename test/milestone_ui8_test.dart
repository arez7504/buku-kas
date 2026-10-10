import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/backup_service.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/wallet_form_screen.dart';
import 'package:catatan_keuangan/theme/category_style.dart';
import 'package:catatan_keuangan/theme/wallet_style.dart';

void main() {
  group('Milestone UI-8: Registry & Fungsi Resolusi Gaya Dompet', () {
    test('Registry memuat tepat 3 ikon Material Icons dan memakai ulang 12 warna dari UI-7', () {
      expect(WalletStyleRegistry.icons.length, equals(3));
      expect(WalletStyleRegistry.icons['uang'], equals(Icons.payments));
      expect(WalletStyleRegistry.icons['dompet'], equals(Icons.account_balance_wallet));
      expect(WalletStyleRegistry.icons['bank'], equals(Icons.account_balance));

      expect(WalletStyleRegistry.colors.length, equals(12));
      // Memastikan identik dan referensi sama dengan CategoryStyleRegistry.colors
      expect(identical(WalletStyleRegistry.colors, CategoryStyleRegistry.colors), isTrue);
    });

    test('resolveWalletStyle: mengembalikan pilihan pengguna jika iconKey dan colorKey valid', () {
      final style = WalletStyleRegistry.resolveWalletStyle(
        walletName: 'Tabungan Darurat',
        iconKey: 'bank',
        colorKey: 'emerald',
      );

      expect(style.icon, equals(Icons.account_balance));
      expect(style.borderColor, equals(WalletStyleRegistry.colors['emerald']!.borderTint));
      expect(style.iconColor, equals(WalletStyleRegistry.colors['emerald']!.iconColor));
    });

    test('resolveWalletStyle: fallback ke pemetaan lama jika iconKey atau colorKey null / tidak dikenal', () {
      // 1. Kunci null: fallback ke nama dompet "BCA" -> Bank
      final fallbackBca = WalletStyleRegistry.resolveWalletStyle(
        walletName: 'BCA',
        iconKey: null,
        colorKey: null,
      );
      expect(fallbackBca.icon, equals(Icons.account_balance));

      // 2. Kunci tidak dikenal: fallback tanpa error
      final fallbackUnknown = WalletStyleRegistry.resolveWalletStyle(
        walletName: 'Tunai',
        iconKey: 'alien_icon',
        colorKey: 'neon_unknown',
      );
      expect(fallbackUnknown.icon, equals(Icons.payments));
    });
  });

  group('Milestone UI-8: Backup & Restore formatVersion 3', () {
    test('Ekspor ke JSON memuat formatVersion 3 serta iconKey dan colorKey dompet', () {
      final wallets = [
        const Wallet(
          id: 'w1',
          name: 'Dompet Utama',
          initialBalance: 500000,
          iconKey: 'dompet',
          colorKey: 'violet',
        ),
      ];

      final jsonString = BackupService.exportToJson(
        wallets: wallets,
        categories: [],
        transactions: [],
      );

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['formatVersion'], equals(3));
      final exportedWallets = decoded['wallets'] as List;
      expect(exportedWallets.first['iconKey'], equals('dompet'));
      expect(exportedWallets.first['colorKey'], equals('violet'));
    });

    test('Impor formatVersion 1 dan 2 tetap berhasil dengan iconKey dan colorKey bernilai null', () {
      // Versi 1
      final v1Json = jsonEncode({
        'formatVersion': 1,
        'exportedAt': '2026-10-10T12:00:00.000',
        'wallets': [
          {'id': 'w_v1', 'name': 'Tunai V1', 'initialBalance': 100000},
        ],
        'categories': [],
        'transactions': [],
      });

      final dataV1 = BackupService.parseAndValidate(v1Json);
      expect(dataV1.wallets.first.iconKey, isNull);
      expect(dataV1.wallets.first.colorKey, isNull);

      // Versi 2
      final v2Json = jsonEncode({
        'formatVersion': 2,
        'exportedAt': '2026-10-10T12:00:00.000',
        'wallets': [
          {'id': 'w_v2', 'name': 'BCA V2', 'initialBalance': 200000, 'isArchived': false},
        ],
        'categories': [],
        'transactions': [],
      });

      final dataV2 = BackupService.parseAndValidate(v2Json);
      expect(dataV2.wallets.first.iconKey, isNull);
      expect(dataV2.wallets.first.colorKey, isNull);
    });

    test('Kunci iconKey/colorKey dompet asing di-sanitize ke null tanpa menolak file', () {
      final jsonWithUnknownKeys = jsonEncode({
        'formatVersion': 3,
        'exportedAt': '2026-10-10T12:00:00.000',
        'wallets': [
          {
            'id': 'w_test',
            'name': 'Gopay',
            'initialBalance': 50000,
            'isArchived': false,
            'iconKey': 'unknown_icon_key',
            'colorKey': 'unknown_color_key',
          },
        ],
        'categories': [],
        'transactions': [],
      });

      final data = BackupService.parseAndValidate(jsonWithUnknownKeys);
      expect(data.wallets.first.iconKey, isNull);
      expect(data.wallets.first.colorKey, isNull);
    });

    test('Format versi di luar 1, 2, dan 3 ditolak', () {
      final invalidJson = jsonEncode({
        'formatVersion': 4,
        'exportedAt': '2026-10-10T12:00:00.000',
        'wallets': [],
        'categories': [],
        'transactions': [],
      });

      expect(
        () => BackupService.parseAndValidate(invalidJson),
        throwsA(isA<BackupValidationException>()),
      );
    });
  });

  group('Milestone UI-8: Widget Test WalletFormScreen', () {
    testWidgets('Tambah Dompet: Tampilan awal, counter 0/30, pilihan 3 ikon, 12 warna, dan pratinjau live', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tambah Dompet'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('0/30'), findsOneWidget);
      expect(find.byKey(const Key('wallet_name_input')), findsOneWidget);
      expect(find.byKey(const Key('wallet_balance_input')), findsOneWidget);
      expect(find.byKey(const Key('wallet_save_button')), findsOneWidget);

      // Verifikasi 3 ikon ada
      expect(find.byKey(const Key('wallet_icon_uang')), findsOneWidget);
      expect(find.byKey(const Key('wallet_icon_dompet')), findsOneWidget);
      expect(find.byKey(const Key('wallet_icon_bank')), findsOneWidget);

      // Verifikasi 12 warna ada
      for (final colorKey in WalletStyleRegistry.colors.keys) {
        expect(find.byKey(Key('wallet_color_$colorKey')), findsOneWidget);
      }

      // Ketik nama dan saldo, pastikan pratinjau dan counter berubah live
      await tester.enterText(find.byKey(const Key('wallet_name_input')), 'Bank Jago');
      await tester.enterText(find.byKey(const Key('wallet_balance_input')), '250000');
      await tester.pumpAndSettle();

      expect(find.text('9/30'), findsOneWidget);
      expect(find.text('Saldo: Rp 250.000'), findsOneWidget);
    });

    testWidgets('Validasi Nama Dompet: kosong, > 30 karakter, dan kembar ditolak dengan error yang benar', (tester) async {
      String? savedName;
      int? savedBalance;

      await tester.pumpWidget(
        MaterialApp(
          home: WalletFormScreen(
            onValidateName: (name) {
              if (name.toLowerCase() == 'bca') {
                return 'Nama dompet sudah digunakan';
              }
              return null;
            },
            onSave: (name, balance, iconKey, colorKey) async {
              savedName = name;
              savedBalance = balance;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Simpan nama kosong
      await tester.tap(find.byKey(const Key('wallet_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama dompet tidak boleh kosong'), findsOneWidget);
      expect(savedName, isNull);

      // 2. Simpan nama > 30 karakter (31 karakter)
      const longName = 'Nama Dompet Sangat Panjang Sekali Lebih Dari Tiga Puluh Karakter';
      await tester.enterText(find.byKey(const Key('wallet_name_input')), longName);
      await tester.pumpAndSettle();
      expect(find.text('${longName.length}/30'), findsOneWidget);

      await tester.tap(find.byKey(const Key('wallet_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama dompet maksimal 30 karakter'), findsOneWidget);
      expect(savedName, isNull);

      // 3. Simpan nama kembar (bca)
      await tester.enterText(find.byKey(const Key('wallet_name_input')), 'bca');
      await tester.tap(find.byKey(const Key('wallet_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama dompet sudah digunakan'), findsOneWidget);
      expect(savedName, isNull);

      // 4. Nama valid, simpan berhasil
      await tester.enterText(find.byKey(const Key('wallet_name_input')), 'SeaBank');
      await tester.enterText(find.byKey(const Key('wallet_balance_input')), '50000');
      await tester.tap(find.byKey(const Key('wallet_icon_bank')));
      await tester.ensureVisible(find.byKey(const Key('wallet_color_cyan')));
      await tester.tap(find.byKey(const Key('wallet_color_cyan')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('wallet_save_button')));
      await tester.pumpAndSettle();

      expect(savedName, equals('SeaBank'));
      expect(savedBalance, equals(50000));
    });

    testWidgets('Ubah Dompet: Form terisi data lama dan kunci input sesuai backward compatibility', (tester) async {
      const existingWallet = Wallet(
        id: 'w_mandiri',
        name: 'Mandiri Prioritas',
        initialBalance: 750000,
        iconKey: 'bank',
        colorKey: 'cyan',
      );

      String? updatedName;
      int? updatedBalance;
      String? updatedIcon;
      String? updatedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: WalletFormScreen(
            wallet: existingWallet,
            onSave: (name, balance, iconKey, colorKey) async {
              updatedName = name;
              updatedBalance = balance;
              updatedIcon = iconKey;
              updatedColor = colorKey;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ubah Dompet'), findsOneWidget);
      expect(find.byKey(const Key('wallet_name_edit_input')), findsOneWidget);
      expect(find.byKey(const Key('wallet_balance_edit_input')), findsOneWidget);
      expect(find.byKey(const Key('wallet_update_button')), findsOneWidget);

      expect(find.text('Mandiri Prioritas'), findsWidgets);
      expect(find.text('750000'), findsOneWidget);

      // Ganti icon ke "uang" dan warna ke "emerald"
      await tester.tap(find.byKey(const Key('wallet_icon_uang')));
      await tester.ensureVisible(find.byKey(const Key('wallet_color_emerald')));
      await tester.tap(find.byKey(const Key('wallet_color_emerald')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('wallet_update_button')));
      await tester.pumpAndSettle();

      expect(updatedName, equals('Mandiri Prioritas'));
      expect(updatedBalance, equals(750000));
      expect(updatedIcon, equals('uang'));
      expect(updatedColor, equals('emerald'));
    });

    testWidgets('Responsif pada resolusi 360x640 dan 411x891 dp tanpa overflow', (tester) async {
      // 360x640 dp
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WalletFormScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 411x891 dp
      tester.view.physicalSize = const Size(411, 891);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
