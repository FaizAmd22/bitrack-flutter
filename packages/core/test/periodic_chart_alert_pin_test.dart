// Pin alert di grafik Periodic Track: ikon yang sama dengan pin di peta,
// sedikit lebih kecil, dan bisa ditekan untuk memunculkan label detailnya.
//
// Sebelumnya alert hanya titik merah 10 px, dan menekannya hampir mustahil:
// trackball memilih titik dengan x terdekat, yang pada data padat biasanya
// data rutin di sebelah alert.
import 'package:bitrack_core/screens/periodic_track/models/periodic_metric.dart';
import 'package:bitrack_core/screens/periodic_track/models/periodic_point.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_chart.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_point_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'support/stub_asset_bundle.dart';

PeriodicPoint _pt(
  int second, {
  double speed = 30,
  String type = 'SAMPLING',
  String name = '',
}) {
  final m = (second ~/ 60).toString().padLeft(2, '0');
  final s = (second % 60).toString().padLeft(2, '0');
  return PeriodicPoint(
    latitude: -6.5,
    longitude: 106.8,
    deviceTime: '2026-09-14 06:$m:$s',
    speed: speed,
    ignition: true,
    externalPowerVoltage: 12.5,
    fuelLevel: 50,
    dallasTemp1: 4,
    dallasTemp2: 5,
    eventType: type,
    eventName: name,
  );
}

/// 120 titik rutin tiap 30 detik, plus dua alert bernilai 0 km/j seperti di
/// laporan. Alert pertama sengaja berbagi detik yang sama dengan data rutin.
List<PeriodicPoint> _points() => [
  for (var i = 0; i < 120; i++)
    _pt(i * 30, speed: 20 + ((i * 7) % 40).toDouble()),
  _pt(30 * 30, speed: 0, type: 'OVERSPEED', name: 'Overspeed'),
  _pt(90 * 30 + 5, speed: 0, type: 'HARSH_BRAKING', name: 'Harsh Braking'),
];

Future<void> _pumpChart(WidgetTester tester) async {
  await tester.pumpWidget(
    withStubAssets(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: PeriodicChart(
                points: _points(),
                metric: PeriodicMetric.speed,
                activeTime: null,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

/// Pin diurutkan dari kiri ke kanan (menurut waktu).
List<Offset> _pinCenters(WidgetTester tester) {
  final centers = [
    for (final e in find.byType(SvgPicture).evaluate())
      tester.getCenter(find.byWidget(e.widget)),
  ]..sort((a, b) => a.dx.compareTo(b.dx));
  return centers;
}

void main() {
  testWidgets('tiap alert tampil sebagai pin, lebih kecil dari pin di peta', (
    tester,
  ) async {
    await _pumpChart(tester);

    final pins = find.byType(SvgPicture);
    expect(pins, findsNWidgets(2));
    for (final e in pins.evaluate()) {
      final size = tester.getSize(find.byWidget(e.widget));
      expect(size.width, lessThan(36), reason: 'pin di peta 36 px');
      expect(size.width, greaterThan(10), reason: 'titik lama 10 px');
    }
  });

  testWidgets('menekan pin memunculkan label alert itu, bukan tetangganya', (
    tester,
  ) async {
    await _pumpChart(tester);

    await tester.tapAt(_pinCenters(tester).first);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PeriodicPointLabel), findsOneWidget);
    // Alert ini berbagi detik dengan data rutin — tetap alert yang tampil.
    expect(find.text('Overspeed'), findsOneWidget);
    expect(find.text('2026-09-14 06:15:00 WIB'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    // Hilang sendiri seperti label lain.
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(PeriodicPointLabel), findsNothing);
  });

  testWidgets('pin kedua memunculkan alert kedua', (tester) async {
    await _pumpChart(tester);

    await tester.tapAt(_pinCenters(tester).last);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Harsh Braking'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('tap biasa di grafik tetap memunculkan label data rutin', (
    tester,
  ) async {
    // Pin ditekan lewat onDataLabelTapped, yang membuat lapisan label ikut
    // menerima tap di seluruh area plot. Tap di luar pin tidak boleh ikut
    // tertelan.
    await _pumpChart(tester);

    final rect = tester.getRect(find.byType(SfCartesianChart));
    await tester.tapAt(Offset(rect.center.dx, rect.top + rect.height * 0.6));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PeriodicPointLabel), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('menekan TEPI pin tetap memunculkan alert-nya', (tester) async {
    // Di grafik ini titik rutin berjarak kira-kira 2,75 px. 12 px dari tengah
    // pin, titik dengan x terdekat sudah data rutin, jadi trackball biasa akan
    // memilihnya. Alert kedua dipakai karena tidak berbagi detik dengan data
    // rutin, supaya preferensi alert tidak ikut menutupi hasilnya.
    await _pumpChart(tester);

    await tester.tapAt(_pinCenters(tester).last + const Offset(12, 0));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Harsh Braking'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}
