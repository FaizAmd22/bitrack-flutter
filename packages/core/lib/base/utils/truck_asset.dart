import 'package:bitrack_core/base/res/media.dart';

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
