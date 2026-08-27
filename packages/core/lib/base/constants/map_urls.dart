import 'package:flutter_dotenv/flutter_dotenv.dart';

String get googleMapUrl {
  final googleMapKey = dotenv.env['GOOGLE_MAP_KEY'] ?? '';
  return 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=$googleMapKey';
}

String get googleSatelliteMapUrl {
  final googleMapKey = dotenv.env['GOOGLE_MAP_KEY'] ?? '';
  return 'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&key=$googleMapKey';
}

const googleMapSubdomains = ['mt0', 'mt1', 'mt2', 'mt3'];
