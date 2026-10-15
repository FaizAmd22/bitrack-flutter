import 'package:flutter_dotenv/flutter_dotenv.dart';

// URL tile peta Google untuk `flutter_map` (bukan untuk `google_maps_flutter`,
// yang memakai API key native di AndroidManifest / Info.plist). Key-nya dari
// `GOOGLE_MAP_KEY` di `.env`. `{s}`, `{x}`, `{y}`, `{z}` diisi `flutter_map`.

/// Peta jalan biasa (`lyrs=m`).
String get googleMapUrl {
  final googleMapKey = dotenv.env['GOOGLE_MAP_KEY'] ?? '';
  return 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=$googleMapKey';
}

/// Satelit + label jalan (`lyrs=y`).
String get googleSatelliteMapUrl {
  final googleMapKey = dotenv.env['GOOGLE_MAP_KEY'] ?? '';
  return 'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&key=$googleMapKey';
}

/// Pengganti `{s}`; beban tile dibagi ke empat server Google.
const googleMapSubdomains = ['mt0', 'mt1', 'mt2', 'mt3'];
