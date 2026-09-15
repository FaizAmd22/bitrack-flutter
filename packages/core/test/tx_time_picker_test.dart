// Input jam bergaya iOS (roda gulir) menggantikan jam putar Material.
import 'package:bitrack_core/base/widgets/tx_inputs.dart';
import 'package:bitrack_core/base/widgets/tx_time_picker.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

/// Buka field, konfirmasi tanggal di pemilih tanggal (tidak diubah), lalu
/// sampai di pemilih jam.
Future<void> _openTimeSheet(WidgetTester tester) async {
  await tester.tap(find.byType(TextField));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _pumpField(
  WidgetTester tester, {
  required DateTime value,
  DateTime? firstDate,
  DateTime? lastDate,
  required List<DateTime?> changes,
}) async {
  await tester.pumpWidget(
    _app(
      TxInputDateTime(
        label: 'Start Date',
        value: value,
        firstDate: firstDate,
        lastDate: lastDate,
        onChanged: changes.add,
      ),
    ),
  );
}

/// Warna setiap angka yang sedang tampil di kolom jam.
List<Color> _hourColors(WidgetTester tester) {
  final hourColumn = find
      .descendant(
        of: find.byType(CupertinoDatePicker),
        matching: find.byType(CupertinoPicker),
      )
      .first;
  return [
    for (final e
        in find
            .descendant(of: hourColumn, matching: find.byType(Text))
            .evaluate())
      DefaultTextStyle.of(e).style.merge((e.widget as Text).style).color!,
  ];
}

void main() {
  group('clampDateTime', () {
    final min = DateTime(2026, 9, 15, 8, 0);
    final max = DateTime(2026, 9, 15, 14, 20);

    test('di dalam rentang: apa adanya', () {
      final v = DateTime(2026, 9, 15, 10, 30);
      expect(clampDateTime(v, min, max), v);
    });

    test('di luar rentang: dijepit ke batasnya', () {
      expect(clampDateTime(DateTime(2026, 9, 15, 7), min, max), min);
      expect(clampDateTime(DateTime(2026, 9, 15, 23), min, max), max);
    });

    test('tanpa batas: apa adanya', () {
      final v = DateTime(2026, 9, 15, 23, 59);
      expect(clampDateTime(v, null, null), v);
    });
  });

  testWidgets('jam dipilih dengan roda gulir, bukan jam putar', (tester) async {
    final changes = <DateTime?>[];
    await _pumpField(
      tester,
      value: DateTime(2026, 9, 10, 10, 30),
      changes: changes,
    );

    await _openTimeSheet(tester);

    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    expect(find.byType(TimePickerDialog), findsNothing);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(changes, [DateTime(2026, 9, 10, 10, 30)]);
  });

  testWidgets('menggulir roda jam mengubah jam, menit tetap', (tester) async {
    final changes = <DateTime?>[];
    await _pumpField(
      tester,
      value: DateTime(2026, 9, 10, 10, 30),
      changes: changes,
    );
    await _openTimeSheet(tester);

    // Kolom pertama = jam. Digulir ke atas = jam lebih besar.
    await tester.drag(
      find.byType(CupertinoPicker).first,
      const Offset(0, -64),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(changes, hasLength(1));
    final picked = changes.single!;
    expect(picked.hour, greaterThan(10));
    expect(picked.minute, 30);
    expect(
      DateTime(picked.year, picked.month, picked.day),
      DateTime(2026, 9, 10),
    );
  });

  testWidgets('batas maksimum berlaku sampai ke menit', (tester) async {
    // Seperti Start Date di filter Periodic Track: lastDate = sekarang.
    final max = DateTime(2026, 9, 15, 14, 20);
    final changes = <DateTime?>[];
    await _pumpField(
      tester,
      value: DateTime(2026, 9, 15, 9, 0),
      lastDate: max,
      changes: changes,
    );
    await _openTimeSheet(tester);

    // Gulir jam jauh melewati batas; picker harus kembali ke dalam batas.
    await tester.drag(
      find.byType(CupertinoPicker).first,
      const Offset(0, -320),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(changes, hasLength(1));
    expect(changes.single!.isAfter(max), isFalse);
  });

  testWidgets('waktu awal di luar batas langsung dijepit tanpa digulir', (
    tester,
  ) async {
    final max = DateTime(2026, 9, 15, 14, 20);
    DateTime? result;

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showTxTimePicker(
                context,
                initial: DateTime(2026, 9, 15, 23, 0),
                maximum: max,
              );
            },
            child: const Text('buka'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, max);
  });

  testWidgets('Cancel tidak mengubah nilai', (tester) async {
    final changes = <DateTime?>[];
    await _pumpField(
      tester,
      value: DateTime(2026, 9, 10, 10, 30),
      changes: changes,
    );
    await _openTimeSheet(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
    expect(find.byType(CupertinoDatePicker), findsNothing);
  });

  testWidgets('ponsel mode gelap: angka jam tetap terbaca di sheet putih', (
    tester,
  ) async {
    // Regression: tanpa brightness terkunci, angka jam yang valid berwarna
    // putih di atas sheet putih. Untuk tanggal lampau semua jam valid, jadi
    // roda tampak kosong seperti sedang loading.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showTxTimePicker(
              context,
              // Tanggal lampau; batasnya "sekarang" di hari lain.
              initial: DateTime(2026, 9, 13, 14, 20),
              maximum: DateTime(2026, 9, 15, 14, 20),
            ),
            child: const Text('buka'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    final colors = _hourColors(tester);
    expect(colors, isNotEmpty);
    for (final c in colors) {
      expect(
        c.computeLuminance(),
        lessThan(0.5),
        reason:
            'angka jam harus gelap supaya terbaca di sheet putih, '
            'bukan $c',
      );
    }

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
