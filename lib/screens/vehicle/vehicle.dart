import 'dart:async';

import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/models/add_vehicle_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/full_screen_loading.dart';
import 'package:bitrack_mobile_flutter/base/widgets/plate_search_bar.dart';
import 'package:bitrack_mobile_flutter/features/monitoring/providers/plate_suggestion_provider.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle/providers/vehicle_infinite_provider.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle/widgets/card_vehicle.dart';

class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  final String _activity = 'allVehicle';

  String _search = '';
  String _debounced = '';
  Timer? _debounce;

  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vehicleInfiniteProvider.notifier).refresh(query: '');
      ref.read(fleetGroupProvider.future);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;

    if (pos.pixels >= pos.maxScrollExtent - 250) {
      ref.read(vehicleInfiniteProvider.notifier).loadMore();
    }
  }

  void _onChanged(String val) {
    setState(() => _search = val);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _debounced = val);

      ref.read(vehicleInfiniteProvider.notifier).refresh(query: val);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final suggestionPlates = ref.watch(plateSuggestionProvider(_activity));
    final vehiclesAsync = ref.watch(vehicleInfiniteProvider);

    final fleetGroupMapAsync = ref.watch(fleetGroupMapProvider);

    return Scaffold(
      backgroundColor: AppStyles.bgColor,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addVehicleScreen,
            arguments: const AddVehicleArgs(status: AddVehicleStatus.create),
          );
        },
        backgroundColor: const Color(0xFFE53935),
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16, top: 12),
                  child: PlateSearchBar(
                    value: _search,
                    onChanged: _onChanged,
                    suggestionPlates: suggestionPlates,
                    hintText: t.searchLicensePlate,
                    onTapFilter: () {},
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: vehiclesAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: AppStyles.textSm.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    data: (state) {
                      if (state.items.isEmpty) {
                        return Center(
                          child: Text(
                            _debounced.trim().isEmpty
                                ? t.noVehicleYet
                                : t.dataNotFound,
                            style: AppStyles.textSm.copyWith(
                              color: AppStyles.blackColor,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: 90,
                        ),
                        itemCount:
                            state.items.length + (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppStyles.primaryColor,
                                ),
                              ),
                            );
                          }

                          final item = state.items[index];
                          final fleetName = fleetGroupMapAsync.maybeWhen(
                            data: (m) =>
                                m[item['fleet_group_id']?.toString().trim()] ??
                                '-',
                            orElse: () => '-',
                          );

                          final merged = {
                            ...item,
                            'fleet_group_name': fleetName,
                          };

                          return CardVehicle(
                            vehicle: merged,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addVehicleScreen,
                                arguments: AddVehicleArgs(
                                  status: AddVehicleStatus.update,
                                  license: item['license_plate'],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            if (vehiclesAsync.isLoading)
              const Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: FullScreenLoading(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
