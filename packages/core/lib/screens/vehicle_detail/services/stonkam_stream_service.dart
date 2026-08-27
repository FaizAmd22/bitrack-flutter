import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StonkamStreamService {
  const StonkamStreamService();

  String _must(String key) {
    final v = dotenv.env[key];
    if (v == null || v.trim().isEmpty) {
      debugPrint('ENV "$key" belum di-set');
      throw Exception(currentL10n().dashcamServiceUnavailable);
    }
    return v.trim();
  }

  String buildUrl({required String deviceId, required int channelId}) {
    final cameraUrl = _must('CAMERA_URL');
    return '$cameraUrl/OpenDeviceStream/100'
        '?DeviceId=$deviceId'
        '&ChannelId=$channelId'
        '&RealTime=1'
        '&SessionId=1071';
  }
}
