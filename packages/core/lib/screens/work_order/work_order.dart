import 'package:bitrack_core/base/network/api_response.dart';
import 'dart:async';

import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/base/widgets/app_toast.dart';
import 'package:bitrack_core/base/widgets/confirm_dialog.dart';
import 'package:bitrack_core/base/widgets/full_screen_loading.dart';
import 'package:bitrack_core/base/widgets/search_bar_base.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/work_order/models/work_order_args.dart';
import 'package:bitrack_core/screens/work_order/models/work_order_options.dart';
import 'package:bitrack_core/screens/work_order/providers/work_order_providers.dart';
import 'package:bitrack_core/screens/work_order/widgets/card_options_sheet.dart';
import 'package:bitrack_core/screens/work_order/widgets/filter_work_order_sheet.dart';
import 'package:bitrack_core/screens/work_order/widgets/work_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Padanan `pages/work-order/work-order.jsx`.
class WorkOrderScreen extends ConsumerStatefulWidget {
  const WorkOrderScreen({super.key});

  @override
  ConsumerState<WorkOrderScreen> createState() => _WorkOrderScreenState();
}

class _WorkOrderScreenState extends ConsumerState<WorkOrderScreen> {
  String _search = '';
  Timer? _debounce;
  bool _isDeleting = false;

  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await ref.read(workOrderListProvider.notifier).refresh();
    if (!mounted) return;

    // Dua panggilan ini tidak memblokir daftar: peran user & option filter.
    unawaited(ref.read(isTechnicianProvider.notifier).refresh());
    unawaited(_loadOptions());
  }

  Future<void> _loadOptions({bool force = false}) async {
    try {
      await ref.read(workOrderOptionsProvider.notifier).load(force: force);
    } catch (_) {
      // Filter tetap bisa dibuka walau option gagal dimuat.
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;

    if (pos.pixels >= pos.maxScrollExtent - 250) {
      ref.read(workOrderListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(workOrderListProvider.notifier).refresh();
    await _loadOptions(force: true);
  }

  Future<void> _openFilter(BuildContext context) async {
    final current =
        ref.read(workOrderListProvider).asData?.value.filter ??
        WorkOrderFilter.empty;

    final result = await FilterWorkOrderSheet.open(
      context,
      current: current,
      options: ref.read(workOrderOptionsProvider),
      isTechnician: ref.read(isTechnicianProvider),
      languageCode: Localizations.localeOf(context).languageCode,
    );

    if (result == null || !mounted) return;
    await ref.read(workOrderListProvider.notifier).refresh(filter: result);
  }

  Future<void> _openCardOptions(
    Map<String, dynamic> item,
    String fleetGroupName,
  ) async {
    final t = AppLocalizations.of(context);
    final id = (item['id'] ?? '').toString();

    ref.read(selectedWorkOrderProvider.notifier).select(item);

    final action = await CardOptionsSheet.open(
      context,
      title: fleetGroupName,
      subtitle: (item['work_order_no'] ?? '-').toString(),
      allowDelete: !ref.read(isTechnicianProvider),
    );

    if (action == null || !mounted) return;

    if (action == CardAction.details) {
      await Navigator.pushNamed(
        context,
        AppRoutes.workListScreen,
        arguments: WorkListArgs(
          workOrderId: id,
          workOrderNo: (item['work_order_no'] ?? '').toString(),
        ),
      );
      if (mounted) await ref.read(workOrderListProvider.notifier).refresh();
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: t.woDeleteTitle,
        desc: t.woDeleteSubtitle,
        textCancel: t.cancel,
        textSubmit: t.woDeleteConfirm,
        funcSubmit: () => _deleteWorkOrder(id),
      ),
    );
  }

  Future<void> _deleteWorkOrder(String id) async {
    final t = AppLocalizations.of(context);
    setState(() => _isDeleting = true);

    try {
      await ref.read(workOrderApiProvider).deleteWorkOrder(id);
      if (mounted) AppToast.show(context, t.woDeleteSuccess);
    } catch (_) {
      if (mounted) AppToast.showFailed(context, t.woDeleteFailed);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
      await ref.read(workOrderListProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    final listAsync = ref.watch(workOrderListProvider);
    final options = ref.watch(workOrderOptionsProvider);
    final isTechnician = ref.watch(isTechnicianProvider);

    return Scaffold(
      backgroundColor: AppStyles.bgColor,

      // Teknisi hanya mengerjakan work order, tidak membuatnya.
      floatingActionButton: isTechnician
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.pushNamed(
                  context,
                  AppRoutes.createWorkOrderScreen,
                );
                if (created == true && mounted) {
                  await ref.read(workOrderListProvider.notifier).refresh();
                }
              },
              backgroundColor: AppStyles.primaryColor,
              elevation: 6,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SearchBarBase(
                  value: _search,
                  onChanged: _onSearchChanged,
                  hintText: t.woSearchPlaceholder,
                  onOpenFilter: _openFilter,
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: listAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => _ErrorState(
                      message: apiErrorText(e, t.failedLoadData),
                      onRetry: _onRefresh,
                    ),
                    data: (state) {
                      final rows = _visibleRows(state.items, options);

                      if (rows.isEmpty) {
                        return RefreshIndicator(
                          color: AppStyles.primaryColor,
                          onRefresh: _onRefresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.55,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          t.woNoDataTitle,
                                          textAlign: TextAlign.center,
                                          style: AppStyles.textMdBold,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          t.woNoDataMessage,
                                          textAlign: TextAlign.center,
                                          style: AppStyles.textSm,
                                        ),
                                      ],
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
                          padding: const EdgeInsets.only(top: 6, bottom: 90),
                          itemCount:
                              rows.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= rows.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppStyles.primaryColor,
                                  ),
                                ),
                              );
                            }

                            final row = rows[index];
                            final fleetGroupName = options.fleetGroupLabel(
                              row['fleet_group_id']?.toString(),
                            );

                            return WorkOrderCard(
                              item: row,
                              fleetGroupName: fleetGroupName,
                              technicianName: options.technicianLabel(
                                row['technician']?.toString(),
                              ),
                              languageCode: languageCode,
                              onTap: () =>
                                  _openCardOptions(row, fleetGroupName),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            if (listAsync.isLoading || _isDeleting)
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

  /// Filter sisi klien + urutkan terbaru dulu, sama seperti `filteredData`
  /// di work-order.jsx.
  List<Map<String, dynamic>> _visibleRows(
    List<Map<String, dynamic>> source,
    WorkOrderOptions options,
  ) {
    final rows = [...source];
    rows.sort((a, b) {
      final da = DateTime.tryParse((a['created_at'] ?? '').toString());
      final db = DateTime.tryParse((b['created_at'] ?? '').toString());
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });

    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return rows;

    return rows.where((row) {
      final haystack = [
        row['created_by'],
        row['id'],
        row['work_order_no'],
        row['status'],
        options.technicianLabel(row['technician']?.toString()),
        options.fleetGroupLabel(row['fleet_group_id']?.toString()),
      ].map((e) => (e ?? '').toString().toLowerCase());

      return haystack.any((value) => value.contains(q));
    }).toList();
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppStyles.primaryColor,
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppStyles.textSm.copyWith(
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
