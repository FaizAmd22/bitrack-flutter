import 'package:bitrack_core/features/monitoring/data/monitoring_api.dart';
import 'package:bitrack_core/screens/home/models/vehicle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// /monitoring dipaginasi lewat cursor. Ambil per 1000 baris lalu ikuti
// next_cursor sampai habis; sebelumnya limit 1000 dipakai sebagai batas keras
// sehingga armada di atas 1000 kendaraan terpotong diam-diam.
const _statusPageLimit = 1000;
const _statusMaxPages = 20;

/// Filter yang mempengaruhi DUA endpoint sekaligus (/monitoring dan
/// /monitoring/position).
///
/// Sengaja dipisah dari activity: provider posisi di-key hanya oleh filter
/// ini, sehingga mengganti chip activity TIDAK memicu request ke
/// /monitoring/position — sama seperti perilaku web tracking-dev.
class MonitoringFilter {
  final String? licensePlate;
  final String? fleetGroupId;

  const MonitoringFilter({this.licensePlate, this.fleetGroupId});

  static const none = MonitoringFilter();

  bool get isActive =>
      (licensePlate?.trim().isNotEmpty ?? false) ||
      (fleetGroupId?.trim().isNotEmpty ?? false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoringFilter &&
          other.licensePlate == licensePlate &&
          other.fleetGroupId == fleetGroupId);

  @override
  int get hashCode => Object.hash(licensePlate, fleetGroupId);
}

class MonitoringQuery {
  final String activity;
  final MonitoringFilter filter;

  const MonitoringQuery({
    required this.activity,
    this.filter = MonitoringFilter.none,
  });

  bool get isAllVehicle => MonitoringApi.activityParam(activity).isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoringQuery &&
          other.activity == activity &&
          other.filter == filter);

  @override
  int get hashCode => Object.hash(activity, filter);
}

/// Hasil /monitoring yang dipakai layar home.
class MonitoringStatus {
  /// Plat kendaraan yang cocok dengan (activity + filter), dinormalisasi
  /// huruf besar. Dipakai untuk menentukan marker mana yang ditampilkan.
  ///
  /// Plat dipilih sebagai kunci pencocokan karena ia satu-satunya field yang
  /// pasti ada dan bentuknya sama di kedua endpoint: /monitoring memakai _id
  /// sedangkan /monitoring/position memakai id, dan vehicle_id beda
  /// kapitalisasi antar-endpoint.
  final Set<String> plates;

  /// metadata.summary: jumlah kendaraan per activity untuk SELURUH armada
  /// (tidak ikut filter search / fleet group).
  final Map<String, int> summary;

  /// Semua halaman berhasil ditarik. Kalau false, [plates] cuma sebagian dan
  /// tidak boleh dipakai sebagai angka total.
  final bool platesComplete;

  const MonitoringStatus({
    required this.plates,
    required this.summary,
    required this.platesComplete,
  });
}

class MonitoringData {
  final List<Vehicle> vehicles;

  /// Angka yang ditampilkan di chip activity.
  final int total;

  const MonitoringData({required this.vehicles, required this.total});
}

/// /monitoring/position — sumber koordinat untuk peta.
final vehiclePositionProvider =
    FutureProvider.family<List<Vehicle>, MonitoringFilter>((ref, filter) async {
      final response = await MonitoringApi.fetchPosition(
        licensePlate: filter.licensePlate,
        fleetGroupId: filter.fleetGroupId,
      );

      final list = response['data'];
      if (list is! List) return const [];

      return list
          .whereType<Map>()
          .map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    });

