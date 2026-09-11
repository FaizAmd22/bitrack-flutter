// Ikon marker custom dari kolom `vehicle_category_icon` pada
// /monitoring/position: URL http(s) -> gambar itu, kosong -> aset truk lama.
import 'dart:async';

import 'package:bitrack_core/base/res/media.dart';
import 'package:bitrack_core/base/widgets/vehicle_marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aset truk ada di `apps/*/assets`, bukan di packages/core.
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
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async =>
      parser(const StandardMessageCodec().encodeMessage(<String, Object>{})!);
}

Widget _host(Widget child) => DefaultAssetBundle(
  bundle: _StubAssetBundle(),
  child: MaterialApp(home: Center(child: child)),
);

bool _isNetworkIcon(Widget w) {
  if (w is! Image) return false;
  final provider = w.image;
  return provider is ResizeImage && provider.imageProvider is NetworkImage;
}

bool _isTruckAsset(Widget w, String asset) {
  if (w is! Image) return false;
  final provider = w.image;
  return provider is AssetImage && provider.assetName == asset;
}

// Diambil apa adanya dari response /monitoring/position.
const _mrtIcon =
    'https://storage.googleapis.com/bitrack-staging/alerts/vehicle-category/icon/1789026446878-2dde2e71-7bb7-477d-ac15-a4dc913419d3.png';
const _userPhoto =
    'https://storage.googleapis.com/bitrack-staging/alerts/user/photo/6614114E-9FAA-46E2-9006-8CEF05C4C651/1787725348894-a13fab6f-6415-4c37-9817-0a5291b4c049.png';

void main() {
  group('isCustomIconUrl', () {
    test('URL http(s) dari API dianggap ikon custom', () {
      expect(VehicleMarkerIcon.isCustomIconUrl(_mrtIcon), isTrue);
      expect(VehicleMarkerIcon.isCustomIconUrl(_userPhoto), isTrue);
      expect(VehicleMarkerIcon.isCustomIconUrl('http://host/a.png'), isTrue);
      expect(VehicleMarkerIcon.isCustomIconUrl('  $_mrtIcon  '), isTrue);
    });

    test('nilai kosong atau bukan URL jatuh ke aset truk', () {
      for (final value in [
        null,
        '',
        '   ',
        'null',
        '/relatif/a.png',
        'ftp://host/a.png',
        'https://',
      ]) {
        expect(
          VehicleMarkerIcon.isCustomIconUrl(value),
          isFalse,
          reason: 'nilai "$value" tidak boleh dianggap URL ikon',
        );
      }
    });
  });

  testWidgets(
    'vehicle_category_icon kosong: tetap aset truk sesuai aktivitas',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const VehicleMarkerIcon(
            iconUrl: '',
            activity: 'MOVING',
            bearingDeg: 90,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate((w) => _isTruckAsset(w, AppMedia.truckMoving)),
        findsOneWidget,
      );
      expect(find.byWidgetPredicate(_isNetworkIcon), findsNothing);
    },
  );

  testWidgets('vehicle_category_icon berisi URL: gambar itu yang dimuat', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const VehicleMarkerIcon(
          iconUrl: _mrtIcon,
          activity: 'STOP',
          bearingDeg: 170,
        ),
      ),
    );

    final network = find.byWidgetPredicate(_isNetworkIcon);
    expect(network, findsOneWidget);

    final provider = tester.widget<Image>(network).image as ResizeImage;
    expect((provider.imageProvider as NetworkImage).url, _mrtIcon);
    // Didecode seukuran tampilannya, bukan resolusi penuh unggahan user.
    expect(provider.width, 45 * 3);
  });

  testWidgets('URL ikon rusak: marker jatuh ke aset truk, tidak hilang', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const VehicleMarkerIcon(
          iconUrl: 'https://example.invalid/tidak-ada.png',
          activity: 'STOP',
          bearingDeg: 0,
        ),
      ),
    );

    // Di lingkungan tes semua request HTTP dijawab 400, jadi pemuatannya
    // gagal — persis kasus URL rusak di lapangan.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    expect(
      find.byWidgetPredicate((w) => _isTruckAsset(w, AppMedia.truckStop)),
      findsOneWidget,
      reason: 'marker harus tetap terlihat walau gambarnya gagal dimuat',
    );
    expect(tester.takeException(), isNull);
  });
}
