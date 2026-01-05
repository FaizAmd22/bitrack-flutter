import 'package:dio/dio.dart';
import 'package:bitrack_mobile_flutter/base/network/api_client.dart';

class MonitoringApi {
  static Future<Map<String, dynamic>> fetchMonitoring({
    required String userId,
    required String status,
  }) async {
    try {
      String statusParam = '';

      switch (status) {
        case 'moving':
          statusParam = '?status=MOVING';
          break;
        case 'idle':
          statusParam = '?status=IDLE';
          break;
        case 'stop':
          statusParam = '?status=STOP';
          break;
        case 'silence':
          statusParam = '?status=SILENCE';
          break;
        case 'inOperation':
          statusParam = '?status=INOPERATION';
          break;
        case 'repair':
          statusParam = '?status=REPAIR';
          break;
        case 'allVehicle':
        default:
          statusParam = '';
      }

      final response = await ApiClient.dio.get(
        '/vehicle-monitoring/cluster/fleet-group/$userId$statusParam',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi login berakhir, silakan login kembali.');
      }
      throw Exception(e.message ?? 'Gagal memuat data monitoring');
    } catch (_) {
      throw Exception('Terjadi kesalahan saat memuat monitoring');
    }
  }

  static Future<Map<String, dynamic>> fetchListGeofence({
    required String userId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/vehicle-monitoring/child/fleet-group/$userId',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi login berakhir, silakan login kembali.');
      }
      throw Exception(e.message ?? 'Gagal memuat data geofence');
    } catch (_) {
      throw Exception('Terjadi kesalahan saat memuat geofence');
    }
  }
}
