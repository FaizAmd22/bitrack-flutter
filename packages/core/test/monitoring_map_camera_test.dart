// Regression test untuk bug "peta di home ter-reset tiap data di-refetch".
//
// Penyebabnya BUKAN MonitoringMap: widget ini memang mempertahankan kamera
// saat daftar kendaraan berubah. Yang menggeser kamera adalah panggilan
// eksplisit fitToVehicles() dari home_screen, yang dulu ikut dijalankan
// polling 30 detik sehingga pan/zoom user dibatalkan tiap setengah menit.
//
// Dua sifat itu dikunci di sini supaya tidak tertukar lagi:
//   1. rebuild dengan data baru  -> kamera TETAP
//   2. fitToVehicles()           -> kamera BERGESER
import 'dart:async';

import 'package:bitrack_core/screens/home/models/vehicle.dart';
import 'package:bitrack_core/screens/home/widgets/monitoring_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

/// Aset gambar (ikon truk) ada di `apps/*/assets`, bukan di packages/core,
/// jadi Image.asset di dalam marker tidak bisa di-resolve dari test package
/// ini. Bundle tiruan di bawah menjawab semua key dengan PNG 1x1 transparan
/// supaya widget-nya tetap bisa dibangun; isi gambarnya memang tidak relevan
/// untuk tes kamera.
class _StubAssetBundle extends CachingAssetBundle {
  static final _pixel = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, //
    0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 96, 0, 2, 0, 0, //
    5, 0, 1, 122, 94, 171, 63, 0, 0, 0, 0, 73, 69, 78, 68, //
    174, 66, 96, 130,
  ]);

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(_pixel);

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '';

  /// AssetImage membaca AssetManifest.bin dulu untuk mencari varian resolusi.
  /// Tanpa override ini, manifest ikut dijawab dengan byte PNG di atas dan
  /// StandardMessageCodec melempar FormatException. Manifest kosong sudah
  /// cukup: kalau sebuah key tidak terdaftar, Flutter jatuh ke key aslinya -
  /// yang memang dijawab load() di atas.
  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    return parser(
      const StandardMessageCodec().encodeMessage(<String, Object>{})!,
    );
  }
}

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
    );

/// MapController milik FlutterMap yang sedang hidup di widget tree.
/// `mapController` adalah field publik FlutterMap, jadi tes ini tidak perlu
/// hook khusus di kode produksi.
MapController _mapControllerOf(WidgetTester tester) =>
    tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;

Widget _app(List<Vehicle> vehicles, MonitoringMapController controller) =>
    DefaultAssetBundle(
      bundle: _StubAssetBundle(),
      child: MaterialApp(
        home: Scaffold(
          body: MonitoringMap(
            vehicles: vehicles,
            showPlate: false,
            controller: controller,
          ),
        ),
      ),
    );

void main() {
  // MonitoringMap membangun URL tile lewat googleMapUrl, yang membaca
  // GOOGLE_MAP_KEY dari dotenv. Tanpa ini build() melempar NotInitializedError
  // sebelum FlutterMap sempat terpasang. Nilainya tidak penting - tile tidak
  // benar-benar diunduh di widget test.
  setUpAll(() => dotenv.testLoad(fileInput: 'GOOGLE_MAP_KEY=test-key'));

  testWidgets('data di-refetch: kamera user TIDAK ikut tereset', (tester) async {
    final controller = MonitoringMapController();

    await tester.pumpWidget(_app([_v('a', -6.2, 106.8)], controller));
    await tester.pump();

    // User menggeser & zoom peta ke suatu tempat.
    const userCenter = LatLng(-6.9, 107.6);
    const userZoom = 13.0;
    _mapControllerOf(tester).move(userCenter, userZoom);
    await tester.pump();

    // Polling 30 detik: posisi kendaraan berubah, ada kendaraan baru, widget
    // di-rebuild dengan list baru. Ini yang dulu bikin peta melompat balik.
    await tester.pumpWidget(
      _app([_v('a', -7.5, 110.0), _v('b', -8.0, 112.0)], controller),
    );
    await tester.pump();

    final camera = _mapControllerOf(tester).camera;
    expect(camera.center.latitude, closeTo(userCenter.latitude, 0.0001));
    expect(camera.center.longitude, closeTo(userCenter.longitude, 0.0001));
    expect(camera.zoom, userZoom);
  });

  testWidgets('fitToVehicles() memang menggeser kamera', (tester) async {
    final controller = MonitoringMapController();

    await tester.pumpWidget(_app([_v('a', -6.2, 106.8)], controller));
    await tester.pump();

    final before = _mapControllerOf(tester).camera.center;

    // Aksi user (ganti filter/search/activity) tetap harus mem-frame ulang.
    controller.fitToVehicles([_v('a', -6.2, 106.8)]);
    await tester.pump();

    final after = _mapControllerOf(tester).camera.center;
    expect(after, isNot(before));
    expect(after.latitude, closeTo(-6.2, 0.0001));
    expect(after.longitude, closeTo(106.8, 0.0001));
  });
}
