// lib/screens/notification/map_coordinate/map_coordinate_screen.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapCoordinateScreen extends StatefulWidget {
  const MapCoordinateScreen({super.key});

  @override
  State<MapCoordinateScreen> createState() => _MapCoordinateScreenState();
}

class _MapCoordinateScreenState extends State<MapCoordinateScreen> {
  bool _copied = false;

  String _toDMS(double dec, bool isLat) {
    final direction = dec >= 0 ? (isLat ? 'N' : 'E') : (isLat ? 'S' : 'W');
    final absDec = dec.abs();
    final degrees = absDec.floor();
    final minutesFull = (absDec - degrees) * 60;
    final minutes = minutesFull.floor();
    final seconds = ((minutesFull - minutes) * 60).toStringAsFixed(1);
    final mm = minutes.toString().padLeft(2, '0');
    return '$degrees°$mm\'$seconds"$direction';
  }

  String _coordinateText(double lat, double lng) {
    return '${_toDMS(lat, true)} ${_toDMS(lng, false)}';
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final item = ModalRoute.of(context)?.settings.arguments as AlertModel?;

    final lat = item?.latitude ?? 0;
    final lng = item?.longitude ?? 0;
    final point = LatLng(lat, lng);
    final coordText = _coordinateText(lat, lng);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(initialCenter: point, initialZoom: 18),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'id.treffix.bitrack',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      t.mapCoordinate,
                      style: AppStyles.textLBold.copyWith(
                        color: AppStyles.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Copy coordinate bar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _copy(coordText),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          coordText,
                          style: AppStyles.textSm.copyWith(
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        _copied ? Icons.done_all : Icons.copy,
                        size: 20,
                        color: _copied
                            ? const Color(0xFF10B981)
                            : AppStyles.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Toast "copied"
          if (_copied)
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t.copyCoordinate,
                    style: AppStyles.textSm.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
