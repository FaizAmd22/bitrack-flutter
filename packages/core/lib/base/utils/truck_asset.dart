import 'package:bitrack_core/base/res/media.dart';

/// Gambar truk sesuai aktivitas kendaraan dari backend (`IDLE`, `MOVING`,
/// `STOP`). Nilai lain atau kosong dianggap silence (tidak ada sinyal).
String resolveTruckAsset(String? activity) {
  switch ((activity ?? '').toUpperCase()) {
    case 'IDLE':
      return AppMedia.truckIdle;
    case 'MOVING':
      return AppMedia.truckMoving;
    case 'STOP':
      return AppMedia.truckStop;
    default:
      return AppMedia.truckSilence;
  }
}
