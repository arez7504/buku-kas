import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/models/transaction.dart';
import 'package:catatan_keuangan/widgets/catat_amount_display.dart';

void main() {
  group('CatatAmountDisplay Cursor Blinking Tests', () {
    testWidgets('Garis kursor berkedip bergantian terlihat dan hilang (~530 ms per fase)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CatatAmountDisplay(
              type: TransactionType.expense,
              formattedAmount: '0',
              dateText: 'Hari ini, 6 Okt',
              onDateTap: () {},
              enableBlink: true,
            ),
          ),
        ),
      );

      final fadeFinder = find.byKey(const Key('catat_cursor_fade'));
      expect(fadeFinder, findsOneWidget);

      // Fase 0 (awal): Garis kursor terlihat penuh (opacity 1.0)
      FadeTransition fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, 1.0);

      // Tengah fase 1 (~265 ms): Transisi halus opacity sedang berkurang
      await tester.pump(const Duration(milliseconds: 265));
      fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, lessThan(1.0));
      expect(fade.opacity.value, greaterThan(0.0));

      // Akhir fase 1 (~530 ms): Garis kursor hilang (opacity 0.0)
      await tester.pump(const Duration(milliseconds: 265));
      fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, closeTo(0.0, 0.01));

      // Akhir fase 2 (~1060 ms): Garis kursor kembali terlihat penuh (opacity 1.0)
      await tester.pump(const Duration(milliseconds: 530));
      fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, closeTo(1.0, 0.01));
    });

    testWidgets('Tombol keypad ditekan: garis langsung terlihat penuh dan siklus kedip dimulai ulang', (tester) async {
      int keypadEpoch = 0;
      String currentAmount = '0';
      late StateSetter setStateCallback;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateCallback = setState;
                return CatatAmountDisplay(
                  type: TransactionType.expense,
                  formattedAmount: currentAmount,
                  dateText: 'Hari ini, 6 Okt',
                  onDateTap: () {},
                  enableBlink: true,
                  keypadTapEpoch: keypadEpoch,
                );
              },
            ),
          ),
        ),
      );

      final fadeFinder = find.byKey(const Key('catat_cursor_fade'));

      // Majukan waktu ke ~530 ms sehingga kursor memudar ke 0.0
      await tester.pump(const Duration(milliseconds: 530));
      var fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, closeTo(0.0, 0.01));

      // Simulasikan penekanan tombol keypad
      setStateCallback(() {
        keypadEpoch++;
        currentAmount = '5';
      });
      await tester.pump(); // Rebuild widget

      // Kursor harus langsung terlihat penuh seketika (opacity 1.0)
      fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, 1.0);

      // Siklus dimulai ulang: setelah 265 ms, opacity kembali bertransisi turun
      await tester.pump(const Duration(milliseconds: 265));
      fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, lessThan(1.0));
      expect(fade.opacity.value, greaterThan(0.0));
    });

    testWidgets('Hormati pengaturan kurangi animasi: kursor diam dan selalu terlihat penuh (opacity 1.0)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: CatatAmountDisplay(
                type: TransactionType.expense,
                formattedAmount: '0',
                dateText: 'Hari ini, 6 Okt',
                onDateTap: () {},
              ),
            ),
          ),
        ),
      );

      final fadeFinder = find.byKey(const Key('catat_cursor_fade'));
      var fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, 1.0);

      // Majukan waktu 530 ms dan 1060 ms: kursor tetap diam pada opacity 1.0
      await tester.pump(const Duration(milliseconds: 530));
      fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, 1.0);

      await tester.pump(const Duration(milliseconds: 530));
      fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, 1.0);
    });

    testWidgets('Animasi dihentikan dan dibersihkan (dispose) saat layar ditutup', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CatatAmountDisplay(
              type: TransactionType.expense,
              formattedAmount: '0',
              dateText: 'Hari ini, 6 Okt',
              onDateTap: () {},
              enableBlink: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Unmount / tutup layar
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      expect(find.byKey(const Key('catat_cursor_fade')), findsNothing);
    });
  });
}
