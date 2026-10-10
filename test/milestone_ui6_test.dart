import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/screens/category_management_screen.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/theme/category_icon_mapping.dart';

void main() {
  group('Milestone UI-6 Tests: Layar Kelola Kategori Bertema Gelap', () {
    late FinanceRepository repository;
    late FinanceState state;

    setUp(() async {
      repository = FinanceRepository.inMemory();
      state = FinanceState(repository: repository);
      await state.loadData();
    });

    tearDown(() async {
      await repository.close();
    });

    Widget createCategoryManagementScreen() {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryManagementScreen(),
        ),
      );
    }

    testWidgets('Responsivitas Layar Kelola Kategori 360x640 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CategoryManagementScreen), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);
    });

    testWidgets('Responsivitas Layar Kelola Kategori 411x891 dp bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CategoryManagementScreen), findsOneWidget);
    });

    testWidgets('Kelola Kategori: Tab switching Pengeluaran dan Pemasukan berfungsi mulus', (tester) async {
      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      // Tab default Pengeluaran aktif -> kategori Makanan muncul, Gaji tidak muncul di tab ini
      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Gaji'), findsNothing);

      // Pindah ke tab Pemasukan
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Sekarang Gaji muncul, Makanan tidak muncul di tab pemasukan
      expect(find.text('Gaji'), findsOneWidget);
      expect(find.text('Makanan'), findsNothing);

      // Kembali ke tab Pengeluaran
      await tester.tap(find.text('Pengeluaran'));
      await tester.pumpAndSettle();

      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Gaji'), findsNothing);
    });

    testWidgets('Kelola Kategori: Nama kategori panjang (50+ karakter) satu baris dengan ellipsis bebas overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const longName = 'Belanja Kebutuhan Pokok Bulanan Supermarket Rumah Tangga Terbesar';
      await state.updateCategory(const Category(
        id: 'exp_makanan',
        name: longName,
        type: CategoryType.expense,
      ));

      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(longName), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text(longName));
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('Kelola Kategori: Header memiliki judul, tombol kembali, dan tombol tambah (+) melingkar bertint', (tester) async {
      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      expect(find.text('Kelola Kategori'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byKey(const Key('add_category_button')), findsOneWidget);
    });

    testWidgets('Kelola Kategori: Pemetaan ikon dan warna kategori menggunakan AppCategoryIcons', (tester) async {
      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      // Verifikasi bahwa ikon yang dipetakan untuk Makanan (restaurant) muncul
      final makananStyle = AppCategoryIcons.getStyle('Makanan');
      expect(makananStyle.icon, Icons.restaurant);
      expect(makananStyle.backgroundColor, AppColors.tintPurpleBg);

      // Verifikasi pemetaan kategori kustom buatan pengguna
      final customStyle = AppCategoryIcons.getStyle('Hobi Menembak');
      expect(customStyle.icon, Icons.label_outline);
      expect(customStyle.backgroundColor, AppColors.tintNeutralBg);
    });

    testWidgets('Kelola Kategori: Tambah kategori baru dengan tipe dan validasi nama kembar/kosong bertema gelap', (tester) async {
      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      // Pindah ke tab Pemasukan (hanya ada Gaji & Lainnya)
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Buka dialog tambah
      await tester.tap(find.byKey(const Key('add_category_button')));
      await tester.pumpAndSettle();

      // Dialog tambah terbuka
      expect(find.text('Tambah Kategori'), findsOneWidget);

      // Simpan kosong -> ditolak
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama kategori tidak boleh kosong'), findsOneWidget);

      // Simpan kembar -> ditolak (Gaji)
      await tester.enterText(find.byKey(const Key('category_name_input')), 'Gaji');
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();
      expect(find.text('Nama kategori sudah digunakan dalam kelompok ini'), findsOneWidget);

      // Masukkan nama baru 'Investasi'
      await tester.enterText(find.byKey(const Key('category_name_input')), 'Investasi');
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();

      // Dialog tertutup dan 'Investasi' muncul di daftar pemasukan
      expect(find.text('Tambah Kategori'), findsNothing);
      expect(find.text('Investasi'), findsOneWidget);
    });

    testWidgets('Kelola Kategori: Seksi DIARSIPKAN menampilkan kategori redup dan pemulihan via Buka Arsip', (tester) async {
      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      // Pindah ke tab Pemasukan (Gaji & Lainnya)
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Awalnya seksi DIARSIPKAN belum ada
      expect(find.text('DIARSIPKAN'), findsNothing);

      // Arsipkan Gaji lewat popup menu (id: inc_gaji)
      await tester.tap(find.byKey(const Key('category_menu_inc_gaji')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();

      // Sekarang seksi DIARSIPKAN muncul
      expect(find.text('DIARSIPKAN'), findsOneWidget);
      expect(find.text('Diarsipkan'), findsOneWidget);

      // Pulihkan Gaji via Buka Arsip
      await tester.tap(find.byKey(const Key('category_menu_inc_gaji')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buka Arsip'));
      await tester.pumpAndSettle();

      // Gaji kembali aktif dan seksi DIARSIPKAN hilang
      expect(find.text('DIARSIPKAN'), findsNothing);
      expect(find.text('Gaji'), findsOneWidget);
    });

    testWidgets('Kelola Kategori: Dialog tidak dapat dihapus menawarkan arsip jika ada transaksi', (tester) async {
      // Tambah transaksi yang menggunakan exp_makanan
      await state.addTransaction(Transaction(
        id: 'tx_used_makanan',
        type: TransactionType.expense,
        amount: 35000,
        date: DateTime.now(),
        walletId: 'bca',
        categoryId: 'exp_makanan',
        note: 'Makan siang',
      ));

      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      // Makanan sudah dipakai transaksi -> coba hapus
      await tester.tap(find.byKey(const Key('category_menu_exp_makanan')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Tidak Dapat Dihapus'), findsOneWidget);
      expect(find.byKey(const Key('offer_archive_category_button')), findsOneWidget);

      // Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Tidak Dapat Dihapus'), findsNothing);
    });

    testWidgets('Kelola Kategori: Dialog konfirmasi hapus permanen jika kategori belum ada transaksi', (tester) async {
      // Pindah ke tab pemasukan lalu tambah kategori pemasukan baru tanpa transaksi
      await state.addCategory(Category(
        id: 'c_baru_inc',
        name: 'Hadiah',
        type: CategoryType.income,
      ));

      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      // Buka tab pemasukan
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      expect(find.text('Hadiah'), findsOneWidget);

      // Buka menu dan pilih Hapus
      await tester.tap(find.byKey(const Key('category_menu_c_baru_inc')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Dialog konfirmasi hapus muncul
      expect(find.text('Hapus Kategori?'), findsOneWidget);
      expect(find.byKey(const Key('confirm_delete_category_button')), findsOneWidget);

      // Konfirmasi hapus
      await tester.tap(find.byKey(const Key('confirm_delete_category_button')));
      await tester.pumpAndSettle();

      // Hadiah terhapus permanen
      expect(find.text('Hadiah'), findsNothing);
    });

    testWidgets('Kelola Kategori: Tipografi minimal 12 sp dan tema gelap konsisten', (tester) async {
      await tester.pumpWidget(createCategoryManagementScreen());
      await tester.pumpAndSettle();

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final tw in textWidgets) {
        if (tw.style?.fontSize != null) {
          expect(
            tw.style!.fontSize!,
            greaterThanOrEqualTo(12.0),
            reason: 'Teks "${tw.data}" memiliki ukuran < 12 sp (${tw.style!.fontSize})',
          );
        }
      }
    });
  });
}
