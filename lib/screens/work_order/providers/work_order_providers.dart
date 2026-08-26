import 'package:ams/screens/work_order/models/work_order_list_page.dart';
import 'package:ams/screens/work_order/models/work_order_options.dart';
import 'package:ams/screens/work_order/services/work_order_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final workOrderApiProvider = Provider<WorkOrderApi>(
  (_) => const WorkOrderApi(),
);

/// Option lintas halaman (fleet group, teknisi, plat, kategori pekerjaan).
/// Sekali dimuat lalu dipakai ulang — padanan `workOrderOptionsSlice`.
class WorkOrderOptionsNotifier extends StateNotifier<WorkOrderOptions> {
  WorkOrderOptionsNotifier(this._api) : super(WorkOrderOptions.empty);

  final WorkOrderApi _api;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;

    final options = await _api.fetchOptions();
    if (!mounted) return;

    state = options;
    _loaded = true;
  }

  void reset() {
    _loaded = false;
    state = WorkOrderOptions.empty;
  }
}

final workOrderOptionsProvider =
    StateNotifierProvider<WorkOrderOptionsNotifier, WorkOrderOptions>(
      (ref) => WorkOrderOptionsNotifier(ref.watch(workOrderApiProvider)),
    );

/// `true` untuk akun teknisi lapangan: tombol buat/hapus WO dan aksi
/// "mark as complete" disembunyikan.
final isTechnicianProvider = StateNotifierProvider<IsTechnicianNotifier, bool>(
  (ref) => IsTechnicianNotifier(ref.watch(workOrderApiProvider)),
);

class IsTechnicianNotifier extends StateNotifier<bool> {
  IsTechnicianNotifier(this._api) : super(false) {
    _restore();
  }

  final WorkOrderApi _api;

  Future<void> _restore() async {
    final cached = await _api.cachedIsTechnician();
    if (!mounted) return;
    state = cached;
  }

  Future<void> refresh() async {
    try {
      final value = await _api.fetchIsTechnician();
      if (!mounted) return;
      state = value;
    } catch (_) {
      // Biarkan nilai cache terakhir dipakai kalau endpoint gagal.
    }
  }
}

/// Work order yang sedang dibuka — dipakai halaman turunan untuk menampilkan
/// nomor WO & nama teknisi tanpa fetch ulang (padanan `selectedWorkOrderSlice`).
final selectedWorkOrderProvider =
    StateNotifierProvider<SelectedWorkOrderNotifier, Map<String, dynamic>?>(
      (_) => SelectedWorkOrderNotifier(),
    );

class SelectedWorkOrderNotifier extends StateNotifier<Map<String, dynamic>?> {
  SelectedWorkOrderNotifier() : super(null);

  void select(Map<String, dynamic>? workOrder) => state = workOrder;
}

// -------------------------------------------------------------- list header

class WorkOrderFilter {
  final String? createdAt;
  final String? fleetGroupId;
  final String? technician;

  const WorkOrderFilter({this.createdAt, this.fleetGroupId, this.technician});

  static const empty = WorkOrderFilter();

  bool get isEmpty =>
      createdAt == null && fleetGroupId == null && technician == null;

  WorkOrderFilter copyWith({
    String? createdAt,
    String? fleetGroupId,
    String? technician,
  }) {
    return WorkOrderFilter(
      createdAt: createdAt ?? this.createdAt,
      fleetGroupId: fleetGroupId ?? this.fleetGroupId,
      technician: technician ?? this.technician,
    );
  }
}

class WorkOrderListState {
  final List<Map<String, dynamic>> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;
  final WorkOrderFilter filter;

  const WorkOrderListState({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.isLoadingMore,
    required this.filter,
  });

  factory WorkOrderListState.initial() => const WorkOrderListState(
    items: [],
    page: 1,
    hasNext: true,
    isLoadingMore: false,
    filter: WorkOrderFilter.empty,
  );

  WorkOrderListState copyWith({
    List<Map<String, dynamic>>? items,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    WorkOrderFilter? filter,
  }) {
    return WorkOrderListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filter: filter ?? this.filter,
    );
  }
}

