import 'dart:async';

import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/widgets/search_bar_base.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/vehicle/widgets/add_vehicle_sheet.dart';
import 'package:ams/screens/vehicle_detail/models/add_vehicle_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/features/monitoring/providers/plate_suggestion_provider.dart';
import 'package:ams/screens/vehicle/providers/vehicle_infinite_provider.dart';
import 'package:ams/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:ams/screens/vehicle/widgets/card_vehicle.dart';

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

  Future<void> _onRefresh() async {
    await ref.read(vehicleInfiniteProvider.notifier).refresh(query: _debounced);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final suggestionPlates = ref.watch(plateSuggestionProvider(_activity));
    final vehiclesAsync = ref.watch(vehicleInfiniteProvider);

    return Scaffold(
      backgroundColor: AppStyles.bgColor,

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await AddVehicleSheet.open(context);
          if (created == true && mounted) {
            ref
                .read(vehicleInfiniteProvider.notifier)
                .refresh(query: _debounced);
          }
        },
        backgroundColor: AppStyles.primaryColor,
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
                SearchBarBase(
                  value: _search,
                  onChanged: _onChanged,
                  suggestionPlates: suggestionPlates,
                  hintText: t.searchLicensePlate,
                  showFilter: false,
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
                        return RefreshIndicator(
                          color: AppStyles.primaryColor,
                          onRefresh: _onRefresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Text(
                                    _debounced.trim().isEmpty
                                        ? t.noVehicleYet
                                        : t.dataNotFound,
                                    style: AppStyles.textSm.copyWith(
                                      color: AppStyles.blackColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppStyles.primaryColor,
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 12, bottom: 90),
                          itemCount:
                              state.items.length +
                              (state.isLoadingMore ? 1 : 0),
                          // separatorBuilder: (_, __) =>
                          //     const SizedBox(height: 12),
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

                            return CardVehicle(
                              vehicle: item,
                              onTap: () async {
                                final updated = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.addVehicleScreen,
                                  arguments: AddVehicleArgs(
                                    status: AddVehicleStatus.update,
                                    license: item['license_plate'],
                                    id: item['id']?.toString(),
                                  ),
                                );
                                if (updated == true && mounted) {
                                  ref
                                      .read(vehicleInfiniteProvider.notifier)
                                      .refresh(query: _debounced);
                                }
                              },
                            );
                          },
                        ),
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
