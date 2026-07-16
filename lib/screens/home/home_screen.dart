// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/base/widgets/search_bar_base.dart';
import 'package:ams/features/monitoring/providers/monitoring_providers.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/home/models/filter_model.dart';
import 'package:ams/screens/home/models/vehicle.dart';
import 'package:ams/screens/home/widgets/activity_chips.dart';
import 'package:ams/screens/home/widgets/filter_tracker_bottom_sheet.dart';
import 'package:ams/screens/home/widgets/monitoring_map.dart';
import 'package:ams/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const HomeScreen({super.key, required this.isActive});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedActivity = 'allVehicle';

  String? _searchQuery;
  String? _debouncedQuery;
  Timer? _debounce;
  Timer? _polling;

  bool _showPlate = false;

  final MonitoringMapController _mapController = MonitoringMapController();

  List<String> _cachedSuggestionPlates = const [];
  int _lastVehiclesHash = 0;

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

  String? selectedFleetgroupId;
  String? selectedGeofenceId;

  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _showLoading = widget.isActive;
    if (widget.isActive) _startPolling();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _startPolling();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _showLoading = true);
          ref.invalidate(monitoringProvider);
        });
      } else {
        _stopPolling();
      }
    }
  }

  void _startPolling() {
    _polling?.cancel();
    _polling = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      ref.invalidate(monitoringProvider);
    });
  }

  void _stopPolling() {
    _polling?.cancel();
    _polling = null;
  }

  @override
  void dispose() {
    _stopPolling();
    _debounce?.cancel();
    super.dispose();
  }

  // Query yang dipakai untuk menampilkan posisi kendaraan di peta:
  // search (license_plate) dan fleet group difilter langsung oleh server
  // lewat /monitoring/position, bukan lagi difilter lokal.
  MonitoringQuery _currentMapQuery() {
    final term = (_debouncedQuery ?? '').trim();
    return MonitoringQuery(
      activity: _selectedActivity,
      licensePlate: term.isEmpty ? null : term,
      fleetGroupId: selectedFleetgroupId,
    );
  }

  Future<void> _fitToQuery(MonitoringQuery query) async {
    try {
      final vehicles = await ref.read(monitoringProvider(query).future);
      if (!mounted) return;
      _mapController.fitToVehicles(_sanitizeVehicles(vehicles));
    } catch (_) {
      // Biarkan error ditampilkan lewat monitoringAsync.hasError di build().
    }
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _debouncedQuery = val);
      _fitToQuery(_currentMapQuery());
    });
  }

  List<FilterOption> _buildFleetGroupOptions(
    List<Map<String, dynamic>> fleetGroups,
  ) {
    final out = <FilterOption>[
      const FilterOption(value: null, label: 'Semua Fleet Group'),
    ];

    for (final fg in fleetGroups) {
      final id = (fg['value'] ?? '').toString().trim();
      if (id.isEmpty) continue;
      final name = (fg['label'] ?? '').toString().trim();
      out.add(FilterOption(value: id, label: name.isNotEmpty ? name : id));
    }

    return out;
  }

  Future<void> _openFilterSheet(List<FilterOption> fleetGroups) async {
    // Geofence belum bisa dipilih sebagai jenis filter (lihat _kTypeOptions
    // di filter_tracker_bottom_sheet.dart), jadi tidak perlu data geofence.
    const geofences = <FilterOption>[
      FilterOption(value: null, label: 'Semua Geofence'),
    ];

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

      selectedFleetgroupId = _selectedFleetGroup.value;
      selectedGeofenceId = _selectedGeofence.value;
    });

    await _fitToQuery(_currentMapQuery());
  }

  // Hygiene data saja (dedup, koordinat invalid, plat kosong). Search
  // (license_plate) dan fleet group sudah difilter server-side.
  List<Vehicle> _sanitizeVehicles(List<Vehicle> source) {
    final seen = <String>{};
    final out = <Vehicle>[];

    for (final v in source) {
      // dedup by id
      if (v.id.isEmpty || !seen.add(v.id)) continue;

      // skip koordinat invalid / 0,0 (sama seperti Cordova)
      if (v.latitude.isNaN || v.longitude.isNaN) continue;
      if (v.latitude == 0 || v.longitude == 0) continue;

      // skip plat kosong
      if (v.licensePlate.trim().isEmpty) continue;

      out.add(v);
    }

    return out;
  }

  List<Vehicle> _lastVehicles = const [];
  List<Vehicle> _lastMapVehicles = const [];

  @override
  Widget build(BuildContext context) {
    final rawAsync = ref.watch(
      monitoringProvider(MonitoringQuery(activity: _selectedActivity)),
    );
    final rawVehicles = rawAsync.asData?.value ?? _lastVehicles;

    // Simpan data valid terbaru
    if (rawAsync.asData != null) {
      _lastVehicles = rawAsync.asData!.value;
    }

    final monitoringAsync = ref.watch(monitoringProvider(_currentMapQuery()));
    final mapVehiclesRaw = monitoringAsync.asData?.value ?? _lastMapVehicles;

    if (monitoringAsync.asData != null) {
      _lastMapVehicles = monitoringAsync.asData!.value;
    }

    // Matikan loading begitu request selesai (data ATAU error)
    if (_showLoading && !monitoringAsync.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showLoading) setState(() => _showLoading = false);
      });
    }

    final currentHash = Object.hashAll(rawVehicles.map((e) => e.licensePlate));
    if (currentHash != _lastVehiclesHash) {
      _lastVehiclesHash = currentHash;
      _cachedSuggestionPlates = rawVehicles
          .map((v) => v.licensePlate)
          .where((p) => p.isNotEmpty)
          .toList(growable: false);
    }

    final filteredVehicles = _sanitizeVehicles(mapVehiclesRaw);

    final fleetGroupsAsync = ref.watch(fleetGroupProvider);
    final fleetGroupOptions = _buildFleetGroupOptions(
      fleetGroupsAsync.asData?.value ?? const [],
    );

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: MonitoringMap(
                vehicles: filteredVehicles,
                showPlate: _showPlate,
                controller: _mapController,
              ),
            ),
          ),

          if (_showLoading)
            const Positioned.fill(
              child: IgnorePointer(ignoring: true, child: FullScreenLoading()),
            ),

          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: SearchBarBase(
              value: _searchQuery,
              onChanged: _onSearchChanged,
              hintText: 'Search Vehicle License Plate ...',
              suggestionPlates: _cachedSuggestionPlates,
              onOpenFilter: (_) => _openFilterSheet(fleetGroupOptions),
              below: ActivityChips(
                selectedActivity: _selectedActivity,
                totalVehicle: rawVehicles.length,
                onActivityChanged: (value) {
                  setState(() {
                    _selectedActivity = value;
                    _searchQuery = '';
                    _debouncedQuery = '';
                    _showLoading = true;
                  });
                  ref.invalidate(monitoringProvider);
                  _fitToQuery(_currentMapQuery());
                },
              ),
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
    final translate = AppLocalizations.of(context);

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
              showPlate ? translate.hidePlate : translate.showPlate,
              style: AppStyles.textMd.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}
