// ignore_for_file: use_build_context_synchronously

import 'package:ams/base/localization/locale_controller.dart';
import 'package:ams/base/network/api_response.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/widgets/app_toast.dart';
import 'package:ams/base/widgets/confirm_dialog.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/base/widgets/segmented_tab_bar.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/models/work_order_args.dart';
import 'package:ams/screens/work_order/pages/work_details/models/evidence_slot.dart';
import 'package:ams/screens/work_order/pages/work_details/widgets/details_tab.dart';
import 'package:ams/screens/work_order/pages/work_details/widgets/evidence_tab.dart';
import 'package:ams/screens/work_order/pages/work_details/widgets/notes_tab.dart';
import 'package:ams/screens/work_order/pages/work_details/widgets/work_action_sheet.dart';
import 'package:ams/screens/work_order/providers/work_order_providers.dart';
import 'package:ams/screens/work_order/utils/work_order_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Padanan `pages/work-order/pages/work-details/work-details.jsx`.
class WorkDetailsScreen extends ConsumerStatefulWidget {
  final WorkDetailsArgs args;

  const WorkDetailsScreen({super.key, required this.args});

  @override
  ConsumerState<WorkDetailsScreen> createState() => _WorkDetailsScreenState();
}

class _WorkDetailsScreenState extends ConsumerState<WorkDetailsScreen> {
  final _notesController = TextEditingController();

  int _activeTab = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, dynamic>? _detail;

  List<EvidenceSlot?> _beforeImages = emptyEvidenceSlots();
  List<EvidenceSlot?> _afterImages = emptyEvidenceSlots();

