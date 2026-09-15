// Label detail saat titik pada grafik Periodic Track ditekan: waktu, nilai
// metrik, dan event titik tersebut.
import 'package:bitrack_core/screens/periodic_track/models/periodic_metric.dart';
import 'package:bitrack_core/screens/periodic_track/models/periodic_point.dart';
import 'package:bitrack_core/screens/periodic_track/utils/chart_series.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_chart.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_point_label.dart';
import 'package:flutter/material.dart';
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

// Grafik sekarang merender pin alert (SVG) dari aset app.
Widget _host(Widget child) => withStubAssets(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('PeriodicPointLabel', () {
    testWidgets('titik biasa: waktu, nilai, dan event tanpa tanda alert', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PeriodicPointLabel(
            point: _pt(125, name: 'Sampling'),
            metric: PeriodicMetric.speed,
          ),
        ),
      );

      expect(find.text('2026-09-14 06:02:05 WIB'), findsOneWidget);
      expect(find.text('30 KM/H'), findsOneWidget);
      expect(find.text('Sampling'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('titik alert: nama event dengan tanda peringatan', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PeriodicPointLabel(
            point: _pt(0, speed: 92, type: 'OVERSPEED', name: 'Overspeed'),
            metric: PeriodicMetric.speed,
          ),
        ),
      );

      expect(find.text('92 KM/H'), findsOneWidget);
      expect(find.text('Overspeed'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('event tanpa nama jatuh ke tipe event-nya', (tester) async {
      await tester.pumpWidget(
        _host(
          PeriodicPointLabel(
            point: _pt(0, type: 'HARSH_BRAKING'),
            metric: PeriodicMetric.speed,
          ),
        ),
      );
      expect(find.text('HARSH_BRAKING'), findsOneWidget);
    });

    testWidgets('nilai mengikuti metrik yang dipilih', (tester) async {
      await tester.pumpWidget(
        _host(PeriodicPointLabel(point: _pt(0), metric: PeriodicMetric.accu)),
      );
      expect(find.text('12.5 V'), findsOneWidget);
    });
  });

  test('titik asal ikut terbawa sampai ke seri yang digambar', () {
    final raw = [for (var i = 0; i < 3000; i++) _pt(i)];
    final normalized = normalizeSeries(raw, PeriodicMetric.speed);
    final rendered = withActivePoint(
      downsampleM4(insertGaps(normalized), maxPoints: 600),
      normalized[1234],
    );

    for (final p in rendered.where((p) => p.value != null)) {
      expect(
        p.source,
        isNotNull,
        reason: 'tiap titik bernilai butuh detailnya',
      );
    }
  });

  testWidgets(
    'menekan grafik memunculkan label titik itu, lalu hilang sendiri',
    (tester) async {
      final points = [
        for (var i = 0; i < 40; i++)
          _pt(i * 30, type: 'OVERSPEED', name: 'Overspeed'),
      ];

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: PeriodicChart(
              points: points,
              metric: PeriodicMetric.speed,
              activeTime: parseDeviceTime(points[20].deviceTime),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Label penggaris (titik aktif) sudah tampil sebelum grafik ditekan.
      expect(find.byType(PeriodicPointLabel), findsOneWidget);

      // Ditekan di dalam area grafik (di bawah garis), tempat tooltip bawaan
      // Syncfusion ("Series 0 / x : y") dulu ikut muncul.
      final rect = tester.getRect(find.byType(SfCartesianChart));
      await tester.tapAt(Offset(rect.center.dx, rect.top + rect.height * 0.8));
      await tester.pump(const Duration(milliseconds: 100));

      // Label penggaris + label titik yang ditekan.
      expect(find.byType(PeriodicPointLabel), findsNWidgets(2));
      expect(
        find.textContaining('Series'),
        findsNothing,
        reason: 'tooltip bawaan tidak boleh muncul bersama label detail',
      );
      // Tap di widget test tidak selalu memicu tooltip bawaan Syncfusion, jadi
      // yang dijaga juga konfigurasinya: tooltip itu tidak boleh dipasang lagi.
      final chart = tester.widget<SfCartesianChart>(
        find.byType(SfCartesianChart),
      );
      expect(
        chart.tooltipBehavior?.enable ?? false,
        isFalse,
        reason: 'tooltip bawaan memunculkan label kedua "Series 0"',
      );

      // Label tap bertahan cukup lama untuk dibaca, lalu hilang sendiri;
      // label penggaris tetap.
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(PeriodicPointLabel), findsNWidgets(2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PeriodicPointLabel), findsOneWidget);
    },
  );

  testWidgets('alert tampil di grafik sebagai penanda tersendiri', (
    tester,
  ) async {
    final points = [
      for (var i = 0; i < 40; i++)
        i % 10 == 3
            ? _pt(i * 30, type: 'OVERSPEED', name: 'Overspeed')
            : _pt(i * 30),
    ];

    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 360,
          child: PeriodicChart(
            points: points,
            metric: PeriodicMetric.speed,
            activeTime: null,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final chart = tester.widget<SfCartesianChart>(
      find.byType(SfCartesianChart),
    );
    final alertSeries = chart.series
        .whereType<ScatterSeries<SeriesPoint, DateTime>>()
        .toList();

    expect(alertSeries, hasLength(1));
    final alerts = alertSeries.single.dataSource!;
    expect(alerts, hasLength(4));
    expect(alerts.map((p) => p.source!.eventName), everyElement('Overspeed'));
    // Tidak ikut memunculkan label trackball sendiri.
    expect(alertSeries.single.enableTrackball, isFalse);
  });

  group('label penggaris (titik aktif)', () {
    Future<void> pumpActive(
      WidgetTester tester,
      List<PeriodicPoint> points,
      int active,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 360,
            child: PeriodicChart(
              points: points,
              metric: PeriodicMetric.speed,
              activeTime: parseDeviceTime(points[active].deviceTime),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('titik alert: waktu, nilai, dan nama event', (tester) async {
      final points = [
        for (var i = 0; i < 40; i++)
          i == 10
              ? _pt(i * 30, speed: 12, type: 'OVERSPEED', name: 'Overspeed')
              : _pt(i * 30, speed: 30),
      ];
      await pumpActive(tester, points, 10);

      final label = find.byType(PeriodicPointLabel);
      expect(label, findsOneWidget);
      expect(
        find.descendant(
          of: label,
          matching: find.text('2026-09-14 06:05:00 WIB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: label, matching: find.text('12 KM/H')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: label, matching: find.text('Overspeed')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: label,
          matching: find.byIcon(Icons.warning_amber_rounded),
        ),
        findsOneWidget,
      );
    });

    testWidgets('titik rutin: tanpa tanda alert', (tester) async {
      final points = [
        for (var i = 0; i < 40; i++) _pt(i * 30, name: 'Sampling'),
      ];
      await pumpActive(tester, points, 5);

      final label = find.byType(PeriodicPointLabel);
      expect(label, findsOneWidget);
      expect(
        find.descendant(of: label, matching: find.text('Sampling')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    // Laporan: di 16:40:05 ada data rutin DAN alert "Over Stay Engine Off".
    // Pin di grafik menandai alert-nya, tapi penggaris menampilkan SAMPLING.
    // Kedua urutan diuji karena pengurutan waktu tidak menjamin mana yang
    // lebih dulu untuk detik yang sama.
    for (final alertFirst in [false, true]) {
      testWidgets('data rutin dan alert di detik yang sama: penggaris '
          'menampilkan alert (${alertFirst ? 'alert' : 'data rutin'} lebih '
          'dulu di data)', (tester) async {
        final routine = _pt(300, speed: 0, name: 'SAMPLING');
        final alert = _pt(
          300,
          speed: 0,
          type: 'OVERSTAY_ENGINE_OFF',
          name: 'Over Stay Engine Off',
        );
        final points = [
          for (var i = 0; i < 40; i++)
            if (i == 10)
              ...(alertFirst ? [alert, routine] : [routine, alert])
            else
              _pt(i * 30),
        ];

        // Titik yang sedang diputar di peta adalah data rutinnya.
        await pumpActive(tester, points, points.indexOf(routine));

        final label = find.byType(PeriodicPointLabel);
        expect(label, findsOneWidget);
        expect(
          find.descendant(
            of: label,
            matching: find.text('Over Stay Engine Off'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: label,
            matching: find.byIcon(Icons.warning_amber_rounded),
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('tetap di dalam grafik untuk titik tinggi di tepi kanan', (
      tester,
    ) async {
      // Label penggaris kini kartu setinggi ±60 px, jauh lebih besar dari chip
      // nilai lama; titik tinggi di ujung kanan paling rawan keluar grafik.
      final points = [
        for (var i = 0; i < 40; i++) _pt(i * 30, speed: i == 39 ? 78 : 30),
      ];
      await pumpActive(tester, points, 39);

      final chart = tester.getRect(find.byType(SfCartesianChart));
      final label = tester.getRect(find.byType(PeriodicPointLabel));
      expect(label.left, greaterThanOrEqualTo(chart.left - 1));
      expect(label.right, lessThanOrEqualTo(chart.right + 1));
      expect(label.top, greaterThanOrEqualTo(chart.top - 1));
      expect(label.bottom, lessThanOrEqualTo(chart.bottom + 1));
    });
  });
}
