import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle/models/vehicle_page.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle/service/fetch_vehicle.dart';
import 'package:flutter_riverpod/legacy.dart';

class VehicleListState {
  final List<Map<String, dynamic>> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;
  final String query;

  const VehicleListState({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.isLoadingMore,
    required this.query,
  });

  factory VehicleListState.initial({String query = ''}) => VehicleListState(
    items: const [],
    page: 1,
    hasNext: true,
    isLoadingMore: false,
    query: query,
  );

  VehicleListState copyWith({
    List<Map<String, dynamic>>? items,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    String? query,
  }) {
    return VehicleListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
    );
  }
}

class VehicleListNotifier extends StateNotifier<AsyncValue<VehicleListState>> {
  VehicleListNotifier(this._api) : super(AsyncData(VehicleListState.initial()));

  final FetchVehicle _api;

  VehicleListState? get _current => state.asData?.value;

  bool get _busy => _current?.isLoadingMore ?? false;

  Future<void> refresh({String query = ''}) async {
    state = const AsyncLoading();

    try {
      final page = await _api.fetch(page: 1, licensePlate: query);

      state = AsyncData(
        VehicleListState(
          items: page.items,
          page: 2,
          hasNext: page.hasNext,
          isLoadingMore: false,
          query: query,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = _current;
    if (current == null) return;
    if (_busy || !current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final VehiclePage page = await _api.fetch(
        page: current.page,
        licensePlate: current.query,
      );

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
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final vehicleApiProvider = Provider<FetchVehicle>((ref) => FetchVehicle());

final vehicleInfiniteProvider =
    StateNotifierProvider<VehicleListNotifier, AsyncValue<VehicleListState>>((
      ref,
    ) {
      final api = ref.watch(vehicleApiProvider);
      return VehicleListNotifier(api);
    });
