// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:bitrack_core/base/network/api_response.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/routes/navigation_service.dart';
import 'package:bitrack_core/base/widgets/full_screen_loading.dart';
import 'package:bitrack_core/base/widgets/search_bar_base.dart';
import 'package:bitrack_core/features/monitoring/providers/monitoring_providers.dart';
import 'package:bitrack_core/features/monitoring/providers/plate_suggestion_provider.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/home/models/filter_model.dart';
import 'package:bitrack_core/screens/home/models/vehicle.dart';
import 'package:bitrack_core/screens/home/widgets/activity_chips.dart';
import 'package:bitrack_core/screens/home/widgets/filter_tracker_bottom_sheet.dart';
import 'package:bitrack_core/screens/home/widgets/monitoring_map.dart';
import 'package:bitrack_core/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Samakan dengan Cordova (setInterval 30 detik). Sebelumnya 10 detik, dan
// karena satu siklus refresh bisa memakan waktu lebih lama dari itu, request
// menumpuk dan overlay loading tidak pernah sempat mati.
const _pollInterval = Duration(seconds: 30);

class HomeScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const HomeScreen({super.key, required this.isActive});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  String _selectedActivity = 'allVehicle';

  String? _searchQuery;
  String? _debouncedQuery;
  Timer? _debounce;
  Timer? _polling;

  bool _showPlate = false;

  final MonitoringMapController _mapController = MonitoringMapController();

  FilterOption? _selectedFilterType;
  FilterOption? _selectedFleetGroup;
  FilterOption? _selectedGeofence;

  String? selectedFleetgroupId;
  String? selectedGeofenceId;

  bool _showLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    if (widget.isActive) {
      _startPolling();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load(showLoading: true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _startPolling();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refresh(showLoading: true, fitCamera: false);
        });
      } else {
        _stopPolling();
      }
    }
  }

  void _startPolling() {
    _polling?.cancel();
    // fitCamera: false — polling cuma memperbarui posisi marker. Kamera
    // dibiarkan di mana pun user menaruhnya (lihat [_load]).
    _polling = Timer.periodic(_pollInterval, (_) => _refresh(fitCamera: false));
  }

  void _stopPolling() {
    _polling?.cancel();
    _polling = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      // subscribe memakai Set, jadi aman dipanggil berulang kali.
      NavigationService.routeObserver.subscribe(this, route);
    }
  }

  /// Ada layar lain yang menimbun HomeScreen (mis. Vehicle Detail).
  ///
  /// State ini tidak di-dispose, jadi tanpa penghentian eksplisit timer-nya
  /// terus menembak `/monitoring/` + `/monitoring/position` — dua request
  /// daftar SELURUH kendaraan tiap 30 detik — sementara layar di atasnya
  /// sedang menunggu response dari server yang sama.
  @override
  void didPushNext() => _stopPolling();

  /// Layar di atas sudah ditutup dan HomeScreen terlihat lagi.
  ///
  /// Selain menyalakan ulang timer, sekalian refresh sekali supaya posisi
  /// marker tidak tertinggal sampai tick berikutnya (bisa 30 detik lagi).
  @override
  void didPopNext() {
    if (!mounted || !widget.isActive) return;
    _startPolling();
    _refresh(fitCamera: false);
  }

  @override
  void dispose() {
    NavigationService.routeObserver.unsubscribe(this);
    _stopPolling();
    _debounce?.cancel();
    super.dispose();
  }

  // Filter yang dikirim ke server. Search dan fleet group ditangani
  // /monitoring (license_plate, fleet_group_ids) dan /monitoring/position
  // (license_plate, fleet_group_id).
  MonitoringFilter _currentFilter() {
    final term = (_debouncedQuery ?? '').trim();
    return MonitoringFilter(
      licensePlate: term.isEmpty ? null : term,
      fleetGroupId: selectedFleetgroupId,
    );
  }

  MonitoringQuery _currentQuery() =>
      MonitoringQuery(activity: _selectedActivity, filter: _currentFilter());

  // Saran plat tidak ikut menyempit saat user mengetik, tapi tetap mengikuti
  // filter fleet group yang aktif.
  MonitoringFilter _suggestionFilter() =>
      MonitoringFilter(fleetGroupId: selectedFleetgroupId);

  /// Sudah pernah memaskan kamera ke armada, minimal sekali. Dipakai sebagai
  /// jaring pengaman `fitCamera: false` — lihat [_load].
  bool _hasFittedCamera = false;

  /// Baca data untuk query aktif, dan (opsional) pas-kan peta ke hasilnya.
  ///
  /// [fitCamera] memisahkan "ambil data baru" dari "geser kamera". Kamera
  /// hanya boleh dipaskan pada aksi yang memang mengubah kumpulan kendaraan
  /// yang sedang dilihat user: load pertama, ganti kata kunci, ganti filter,
  /// ganti activity. Polling 30 detik TIDAK termasuk — sebelumnya polling ikut
  /// memanggil fitToVehicles(), jadi pan/zoom user dibatalkan sendiri tiap
  /// setengah menit dan peta melompat balik ke bounding box seluruh armada.
  ///
  /// Overlay loading dimatikan di blok finally supaya tidak pernah tersangkut:
  /// sebelumnya ia bergantung pada `monitoringAsync.isLoading` di build(),
  /// yang terus di-reset oleh polling sehingga kondisinya tidak pernah
  /// terpenuhi.
  Future<void> _load({bool showLoading = false, bool fitCamera = true}) async {
    if (showLoading && mounted) setState(() => _showLoading = true);

    try {
      final data = await ref.read(monitoringProvider(_currentQuery()).future);
      if (!mounted) return;

      final vehicles = _sanitizeVehicles(data.vehicles);
      // `!_hasFittedCamera` menjaga kasus kamera belum pernah dipaskan sama
      // sekali — load pertama gagal, atau saat itu hasilnya kosong. Tanpa ini
      // peta bisa tertinggal di posisi awal (tengah Indonesia, zoom 5) dengan
      // marker berserakan di luar layar, karena polling sesudahnya tidak
      // pernah boleh menggeser kamera. Berlaku sekali saja.
      if ((fitCamera || !_hasFittedCamera) && vehicles.isNotEmpty) {
        _mapController.fitToVehicles(vehicles);
        _hasFittedCamera = true;
      }
    } catch (_) {
      // Error tetap ditampilkan lewat monitoringAsync.hasError di build().
    } finally {
      if (mounted && _showLoading) setState(() => _showLoading = false);
    }
  }

  /// Tarik ulang dari server. Dilewati kalau siklus sebelumnya belum selesai,
  /// supaya request tidak menumpuk saat armada besar.
  Future<void> _refresh({
    bool showLoading = false,
    bool fitCamera = true,
  }) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      ref.invalidateMonitoring();
      await _load(showLoading: showLoading, fitCamera: fitCamera);
    } finally {
      _isRefreshing = false;
    }
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _debouncedQuery = val);
      _load();
    });
  }

  List<FilterOption> _buildFleetGroupOptions(
    List<Map<String, dynamic>> fleetGroups,
  ) {
    final out = <FilterOption>[
      FilterOption(
        value: null,
        label: AppLocalizations.of(context).filterAllFleetGroup,
      ),
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
    // Geofence belum bisa dipilih sebagai jenis filter (lihat _typeOptions
    // di filter_tracker_bottom_sheet.dart), jadi tidak perlu data geofence.
    final geofences = <FilterOption>[
      FilterOption(
        value: null,
        label: AppLocalizations.of(context).filterAllGeofence,
      ),
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

      selectedFleetgroupId = result.selectedFleetGroup.value;
      selectedGeofenceId = result.selectedGeofence.value;
    });

    await _load(showLoading: true);
  }

  // Hygiene data saja (dedup, koordinat invalid, plat kosong). Search dan
  // fleet group sudah difilter server-side, activity sudah difilter lewat
  // daftar plat dari /monitoring.
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

  List<Vehicle> _lastMapVehicles = const [];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final monitoringAsync = ref.watch(monitoringProvider(_currentQuery()));
    final suggestionPlates = ref.watch(
      plateSuggestionProvider(_suggestionFilter()),
    );

    final data = monitoringAsync.asData?.value;
    if (data != null) _lastMapVehicles = data.vehicles;

    final filteredVehicles = _sanitizeVehicles(
      data?.vehicles ?? _lastMapVehicles,
    );

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
              hintText: t.searchLicensePlate,
              suggestionPlates: suggestionPlates,
              onOpenFilter: (_) => _openFilterSheet(fleetGroupOptions),
              below: ActivityChips(
                selectedActivity: _selectedActivity,
                // Angka dari server (metadata.summary), bukan jumlah marker
                // yang lolos sanitasi — supaya sama dengan Cordova/web.
                totalVehicle: data?.total ?? filteredVehicles.length,
                onActivityChanged: (value) {
                  setState(() {
                    _selectedActivity = value;
                    _searchQuery = '';
                    _debouncedQuery = '';
                  });
                  // Ganti activity hanya menyentuh /monitoring; cache
                  // /monitoring/position dipakai ulang karena provider posisi
                  // tidak di-key oleh activity.
                  _load(showLoading: true);
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
                apiErrorText(monitoringAsync.error!, t.failedLoadData),
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
