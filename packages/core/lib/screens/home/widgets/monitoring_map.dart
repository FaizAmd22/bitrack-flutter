// ignore_for_file: deprecated_member_use

import 'package:bitrack_core/base/config/app_branding.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/base/widgets/vehicle_marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:bitrack_core/screens/home/models/vehicle.dart';
import 'package:bitrack_core/screens/vehicle_detail/models/vehicle_detail_args.dart';
import 'package:bitrack_core/base/constants/map_urls.dart';

class MonitoringMapController {
  void Function(List<Vehicle> vehicles)? _fit;

  void fitToVehicles(List<Vehicle> vehicles) => _fit?.call(vehicles);
}

class MonitoringMap extends StatefulWidget {
  final List<Vehicle> vehicles;
  final bool showPlate;
  final MonitoringMapController? controller;

  const MonitoringMap({
    super.key,
    required this.vehicles,
    required this.showPlate,
    this.controller,
  });

  @override
  State<MonitoringMap> createState() => _MonitoringMapState();
}

class _MonitoringMapState extends State<MonitoringMap> {
  late final MapController _mapController = MapController();

  static const LatLng _indonesiaCenter = LatLng(-2.5, 115.0);
  static const InteractionOptions _interaction = InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
  );

  List<Marker> _cachedMarkers = const [];
  int _cacheKey = 0;

  void fitToVehicles(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) return;

    if (vehicles.length == 1) {
      final v = vehicles.first;
      _mapController.move(LatLng(v.latitude, v.longitude), 16);
      return;
    }

    final lats = vehicles.map((e) => e.latitude);
    final lngs = vehicles.map((e) => e.longitude);

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(60, 160, 60, 120),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MonitoringMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._fit = null;
      widget.controller?._fit = fitToVehicles;
    }

    _rebuildMarkersIfNeeded();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._fit = fitToVehicles;
    _rebuildMarkersIfNeeded();
  }

  void _rebuildMarkersIfNeeded() {
    final vehicles = widget.vehicles;
    int roundedBearing(double b) => ((b / 5).round() * 5) % 360;

    final key = Object.hash(
      widget.showPlate,
      vehicles.length,
      Object.hashAll(
        vehicles.map(
          (v) => Object.hash(
            v.id,
            v.latitude,
            v.longitude,
            roundedBearing(v.bearing),
            v.activity,
            v.deviceTime,
            v.ignition,
            v.licensePlate,
            v.vehicleCategoryIcon,
          ),
        ),
      ),
    );

    if (key == _cacheKey) return;
    _cacheKey = key;

    _cachedMarkers = vehicles
        .map((v) {
          debugPrint('data vehicle : "$v"');

          return Marker(
            point: LatLng(v.latitude, v.longitude),
            width: 110,
            height: widget.showPlate ? 85 : 65,
            rotate: false,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.vehicleDetailScreen,
                  // Ikut dikirim data yang sudah ada di marker ini supaya
                  // layar detail bisa langsung tampil tanpa menunggu API.
                  arguments: VehicleDetailArgs(
                    id: v.vehicleId.isNotEmpty ? v.vehicleId : v.id,
                    licensePlate: v.licensePlate,
                    fleetGroupName: v.fleetGroupName,
                    latitude: v.latitude,
                    longitude: v.longitude,
                    direction: v.bearing,
                    activity: v.activity,
                    ignition: v.ignition,
                    deviceTime: v.deviceTime,
                    vehicleCategoryIcon: v.vehicleCategoryIcon,
                  ),
                );
              },
              child: Transform.translate(
                offset: widget.showPlate ? const Offset(0, -17) : Offset.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showPlate) _PlateBubble(text: v.licensePlate),
                    const SizedBox(height: 2),
                    VehicleMarkerIcon(
                      iconUrl: v.vehicleCategoryIcon,
                      activity: v.activity,
                      bearingDeg: roundedBearing(v.bearing).toDouble(),
                    ),
                  ],
                ),
              ),
            ),
          );
        })
        .toList(growable: false);
  }

  @override
  void dispose() {
    widget.controller?._fit = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rebuildMarkersIfNeeded();

    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: _indonesiaCenter,
        initialZoom: 5,
        maxZoom: 18,
        minZoom: 3,
        interactionOptions: _interaction,
      ),
      children: [
        TileLayer(
          // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: AppBranding.mapUserAgentPackageName,
          // key: '',
          urlTemplate: googleMapUrl,
          subdomains: googleMapSubdomains,
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 120,
            size: const Size(40, 40),
            rotate: false,
            polygonOptions: const PolygonOptions(
              borderColor: Colors.transparent,
              color: Colors.transparent,
              borderStrokeWidth: 0,
            ),
            builder: (context, markers) {
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppStyles.blueColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  markers.length.toString(),
                  style: AppStyles.textMd.copyWith(color: AppStyles.whiteColor),
                ),
              );
            },
            markers: _cachedMarkers,
          ),
        ),
      ],
    );
  }
}

class _PlateBubble extends StatelessWidget {
  final String text;
  const _PlateBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: AppStyles.blackColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppStyles.textXsBold.copyWith(color: AppStyles.whiteColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