class WorkOrderListNotifier
    extends StateNotifier<AsyncValue<WorkOrderListState>> {
  WorkOrderListNotifier(this._api)
    : super(AsyncData(WorkOrderListState.initial()));

  final WorkOrderApi _api;

  WorkOrderListState? get _current => state.asData?.value;

  Future<void> refresh({WorkOrderFilter? filter}) async {
    final effectiveFilter = filter ?? _current?.filter ?? WorkOrderFilter.empty;
    state = const AsyncLoading();

    try {
      final page = await _api.fetchWorkOrder(
        page: 1,
        fleetGroupId: effectiveFilter.fleetGroupId,
        date: effectiveFilter.createdAt,
        technician: effectiveFilter.technician,
      );
      if (!mounted) return;

      state = AsyncData(
        WorkOrderListState(
          items: page.items,
          page: 2,
          hasNext: page.hasNext,
          isLoadingMore: false,
          filter: effectiveFilter,
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = _current;
    if (current == null || current.isLoadingMore || !current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final WorkOrderListPage page = await _api.fetchWorkOrder(
        page: current.page,
        fleetGroupId: current.filter.fleetGroupId,
        date: current.filter.createdAt,
        technician: current.filter.technician,
      );
      if (!mounted) return;

      final seen = <String>{
        for (final e in current.items) (e['id'] ?? '').toString(),
      };
      final appended = <Map<String, dynamic>>[
        ...current.items,
        ...page.items.where((e) => seen.add((e['id'] ?? '').toString())),
      ];

      state = AsyncData(
        current.copyWith(
          items: appended,
          page: current.page + 1,
          hasNext: page.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      state = AsyncData(current.copyWith(isLoadingMore: false, hasNext: false));
    }
  }
}

final workOrderListProvider =
    StateNotifierProvider<
      WorkOrderListNotifier,
      AsyncValue<WorkOrderListState>
    >((ref) => WorkOrderListNotifier(ref.watch(workOrderApiProvider)));

// -------------------------------------------------------------- list detail

class WorkOrderDetailListState {
  final List<Map<String, dynamic>> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  const WorkOrderDetailListState({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.isLoadingMore,
  });

  WorkOrderDetailListState copyWith({
    List<Map<String, dynamic>>? items,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return WorkOrderDetailListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class WorkOrderDetailListNotifier
    extends StateNotifier<AsyncValue<WorkOrderDetailListState>> {
  WorkOrderDetailListNotifier(this._api, this._workOrderId)
    : super(const AsyncLoading()) {
    refresh();
  }

  final WorkOrderApi _api;
  final String _workOrderId;

  WorkOrderDetailListState? get _current => state.asData?.value;

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final rows = await _api.fetchWorkOrderDetail(_workOrderId, page: 1);
      if (!mounted) return;

      state = AsyncData(
        WorkOrderDetailListState(
          items: rows,
          page: 2,
          hasNext: rows.isNotEmpty,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = _current;
    if (current == null || current.isLoadingMore || !current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final rows = await _api.fetchWorkOrderDetail(
        _workOrderId,
        page: current.page,
      );
      if (!mounted) return;

      final seen = <String>{
        for (final e in current.items) (e['id'] ?? '').toString(),
      };
      final appended = <Map<String, dynamic>>[
        ...current.items,
        ...rows.where((e) => seen.add((e['id'] ?? '').toString())),
      ];

      state = AsyncData(
        current.copyWith(
          items: appended,
          page: current.page + 1,
          hasNext: rows.isNotEmpty,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      state = AsyncData(current.copyWith(isLoadingMore: false, hasNext: false));
    }
  }
}

final workOrderDetailListProvider =
    StateNotifierProvider.family<
      WorkOrderDetailListNotifier,
      AsyncValue<WorkOrderDetailListState>,
      String
    >(
      (ref, workOrderId) => WorkOrderDetailListNotifier(
        ref.watch(workOrderApiProvider),
        workOrderId,
      ),
    );
