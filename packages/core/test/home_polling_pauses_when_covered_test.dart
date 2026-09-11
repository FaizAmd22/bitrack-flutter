// Regression test untuk "loading Vehicle Detail lama sekali".
//
// Navigator.push TIDAK men-dispose layar di bawahnya. HomeScreen tetap hidup
// dengan `isActive: true` (nilainya cuma berubah kalau user ganti tab bottom
// nav), jadi Timer.periodic 30 detiknya terus menembak /monitoring/ +
// /monitoring/position — dua request daftar SELURUH kendaraan — persis saat
// Vehicle Detail sedang menunggu response dari server yang sama.
//
// Perbaikannya: HomeScreen jadi RouteAware lewat NavigationService
// .routeObserver, berhenti polling di didPushNext dan menyala lagi di
// didPopNext. Sebelum perbaikan, tes pertama GAGAL.
import 'dart:async';

import 'package:bitrack_core/base/routes/navigation_service.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async =>
      parser(const StandardMessageCodec().encodeMessage(<String, Object>{})!);
}

/// TileLayer tetap mencoba menarik tile Google dan dijawab 400 di lingkungan
/// tes. Tidak ada hubungannya dengan yang diuji di sini.
void _muteTileImageErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.library == 'image resource service') return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

/// Tiap kali provider ini dijalankan ulang = satu siklus ambil data.
/// _refresh() memanggil invalidateMonitoring() yang membuang cache-nya, jadi
/// counter ini setara dengan "berapa kali home menembak API".
Widget _harness(List<Vehicle> vehicles, void Function() onFetch) =>
    ProviderScope(
      overrides: [
        monitoringProvider.overrideWith((ref, query) async {
          onFetch();
          return MonitoringData(vehicles: vehicles, total: vehicles.length);
        }),
        plateSuggestionProvider.overrideWith((ref, filter) => const <String>[]),
        fleetGroupProvider.overrideWith(
          (ref) async => const <Map<String, dynamic>>[],
        ),
      ],
      child: DefaultAssetBundle(
        bundle: _StubAssetBundle(),
        child: MaterialApp(
          navigatorObservers: [NavigationService.routeObserver],
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

Future<void> _settleOnce(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(() => dotenv.testLoad(fileInput: 'GOOGLE_MAP_KEY=test-key'));

  testWidgets('polling home BERHENTI selama layar lain menimbuninya', (
    tester,
  ) async {
    _muteTileImageErrors();
    var fetches = 0;
    await tester.pumpWidget(_harness([_v('a', -6.2, 106.8)], () => fetches++));
    await _settleOnce(tester);

    // Baseline: satu siklus polling saat home terlihat.
    await tester.pump(const Duration(seconds: 30));
    await _settleOnce(tester);
    final whileVisible = fetches;
    expect(
      whileVisible,
      greaterThan(0),
      reason: 'home harus polling saat terlihat',
    );

    // Vehicle Detail (atau layar apa pun) di-push ke atas home.
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold(body: SizedBox())),
    );
    await _settleOnce(tester);

    // Lewati dua siklus penuh. Home tidak boleh menembak API sama sekali.
    await tester.pump(const Duration(seconds: 30));
    await _settleOnce(tester);
    await tester.pump(const Duration(seconds: 30));
    await _settleOnce(tester);

    expect(
      fetches,
      whileVisible,
      reason: 'home tidak boleh menembak API saat tertimbun layar lain',
    );

    // Kembali ke home: polling nyala lagi DAN langsung refresh sekali supaya
    // marker tidak basi sampai tick berikutnya.
    navigator.pop();
    await _settleOnce(tester);
    expect(
      fetches,
      greaterThan(whileVisible),
      reason: 'kembali ke home harus memicu refresh langsung',
    );

    final afterPop = fetches;
    await tester.pump(const Duration(seconds: 30));
    await _settleOnce(tester);
    expect(
      fetches,
      greaterThan(afterPop),
      reason: 'timer harus menyala lagi setelah kembali',
    );
  });
}
