import 'package:ams/base/network/api_response.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/widgets/app_toast.dart';
import 'package:ams/base/widgets/confirm_dialog.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/base/widgets/search_bar_base.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/models/work_order_args.dart';
import 'package:ams/screens/work_order/pages/work_list/widgets/assign_work_sheet.dart';
import 'package:ams/screens/work_order/pages/work_list/widgets/work_list_card.dart';
import 'package:ams/screens/work_order/providers/work_order_providers.dart';
import 'package:ams/screens/work_order/utils/format_label.dart';
import 'package:ams/screens/work_order/widgets/card_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Padanan `pages/work-order/pages/work-list/work-list.jsx`:
/// daftar pekerjaan (detail) di dalam satu work order.
class WorkListScreen extends ConsumerStatefulWidget {
  final WorkListArgs args;

  const WorkListScreen({super.key, required this.args});

  @override
  ConsumerState<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends ConsumerState<WorkListScreen> {
  String _search = '';
  bool _isBusy = false;

  late final ScrollController _scroll;

  String get _workOrderId => widget.args.workOrderId;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workOrderOptionsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;

    if (pos.pixels >= pos.maxScrollExtent - 250) {
      ref.read(workOrderDetailListProvider(_workOrderId).notifier).loadMore();
    }
  }

  Future<void> _refresh() =>
      ref.read(workOrderDetailListProvider(_workOrderId).notifier).refresh();

  /// Nama teknisi diambil dari work order yang dipilih; dipakai sebagai nilai
  /// field "Technician" pada form detail (read-only di sana).
  String get _technicianName {
    final workOrder = ref.read(selectedWorkOrderProvider);
    final raw = workOrder?['technician']?.toString();
    return ref.read(workOrderOptionsProvider).technicianLabel(raw);
  }

  Future<void> _openAssignSheet() async {
    final categories = ref.read(workOrderOptionsProvider).workCategory;

    final selection = await AssignWorkSheet.open(
      context,
      categories: categories,
    );
    if (selection == null || !mounted) return;

    await Navigator.pushNamed(
      context,
      AppRoutes.createDetailWoScreen,
      arguments: CreateDetailWoArgs(
        category: selection.category.name,
        type: selection.type.value,
        categoryLabel: selection.category.name,
        typeLabel: selection.type.label,
        technician: _technicianName,
        workOrderId: _workOrderId,
      ),
    );

    if (mounted) await _refresh();
  }

  Future<void> _openCardOptions(
    Map<String, dynamic> item,
    String title,
    String subtitle,
  ) async {
    final t = AppLocalizations.of(context);
    final id = (item['id'] ?? '').toString();

    final action = await CardOptionsSheet.open(
      context,
      title: title,
      subtitle: subtitle,
      allowDelete: !ref.read(isTechnicianProvider),
    );
    if (action == null || !mounted) return;

    if (action == CardAction.details) {
      await Navigator.pushNamed(
        context,
        AppRoutes.workDetailsScreen,
        arguments: WorkDetailsArgs(detailId: id),
      );
      if (mounted) await _refresh();
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: t.woDetailDeleteTitle,
        desc: t.woDetailDeleteSubtitle,
        textCancel: t.cancel,
        textSubmit: t.woDeleteConfirm,
        funcSubmit: () => _deleteDetail(id),
      ),
    );
  }

  Future<void> _deleteDetail(String id) async {
    final t = AppLocalizations.of(context);
    setState(() => _isBusy = true);

    try {
      await ref.read(workOrderApiProvider).deleteWorkOrderDetail(id);
      if (mounted) AppToast.show(context, t.woDeleteSuccess);
    } catch (_) {
      if (mounted) AppToast.showFailed(context, t.woDeleteFailed);
    } finally {
      if (mounted) setState(() => _isBusy = false);
      await _refresh();
    }
  }

  List<Map<String, dynamic>> _visibleRows(List<Map<String, dynamic>> source) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return source;

    return source.where((row) {
      final haystack = [
        row['license_plate'],
        row['work_type'],
        row['work_category'],
        row['status'],
      ].map((e) => (e ?? '').toString().toLowerCase());

      return haystack.any((value) => value.contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = ref.watch(workOrderOptionsProvider);
    final isTechnician = ref.watch(isTechnicianProvider);
    final listAsync = ref.watch(workOrderDetailListProvider(_workOrderId));

    final title = widget.args.workOrderNo.trim().isEmpty
        ? t.woWorkListTitle
        : '${t.woWorkListTitle} ${widget.args.workOrderNo}';

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppStyles.blackColor),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.textMdBold,
        ),
      ),

      // Teknisi hanya mengerjakan, penugasan pekerjaan dibuat oleh admin.
      bottomNavigationBar: isTechnician
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppStyles.whiteColor,
                border: Border(
                  top: BorderSide(color: AppStyles.borderLightGray),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _openAssignSheet,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppStyles.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    t.woAssignButton,
                    style: AppStyles.textMd.copyWith(
                      color: AppStyles.whiteColor,
                    ),
                  ),
                ),
              ),
            ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SearchBarBase(
                  value: _search,
                  onChanged: (value) => setState(() => _search = value),
                  hintText: t.filterSearch,
                  showFilter: false,
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: listAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          apiErrorText(e, t.failedLoadData),
                          textAlign: TextAlign.center,
                          style: AppStyles.textSm.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    data: (state) {
                      final rows = _visibleRows(state.items);

                      if (rows.isEmpty) {
                        return RefreshIndicator(
                          color: AppStyles.primaryColor,
                          onRefresh: _refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        t.woWorkListEmptyTitle,
                                        style: AppStyles.textMdBold,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.woWorkListEmptyMessage,
                                        textAlign: TextAlign.center,
                                        style: AppStyles.textSm,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppStyles.primaryColor,
                        onRefresh: _refresh,
                        child: ListView.builder(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 6, bottom: 24),
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

                            return WorkListCard(
                              key: ValueKey(
                                '${row['id']}-${row['work_category']}',
                              ),
                              data: row,
                              options: options,
                              onTap: (cardTitle, subtitle) => _openCardOptions(
                                row,
                                formatStatus(cardTitle),
                                subtitle,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            if (listAsync.isLoading || _isBusy)
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
