// Regression test untuk bug "posisi peta di home ikut tereset tiap data
// di-refetch".
//
// Penyebabnya: polling 30 detik memanggil _refresh() -> _load(), dan _load()
// selalu memanggil fitToVehicles(). Jadi setiap setengah menit kamera dipaksa
// balik ke bounding box seluruh armada, membatalkan pan/zoom user.
//
// Perbaikannya memisahkan "ambil data baru" dari "geser kamera" lewat
// parameter fitCamera, dan polling memakai fitCamera: false. Tes ini
// memverifikasi tepat perilaku itu — sebelum perbaikan, tes pertama GAGAL.
import 'dart:async';

import 'package:bitrack_core/features/monitoring/providers/monitoring_providers.dart';
import 'package:bitrack_core/features/monitoring/providers/plate_suggestion_provider.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/home/home_screen.dart';
import 'package:bitrack_core/screens/home/models/vehicle.dart';
import 'package:bitrack_core/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

Vehicle _v(String id, double lat, double lng) => Vehicle(
  id: id,
  vehicleId: id,
  latitude: lat,
  longitude: lng,
  bearing: 0,
  activity: 'MOVING',
  deviceTime: '2026-01-01 00:00:00',
  ignition: 1,
  licensePlate: 'B $id XX',
  fleetGroupName: 'grup',
  vehicleCategoryIcon: "",
);

/// Aset (ikon truk, animasi lottie loading) ada di `apps/*/assets`, bukan di
/// packages/core, jadi tidak bisa di-resolve dari test package ini.
class _StubAssetBundle extends CachingAssetBundle {
  static final _pixel = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, //
    0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 96, 0, 2, 0, 0, //
    5, 0, 1, 122, 94, 171, 63, 0, 0, 0, 0, 73, 69, 78, 68, //
    174, 66, 96, 130,
  ]);

  static const _lottieJson =
      '{"v":"5.5.7","fr":30,"ip":0,"op":30,"w":100,"h":100,"layers":[]}';
  static const _svgXml =
      '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"></svg>';

  static Uint8List _bytes(String key) {
    if (key.endsWith('.json')) return Uint8List.fromList(_lottieJson.codeUnits);
    if (key.endsWith('.svg')) return Uint8List.fromList(_svgXml.codeUnits);
    return _pixel;
  }

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(_bytes(key));

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      String.fromCharCodes(_bytes(key));

  /// Manifest kosong: key yang tidak terdaftar jatuh ke key aslinya, yang
  /// memang dijawab load() di atas.
  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async =>
      parser(const StandardMessageCodec().encodeMessage(<String, Object>{})!);
}

/// TileLayer benar-benar mencoba menarik tile Google, dan di lingkungan tes
/// semua request HTTP dijawab 400 sehingga image resource service melaporkan
/// error. Itu tidak ada hubungannya dengan yang diuji di sini (posisi kamera),
/// jadi khusus error dari service itu dibuang. Error lain tetap diteruskan
/// supaya kegagalan asli tidak ikut tertelan.
///
/// Dipasang di dalam body tiap tes, bukan di setUp(): binding flutter_test
/// memasang FlutterError.onError miliknya sendiri saat tes mulai, jadi
/// override dari setUp() ketimpa.
void _muteTileImageErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.library == 'image resource service') return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

MapController _mapControllerOf(WidgetTester tester) =>
    tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;

Widget _harness(List<Vehicle> vehicles) => ProviderScope(
  overrides: [
    monitoringProvider.overrideWith(
      (ref, query) async =>
          MonitoringData(vehicles: vehicles, total: vehicles.length),
    ),
    plateSuggestionProvider.overrideWith((ref, filter) => const <String>[]),
    fleetGroupProvider.overrideWith(
      (ref) async => const <Map<String, dynamic>>[],
    ),
  ],
  child: DefaultAssetBundle(
    bundle: _StubAssetBundle(),
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(isActive: true),
    ),
  ),
);

void main() {
  setUpAll(() => dotenv.testLoad(fileInput: 'GOOGLE_MAP_KEY=test-key'));

  testWidgets('polling 30 detik TIDAK menggeser kamera user', (tester) async {
    _muteTileImageErrors();
    await tester.pumpWidget(
      _harness([_v('a', -6.2, 106.8), _v('b', -6.4, 107.0)]),
    );
    // pumpAndSettle tidak dipakai: animasi lottie loading berulang terus dan
    // tile terus di-retry, jadi frame tidak pernah "diam". Pump manual saja
    // sampai load pertama selesai.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // User menggeser & zoom peta ke tempat pilihannya.
    const userCenter = LatLng(-7.8, 110.4);
    const userZoom = 14.0;
    _mapControllerOf(tester).move(userCenter, userZoom);
    await tester.pump();

    // Lewati satu siklus polling (_pollInterval = 30 detik).
    await tester.pump(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 100));

    final camera = _mapControllerOf(tester).camera;
    expect(
      camera.center.latitude,
      closeTo(userCenter.latitude, 0.0001),
      reason: 'polling tidak boleh menggeser kamera',
    );
    expect(
      camera.center.longitude,
      closeTo(userCenter.longitude, 0.0001),
      reason: 'polling tidak boleh menggeser kamera',
    );
    expect(camera.zoom, userZoom, reason: 'polling tidak boleh mengubah zoom');
  });

  testWidgets('load pertama TETAP mem-frame armada', (tester) async {
    _muteTileImageErrors();
    await tester.pumpWidget(
      _harness([_v('a', -6.2, 106.8), _v('b', -6.4, 107.0)]),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Kamera pindah dari posisi awal (tengah Indonesia, -2.5/115.0) ke tengah
    // armada — memastikan fitCamera: false pada polling tidak ikut mematikan
    // fit pada load pertama.
    final fitted = _mapControllerOf(tester).camera.center;
    expect(fitted.latitude, closeTo(-6.3, 0.2));
    expect(fitted.longitude, closeTo(106.9, 0.2));
  });
}
