import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/main.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/models/wallet.dart';
import 'package:catatan_keuangan/screens/category_management_screen.dart';
import 'package:catatan_keuangan/screens/settings_screen.dart';
import 'package:catatan_keuangan/screens/wallet_management_screen.dart';

void main() {
  group('Milestone 5 Widget Tests: Kelola Dompet & Kategori', () {
    late FinanceState state;

    setUp(() {
      state = FinanceState(
        initialWallets: [
          const Wallet(id: 'bca', name: 'BCA', initialBalance: 0),
          const Wallet(id: 'tunai', name: 'Tunai', initialBalance: 200000),
        ],
        initialCategories: [
          const Category(id: 'exp_makan', name: 'Makanan', type: CategoryType.expense),
          const Category(id: 'inc_gaji', name: 'Gaji', type: CategoryType.income),
        ],
        initialTransactions: [
          Transaction(
            id: 'tx_old_1',
            type: TransactionType.expense,
            amount: 50000,
            date: DateTime(2026, 10, 1),
            walletId: 'tunai',
            categoryId: 'exp_makan',
            note: 'Nasi padang siang',
          ),
        ],
      );
    });

    testWidgets('Header Buku Kas memiliki ikon gerigi yang membuka layar Pengaturan', (tester) async {
      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Cari tombol gerigi di header
      final settingsBtn = find.byKey(const Key('settings_button'));
      expect(settingsBtn, findsOneWidget);

      // Tap ikon gerigi
      await tester.tap(settingsBtn);
      await tester.pumpAndSettle();

      // Verifikasi layar Pengaturan terbuka dan memiliki dua menu
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Kelola Dompet'), findsOneWidget);
      expect(find.text('Kelola Kategori'), findsOneWidget);
    });

    testWidgets('(b) Ubah saldo awal BCA jadi 1.000.000: saldo BCA di Buku Kas berubah', (tester) async {
      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Awalnya BCA bersaldo 0
      expect(find.text('BCA'), findsWidgets);
      expect(find.text('Rp 0'), findsOneWidget);

      // Buka Pengaturan -> Kelola Dompet
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kelola Dompet'));
      await tester.pumpAndSettle();
      expect(find.byType(WalletManagementScreen), findsOneWidget);

      // Buka menu popup dompet BCA
      await tester.tap(find.byKey(const Key('wallet_menu_bca')));
      await tester.pumpAndSettle();

      // Pilih Ubah
      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();

      // Ubah saldo awal menjadi 1000000
      final balanceInput = find.byKey(const Key('wallet_balance_edit_input'));
      await tester.enterText(balanceInput, '1000000');
      await tester.pumpAndSettle();

      // Simpan perubahan
      await tester.tap(find.byKey(const Key('wallet_update_button')));
      await tester.pumpAndSettle();

      // Kembali ke Pengaturan lalu kembali ke Buku Kas
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verifikasi: Saldo BCA di baris dompet Buku Kas sekarang menjadi Rp 1.000.000
      expect(find.text('Rp 1.000.000'), findsOneWidget);
    });

    testWidgets('(e) Validasi nama dompet kosong dan kembar ditolak di dialog tambah dompet', (tester) async {
      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Masuk ke Kelola Dompet
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kelola Dompet'));
      await tester.pumpAndSettle();

      // Tap tombol tambah dompet
      await tester.tap(find.byKey(const Key('add_wallet_button')));
      await tester.pumpAndSettle();

      // 1. Coba simpan dengan nama kosong
      await tester.tap(find.byKey(const Key('wallet_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama dompet tidak boleh kosong'), findsOneWidget);

      // 2. Coba simpan dengan nama kembar (bca - huruf kecil)
      await tester.enterText(find.byKey(const Key('wallet_name_input')), 'bca');
      await tester.tap(find.byKey(const Key('wallet_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama dompet sudah digunakan'), findsOneWidget);

      // 3. Nama valid
      await tester.enterText(find.byKey(const Key('wallet_name_input')), 'E-Wallet');
      await tester.enterText(find.byKey(const Key('wallet_balance_input')), '50000');
      await tester.tap(find.byKey(const Key('wallet_save_button')));
      await tester.pumpAndSettle();

      // Dialog tertutup dan dompet baru muncul
      expect(find.text('E-Wallet'), findsOneWidget);
    });

    testWidgets('(c) & (d) Dompet dengan transaksi tidak bisa dihapus permanen, tapi bisa diarsipkan; hilang dari form Catat tapi riwayat lamanya tetap tampil', (tester) async {
      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Verifikasi awal: di riwayat Buku Kas ada transaksi "Nasi padang siang" dari Tunai
      expect(find.text('Nasi padang siang'), findsOneWidget);
      expect(find.text('Tunai'), findsWidgets);

      // Buka Pengaturan -> Kelola Dompet
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kelola Dompet'));
      await tester.pumpAndSettle();

      // Coba hapus dompet Tunai (yang sudah punya transaksi tx_old_1)
      await tester.tap(find.byKey(const Key('wallet_menu_tunai')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // (c) Harus muncul dialog penolakan dan tawarkan arsip
      expect(find.text('Tidak Dapat Dihapus'), findsOneWidget);
      expect(find.byKey(const Key('offer_archive_wallet_button')), findsOneWidget);
      expect(find.byKey(const Key('confirm_delete_wallet_button')), findsNothing);

      // Tap Arsipkan pada penawaran arsip
      await tester.tap(find.byKey(const Key('offer_archive_wallet_button')));
      await tester.pumpAndSettle();

      // Verifikasi dompet Tunai berstatus diarsipkan
      expect(find.text('Diarsipkan'), findsOneWidget);

      // Kembali ke Buku Kas
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // (c) Riwayat lama yang memakai Tunai tetap tampil normal
      expect(find.text('Nasi padang siang'), findsOneWidget);

      // Buka form Catat Transaksi via FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // (d) Dompet Tunai yang diarsipkan HILANG dari pilihan dompet form Catat!
      // Hanya dompet BCA yang aktif yang boleh muncul di form Catat
      expect(find.text('BCA'), findsWidgets);
      // Di form Catat, tidak boleh ada opsi Tunai
      expect(find.text('Tunai'), findsNothing);
    });

    testWidgets('Kelola Kategori: tambah, tolak nama kembar/kosong, arsipkan, hilang dari form Catat', (tester) async {
      await tester.pumpWidget(MyApp(initialState: state));
      await tester.pumpAndSettle();

      // Buka Pengaturan -> Kelola Kategori
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kelola Kategori'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryManagementScreen), findsOneWidget);

      // Tab Pengeluaran default aktif, Makanan muncul
      expect(find.text('Makanan'), findsOneWidget);

      // Tap Tambah Kategori
      await tester.tap(find.byKey(const Key('add_category_button')));
      await tester.pumpAndSettle();

      // (e) Simpan nama kosong -> ditolak
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama kategori tidak boleh kosong'), findsOneWidget);

      // (e) Simpan nama kembar di kelompok yang sama -> ditolak
      await tester.enterText(find.byKey(const Key('category_name_input')), 'makanan');
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama kategori sudah digunakan dalam kelompok ini'), findsOneWidget);

      // Batal dialog tambah
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Coba hapus kategori Makanan yang sudah dipakai transaksi -> tawarkan arsip
      await tester.tap(find.byKey(const Key('category_menu_exp_makan')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(find.text('Tidak Dapat Dihapus'), findsOneWidget);

      // Arsipkan Makanan
      await tester.tap(find.byKey(const Key('offer_archive_category_button')));
      await tester.pumpAndSettle();

      // Kembali ke Buku Kas lalu buka Form Catat
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Kategori Makanan yang diarsipkan TIDAK muncul di form Catat
      expect(find.text('Makanan'), findsNothing);
    });
  });
}
