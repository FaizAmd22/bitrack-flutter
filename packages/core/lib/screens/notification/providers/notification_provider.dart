import 'dart:async';

import 'package:bitrack_core/screens/notification/models/alert_model.dart';
import 'package:bitrack_core/screens/notification/services/notification_service.dart';
import 'package:bitrack_core/screens/vehicle_detail/services/fetch_address.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Filter daftar notifikasi. Field `...Label` hanya untuk ditampilkan di
/// UI; yang dikirim ke API adalah nilai tanpa `Label`.
class NotificationFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? fleetGroup;
  final String? fleetGroupLabel;
  final String? status;
  final String? statusLabel;
  final String? alertType;
  final String? alertTypeLabel;

  const NotificationFilter({
    this.startDate,
    this.endDate,
    this.fleetGroup,
    this.fleetGroupLabel,
    this.status,
    this.statusLabel,
    this.alertType,
    this.alertTypeLabel,
  });

  /// Catatan: field `...Label` tidak ikut disalin (menjadi null).
  NotificationFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? fleetGroup,
    String? status,
    String? alertType,
  }) {
    return NotificationFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      fleetGroup: fleetGroup ?? this.fleetGroup,
      status: status ?? this.status,
      alertType: alertType ?? this.alertType,
    );
  }

  NotificationFilter clear() => const NotificationFilter();
}

/// Isi daftar notifikasi yang sudah dimuat (halaman 1 sampai [page]).
class NotificationListState {
  final List<AlertModel> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final int total;

  const NotificationListState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.total,
  });

  factory NotificationListState.initial() => const NotificationListState(
    items: [],
    page: 1,
    hasMore: true,
    isLoadingMore: false,
    total: 0,
  );

  NotificationListState copyWith({
    List<AlertModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    int? total,
  }) {
    return NotificationListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      total: total ?? this.total,
    );
  }
}

/// Seluruh state halaman Notifikasi: daftar, filter, teks cari, dan angka
/// badge.
class NotificationState {
  final bool isLoading;
  final NotificationListState list;
  final NotificationFilter filter;
  final String search;
  // Total notif keseluruhan (tanpa filter apapun), dipakai khusus untuk badge
  // di bottom nav supaya tidak ikut berubah saat user memfilter di halaman ini.
  final int badgeTotal;

  const NotificationState({
    required this.isLoading,
    required this.list,
    required this.filter,
    required this.search,
    required this.badgeTotal,
  });

  factory NotificationState.initial() => NotificationState(
    isLoading: false,
    list: NotificationListState.initial(),
    filter: const NotificationFilter(),
    search: '',
    badgeTotal: 0,
  );

  NotificationState copyWith({
    bool? isLoading,
    NotificationListState? list,
    NotificationFilter? filter,
    String? search,
    int? badgeTotal,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      filter: filter ?? this.filter,
      search: search ?? this.search,
      badgeTotal: badgeTotal ?? this.badgeTotal,
    );
  }
}

