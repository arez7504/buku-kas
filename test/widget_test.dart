import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/main.dart';

void main() {
  testWidgets('MainNavigationScreen smoke test: Menampilkan saldo, riwayat, dan bilah navigasi', (WidgetTester tester) async {
    // Alasan pembaruan Milestone NAV-1: Tombol FAB di HistoryScreen telah digantikan
    // oleh bilah navigasi bawah dengan tombol aksi tengah 'nav_catat'.
    await tester.pumpWidget(const MyApp());

    // Alasan pembaruan Milestone NAV-3: Bagian transaksi di Beranda diubah menjadi
    // 'Transaksi Terbaru' dengan tautan 'Lihat semua' (Key('beranda_lihat_semua')).
    expect(find.text('Buku Kas'), findsOneWidget);
    expect(find.text('AKUN & DOMPET'), findsOneWidget);
    expect(find.text('Transaksi Terbaru'), findsOneWidget);
    expect(find.byKey(const Key('beranda_lihat_semua')), findsOneWidget);
    expect(find.byKey(const Key('nav_catat')), findsOneWidget);
  });

  testWidgets('Tombol Catat di bilah navigasi membuka layar Tambah Transaksi', (WidgetTester tester) async {
    // Alasan pembaruan Milestone NAV-1: Pembukaan form Tambah Transaksi dilakukan melalui
    // tombol tengah bilah navigasi bawah (Key('nav_catat')).
    await tester.pumpWidget(const MyApp());

    // Tap tombol Catat di bilah navigasi
    await tester.tap(find.byKey(const Key('nav_catat')));
    await tester.pumpAndSettle();

    // Verifikasi layar form terbuka
    expect(find.text('Tambah Transaksi'), findsOneWidget);
    expect(find.text('Simpan Transaksi'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
  });
}
