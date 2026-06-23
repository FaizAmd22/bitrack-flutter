import 'dart:async';

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/utils/string_utils.dart';
import 'package:ams/base/widgets/search_bar_base.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/home/models/filter_model.dart';
import 'package:ams/screens/notification/providers/notification_provider.dart';
import 'package:ams/screens/notification/widgets/card_notif.dart';
import 'package:ams/screens/notification/widgets/filter_notif_bottom_sheet.dart';
import 'package:ams/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => NotificationScreenState();
}

// State class public agar bisa dipanggil lewat GlobalKey dari BottomNavBar.
class NotificationScreenState extends ConsumerState<NotificationScreen> {
  late final ScrollController _scroll;

  final _searchController = TextEditingController();
  Timer? _debounce;
  String _search = '';
  NotificationFilter _filter = const NotificationFilter();

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);

    // Fetch awal — sekali saja saat halaman pertama dibuat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    ref
        .read(notificationProvider.notifier)
        .refresh(search: _search, filter: _filter);
  }

  /// Dipanggil oleh BottomNavBar HANYA saat user pindah ke tab notifikasi.
  void refreshFromOutside() {
    ref
        .read(notificationProvider.notifier)
        .refresh(search: _search, filter: _filter, force: true);
  }

  void _onSearchChanged(String val) {
    setState(() => _search = val);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref
          .read(notificationProvider.notifier)
          .refresh(search: val, filter: _filter, force: true);
    });
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 250) {
      ref.read(notificationProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(notificationProvider.notifier)
        .refresh(search: _search, filter: _filter, force: true);
  }

  Future<void> _openFilter() async {
    final state = ref.read(notificationProvider);

    List<Map<String, dynamic>> fleetGroupRaw = const [];
    try {
      fleetGroupRaw = await ref.read(fleetGroupProvider.future);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }

    final fleetGroups = fleetGroupRaw
        .map((fg) {
          final id = (fg['value'] ?? '').toString().trim();
          if (id.isEmpty) return null;
          final name = (fg['label'] ?? '').toString().trim();
          return FilterOption(value: id, label: name.isNotEmpty ? name : id);
        })
        .whereType<FilterOption>()
        .toList();

    final seenAlert = <String>{};
    final alertTypes = <FilterOption>[];
    for (final item in state.list.items) {
      if (item.eventType != null && seenAlert.add(item.eventType!)) {
        alertTypes.add(
          FilterOption(
            value: item.eventType,
            label: titleCase(item.eventName ?? item.eventType!),
          ),
        );
      }
    }

    if (!mounted) return;
    final result = await FilterNotifBottomSheet.open(
      context,
      initialFilter: _filter,
      fleetGroups: fleetGroups,
      alertTypes: alertTypes,
    );

    if (result != null && mounted) {
      setState(() => _filter = result);
      ref
          .read(notificationProvider.notifier)
          .refresh(search: _search, filter: result, force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SearchBarBase(
              value: _search,
              onChanged: _onSearchChanged,
              hintText: t.searchLicensePlate,
              onOpenFilter: (_) => _openFilter(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppStyles.primaryColor,
                      ),
                    )
                  : _buildList(
                      items: state.list.items,
                      isLoadingMore: state.list.isLoadingMore,
                      emptyLabel: t.notifNoData,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required List items,
    required bool isLoadingMore,
    required String emptyLabel,
  }) {
    return RefreshIndicator(
      color: AppStyles.primaryColor,
      onRefresh: _onRefresh,
      child: items.isEmpty && !isLoadingMore
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      emptyLabel,
                      style: AppStyles.textSm.copyWith(
                        color: AppStyles.textDarkGrayColor,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12, bottom: 90),
              itemCount: items.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppStyles.primaryColor,
                      ),
                    ),
                  );
                }
                return CardNotif(item: items[index]);
              },
            ),
    );
  }
}
