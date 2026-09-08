// Regression test: sheet Informasi menembak ulang `?tab=DASHBOARD` yang
// datanya SUDAH dipegang layar Vehicle Detail.
//
// Endpoint itu butuh ~9,5 detik di server — terukur dari panel Timing DevTools
// pada web ("Waiting for server response 9,57 s", Content Download 0,50 ms) —
// jadi mengambilnya dua kali berarti pengguna menunggu selama itu lagi untuk
// data yang sudah ada di memori.
//
// Request dihitung di level HttpClientAdapter, jadi yang diuji adalah request
// yang BENAR-BENAR keluar. Sebelum perbaikan, tes pertama GAGAL: DASHBOARD
// ikut tercatat.
import 'dart:convert';

import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/screens/vehicle_detail/providers/vehicle_information_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _vehicleId = 'VH-1';

/// Data DASHBOARD yang sudah di-flatten, seperti yang dipublikasikan
/// VehicleDetail setelah response pertamanya tiba.
Map<String, dynamic> dashboardCache() => {
  'vehicle_id': _vehicleId,
  'license_plate': 'B-1095-DFC',
  'fuel_consumed': 38.6,
};

class _CountingAdapter implements HttpClientAdapter {
  final List<String> tabs = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    tabs.add('${options.queryParameters['tab']}');
    return ResponseBody.fromString(
      jsonEncode({
        'data': {
          'unit_detail': {'license_plate': 'DARI-API', 'chiller': false},
          'live_tracking': {'latitude': -7.2, 'longitude': 110.4},
          'speed': {'speed': 0},
          'sensor': <String, dynamic>{},
          'fuel_consumption': <dynamic>[],
          'status': {
            'odometer': 12345,
            'internal_battery': 4.05,
            'external_battery': 92,
          },
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _CountingAdapter adapter;

  setUpAll(
    () => dotenv.testLoad(fileInput: 'BASE_URL=https://example.invalid/api'),
  );

  setUp(() {
    adapter = _CountingAdapter();
    final previous = ApiClient.dio.httpClientAdapter;
    ApiClient.dio.httpClientAdapter = adapter;
    addTearDown(() => ApiClient.dio.httpClientAdapter = previous);
  });

  test(
    'data detail dipakai ulang: DASHBOARD tidak ditembak dua kali',
    () async {
      final container = ProviderContainer(
        overrides: [
          vehicleDashboardCacheProvider.overrideWith((ref) => dashboardCache()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        vehicleDetailByVehicleIdProvider(_vehicleId).future,
      );

      expect(
        adapter.tabs,
        ['INFORMATION'],
        reason:
            'hanya INFORMATION yang perlu diambil; DASHBOARD sudah di memori',
      );

      // Field DASHBOARD datang dari cache, bukan dari API.
      expect(result['license_plate'], 'B-1095-DFC');
      expect(result['fuel_consumed'], 38.6);
      // Field INFORMATION tetap segar dari API.
      expect(result['total_odometer'], 12345);
    },
  );

  test('tanpa cache, keduanya tetap diambil', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      vehicleDetailByVehicleIdProvider(_vehicleId).future,
    );

    expect(adapter.tabs, containsAll(['DASHBOARD', 'INFORMATION']));
    expect(adapter.tabs.length, 2);
    expect(result['license_plate'], 'DARI-API');
  });

  test('cache milik kendaraan LAIN tidak dipakai', () async {
    final container = ProviderContainer(
      overrides: [
        vehicleDashboardCacheProvider.overrideWith(
          (ref) => {...dashboardCache(), 'vehicle_id': 'KENDARAAN-LAIN'},
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      vehicleDetailByVehicleIdProvider(_vehicleId).future,
    );

    expect(
      adapter.tabs,
      containsAll(['DASHBOARD', 'INFORMATION']),
      reason: 'cache kendaraan lain harus diabaikan',
    );
    expect(result['license_plate'], 'DARI-API');
  });
}
