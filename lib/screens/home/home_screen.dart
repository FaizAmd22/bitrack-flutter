// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/features/monitoring/providers/fleet_geofence_provider.dart';
import 'package:bitrack_mobile_flutter/features/monitoring/providers/monitoring_providers.dart';
import 'package:bitrack_mobile_flutter/screens/home/models/filter_model.dart';
import 'package:bitrack_mobile_flutter/screens/home/models/vehicle.dart';
import 'package:bitrack_mobile_flutter/screens/home/widgets/filter_tracker_bottom_sheet.dart';
import 'package:bitrack_mobile_flutter/screens/home/widgets/monitoring_map.dart';
import 'package:bitrack_mobile_flutter/screens/home/widgets/monitoring_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedActivity = 'allVehicle';

  String? _searchQuery;
  String? _debouncedQuery;
  Timer? _debounce;

  bool _showPlate = false;

  List<String> _cachedSuggestionPlates = const [];
  int _lastVehiclesHash = 0;

  // ===== tempat tampung hasil selection =====
  FilterOption _selectedFilterType = const FilterOption(
    value: null,
    label: 'Pilih jenis filter',
  );

  FilterOption _selectedFleetGroup = const FilterOption(
    value: null,
    label: 'Semua Fleet Group',
  );

  FilterOption _selectedGeofence = const FilterOption(
    value: null,
    label: 'Semua Geofence',
  );

  // FINAL id yang dipakai nanti untuk filter map/request
  String? selectedFleetgroupId;
  String? selectedGeofenceId;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _debouncedQuery = val);
    });
  }

  List<FilterOption> _buildFleetGroupOptionsFromMonitoring(
    List<Vehicle> vehicles,
  ) {
    final seen = <String>{};
    final out = <FilterOption>[];

    for (final v in vehicles) {
      final name = v.fleetGroupName.trim();
      if (name.isEmpty) continue;

      if (seen.add(name)) {
        // ✅ sama seperti React: value = fleet_group_name
        out.add(FilterOption(value: name, label: name));
      }
    }

    return [
      const FilterOption(value: null, label: 'Semua Fleet Group'),
      ...out,
    ];
  }

  List<FilterOption> _buildGeofenceOptions(Map<String, dynamic> result) {
    final raw = result['data'];
    final List list = raw is List ? raw : const [];

    final out = <FilterOption>[];

    for (final item in list) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);

      final geos = m['geofence'];
      if (geos is! List) continue;

      for (final g in geos) {
        if (g is! Map) continue;
        final gm = Map<String, dynamic>.from(g);

        final id = (gm['geofence_id'] ?? gm['id'] ?? '').toString().trim();
        final name = (gm['geofence_name'] ?? gm['name'] ?? '')
            .toString()
            .trim();

        if (id.isEmpty || name.isEmpty) continue;
        out.add(FilterOption(value: id, label: name));
      }
    }

    final seen = <String>{};
    final unique = out.where((e) => e.value != null && seen.add(e.value!));

    return [
      const FilterOption(value: null, label: 'Semua Geofence'),
      ...unique,
    ];
  }

  Future<void> _openFilterSheet(List<Vehicle> currentVehicles) async {
    // ✅ Fleet Group dari Monitoring (Framework7 style)
    final fleetGroups = _buildFleetGroupOptionsFromMonitoring(currentVehicles);

    // ✅ Geofence tetap dari API child/fleet-group
    Map<String, dynamic> dataAsync;
    try {
      dataAsync = await ref.read(fleetGeofenceProvider.future);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      return;
    }

    final geofences = _buildGeofenceOptions(dataAsync);

    final result = await FilterTrackerBottomSheet.open(
      context,
      fleetGroups: fleetGroups,
      geofences: geofences,
      initialType: _selectedFilterType,
      initialFleetGroup: _selectedFleetGroup,
      initialGeofence: _selectedGeofence,
    );

    if (!mounted) return;
    if (result == null) return;

    setState(() {
      _selectedFilterType = result.selectedType;
      _selectedFleetGroup = result.selectedFleetGroup;
      _selectedGeofence = result.selectedGeofence;

      // ✅ karena value fleetgroup = NAME, bukan id
      selectedFleetgroupId = _selectedFleetGroup.value;
      selectedGeofenceId = _selectedGeofence.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monitoringAsync = ref.watch(monitoringProvider(_selectedActivity));
    final rawVehicles = monitoringAsync.asData?.value ?? const <Vehicle>[];

    // cache suggestion plates
    final currentHash = Object.hashAll(rawVehicles.map((e) => e.licensePlate));
    if (currentHash != _lastVehiclesHash) {
      _lastVehiclesHash = currentHash;
      _cachedSuggestionPlates = rawVehicles
          .map((v) => v.licensePlate)
          .where((p) => p.isNotEmpty)
          .toList(growable: false);
    }

    List<Vehicle> _filterVehicles(
      List<Vehicle> source, {
      String? search,
      String? fleetGroupName,
      String? geofenceId,
    }) {
      Iterable<Vehicle> out = source;

      // search by plate
      final q = (search ?? '').trim();
      if (q.isNotEmpty) {
        final needle = q.toLowerCase();
        out = out.where((v) => v.licensePlate.toLowerCase().startsWith(needle));
      }

      // ✅ Fleet group filter (by name)
      if (fleetGroupName != null && fleetGroupName.trim().isNotEmpty) {
        final fg = fleetGroupName.trim();
        out = out.where((v) => v.fleetGroupName.trim() == fg);
      }

      // ⚠️ Geofence filter:
      // kendaraan dari monitoring endpoint biasanya tidak punya geofence_id langsung.
      // jadi kalau monitoring data kamu tidak punya geofence_id, filter ini tidak bisa dilakukan dari list vehicles saja.
      // Kalau ada field geofence_id di JSON monitoring, baru bisa:
      //
      // if (geofenceId != null && geofenceId.trim().isNotEmpty) {
      //   out = out.where((v) => v.geofenceId == geofenceId);
      // }

      return out.toList(growable: false);
    }

    final filteredVehicles = _filterVehicles(
      rawVehicles,
      search: _debouncedQuery,
      fleetGroupName: selectedFleetgroupId,
      geofenceId: selectedGeofenceId,
    );

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: MonitoringMap(
              vehicles: filteredVehicles,
              showPlate: _showPlate,
            ),
          ),

          if (monitoringAsync.isLoading)
            const Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),

          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: MonitoringSearchBar(
              searchQuery: _searchQuery,
              onSearchChanged: _onSearchChanged,
              selectedActivity: _selectedActivity,
              onActivityChanged: (value) {
                setState(() {
                  _selectedActivity = value;
                  _searchQuery = '';
                  _debouncedQuery = '';
                });
              },
              totalVehicle: rawVehicles.length,
              suggestionPlates: _cachedSuggestionPlates,
              onTapFilter: () => _openFilterSheet(rawVehicles),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 24,
            child: _TogglePlateButton(
              showPlate: _showPlate,
              onTap: () => setState(() => _showPlate = !_showPlate),
            ),
          ),

          if (monitoringAsync.hasError)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: Text(
                monitoringAsync.error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
                textAlign: TextAlign.center,
                style: AppStyles.textSm.copyWith(color: AppStyles.primaryColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _TogglePlateButton extends StatelessWidget {
  final bool showPlate;
  final VoidCallback onTap;

  const _TogglePlateButton({required this.showPlate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = showPlate
        ? AppStyles.primaryColor
        : AppStyles.whiteColor.withOpacity(0.5);
    final fgColor = showPlate ? AppStyles.primaryColor : AppStyles.blackColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppStyles.whiteColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppStyles.blackColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showPlate ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: fgColor,
            ),
            const SizedBox(width: 8),
            Text(
              showPlate ? 'Hide Plate' : 'Show Plate',
              style: AppStyles.textMd.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}
