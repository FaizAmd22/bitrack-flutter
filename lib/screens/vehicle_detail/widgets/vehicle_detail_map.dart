import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VehicleDetailMap extends StatefulWidget {
  const VehicleDetailMap({super.key});

  @override
  State<VehicleDetailMap> createState() => _VehicleDetailMapState();
}

class _VehicleDetailMapState extends State<VehicleDetailMap> {
  late final MapController _mapController = MapController();

  static const LatLng _indonesiaCenter = LatLng(-2.5, 115.0);
  static const InteractionOptions _interaction = InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
  );

  @override
  Widget build(BuildContext context) {
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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
      ],
    );
  }
}
