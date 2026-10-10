import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/main.dart';

void main() {
  testWidgets('HistoryScreen smoke test: Menampilkan saldo, riwayat, dan FAB', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Memastikan elemen utama muncul
    expect(find.text('Buku Kas'), findsOneWidget);
    expect(find.text('AKUN & DOMPET'), findsOneWidget);
    expect(find.text('Transaksi Terkini'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('FAB membuka layar Tambah Transaksi', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap tombol FAB Tambah Transaksi
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verifikasi layar form terbuka
    expect(find.text('Tambah Transaksi'), findsOneWidget);
    expect(find.text('Simpan Transaksi'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
  });
}
