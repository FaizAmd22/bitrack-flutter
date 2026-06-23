import 'dart:async';

import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:ams/screens/notification/services/notification_service.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_address.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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

class NotificationState {
  final bool isLoading;
  final NotificationListState list;
  final NotificationFilter filter;
  final String search;

  const NotificationState({
    required this.isLoading,
    required this.list,
    required this.filter,
    required this.search,
  });

  factory NotificationState.initial() => NotificationState(
    isLoading: false,
    list: NotificationListState.initial(),
    filter: const NotificationFilter(),
    search: '',
  );

  NotificationState copyWith({
    bool? isLoading,
    NotificationListState? list,
    NotificationFilter? filter,
    String? search,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      filter: filter ?? this.filter,
      search: search ?? this.search,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._service) : super(NotificationState.initial());

  final NotificationService _service;

  // Guard: cegah refresh beruntun yang memicu loading terus-menerus.
  DateTime? _lastRefresh;

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
  }

  Future<void> loadMore() async {
    final list = state.list;
    if (list.isLoadingMore || !list.hasMore) return;

    state = state.copyWith(list: list.copyWith(isLoadingMore: true));

    await _loadPage(page: list.page + 1, existing: list.items);
  }

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

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier(ref.watch(notificationServiceProvider));
    });
