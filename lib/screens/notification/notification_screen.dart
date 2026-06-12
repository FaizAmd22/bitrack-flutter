import 'dart:async';

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/search_bar_base.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/home/models/filter_model.dart';
import 'package:ams/screens/notification/providers/notification_provider.dart';
import 'package:ams/screens/notification/widgets/card_notif.dart';
import 'package:ams/screens/notification/widgets/filter_notif_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => NotificationScreenState();
}

// State class public agar bisa dipanggil lewat GlobalKey dari BottomNavBar.
class NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _urgentScroll;
  late final ScrollController _summaryScroll;

  final _searchController = TextEditingController();
  Timer? _debounce;
  String _search = '';
  NotificationFilter _filter = const NotificationFilter();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _urgentScroll = ScrollController()..addListener(_onUrgentScroll);
    _summaryScroll = ScrollController()..addListener(_onSummaryScroll);

    // Fetch awal — sekali saja saat halaman pertama dibuat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _urgentScroll.removeListener(_onUrgentScroll);
    _summaryScroll.removeListener(_onSummaryScroll);
    _urgentScroll.dispose();
    _summaryScroll.dispose();
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

  void _onUrgentScroll() {
    if (!_urgentScroll.hasClients) return;
    final pos = _urgentScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 250) {
      ref.read(notificationProvider.notifier).loadMoreUrgent();
    }
  }

  void _onSummaryScroll() {
    if (!_summaryScroll.hasClients) return;
    final pos = _summaryScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 250) {
      ref.read(notificationProvider.notifier).loadMoreSummary();
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(notificationProvider.notifier)
        .refresh(search: _search, filter: _filter, force: true);
  }

  Future<void> _openFilter() async {
    final state = ref.read(notificationProvider);
    final allItems = [...state.urgent.items, ...state.summary.items];

    final seenFleet = <String>{};
    final fleetGroups = <FilterOption>[];
    final seenAlert = <String>{};
    final alertTypes = <FilterOption>[];

    for (final item in allItems) {
      if (item.fleetGroupId != null && seenFleet.add(item.fleetGroupId!)) {
        fleetGroups.add(
          FilterOption(
            value: item.fleetGroupId,
            label: item.fleetGroupName ?? item.fleetGroupId!,
          ),
        );
      }
      if (item.eventType != null && seenAlert.add(item.eventType!)) {
        alertTypes.add(
          FilterOption(
            value: item.eventType,
            label: item.eventName ?? item.eventType!,
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
            _buildTabBar(t),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppStyles.primaryColor,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(
                          items: state.urgent.items,
                          hasMore: state.urgent.hasMore,
                          isLoadingMore: state.urgent.isLoadingMore,
                          scroll: _urgentScroll,
                          emptyLabel: t.notifNoData,
                        ),
                        _buildList(
                          items: state.summary.items,
                          hasMore: state.summary.hasMore,
                          isLoadingMore: state.summary.isLoadingMore,
                          scroll: _summaryScroll,
                          emptyLabel: t.notifNoData,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppStyles.inputDisableBg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppStyles.primaryColor,
          unselectedLabelColor: AppStyles.textDarkGrayColor,
          labelStyle: AppStyles.textSmBold.copyWith(
            color: AppStyles.primaryColor,
          ),
          unselectedLabelStyle: AppStyles.textSm.copyWith(
            color: AppStyles.textDarkGrayColor,
          ),
          tabs: [
            Tab(text: t.notifUrgent),
            Tab(text: t.notifSummary),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required List items,
    required bool hasMore,
    required bool isLoadingMore,
    required ScrollController scroll,
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
              controller: scroll,
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
