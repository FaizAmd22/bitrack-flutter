// Grafik Periodic Track tidak digambar ulang lebih sering dari perlu.
//
// Satu rebuild grafik ±40 ms (17 ribu titik, ratusan pin alert). Dulu grafik
// digambar ulang setiap kali layar induk di-build ulang dan setiap kali titik
// aktif berganti — di 16x itu tiap ±63 ms, dan saat slider digeser malah
// setiap event geser.
import 'package:bitrack_core/screens/periodic_track/models/periodic_metric.dart';
import 'package:bitrack_core/screens/periodic_track/models/periodic_point.dart';
import 'package:bitrack_core/screens/periodic_track/utils/chart_series.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_chart.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_point_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'support/stub_asset_bundle.dart';

PeriodicPoint _pt(int second) {
  final m = (second ~/ 60).toString().padLeft(2, '0');
  final s = (second % 60).toString().padLeft(2, '0');
  return PeriodicPoint(
    latitude: -6.5,
    longitude: 106.8,
    deviceTime: '2026-09-14 06:$m:$s',
    speed: 30,
    ignition: true,
    externalPowerVoltage: 12.5,
    fuelLevel: 50,
    dallasTemp1: 4,
    dallasTemp2: 5,
    eventType: 'SAMPLING',
    eventName: '',
  );
}

final _points = [for (var i = 0; i < 60; i++) _pt(i * 30)];

Widget _chart(int activeIndex) => withStubAssets(
  MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: PeriodicChart(
            points: _points,
            metric: PeriodicMetric.speed,
            activeTime: parseDeviceTime(_points[activeIndex].deviceTime),
          ),
        ),
      ),
    ),
  ),
);

SfCartesianChart _sf(WidgetTester tester) =>
    tester.widget<SfCartesianChart>(find.byType(SfCartesianChart));

/// Waktu yang tertera di label penggaris.
String _rulerTime(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byType(PeriodicPointLabel),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .firstWhere((t) => t.endsWith('WIB'));

void main() {
  testWidgets('rebuild induk tanpa perubahan tidak menggambar ulang grafik', (
    tester,
  ) async {
    await tester.pumpWidget(_chart(5));
    await tester.pump();
    final first = _sf(tester);

    // Layar induk di-build ulang dengan nilai yang sama.
    await tester.pumpWidget(_chart(5));
    await tester.pump();

    expect(identical(_sf(tester), first), isTrue);
  });

  testWidgets('satu perpindahan setelah diam langsung digambar', (
    tester,
  ) async {
    await tester.pumpWidget(_chart(0));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(_chart(7)); // mis. ⏭ ditekan
    await tester.pump();

    expect(_rulerTime(tester), '${_points[7].deviceTime} WIB');
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets(
    'berganti cepat: digambar ulang paling sering tiap 200 ms, dan penggaris '
    'berakhir tepat di titik terakhir',
    (tester) async {
      await tester.pumpWidget(_chart(0));
      await tester.pump(const Duration(milliseconds: 300));

      // 10 perpindahan dalam 200 ms, seperti pemutaran 16x atau slider.
      final drawn = Set<SfCartesianChart>.identity();
      for (var i = 1; i <= 10; i++) {
        await tester.pumpWidget(_chart(i));
        await tester.pump(const Duration(milliseconds: 20));
        drawn.add(_sf(tester));
      }
      expect(drawn.length, lessThanOrEqualTo(3));

      await tester.pump(const Duration(milliseconds: 250));
      expect(_rulerTime(tester), '${_points[10].deviceTime} WIB');
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
}