  /// URL foto server yang dihapus user; baru benar-benar dihapus saat simpan.
  final List<String> _pendingDeleteUrls = [];
  String _originalNotes = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _activity {
    final raw = _detail?['activity'];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  bool get _isCompleted => _detail?['status']?.toString() == 'COMPLETED';

  String get _technicianName {
    final workOrder = ref.read(selectedWorkOrderProvider);
    return ref
        .read(workOrderOptionsProvider)
        .technicianLabel(workOrder?['technician']?.toString());
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final response = await ref
          .read(workOrderApiProvider)
          .fetchWorkOrderDetailById(widget.args.detailId);
      if (!mounted) return;

      final activity = response['activity'];
      final activityMap = activity is Map
          ? Map<String, dynamic>.from(activity)
          : <String, dynamic>{};
      final evidence = activityMap['evidence'];
      final notes = (activityMap['notes'] ?? '').toString();

      setState(() {
        _detail = response;
        _notesController.text = notes;
        _originalNotes = notes.trim();
        _pendingDeleteUrls.clear();
        _beforeImages = evidenceSlotsFromUrls(
          evidence is Map ? evidence['before'] : null,
        );
        _afterImages = evidenceSlotsFromUrls(
          evidence is Map ? evidence['after'] : null,
        );
      });
    } catch (e) {
      if (!mounted) return;
      AppToast.showFailed(
        context,
        apiErrorText(e, currentL10n().failedLoadData),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _hasUnsavedChanges {
    final hasNewImages = [
      ..._beforeImages,
      ..._afterImages,
    ].any((slot) => slot?.isNew == true);

    return hasNewImages ||
        _notesController.text.trim() != _originalNotes ||
        _pendingDeleteUrls.isNotEmpty;
  }

  void _onSlotChanged(EvidenceSection section, int index, EvidenceSlot? slot) {
    setState(() {
      final target = section == EvidenceSection.before
          ? [..._beforeImages]
          : [..._afterImages];
      target[index] = slot;

      if (section == EvidenceSection.before) {
        _beforeImages = target;
      } else {
        _afterImages = target;
      }
    });
  }

  /// Konfirmasi keluar kalau ada perubahan yang belum disimpan.
  Future<bool> _confirmLeave() async {
    if (!_hasUnsavedChanges) return true;

    final t = AppLocalizations.of(context);
    var leave = false;

    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: t.woLeaveTitle,
        desc: t.woLeaveMessage,
        textCancel: t.cancel,
        textSubmit: t.confirm,
        funcSubmit: () => leave = true,
      ),
    );

    return leave;
  }

  Map<String, dynamic> _activityPayload() {
    switch (resolveFormKind(
      _detail?['work_category']?.toString(),
      _detail?['work_type']?.toString(),
    )) {
      case WorkDetailFormKind.gpsInspection:
      case WorkDetailFormKind.inspection:
        return {'result': _activity['result'], 'action': _activity['action']};

      case WorkDetailFormKind.simCardReplacement:
        return {'simcard_number': _activity['simcard_number']};

      case WorkDetailFormKind.gpsInstallationReplacement:
        return {
          'device_type': _activity['device_type'],
          'device_model': _activity['device_model'],
          'imei': _activity['imei'],
          'simcard_number': _activity['simcard_number'],
        };

      case WorkDetailFormKind.dashcamInstallationReplacement:
        return {
          'dashcam_type': _activity['dashcam_type'],
          'imei': _activity['imei'],
          'simcard_number': _activity['simcard_number'],
          'dashcam_position': _activity['dashcam_position'],
        };

      case WorkDetailFormKind.sensorInstallationReplacement:
        return {
          'sensor_type': _activity['sensor_type'],
          'sensor_serial_number': _activity['sensor_serial_number'],
          'sensor_position': _activity['sensor_position'],
        };

      case WorkDetailFormKind.none:
        return const {};
    }
  }

  Map<String, dynamic> _completePayload({required bool isComplete}) {
    final detail = _detail!;

    return {
      'id': detail['id'],
      'is_complete': isComplete ? 1 : 0,
      'work_order_id': detail['work_order_id'],
      'work_category': detail['work_category'],
      'work_type': detail['work_type'],
      'license_plate': detail['license_plate'],
      'odometer': _activity['odometer'],
      'technician': _technicianName,
      'device_condition': _activity['device_condition'],
      ..._activityPayload(),
    };
  }

  Future<void> _persist({required bool isComplete}) async {
    final api = ref.read(workOrderApiProvider);
    final detailId = (_detail!['id'] ?? '').toString();

    final beforeFiles = _beforeImages
        .where((s) => s?.isNew == true)
        .map((s) => s!.file!)
        .toList();
    final afterFiles = _afterImages
        .where((s) => s?.isNew == true)
        .map((s) => s!.file!)
        .toList();
    final notes = _notesController.text.trim();

    await Future.wait([
      if (beforeFiles.isNotEmpty)
        api.uploadEvidence(
          files: beforeFiles,
          workOrderDetailId: detailId,
          event: 'BEFORE',
        ),
      if (afterFiles.isNotEmpty)
        api.uploadEvidence(
          files: afterFiles,
          workOrderDetailId: detailId,
          event: 'AFTER',
        ),
      if (isComplete || notes.isNotEmpty)
        api.updateNotes(workOrderDetailId: detailId, notes: notes),
      api.createWorkOrderDetail(_completePayload(isComplete: isComplete)),
      ..._pendingDeleteUrls.map(api.deleteEvidence),
    ]);
  }

  Future<void> _saveDraft() async {
    final t = AppLocalizations.of(context);
    setState(() => _isSaving = true);

    try {
      await _persist(isComplete: false);
      if (!mounted) return;

      AppToast.show(context, t.woSavedSuccess);
      await _fetchData();
    } catch (_) {
      if (mounted) AppToast.showFailed(context, t.woSavedFailed);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _markComplete() async {
    final t = AppLocalizations.of(context);

    // Bukti sebelum & sesudah plus catatan wajib ada sebelum ditandai selesai.
    final errors = <String>[
      if (!_beforeImages.any((s) => s != null)) t.woErrorBeforeImage,
      if (!_afterImages.any((s) => s != null)) t.woErrorAfterImage,
      if (_notesController.text.trim().isEmpty) t.woErrorNotes,
    ];

    if (errors.isNotEmpty) {
      AppToast.showFailed(context, errors.first);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _persist(isComplete: true);
      if (!mounted) return;

      AppToast.show(context, t.woCompleteSuccess);
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) AppToast.showFailed(context, t.woCompleteFailed);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openActionSheet() async {
    final options = ref.read(workOrderOptionsProvider);
    final category = _detail?['work_category']?.toString();
    final type = _detail?['work_type']?.toString();

    final action = await WorkActionSheet.open(
      context,
      title:
          '${options.categoryLabel(category)} - ${options.workTypeLabel(category, type)}',
      licensePlate: (_detail?['license_plate'] ?? '-').toString(),
      allowComplete: !ref.read(isTechnicianProvider),
    );

    if (action == null || !mounted) return;

    if (action == WorkAction.saveDraft) {
      await _saveDraft();
    } else {
      await _markComplete();
    }
  }

  Future<void> _openEdit() async {
    if (!await _confirmLeave() || !mounted) return;

    final detail = _detail;
    if (detail == null) return;

    final options = ref.read(workOrderOptionsProvider);
    final category = detail['work_category']?.toString() ?? '';
    final type = detail['work_type']?.toString() ?? '';

    await Navigator.pushNamed(
      context,
      AppRoutes.createDetailWoScreen,
      arguments: CreateDetailWoArgs(
        category: category,
        type: type,
        categoryLabel: options.categoryLabel(category),
        typeLabel: options.workTypeLabel(category, type),
        technician: _technicianName,
        workOrderId: (detail['work_order_id'] ?? '').toString(),
        detail: detail,
      ),
    );

    if (mounted) await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = ref.watch(workOrderOptionsProvider);
    final detail = _detail;

    if (_isLoading || detail == null) {
      return const Scaffold(
        backgroundColor: AppStyles.bgColor,
        body: FullScreenLoading(opacity: 0),
      );
    }

    final category = detail['work_category']?.toString() ?? '';
    final type = detail['work_type']?.toString() ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: AppStyles.blackColor,
            onPressed: () async {
              if (await _confirmLeave() && mounted) Navigator.pop(context);
            },
          ),
          title: Text(t.woDetailsTitle, style: AppStyles.textMdBold),
        ),

        bottomNavigationBar: _isCompleted
            ? null
            : Container(
                color: AppStyles.whiteColor,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _openEdit,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(
                              color: AppStyles.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            t.woDetailsEdit,
                            style: AppStyles.textMd.copyWith(
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _openActionSheet,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: AppStyles.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            t.woDetailsSave,
                            style: AppStyles.textMd.copyWith(
                              color: AppStyles.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: SegmentedTabBar(
                      labels: [t.woTabDetails, t.woTabEvidence, t.woTabNotes],
                      activeIndex: _activeTab,
                      onChanged: (i) => setState(() => _activeTab = i),
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _activeTab,
                      children: [
                        DetailsTab(
                          categoryLabel: options.categoryLabel(category),
                          typeLabel: options.workTypeLabel(category, type),
                          rawCategory: category,
                          rawType: type,
                          licensePlate: (detail['license_plate'] ?? '-')
                              .toString(),
                          technician: _technicianName,
                          activity: _activity,
                        ),
                        EvidenceTab(
                          beforeImages: _beforeImages,
                          afterImages: _afterImages,
                          readOnly: _isCompleted,
                          onSlotChanged: _onSlotChanged,
                          onRemoteImageRemoved: (url) =>
                              _pendingDeleteUrls.add(url),
                        ),
                        NotesTab(
                          controller: _notesController,
                          readOnly: _isCompleted,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_isSaving) const Positioned.fill(child: FullScreenLoading()),
            ],
          ),
        ),
      ),
    );
  }
}
