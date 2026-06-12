import 'dart:async';

import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:ams/screens/notification/services/notification_service.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_address.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

const int _pageSize = 10;

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

class NotificationTabState {
  final List<AlertModel> items;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationTabState({
    required this.items,
    required this.nextPage,
    required this.hasMore,
    required this.isLoadingMore,
  });

  factory NotificationTabState.initial() => const NotificationTabState(
    items: [],
    nextPage: 1,
    hasMore: true,
    isLoadingMore: false,
  );

  NotificationTabState copyWith({
    List<AlertModel>? items,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationTabState(
      items: items ?? this.items,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class NotificationState {
  final bool isLoading;
  final NotificationTabState urgent;
  final NotificationTabState summary;
  final NotificationFilter filter;
  final String search;

  const NotificationState({
    required this.isLoading,
    required this.urgent,
    required this.summary,
    required this.filter,
    required this.search,
  });

  factory NotificationState.initial() => NotificationState(
    isLoading: false,
    urgent: NotificationTabState.initial(),
    summary: NotificationTabState.initial(),
    filter: const NotificationFilter(),
    search: '',
  );

  NotificationState copyWith({
    bool? isLoading,
    NotificationTabState? urgent,
    NotificationTabState? summary,
    NotificationFilter? filter,
    String? search,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      urgent: urgent ?? this.urgent,
      summary: summary ?? this.summary,
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
      urgent: NotificationTabState.initial(),
      summary: NotificationTabState.initial(),
    );

    try {
      await Future(() async {
        await _loadTab(
          isUrgent: true,
          page: 1,
          existing: const [],
          search: s,
          filter: f,
        );
        await _loadTab(
          isUrgent: false,
          page: 1,
          existing: const [],
          search: s,
          filter: f,
        );
      }).timeout(const Duration(seconds: 30));
    } on TimeoutException {
      debugPrint('notification refresh: timed out after 30s');
    } catch (e) {
      debugPrint('notification refresh error: $e');
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }

    if (mounted) _service.markAllAsRead().ignore();
  }

  Future<void> loadMoreUrgent() async {
    final tab = state.urgent;
    if (tab.isLoadingMore || !tab.hasMore) return;

    state = state.copyWith(urgent: tab.copyWith(isLoadingMore: true));

    await _loadTab(
      isUrgent: true,
      page: tab.nextPage,
      existing: tab.items,
      search: state.search,
      filter: state.filter,
    );
  }

  Future<void> loadMoreSummary() async {
    final tab = state.summary;
    if (tab.isLoadingMore || !tab.hasMore) return;

    state = state.copyWith(summary: tab.copyWith(isLoadingMore: true));

    await _loadTab(
      isUrgent: false,
      page: tab.nextPage,
      existing: tab.items,
      search: state.search,
      filter: state.filter,
    );
  }

  Future<void> _loadTab({
    required bool isUrgent,
    required int page,
    required List<AlertModel> existing,
    required String search,
    required NotificationFilter filter,
  }) async {
    try {
      final rawList = isUrgent
          ? await _service.fetchAlertUrgent(
              page: page,
              startDate: filter.startDate,
              endDate: filter.endDate,
              eventType: filter.alertType,
              fleetGroupId: filter.fleetGroup,
              statusVerified: filter.status,
              licensePlate: search.isNotEmpty ? search : null,
            )
          : await _service.fetchAlertSummary(
              page: page,
              startDate: filter.startDate,
              endDate: filter.endDate,
              eventType: filter.alertType,
              fleetGroupId: filter.fleetGroup,
              statusVerified: filter.status,
              licensePlate: search.isNotEmpty ? search : null,
            );

      debugPrint(
        '>>> _loadTab isUrgent=$isUrgent page=$page rawCount=${rawList.length}',
      );

      final newItems = rawList.map((e) {
        try {
          return AlertModel.fromJson(e as Map<String, dynamic>);
        } catch (_) {
          return const AlertModel();
        }
      }).toList();

      if (!mounted) return;

      final hasMore = newItems.length >= _pageSize;
      final merged = [...existing, ...newItems];

      if (isUrgent) {
        state = state.copyWith(
          urgent: state.urgent.copyWith(
            items: merged,
            nextPage: page + 1,
            hasMore: hasMore,
            isLoadingMore: false,
          ),
        );
      } else {
        state = state.copyWith(
          summary: state.summary.copyWith(
            items: merged,
            nextPage: page + 1,
            hasMore: hasMore,
            isLoadingMore: false,
          ),
        );
      }

      unawaited(
        _attachAddressesParallel(
          newItems,
          isUrgent: isUrgent,
          offset: existing.length,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (isUrgent) {
        state = state.copyWith(
          urgent: state.urgent.copyWith(isLoadingMore: false),
        );
      } else {
        state = state.copyWith(
          summary: state.summary.copyWith(isLoadingMore: false),
        );
      }
    }
  }

  Future<void> _attachAddressesParallel(
    List<AlertModel> items, {
    required bool isUrgent,
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
      if (isUrgent) {
        final current = List<AlertModel>.from(state.urgent.items);
        if (idx < current.length && current[idx].id == items[i].id) {
          current[idx] = current[idx].copyWith(address: address);
          state = state.copyWith(urgent: state.urgent.copyWith(items: current));
        }
      } else {
        final current = List<AlertModel>.from(state.summary.items);
        if (idx < current.length && current[idx].id == items[i].id) {
          current[idx] = current[idx].copyWith(address: address);
          state = state.copyWith(
            summary: state.summary.copyWith(items: current),
          );
        }
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
