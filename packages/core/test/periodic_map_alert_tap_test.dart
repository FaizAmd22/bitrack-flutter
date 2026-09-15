// Regression test: pin alert di peta Periodic Track tertutup titik biru dan
// sulit ditekan.
//
// Di FlutterMap, layer yang ditulis belakangan digambar di atas sekaligus
// menerima tap lebih dulu. Layer alert dulu ditulis SEBELUM layer titik biru,
// jadi titik biru menutupi pin alert dan menangkap tap-nya.
import 'dart:async';

import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/periodic_track/models/periodic_metric.dart';
import 'package:bitrack_core/screens/periodic_track/models/periodic_point.dart';
import 'package:bitrack_core/screens/periodic_track/models/playback_speed.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aset (ikon alert SVG, truk) ada di `apps/*/assets`, bukan di core.
class _StubAssetBundle extends CachingAssetBundle {
  static final _pixel = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, //
    0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 96, 0, 2, 0, 0, //
    5, 0, 1, 122, 94, 171, 63, 0, 0, 0, 0, 73, 69, 78, 68, //
    174, 66, 96, 130,
  ]);
  static const _svgXml =
      '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36">'
      '<rect width="36" height="36"/></svg>';

  static Uint8List _bytes(String key) =>
      key.endsWith('.svg') ? Uint8List.fromList(_svgXml.codeUnits) : _pixel;

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(_bytes(key));

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      String.fromCharCodes(_bytes(key));

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async =>
      parser(const StandardMessageCodec().encodeMessage(<String, Object>{})!);
}

/// Tile Google tetap dicoba dimuat dan dijawab 400 di lingkungan tes.
void _muteTileImageErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.library == 'image resource service') return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

PeriodicPoint _pt(
  double lat,
  double lng,
  String time, {
  String type = 'SAMPLING',
  String name = '',
}) => PeriodicPoint(
  latitude: lat,
  longitude: lng,
  deviceTime: time,
  speed: 0,
  ignition: false,
  externalPowerVoltage: 12,
  fuelLevel: 50,
  dallasTemp1: 4,
  dallasTemp2: 5,
  eventType: type,
  eventName: name,
);

void main() {
  setUpAll(() => dotenv.testLoad(fileInput: 'GOOGLE_MAP_KEY=test-key'));

  testWidgets(
    'pin alert yang bertumpuk dengan titik biru dan truk tetap bisa ditekan',
    (tester) async {
      _muteTileImageErrors();
      // Ukuran ponsel umum (411x891). Layar bawaan tes (800x600) terlalu pendek
      // untuk sheet detail alert yang terbuka setelah tap. Lebarnya juga tidak
      // dibuat 360: font tes menggambar tiap huruf sebagai kotak selebar 1 em,
      // jadi teks sheet terukur hampir dua kali lebih lebar dari di perangkat.
      tester.view.physicalSize = const Size(1233, 2673);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      // Persis kasus di screenshot: titik biru, pin alert, dan truk (yang
      // sedang berhenti di titik 0) berada di koordinat yang sama.
      const lat = -7.0;
      const lng = 110.4;
      final points = [
        _pt(lat, lng, '2026-09-07 10:19:51'),
        _pt(
          lat,
          lng,
          '2026-09-07 10:19:52',
          type: 'OVERSPEED',
          name: 'Overspeed',
        ),
        _pt(lat + 0.01, lng + 0.01, '2026-09-07 10:25:00'),
      ];
      const alertIndex = 1;

      final selected = <int>[];
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _StubAssetBundle(),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 400,
                  child: PeriodicMap(
                    mapController: MapController(),
                    points: points,
                    currentIndex: 0,
                    metric: PeriodicMetric.speed,
                    autoCenter: false,
                    onPointSelected: selected.add,
                    isPlaying: false,
                    speed: PlaybackSpeed.x1,
                    isSatellite: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Peta berpusat di titik 0, jadi ketiganya ada tepat di tengah peta.
      await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
      await tester.pump();

      expect(
        selected,
        [alertIndex],
        reason: 'tap harus sampai ke pin alert, bukan ke titik biru atau truk',
      );

      // Sheet detail alert terbuka; tutup supaya tidak ada animasi tertunda.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Overspeed'), findsWidgets);
    },
  );

  testWidgets('titik biru bisa ditekan dan langsung terpilih', (tester) async {
    // Hanya SATU pump setelah tap: tap titik biru harus langsung, bukan
    // tertunda menunggu double-tap seperti MapOptions.onTap di flutter_map 6.
    _muteTileImageErrors();
    tester.view.physicalSize = const Size(1233, 2673);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final points = [
      _pt(-7.0, 110.4, '2026-09-07 10:19:51'),
      _pt(-7.001, 110.401, '2026-09-07 10:20:01'),
      _pt(-7.002, 110.402, '2026-09-07 10:20:11'),
    ];

    final selected = <int>[];
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _StubAssetBundle(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 400,
                child: PeriodicMap(
                  mapController: MapController(),
                  points: points,
                  currentIndex: 0,
                  metric: PeriodicMetric.speed,
                  autoCenter: false,
                  onPointSelected: selected.add,
                  isPlaying: false,
                  speed: PlaybackSpeed.x1,
                  isSatellite: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Peta berpusat di titik 0 (truk juga di sana, tapi tidak menangkap tap).
    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
    await tester.pump();

    expect(selected, [0]);
    await tester.pump(const Duration(milliseconds: 400));
  });
}
