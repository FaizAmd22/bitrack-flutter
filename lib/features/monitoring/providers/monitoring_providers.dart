import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ams/features/auth/providers/auth_providers.dart';
import 'package:ams/features/monitoring/data/monitoring_api.dart';
import 'package:ams/screens/home/models/vehicle.dart';

final monitoringProvider = FutureProvider.family<List<Vehicle>, String>((
  ref,
  activity,
) async {
  final FlutterSecureStorage storage = ref.read(secureStorageProvider);

  final userId = await storage.read(key: 'user_id');

  if (userId == null || userId.isEmpty) {
    throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
  }

  final result = await MonitoringApi.fetchMonitoring(
    userId: userId,
    status: activity,
  );

  final status = result['status']?.toString();
  if (status != 'true') {
    final msg = result['error_msg']?.toString() ?? 'Gagal memuat data';
    throw Exception(msg);
  }

  final List<dynamic> rawList = (result['data'] as List?) ?? [];

  return rawList
      .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
      .toList();
});