/// /monitoring — status + summary. Satu-satunya provider yang ikut berubah
/// saat activity diganti.
final monitoringStatusProvider =
    FutureProvider.family<MonitoringStatus, MonitoringQuery>((
      ref,
      query,
    ) async {
      final plates = <String>{};
      var summary = const <String, int>{};
      var platesComplete = false;
      String? cursor;

      for (var page = 0; page < _statusMaxPages; page++) {
        final response = await MonitoringApi.fetchMonitoring(
          status: query.activity,
          licensePlate: query.filter.licensePlate,
          fleetGroupIds: query.filter.fleetGroupId,
          limit: _statusPageLimit,
          cursor: cursor,
        );

        final rows = response['data'];
        if (rows is List) {
          for (final row in rows) {
            if (row is! Map) continue;
            final plate = (row['license_plate'] ?? '')
                .toString()
                .trim()
                .toUpperCase();
            if (plate.isNotEmpty) plates.add(plate);
          }
        }

        final metadata = response['metadata'];
        if (metadata is! Map) {
          platesComplete = true;
          break;
        }

        if (summary.isEmpty) {
          final raw = metadata['summary'];
          if (raw is Map) {
            summary = {
              for (final entry in raw.entries)
                entry.key.toString(): _asInt(entry.value),
            };
          }
        }

        // "All Vehicle" tidak menyaring marker apa pun, jadi tidak perlu
        // menarik seluruh armada — halaman pertama sudah cukup untuk summary.
        if (query.isAllVehicle && summary.containsKey('ALL')) break;

        final hasMore =
            metadata['has_more'] == true || metadata['hasNext'] == true;
        final next = (metadata['next_cursor'] ?? metadata['next'])?.toString();

        if (!hasMore || next == null || next.isEmpty) {
          platesComplete = true;
          break;
        }
        cursor = next;
      }

      return MonitoringStatus(
        plates: plates,
        summary: summary,
        platesComplete: platesComplete,
      );
    });

/// Gabungan keduanya: marker untuk peta + angka untuk chip.
///
/// Marker dibangun sepenuhnya dari /monitoring/position (payload-nya sudah
/// lengkap: lat, lng, direction, vehicle_activity, device_time, ignition,
/// license_plate, fleet_group_name, vehicle_id), lalu disaring memakai daftar
/// plat dari /monitoring. Tidak ada lagi inner join by id yang diam-diam
/// membuang kendaraan.
final monitoringProvider =
    FutureProvider.family<MonitoringData, MonitoringQuery>((ref, query) async {
      // Dijalankan paralel: keduanya saling independen. Pakai record .wait
      // supaya kalau salah satu gagal, future satunya tetap punya handler
      // (tidak jadi unhandled exception).
      final (positions, status) = await (
        ref.watch(vehiclePositionProvider(query.filter).future),
        ref.watch(monitoringStatusProvider(query).future),
      ).wait;

      final vehicles = query.isAllVehicle
          ? positions
          : positions
                .where(
                  (v) => status.plates.contains(
                    v.licensePlate.trim().toUpperCase(),
                  ),
                )
                .toList(growable: false);

      return MonitoringData(
        vehicles: vehicles,
        total: _resolveTotal(query, status, vehicles.length),
      );
    });

/// Angka chip mengikuti hitungan server, bukan jumlah marker yang lolos
/// sanitasi — supaya cocok dengan angka di aplikasi Cordova/web.
int _resolveTotal(MonitoringQuery query, MonitoringStatus status, int shown) {
  // summary dihitung server untuk seluruh armada, jadi hanya sahih selama
  // tidak ada filter search / fleet group yang aktif.
  if (!query.filter.isActive) {
    final fromSummary = status.summary[MonitoringApi.summaryKey(query.activity)];
    if (fromSummary != null) return fromSummary;
  }

  if (!query.isAllVehicle && status.platesComplete) return status.plates.length;

  return shown;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

extension MonitoringRefresh on WidgetRef {
  /// Buang cache kedua endpoint sekaligus. Provider gabungan ikut ter-refresh
  /// karena bergantung pada keduanya.
  void invalidateMonitoring() {
    invalidate(vehiclePositionProvider);
    invalidate(monitoringStatusProvider);
    invalidate(monitoringProvider);
  }
}
