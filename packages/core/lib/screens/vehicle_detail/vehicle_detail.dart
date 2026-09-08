// ignore_for_file: deprecated_member_use

import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'dart:async';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/back_button_circle.dart';
import 'package:bitrack_core/base/widgets/full_screen_loading.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/vehicle_detail/models/vehicle_detail_args.dart';
import 'package:bitrack_core/screens/vehicle_detail/providers/vehicle_information_provider.dart';
import 'package:bitrack_core/screens/vehicle_detail/services/fetch_address.dart';
import 'package:bitrack_core/screens/vehicle_detail/services/fetch_monitoring_detail.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/flatten_monitoring_detail.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/vehicle_detail_safety.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/vehicle_detail_content.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/vehicle_realtime_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

const _detailInterval = Duration(seconds: 10);

/// Batas atas jeda polling saat request gagal beruntun.
///
/// Endpoint /monitoring bisa memakan belasan detik dan kadang timeout. Terus
/// menembaknya tiap 10 detik hanya menambah beban server yang sudah kepayahan,
/// dan memperbesar peluang timeout berikutnya.
const _maxDetailInterval = Duration(seconds: 60);

class VehicleDetail extends ConsumerStatefulWidget {
  const VehicleDetail({super.key});

  @override
  ConsumerState<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends ConsumerState<VehicleDetail> {
  final _api = const FetchMonitoringDetail();

  String _detailId = '';
  late Future<Map<String, dynamic>> _future;
  bool _initialized = false;

  LatLng? _coordinate;
  double _direction = 0;
  Map<String, dynamic> _detailData = {};

  /// False selama _detailData masih berisi data awal dari layar pemanggil.
  /// Dipakai VehicleDetailContent untuk memutuskan field mana yang diganti
  /// skeleton. Tidak diambil dari snapshot FutureBuilder supaya polling yang
  /// berhasil juga ikut menandainya.
  bool _hasApiData = false;

  Timer? _detailTimer;
  bool _detailFetchInFlight = false;
  Duration _nextPollDelay = _detailInterval;

  /// Request terakhir gagal padahal layar sudah punya data untuk ditampilkan.
  /// Dipakai untuk memunculkan banner "coba lagi" TANPA membuang data itu.
  bool _loadFailed = false;

  String _address = '-';
  bool _loadingAddress = false;
  double? _lastLat;
  double? _lastLng;

  @override
  void dispose() {
    _detailTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    // String tetap diterima supaya pemanggil lama (dan deep link) tidak rusak;
    // VehicleDetailArgs menambahkan data awal untuk dipaint lebih dulu.
    final VehicleDetailArgs? detailArgs = args is VehicleDetailArgs
        ? args
        : null;
    final id = (detailArgs?.id ?? (args is String ? args : '')).trim();
    _detailId = id;

    if (detailArgs != null) {
      _detailData = detailArgs.toSeedData();
      if (detailArgs.hasCoordinate) {
        _coordinate = LatLng(detailArgs.latitude!, detailArgs.longitude!);
        _direction = detailArgs.direction;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(vehicleIdProvider.notifier).state = id.isEmpty ? null : id;

      // Dikosongkan saat MASUK, bukan saat keluar. Mengosongkannya di
      // dispose() menciptakan balapan — dispose layar lama bisa berjalan
      // setelah layar baru mengisi cache — dan tetap membiarkan sisa data
      // kunjungan sebelumnya terpakai kalau kendaraan yang sama dibuka lagi.
      // Dengan dibersihkan di sini, cache hanya berisi response milik
      // kunjungan ini.
      ref.read(vehicleDashboardCacheProvider.notifier).state = null;

      // Alamat ikut dicari dari koordinat seed, jadi baris alamat tidak perlu
      // menunggu response detail selesai lebih dulu.
      final seeded = _coordinate;
      if (seeded != null) {
        _onCoordinateReady(seeded.latitude, seeded.longitude);
      }
    });

    _future = _detailId.isNotEmpty
        ? _loadInitial()
        : Future.error(Exception(currentL10n().failedLoadData));

    _initialized = true;
  }

  Map<String, dynamic> _flattenDetail(Map<String, dynamic> data) =>
      flattenMonitoringDetail(data, detailId: _detailId);

  /// Membagikan data DASHBOARD ke sheet Informasi supaya sheet itu tidak
  /// menembak ulang endpoint yang sama. Dipanggil di luar setState karena
  /// mengubah provider saat build sedang berjalan tidak diperbolehkan.
  void _publishDashboardCache(Map<String, dynamic> detail) {
    ref.read(vehicleDashboardCacheProvider.notifier).state = detail;
  }

  Future<Map<String, dynamic>> _loadInitial() async {
    // Diukur di level layar, bukan cuma di interceptor: angka ini mencakup
    // parsing, logging, dan antrean UI. Selisihnya terhadap angka [API]
    // menunjukkan berapa lama yang habis DI LUAR jaringan.
    final started = DateTime.now();
    final Map<String, dynamic> raw;
    try {
      raw = await _api.getDetail(_detailId);
    } catch (_) {
      // Ditandai supaya layar bisa memunculkan banner "coba lagi" sambil
      // tetap menampilkan data awal, bukan menggantinya dengan layar error.
      if (mounted) setState(() => _loadFailed = true);
      rethrow;
    }
    final detail = _flattenDetail(raw);
    debugPrint(
      '[DETAIL] data siap tampil dalam '
      '${DateTime.now().difference(started).inMilliseconds}ms',
    );

    if (mounted) {
      final lat = _toDouble(detail['latitude']);
      final lng = _toDouble(detail['longitude']);
      setState(() {
        if (lat != null && lng != null) {
          _coordinate = LatLng(lat, lng);
          _direction = _toDouble(detail['direction']) ?? 0;
        }
        _detailData = detail;
        _hasApiData = true;
        _loadFailed = false;
        _nextPollDelay = _detailInterval;
      });

      _publishDashboardCache(detail);

      if (lat != null && lng != null) {
        _onCoordinateReady(lat, lng);
      }
    }

    _startDetailPolling();
    return detail;
  }

  /// Menjadwalkan satu poll berikutnya, BUKAN Timer.periodic.
  ///
  /// Timer.periodic menembak tiap 10 detik tanpa peduli request sebelumnya
  /// selesai atau belum. Ketika satu request memakan 15 detik, tick berikutnya
  /// sudah menunggu begitu request itu kelar — jadi server praktis dihantam
  /// terus-menerus tanpa jeda. Menjadwalkan setelah selesai menjamin ada jeda
  /// nyata di antara dua request.
  void _startDetailPolling() {
    _detailTimer?.cancel();
    if (_detailId.isEmpty) return;
    _detailTimer = Timer(_nextPollDelay, _pollDetailOnce);
  }

  Future<void> _pollDetailOnce() async {
    await _fetchDetailData();
    if (!mounted) return;
    _startDetailPolling();
  }

  Future<void> _fetchDetailData() async {
    if (_detailId.isEmpty) return;

    // /monitoring kerap memakan waktu lebih lama dari _detailInterval.
    // Timer.periodic tetap menembak tiap 10 detik tanpa peduli request
    // sebelumnya sudah selesai atau belum, jadi tanpa penjaga ini request
    // menumpuk: server makin terbebani, dan response lama bisa tiba
    // belakangan lalu menimpa data yang lebih baru.
    if (_detailFetchInFlight) return;
    _detailFetchInFlight = true;

    try {
      final raw = await _api.getDetail(_detailId);
      if (!mounted) return;

      final detail = _flattenDetail(raw);
      final lat = _toDouble(detail['latitude']);
      final lng = _toDouble(detail['longitude']);

      setState(() {
        _detailData = detail;
        _hasApiData = true;
        _loadFailed = false;
        _nextPollDelay = _detailInterval;
        if (lat != null && lng != null) {
          _coordinate = LatLng(lat, lng);
          _direction = _toDouble(detail['direction']) ?? _direction;
        }
      });

      _publishDashboardCache(detail);

      if (lat != null && lng != null) {
        _onCoordinateReady(lat, lng);
      }
    } catch (e) {
      debugPrint('FETCH DETAIL VEHICLE ERROR: $e');
      if (mounted) setState(() => _loadFailed = true);

      final backoff = _nextPollDelay * 2;
      _nextPollDelay = backoff > _maxDetailInterval
          ? _maxDetailInterval
          : backoff;
    } finally {
      _detailFetchInFlight = false;
    }
  }

  /// Coba lagi tanpa mengosongkan layar.
  ///
  /// Berbeda dari [_retry] yang dipakai layar error penuh: di sini sudah ada
  /// data yang berguna di layar, jadi membuangnya untuk memunculkan scrim
  /// justru membuat keadaan lebih buruk.
  void _retryQuietly() {
    setState(() {
      _loadFailed = false;
      _nextPollDelay = _detailInterval;
    });
    _startDetailPolling();
    _fetchDetailData();
  }

  void _retry() {
    setState(() {
      _address = '-';
      _loadingAddress = false;
      _lastLat = null;
      _lastLng = null;
      _coordinate = null;
      _detailData = {};
      _hasApiData = false;
      _loadFailed = false;
      _nextPollDelay = _detailInterval;
      _future = _loadInitial();
    });
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  bool _shouldFetch(double lat, double lng) {
    if (_lastLat == null || _lastLng == null) return true;
    final dLat = (lat - _lastLat!).abs();
    final dLng = (lng - _lastLng!).abs();
    return dLat > 0.0001 || dLng > 0.0001;
  }

  void _onCoordinateReady(double lat, double lng) {
    if (_loadingAddress) return;
    if (!_shouldFetch(lat, lng)) return;
    _fetchAddress(lat, lng);
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    setState(() => _loadingAddress = true);
    final addr = await getAddress(lat, lng);
    if (!mounted) return;
    setState(() {
      _address = addr;
      _loadingAddress = false;
      _lastLat = lat;
      _lastLng = lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final translate = AppLocalizations.of(context);

    final speed = _toDouble(_detailData['speed']) ?? 0.0;
    final activity = _detailData['vehicle_activity']?.toString();

    final livecam = _detailData['livecam'];
    final hasDashcam = livecam is Map;
    final isChiller = safeBoolFrom(_detailData, 'chiller');

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: h * 0.45,
              width: double.infinity,
              child: VehicleRealtimeMap(
                coordinate: _coordinate,
                direction: _direction,
                speed: speed,
                vehicleActivity: activity,
                initialZoom: 15,
                followMarker: true,
              ),
            ),
          ),

          FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              // Scrim penuh hanya kalau benar-benar belum ada yang bisa
              // ditampilkan. Kalau layar pemanggil sudah mengoper data awal,
              // kartu detail langsung tampil dan response API cuma melengkapi
              // field yang belum diketahui.
              final hasSeed = _detailData.isNotEmpty;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !hasSeed) {
                return const Center(child: FullScreenLoading());
              }

              // Kalau layar sudah punya sesuatu untuk ditampilkan, kegagalan
              // TIDAK menggantinya dengan layar error — data yang ada tetap
              // berguna, dan bannernya (di bawah) menawarkan coba lagi.
              if (snapshot.hasError && !hasSeed) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          translate.vehicleDataCantLoaded,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          translate.pleaseTryAgain,
                          style: AppStyles.textSm,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _detailId.isEmpty ? null : _retry,
                          child: Text(translate.tryAgain),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final contentData = hasSeed ? _detailData : snapshot.data!;

              return VehicleDetailContent(
                detailData: contentData,
                address: _address,
                loadingAddress: _loadingAddress,
                hasDashcam: hasDashcam,
                dashcamOnline: hasDashcam,
                isChiller: isChiller,
                loadingDashcam: false,
                loadingDetail: !_hasApiData,
                vehicleData: hasDashcam ? {'dashcam': livecam} : null,
              );
            },
          ),

          // Padding kiri mengosongkan ruang tombol back yang ada di atasnya.
          if (_loadFailed && _detailData.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 72, right: 16, top: 16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _StaleDataBanner(
                    message: translate.vehicleDataCantLoaded,
                    actionLabel: translate.tryAgain,
                    onRetry: _detailId.isEmpty ? null : _retryQuietly,
                  ),
                ),
              ),
            ),

          // Sengaja diletakkan setelah FutureBuilder: di dalam Stack, child
          // yang belakangan digambar paling atas DAN diuji sentuh lebih dulu.
          // Sebelumnya tombol ini ada di bawah overlay loading, yang punya
          // scrim seukuran layar, sehingga tertutup sekaligus tidak bisa
          // ditekan selama data belum datang.
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: BackButtonCircle(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pemberitahuan ringkas bahwa pembaruan terakhir gagal, tanpa menutupi layar.
class _StaleDataBanner extends StatelessWidget {
  const _StaleDataBanner({
    required this.message,
    required this.actionLabel,
    required this.onRetry,
  });

  final String message;
  final String actionLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyles.whiteColor,
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: AppStyles.yellowColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: AppStyles.textSm,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel, style: AppStyles.textSmBold),
            ),
          ],
        ),
      ),
    );
  }
}
