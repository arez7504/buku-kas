import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/data/finance_repository.dart';
import 'package:catatan_keuangan/logic/finance_state.dart';
import 'package:catatan_keuangan/models/category.dart';
import 'package:catatan_keuangan/screens/category_form_screen.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';
import 'package:catatan_keuangan/theme/category_style.dart';

void main() {
  group('Milestone UI-9 Test Suite', () {
    // -------------------------------------------------------------------------
    // 1. Perhitungan halaman dan partisi ikon
    // -------------------------------------------------------------------------
    test('1. Total ikon dan kalkulasi dinamis jumlah halaman (12 ikon/halaman)', () {
      final totalIcons = CategoryStyleRegistry.icons.length;
      expect(totalIcons, equals(41));

      final calculatedPages = (totalIcons / 12).ceil();
      expect(calculatedPages, equals(4));

      // Verifikasi pembagian:
      // Halaman 1 (indeks 0-11) = 12 ikon
      // Halaman 2 (indeks 12-23) = 12 ikon
      // Halaman 3 (indeks 24-35) = 12 ikon
      // Halaman 4 (indeks 36-40) = 5 ikon (sisanya 7 slot kosong)
      final keys = CategoryStyleRegistry.icons.keys.toList();
      expect(keys[0], equals('makan'));
      expect(keys[11], equals('listrik'));
      expect(keys[12], equals('internet'));
      expect(keys[23], equals('musik'));
      expect(keys[24], equals('hewan'));
      expect(keys[35], equals('kecantikan'));
      expect(keys[36], equals('gadget'));
      expect(keys[40], equals('kategori'));
    });

    // -------------------------------------------------------------------------
    // 2. Kontras warna indikator titik >= 3:1 terhadap #141422
    // -------------------------------------------------------------------------
    test('2. Token indikator titik memenuhi spesifikasi ukuran dan kontras >= 3:1', () {
      expect(AppDimens.categoryPickerDotHeight, equals(6.0));
      expect(AppDimens.categoryPickerDotWidthInactive, equals(6.0));
      expect(AppDimens.categoryPickerDotWidthActive, equals(18.0));
      expect(AppDimens.categoryPickerDotSpacing, equals(6.0));
      expect(AppDimens.categoryPickerGridSpacing, equals(8.0));

      // Background card: #141422 (R=20, G=20, B=34)
      // categoryPickerDotInactive = Color(0x66FFFFFF) (alpha 0.40)
      // Hitung kontras:
      const bgR = 0x14;
      const bgG = 0x14;
      const bgB = 0x22;
      const alpha = 0x66 / 255.0;

      final fgR = (bgR + (255 - bgR) * alpha).round();
      final fgG = (bgG + (255 - bgG) * alpha).round();
      final fgB = (bgB + (255 - bgB) * alpha).round();

      double sRgbToLin(int val) {
        final c = val / 255.0;
        return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055);
      }

      final lumBg = 0.2126 * sRgbToLin(bgR) + 0.7152 * sRgbToLin(bgG) + 0.0722 * sRgbToLin(bgB);
      final lumFg = 0.2126 * sRgbToLin(fgR) + 0.7152 * sRgbToLin(fgG) + 0.0722 * sRgbToLin(fgB);

      final contrastRatio = (lumFg + 0.05) / (lumBg + 0.05);
      expect(contrastRatio, greaterThanOrEqualTo(3.0));
    });

    // -------------------------------------------------------------------------
    // 3. Tampilan awal, 4 titik, tanpa teks angka, dan TalkBack Semantics
    // -------------------------------------------------------------------------
    testWidgets('3. Widget: 4 titik indikator hadir, bentuk kapsul aktif & lingkaran tidak aktif, tanpa teks angka', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Gulir form agar pemilih ikon terlihat di viewport
      await tester.ensureVisible(find.byKey(const Key('category_icon_page_view')));
      await tester.pumpAndSettle();

      // PageView harus ada
      expect(find.byKey(const Key('category_icon_page_view')), findsOneWidget);

      // Tepat ada 4 titik indikator
      for (int i = 0; i < 4; i++) {
        expect(find.byKey(Key('category_picker_dot_$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('category_picker_dot_4')), findsNothing);

      // TIDAK ADA teks angka penomoran halaman (seperti "1/4", "Halaman 1/4")
      expect(find.text('1/4'), findsNothing);
      expect(find.text('Halaman 1/4'), findsNothing);
      expect(find.text('Halaman 1 dari 4'), findsNothing); // Teks visual tidak ada (hanya label Semantics)

      // Cek Semantics label untuk screen reader
      final semanticsHandle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Halaman 1 dari 4')),
        isNotNull,
      );
      semanticsHandle.dispose();

      // Cek bentuk titik aktif (indeks 0: kapsul lebar 18) vs tidak aktif (lebar 6)
      final size0 = tester.getSize(find.byKey(const Key('category_picker_dot_0')));
      final size1 = tester.getSize(find.byKey(const Key('category_picker_dot_1')));
      expect(size0.width, equals(18.0));
      expect(size0.height, equals(6.0));
      expect(size1.width, equals(6.0));
      expect(size1.height, equals(6.0));

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 4. Geser halaman: indikator berpindah dan tinggi halaman identik (halaman 4 tidak melompat)
    // -------------------------------------------------------------------------
    testWidgets('4. Widget: Geser halaman memperbarui titik aktif & tinggi area konsisten antar-halaman', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('category_icon_page_view')));
      await tester.pumpAndSettle();

      final pageViewSizePage1 = tester.getSize(find.byKey(const Key('category_icon_page_view')));

      // Halaman 1 memuat 12 ikon (mis. makan, belanja, listrik)
      expect(find.byKey(const Key('category_icon_makan')), findsOneWidget);
      expect(find.byKey(const Key('category_icon_listrik')), findsOneWidget);

      // Geser ke Halaman 2
      await tester.drag(find.byKey(const Key('category_icon_page_view')), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Titik aktif sekarang adalah titik 1
      final sizeDot0Page2 = tester.getSize(find.byKey(const Key('category_picker_dot_0')));
      final sizeDot1Page2 = tester.getSize(find.byKey(const Key('category_picker_dot_1')));
      expect(sizeDot0Page2.width, equals(6.0));
      expect(sizeDot1Page2.width, equals(18.0));

      // Ikon halaman 2 tampil (mis. internet, musik)
      expect(find.byKey(const Key('category_icon_internet')), findsOneWidget);
      expect(find.byKey(const Key('category_icon_musik')), findsOneWidget);

      // Geser ke Halaman 3
      await tester.drag(find.byKey(const Key('category_icon_page_view')), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Geser ke Halaman 4 (halaman terakhir dengan 5 ikon)
      await tester.drag(find.byKey(const Key('category_icon_page_view')), const Offset(-400, 0));
      await tester.pumpAndSettle();

      final sizeDot3Page4 = tester.getSize(find.byKey(const Key('category_picker_dot_3')));
      expect(sizeDot3Page4.width, equals(18.0));

      // Ikon halaman 4 tampil: gadget (36), kategori (40)
      expect(find.byKey(const Key('category_icon_gadget')), findsOneWidget);
      expect(find.byKey(const Key('category_icon_kategori')), findsOneWidget);

      // Tinggi area PageView di Halaman 4 SAMA PERSIS dengan Halaman 1 (tidak melompat)
      final pageViewSizePage4 = tester.getSize(find.byKey(const Key('category_icon_page_view')));
      expect(pageViewSizePage4.height, equals(pageViewSizePage1.height));

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 5. Pemilihan ikon global: pemilihan di halaman 2 tersimpan dan tidak reset saat geser
    // -------------------------------------------------------------------------
    testWidgets('5. Widget: Seleksi ikon bersifat global antar-halaman dan tersimpan saat simpan', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Isi nama
      await tester.enterText(find.byKey(const Key('category_name_input')), 'Les Musik');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('category_icon_page_view')));
      await tester.pumpAndSettle();

      // Geser ke Halaman 2
      await tester.drag(find.byKey(const Key('category_icon_page_view')), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Pilih ikon 'musik' di Halaman 2 (pastikan terlihat di atas bottomNavigationBar)
      await tester.ensureVisible(find.byKey(const Key('category_icon_musik')));
      await tester.tap(find.byKey(const Key('category_icon_musik')));
      await tester.pumpAndSettle();

      // Geser kembali ke Halaman 1
      await tester.ensureVisible(find.byKey(const Key('category_icon_page_view')));
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key('category_icon_page_view')), const Offset(400, 0));
      await tester.pumpAndSettle();

      // Geser lagi ke Halaman 2: verifikasi ikon 'musik' tetap terpilih
      await tester.drag(find.byKey(const Key('category_icon_page_view')), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Simpan
      await tester.ensureVisible(find.byKey(const Key('category_save_button')));
      await tester.tap(find.byKey(const Key('category_save_button')));
      await tester.pumpAndSettle();

      // Verifikasi di state bahwa ikon tersimpan adalah 'musik'
      final saved = state.categories.firstWhere((c) => c.name == 'Les Musik');
      expect(saved.iconKey, equals('musik'));

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 6. Mode Ubah membuka langsung di halaman tempat ikon berada (Halaman 3 & 4)
    // -------------------------------------------------------------------------
    testWidgets('6. Widget: Layar Ubah dengan ikon di halaman 3 membuka pemilih langsung di halaman 3', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      // Ikon 'rumah' berada di Halaman 3 (indeks 25, indeks halaman 2)
      const existingCategoryPage3 = Category(
        id: 'cat_rumah_edit',
        name: 'Rumah & Properti',
        type: CategoryType.expense,
        iconKey: 'rumah',
        colorKey: 'cyan',
      );
      await state.addCategory(existingCategoryPage3);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(category: existingCategoryPage3),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('category_icon_page_view')));
      await tester.pumpAndSettle();

      // Titik aktif harus langsung di halaman 3 (indeks 2)
      final dot2Size = tester.getSize(find.byKey(const Key('category_picker_dot_2')));
      expect(dot2Size.width, equals(18.0));

      // Ikon 'rumah' langsung terlihat di layar
      expect(find.byKey(const Key('category_icon_rumah')), findsOneWidget);

      await repo.close();
    });

    testWidgets('6b. Widget: Layar Ubah dengan ikon di halaman 4 membuka pemilih langsung di halaman 4', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      // Ikon 'gadget' berada di Halaman 4 (indeks 36, indeks halaman 3)
      const existingCategoryPage4 = Category(
        id: 'cat_gadget_edit',
        name: 'Elektronik & Gadget',
        type: CategoryType.expense,
        iconKey: 'gadget',
        colorKey: 'cyan',
      );
      await state.addCategory(existingCategoryPage4);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(category: existingCategoryPage4),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('category_icon_page_view')));
      await tester.pumpAndSettle();

      // Titik aktif harus langsung di halaman 4 (indeks 3)
      final dot3Size = tester.getSize(find.byKey(const Key('category_picker_dot_3')));
      expect(dot3Size.width, equals(18.0));

      // Ikon 'gadget' langsung terlihat di layar
      expect(find.byKey(const Key('category_icon_gadget')), findsOneWidget);

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 7. Auto-scroll saat mengetik nama pemetaan di mode Tambah
    // -------------------------------------------------------------------------
    testWidgets('7. Widget: Mengetik nama yang memicu pemetaan ikon menggeser pemilih secara dinamis', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: FinanceScope(
          state: state,
          child: const CategoryFormScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Awalnya di halaman 1 (titik 0 aktif)
      final dot0SizeInitial = tester.getSize(find.byKey(const Key('category_picker_dot_0')));
      expect(dot0SizeInitial.width, equals(18.0));

      // Ketik 'kesehatan' -> CategoryStyleRegistry memetakan ke icon 'kesehatan' (indeks 17 di Halaman 2)
      await tester.enterText(find.byKey(const Key('category_name_input')), 'kesehatan');
      await tester.pumpAndSettle();

      // Pemilih otomatis bergeser ke Halaman 2 (titik 1 aktif)
      final dot1SizeAfterType = tester.getSize(find.byKey(const Key('category_picker_dot_1')));
      expect(dot1SizeAfterType.width, equals(18.0));
      expect(find.byKey(const Key('category_icon_kesehatan')), findsOneWidget);

      // Pengguna sekarang memilih ikon 'obat' (juga di halaman 2) secara manual
      await tester.ensureVisible(find.byKey(const Key('category_icon_page_view')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category_icon_obat')));
      await tester.pumpAndSettle();

      // Sekarang pengguna mengubah teks ke 'belanja' (yang memetakan ke Halaman 1)
      await tester.enterText(find.byKey(const Key('category_name_input')), 'belanja');
      await tester.pumpAndSettle();

      // Karena pengguna sudah memilih manual, pemilih TIDAK bergeser dan ikon 'obat' tetap terpilih
      final dot1SizeAfterManual = tester.getSize(find.byKey(const Key('category_picker_dot_1')));
      expect(dot1SizeAfterManual.width, equals(18.0));

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 8. Bebas overflow pada 360x640 dan 411x891 dengan skala huruf 1.0 dan 2.0
    // -------------------------------------------------------------------------
    testWidgets('8. Widget: Bebas overflow pada 360x640 dan 411x891 dengan fontScale 1.0 dan 2.0', (tester) async {
      final repo = FinanceRepository.inMemory();
      final state = FinanceState(repository: repo);
      await state.loadData();

      for (final scale in [1.0, 2.0]) {
        for (final size in [const Size(360, 640), const Size(411, 891)]) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.darkTheme,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: FinanceScope(
                state: state,
                child: const CategoryFormScreen(),
              ),
            ),
          ));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'Overflow pada size $size scale $scale');
        }
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();

      // Sentuhan target ikon >= 48x48 dp
      final tileBox = tester.getRect(find.byKey(const Key('category_icon_makan')));
      expect(tileBox.width, greaterThanOrEqualTo(48.0));
      expect(tileBox.height, greaterThanOrEqualTo(48.0));

      await repo.close();
    });

    // -------------------------------------------------------------------------
    // 9. Deretan titik disembunyikan jika hanya ada 1 halaman
    // -------------------------------------------------------------------------
    testWidgets('9. Widget: Deretan titik disembunyikan jika hanya 1 halaman', (tester) async {
      final pageController = PageController();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: CategoryPageIndicatorDots(
            pageCount: 1,
            currentPage: 0,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Tidak ada titik yang dirender
      expect(find.byKey(const Key('category_picker_dot_0')), findsNothing);

      pageController.dispose();
    });
  });
}
