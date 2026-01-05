import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bitrack_mobile_flutter/features/auth/providers/auth_providers.dart';
import 'package:bitrack_mobile_flutter/features/monitoring/data/monitoring_api.dart';

final fleetGeofenceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final FlutterSecureStorage storage = ref.read(secureStorageProvider);

  final userId = await storage.read(key: 'user_id');
  if (userId == null || userId.isEmpty) {
    throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
  }

  final result = await MonitoringApi.fetchListGeofence(userId: userId);

  final status = result['status']?.toString();
  if (status != 'true') {
    final msg = result['error_msg']?.toString() ?? 'Gagal memuat data filter';
    throw Exception(msg);
  }

  return result;
});
