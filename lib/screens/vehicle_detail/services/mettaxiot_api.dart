import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ams/screens/vehicle_detail/services/mettaxiot_stream_service.dart';

/// Thin wrapper di atas [MettaxiotStreamService] untuk semua API call dashcam.
/// Menggunakan Dio dari [MettaxiotStreamService] agar `followRedirects: true` berlaku.
class MettaxiotApi {
  MettaxiotApi._();

  static final _service = MettaxiotStreamService.I;
  static Dio get _dio => _service.dio;

  /// Token via [MettaxiotStreamService] (cached 10 menit).
  static Future<String> createToken() => _service.createToken();

  /// Ambil stream URL berdasarkan tipe kamera.
  static Future<String> getLiveStreamUrl({
    required String deviceId,
    required int channelId,
    required String camType,
  }) async {
    if (camType == 'STONKAM') {
      final base = dotenv.env['CAMERA_URL'] ?? '';
      return '$base/OpenDeviceStream/100'
          '?DeviceId=$deviceId&ChannelId=$channelId&RealTime=1&SessionId=1071';
    }
    return _service.getLiveStreamUrl(deviceId: deviceId, channelId: channelId);
  }

  /// Ambil WebSocket talk URL untuk fitur speaker/intercom.
  static Future<String> getTalkUrl({required String deviceId}) async {
    final token = await createToken();
    final url = dotenv.env['METTAXIOT_AUDIO'] ?? '';
    if (url.isEmpty) throw Exception('METTAXIOT_AUDIO env not set');

    final resp = await _dio.post(
      url,
      data: {
        'channelId': 1,
        'deviceId': deviceId,
        'talkChannel': 'singapore-1',
      },
      options: Options(
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      ),
    );

    final body = resp.data;
    final talkUrl = (body is Map)
        ? (body['data']?['talkUrl']?.toString() ?? '')
        : '';

    if (talkUrl.isEmpty) {
      final msg = (body is Map) ? (body['msg']?.toString() ?? '') : '';
      throw Exception(msg.isEmpty ? 'Failed to get talkUrl' : msg);
    }
    return talkUrl;
  }
}
