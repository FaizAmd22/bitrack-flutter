import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleDetailMap extends StatefulWidget {
  const VehicleDetailMap({super.key});

  @override
  State<VehicleDetailMap> createState() => _VehicleDetailMapState();
}

class _VehicleDetailMapState extends State<VehicleDetailMap> {
  GoogleMapController? _mapController;

  static const LatLng _indonesiaCenter = LatLng(-2.5, 115.0);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _indonesiaCenter,
        zoom: 5,
      ),

      onMapCreated: (controller) {
        _mapController = controller;
      },

      rotateGesturesEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: true,
      myLocationButtonEnabled: false,
      minMaxZoomPreference: const MinMaxZoomPreference(3, 18),
      mapType: MapType.normal,
      markers: {
        Marker(
          markerId: const MarkerId('vehicle'),
          position: LatLng(-6.2, 106.8),
        ),
      },
    );
  }
}