/// Logika halaman Notifikasi: muat ulang, muat halaman berikutnya (infinite
/// scroll), angka badge, dan pengisian alamat tiap alert.
///
/// Tidak ada polling: [refresh] dipanggil saat tab Notifikasi dibuka, saat
/// pull-to-refresh, dan saat filter/cari berubah.
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._service) : super(NotificationState.initial());

  final NotificationService _service;

  // Guard: cegah refresh beruntun yang memicu loading terus-menerus.
  DateTime? _lastRefresh;

  /// Muat ulang dari halaman 1, lalu tandai semua sudah dibaca dan perbarui
  /// badge. Tanpa [force], diabaikan bila refresh terakhir kurang dari 3 detik
  /// lalu.
  Future<void> refresh({
    String? search,
    NotificationFilter? filter,
    bool force = false,
  }) async {
    // Cegah refresh beruntun (kecuali force: pull-to-refresh, ganti filter, ganti search).
    if (!force) {
      final now = DateTime.now();
      if (_lastRefresh != null &&
          now.difference(_lastRefresh!) < const Duration(seconds: 3)) {
        debugPrint('>>> refresh SKIPPED (too soon)');
        return;
      }
    }

    // Guard: skip jika refresh sedang berjalan.
    if (state.isLoading) return;

    _lastRefresh = DateTime.now();

    final s = search ?? state.search;
    final f = filter ?? state.filter;

    state = state.copyWith(
      isLoading: true,
      search: s,
      filter: f,
      list: NotificationListState.initial(),
    );

    try {
      await _loadPage(page: 1, existing: const []).timeout(
        const Duration(seconds: 30),
      );
    } on TimeoutException {
      debugPrint('notification refresh: timed out after 30s');
    } catch (e) {
      debugPrint('notification refresh error: $e');
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }

    if (mounted) _service.markAllAsRead().ignore();
    unawaited(refreshBadgeTotal());
  }

  // Selalu fetch tanpa filter/search supaya badge di bottom nav menampilkan
  // jumlah notif keseluruhan, terlepas dari filter yang aktif di halaman ini.
  Future<void> refreshBadgeTotal() async {
    try {
      final result = await _service.fetchAlerts(page: 1);
      if (!mounted) return;
      state = state.copyWith(badgeTotal: result.total);
    } catch (e) {
      debugPrint('refreshBadgeTotal error: $e');
    }
  }

  /// Muat halaman berikutnya (dipanggil saat daftar di-scroll sampai bawah).
  Future<void> loadMore() async {
    final list = state.list;
    if (list.isLoadingMore || !list.hasMore) return;

    state = state.copyWith(list: list.copyWith(isLoadingMore: true));

    await _loadPage(page: list.page + 1, existing: list.items);
  }

  /// Ambil satu halaman, gabungkan dengan [existing], lalu isi alamatnya di
  /// latar belakang. Item yang gagal di-parse diganti AlertModel kosong.
  Future<void> _loadPage({
    required int page,
    required List<AlertModel> existing,
  }) async {
    try {
      final filter = state.filter;
      final search = state.search;

      final result = await _service.fetchAlerts(
        page: page,
        startDate: filter.startDate,
        endDate: filter.endDate,
        eventType: filter.alertType,
        fleetGroupId: filter.fleetGroup,
        status: filter.status,
        licensePlate: search.isNotEmpty ? search : null,
      );

      debugPrint(
        '>>> _loadPage page=$page rawCount=${result.items.length} '
        'totalPages=${result.totalPages}',
      );

      final newItems = result.items.map((e) {
        try {
          return AlertModel.fromJson(e as Map<String, dynamic>);
        } catch (_) {
          return const AlertModel();
        }
      }).toList();

      if (!mounted) return;

      final merged = [...existing, ...newItems];
      final hasMore = result.page < result.totalPages;

      state = state.copyWith(
        list: state.list.copyWith(
          items: merged,
          page: result.page,
          hasMore: hasMore,
          isLoadingMore: false,
          total: result.total,
        ),
      );

      unawaited(_attachAddressesParallel(newItems, offset: existing.length));
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(list: state.list.copyWith(isLoadingMore: false));
    }
  }

  /// Isi alamat tiap alert lewat reverse geocoding secara paralel. Setiap
  /// alamat dipasang hanya kalau item di posisi itu masih alert yang sama
  /// (daftar bisa sudah dimuat ulang saat alamat datang).
  Future<void> _attachAddressesParallel(
    List<AlertModel> items, {
    required int offset,
  }) async {
    final futures = items.map((item) async {
      if (item.latitude == null || item.longitude == null) return null;
      try {
        return await getAddress(item.latitude!, item.longitude!);
      } catch (_) {
        return '-';
      }
    }).toList();

    final addresses = await Future.wait(futures);

    if (!mounted) return;

    for (int i = 0; i < items.length; i++) {
      final address = addresses[i];
      if (address == null) continue;

      final idx = offset + i;
      final current = List<AlertModel>.from(state.list.items);
      if (idx < current.length && current[idx].id == items[i].id) {
        current[idx] = current[idx].copyWith(address: address);
        state = state.copyWith(list: state.list.copyWith(items: current));
      }
    }
  }
}

/// Service API notifikasi (bisa diganti versi palsu di tes).
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// State halaman Notifikasi + badge di bottom navigation. Di-invalidate saat
/// login/logout supaya tidak membawa data user sebelumnya.
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier(ref.watch(notificationServiceProvider));
    });
