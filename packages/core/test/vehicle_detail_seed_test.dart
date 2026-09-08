// Regression test untuk "loading Vehicle Detail lama sekali".
//
// Layar detail menahan SELURUH tampilan di balik scrim FullScreenLoading
// selama menunggu /monitoring/{id}?tab=DASHBOARD — di lapangan tujuh detik
// atau lebih. Padahal plat, posisi, arah, aktivitas, dan status mesin sudah
// ada di memori sejak home memuat daftar kendaraan.
//
// Perbaikannya: monitoring_map mengoper VehicleDetailArgs (bukan lagi String
// id telanjang), dan layar detail memaint data itu lebih dulu. Sebelum
// perbaikan, tes kedua GAGAL — yang tampil cuma FullScreenLoading.
import 'dart:async';
import 'dart:io';

import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/vehicle_detail/models/vehicle_detail_args.dart';
import 'package:bitrack_core/screens/vehicle_detail/vehicle_detail.dart';
import 'package:bitrack_core/base/widgets/full_screen_loading.dart';
import 'package:bitrack_core/base/widgets/skeleton_box.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/vehicle_detail_content.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/vehicle_realtime_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Request HTTP yang tidak pernah dijawab.
///
/// Tanpa ini `/monitoring` gagal seketika di lingkungan tes, FutureBuilder
/// langsung lompat ke cabang error, dan state `waiting` — justru yang sedang
/// diuji — tidak pernah sempat terlihat. Menggantungkannya meniru API asli
/// yang butuh tujuh detik.
class _HangingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _HangingHttpClient();
}

class _HangingHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      Completer<HttpClientRequest>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void _hangAllRequests() {
  final previous = HttpOverrides.current;
  HttpOverrides.global = _HangingHttpOverrides();
  addTearDown(() => HttpOverrides.global = previous);
}

void _muteNetworkImageErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.library == 'image resource service') return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

/// Mendorong VehicleDetail lewat route sungguhan supaya
/// `ModalRoute.of(context).settings.arguments` benar-benar terisi.
Future<void> _openDetail(WidgetTester tester, Object? arguments) async {
  await tester.pumpWidget(
    ProviderScope(
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
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const VehicleDetail(),
                      settings: RouteSettings(arguments: arguments),
                    ),
                  ),
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('buka'));
  // Satu pump saja: request /monitoring masih menggantung, jadi inilah yang
  // dilihat user pada detik-detik pertama.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

/// Request yang digantung meninggalkan timer timeout milik Dio. Binding tes
/// menolak selesai selama masih ada timer tertunda, jadi jamnya dimajukan
/// melewati connectTimeout (15 detik) supaya timer itu bebas.
Future<void> _drainPendingTimeouts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 30));
}

void main() {
  setUpAll(
    () => dotenv.testLoad(
      fileInput:
          'GOOGLE_MAP_KEY=test-key\nBASE_URL=https://example.invalid/api',
    ),
  );

  testWidgets('TANPA seed (id String): layar tertahan di balik scrim', (
    tester,
  ) async {
    _muteNetworkImageErrors();
    _hangAllRequests();
    await _openDetail(tester, 'ID-TANPA-SEED');

    expect(find.byType(FullScreenLoading), findsOneWidget);
    expect(find.byType(VehicleDetailContent), findsNothing);

    await _drainPendingTimeouts(tester);
  });

  testWidgets('DENGAN seed: kartu detail langsung tampil tanpa tunggu API', (
    tester,
  ) async {
    _muteNetworkImageErrors();
    _hangAllRequests();
    await _openDetail(
      tester,
      const VehicleDetailArgs(
        id: 'ID-DENGAN-SEED',
        licensePlate: 'B-9202-VCE',
        fleetGroupName: 'Treffix',
        latitude: -6.5143016,
        longitude: 106.80716,
        direction: 32,
        activity: 'STOP',
        ignition: 0,
        deviceTime: '2026-09-02 11:22:28',
      ),
    );

    expect(
      find.byType(FullScreenLoading),
      findsNothing,
      reason: 'scrim tidak boleh muncul kalau sudah ada data awal',
    );
    expect(find.byType(VehicleDetailContent), findsOneWidget);

    // Plat dan fleet group dari seed sudah terbaca user.
    expect(find.text('B-9202-VCE'), findsOneWidget);
    expect(find.text('Treffix'), findsOneWidget);

    // Peta juga sudah diarahkan ke posisi kendaraan, bukan posisi default.
    final map = tester.widget<VehicleRealtimeMap>(
      find.byType(VehicleRealtimeMap),
    );
    expect(map.coordinate, isNotNull);
    expect(map.coordinate!.latitude, closeTo(-6.5143016, 0.0001));
    expect(map.coordinate!.longitude, closeTo(106.80716, 0.0001));

    await _drainPendingTimeouts(tester);
  });

  testWidgets('field yang belum ada tampil sebagai skeleton, bukan "-"', (
    tester,
  ) async {
    _muteNetworkImageErrors();
    _hangAllRequests();
    await _openDetail(
      tester,
      const VehicleDetailArgs(
        id: 'ID-DENGAN-SEED',
        licensePlate: 'B-9202-VCE',
        fleetGroupName: 'Treffix',
        latitude: -6.5143016,
        longitude: 106.80716,
        activity: 'STOP',
        ignition: 0,
        deviceTime: '2026-09-02 11:22:28',
      ),
    );

    // Model kendaraan, pengemudi, waktu mesin terakhir menyala, plus tiga chip
    // indikator (chiller, bahan bakar, dashcam) — semuanya hanya ada di
    // response detail.
    expect(find.byType(SkeletonBox), findsNWidgets(6));

    // Yang PALING menyesatkan sebelum ini: seed mengisi fuel_consumed dengan 0,
    // jadi chip bahan bakar menampilkan "0 %" berlatar merah — terbaca sebagai
    // tangki kosong.
    expect(find.text('0 %'), findsNothing);
    expect(find.text('0.0 %'), findsNothing);

    // Sebaliknya, data yang memang sudah dipegang tetap tampil apa adanya.
    expect(find.text('B-9202-VCE'), findsOneWidget);
    expect(find.text('Treffix'), findsOneWidget);

    await _drainPendingTimeouts(tester);
  });

  testWidgets('request gagal TIDAK membuang data yang sudah tampil', (
    tester,
  ) async {
    _muteNetworkImageErrors();
    _hangAllRequests();
    await _openDetail(
      tester,
      const VehicleDetailArgs(
        id: 'ID-DENGAN-SEED',
        licensePlate: 'B-9202-VCE',
        fleetGroupName: 'Treffix',
        latitude: -6.5143016,
        longitude: 106.80716,
        activity: 'STOP',
        ignition: 0,
      ),
    );

    // Biarkan request menggantung sampai melewati batas waktu.
    await tester.pump(const Duration(seconds: 50));
    await tester.pump(const Duration(milliseconds: 100));

    // Layar error penuh TIDAK boleh menggantikan data yang sudah ada.
    expect(
      find.byType(VehicleDetailContent),
      findsOneWidget,
      reason: 'data yang sudah tampil harus dipertahankan',
    );
    expect(
      find.text('Vehicle data could not be loaded.'),
      findsOneWidget,
      reason: 'kegagalan tetap harus diberitahukan, sekali saja',
    );
    expect(find.text('B-9202-VCE'), findsOneWidget);

    // Tombol coba lagi tersedia tanpa menutupi layar.
    expect(find.text('Try again.'), findsOneWidget);

    await _drainPendingTimeouts(tester);
  });
}
