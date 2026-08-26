// ignore_for_file: use_build_context_synchronously

import 'package:ams/base/network/api_response.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/app_toast.dart';
import 'package:ams/base/widgets/confirm_dialog.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/models/work_order_args.dart';
import 'package:ams/screens/work_order/pages/create_detail_wo/widgets/review_form.dart';
import 'package:ams/screens/work_order/pages/create_detail_wo/widgets/step_one_form.dart';
import 'package:ams/screens/work_order/pages/create_detail_wo/widgets/step_two_form.dart';
import 'package:ams/screens/work_order/providers/work_order_providers.dart';
import 'package:ams/screens/work_order/services/work_order_api.dart';
import 'package:ams/screens/work_order/utils/format_label.dart';
import 'package:ams/screens/work_order/utils/work_order_validation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Padanan `pages/work-order/pages/create-detail-wo/create-detail-wo.jsx`.
/// Wizard 2–3 langkah untuk membuat atau memperbarui satu pekerjaan.
class CreateDetailWoScreen extends ConsumerStatefulWidget {
  final CreateDetailWoArgs args;

  const CreateDetailWoScreen({super.key, required this.args});

  @override
  ConsumerState<CreateDetailWoScreen> createState() =>
      _CreateDetailWoScreenState();
}

enum _StepKey { details, information, review }

class _CreateDetailWoScreenState extends ConsumerState<CreateDetailWoScreen> {
  final _stepOneKey = GlobalKey<FormState>();
  final _stepTwoKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};

  late Map<String, dynamic> _stepOne;
  late Map<String, dynamic> _stepTwo;

  WorkOrderDetailOptions _detailOptions = WorkOrderDetailOptions.empty;
  Map<String, dynamic>? _vehicleInfo;

  int _activeStep = 0;
  bool _isBusy = false;

  CreateDetailWoArgs get _args => widget.args;

  List<_StepKey> get _steps {
    if (isInspection(_args.type)) {
      return [_StepKey.details, _StepKey.information, _StepKey.review];
    }
    if (isDismantle(_args.type)) {
      return [_StepKey.details, _StepKey.review];
    }
    return [_StepKey.details, _StepKey.information, _StepKey.review];
  }

  @override
  void initState() {
    super.initState();
    _stepOne = _initialStepOne();
    _stepTwo = _initialStepTwo();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetailOptions());
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: (_stepOne[key] ?? _stepTwo[key] ?? '').toString(),
      ),
    );
  }

  Map<String, dynamic> _initialStepOne() {
    final base = <String, dynamic>{
      'work_category': _args.category,
      'work_category_label': _args.categoryLabel,
      'work_type': _args.type,
      'work_type_label': _args.typeLabel,
      'technician': _args.technician,
    };

    final detail = _args.detail;
    if (detail == null) return base;

    final activity = detail['activity'];
    final activityMap = activity is Map ? activity : const {};

    return {
      ...base,
      'license_plate': (detail['license_plate'] ?? '').toString(),
      'license_plate_label': (detail['license_plate'] ?? '').toString(),
      'odometer': (activityMap['odometer'] ?? '').toString(),
      'device_condition': (activityMap['device_condition'] ?? '').toString(),
      'device_condition_label': (activityMap['device_condition'] ?? '')
          .toString(),
    };
  }

  Map<String, dynamic> _initialStepTwo() {
    final kind = resolveFormKind(_args.category, _args.type);
    final detail = _args.detail;
    final activity = detail?['activity'];
    final a = activity is Map ? activity : const {};

    String v(String key, [String fallback = '']) =>
        (a[key] ?? fallback).toString();

    switch (kind) {
      case WorkDetailFormKind.gpsInspection:
        return {
          'action': v('action'),
          'action_label': formatStatus(v('action')),
          'result': v('result'),
          'simcard_number': v('simcard_number'),
          'imei': v('imei'),
        };

      case WorkDetailFormKind.inspection:
        return {
          'action': v('action'),
          'action_label': formatStatus(v('action')),
          'result': v('result'),
        };

      case WorkDetailFormKind.simCardReplacement:
        return {'simcard_number': v('simcard_number')};

      case WorkDetailFormKind.gpsInstallationReplacement:
        return {
          'device_type': v('device_type', 'Teltonika'),
          'device_model': v('device_model'),
          'simcard_number': v('simcard_number'),
          'imei': v('imei'),
        };

      case WorkDetailFormKind.dashcamInstallationReplacement:
        return {
          'dashcam_type': v('dashcam_type'),
          'dashcam_type_label': v('dashcam_type'),
          'imei': v('imei'),
          'simcard_number': v('simcard_number'),
          'dashcam_position': v('dashcam_position'),
          'dashcam_position_label': v('dashcam_position'),
        };

      case WorkDetailFormKind.sensorInstallationReplacement:
        return {
          'sensor_type': v('sensor_type'),
          'sensor_type_label': v('sensor_type'),
          'sensor_serial_number': v('sensor_serial_number'),
          'sensor_position': v('sensor_position'),
          'sensor_position_label': v('sensor_position'),
        };

      case WorkDetailFormKind.none:
        return {};
    }
  }

  Future<void> _loadDetailOptions() async {
    try {
      final options = await ref
          .read(workOrderApiProvider)
          .fetchDetailOptions(_args.category);
      if (!mounted) return;

      setState(() {
        _detailOptions = options;
        // Saat update, label pilihan baru bisa diisi setelah option-nya ada.
        _syncLabelsFromOptions();
      });
    } catch (_) {
      // Form tetap bisa dipakai; picker akan kosong sampai option termuat.
    }
  }

  void _syncLabelsFromOptions() {
    if (!_args.isUpdate) return;

    String labelOf(List options, String? value) {
      for (final o in options) {
        if (o.value == value) return o.label as String;
      }
      return value ?? '';
    }

    if (_stepTwo.containsKey('sensor_type')) {
      _stepTwo['sensor_type_label'] = labelOf(
        _detailOptions.option,
        _stepTwo['sensor_type']?.toString(),
      );
      _stepTwo['sensor_position_label'] = labelOf(
        _detailOptions.position,
        _stepTwo['sensor_position']?.toString(),
      );
    }
    if (_stepTwo.containsKey('dashcam_type')) {
      _stepTwo['dashcam_type_label'] = labelOf(
        _detailOptions.option,
        _stepTwo['dashcam_type']?.toString(),
      );
      _stepTwo['dashcam_position_label'] = labelOf(
        _detailOptions.position,
        _stepTwo['dashcam_position']?.toString(),
      );
    }
    if (_stepTwo.containsKey('action')) {
      _stepTwo['action_label'] = labelOf(
        _detailOptions.action,
        _stepTwo['action']?.toString(),
      );
    }
    if (_stepOne.containsKey('device_condition')) {
      _stepOne['device_condition_label'] = labelOf(
        _detailOptions.condition,
        _stepOne['device_condition']?.toString(),
      );
    }
  }

  Future<void> _next() async {
    final t = AppLocalizations.of(context);
    final step = _steps[_activeStep];

    if (step == _StepKey.details) {
      if (!(_stepOneKey.currentState?.validate() ?? true)) return;

      // Untuk pekerjaan GPS selain pemasangan baru, tampilkan perangkat yang
      // sekarang terpasang di step berikutnya.
      if (isGpsCategory(_args.category) &&
          _args.type.toLowerCase() != 'installation') {
        setState(() => _isBusy = true);
        try {
          final info = await ref
              .read(workOrderApiProvider)
              .vehicleInformation(_stepOne['license_plate']?.toString() ?? '');
          if (!mounted) return;
          setState(() => _vehicleInfo = info);
        } catch (_) {
          if (!mounted) return;
          AppToast.showFailed(context, t.woVehicleInfoFailed);
          return;
        } finally {
          if (mounted) setState(() => _isBusy = false);
        }
      }
    }

    if (step == _StepKey.information) {
      if (!(_stepTwoKey.currentState?.validate() ?? true)) return;
    }

    if (_activeStep < _steps.length - 1) {
      setState(() => _activeStep++);
      return;
    }

    await _confirmSubmit();
  }

  Future<void> _confirmSubmit() async {
    final t = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: t.woSubmitConfirmTitle,
        desc: t.woSubmitConfirmMessage,
        textCancel: t.cancel,
        textSubmit: t.confirm,
        funcSubmit: _submit,
      ),
    );
  }

  Map<String, dynamic> _stripLabels(Map<String, dynamic> source) {
    return {
      for (final entry in source.entries)
        if (!entry.key.endsWith('_label')) entry.key: entry.value,
    };
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    setState(() => _isBusy = true);

    try {
      final payload = <String, dynamic>{
        'work_order_id': _args.workOrderId,
        ..._stripLabels(_stepOne),
        ..._stripLabels(_stepTwo),
        'work_category': formatPayloadKey(_args.category),
        'work_type': formatPayloadKey(_args.type),
        if (_args.isUpdate) ...{'is_complete': 0, 'id': _args.detail?['id']},
      };

      await ref.read(workOrderApiProvider).createWorkOrderDetail(payload);
      if (!mounted) return;

      AppToast.show(
        context,
        _args.isUpdate ? t.woUpdateDetailSuccess : t.woCreateDetailSuccess,
      );
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      AppToast.showFailed(
        context,
        apiErrorText(
          e,
          _args.isUpdate ? t.woUpdateDetailFailed : t.woCreateDetailFailed,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.showFailed(
        context,
        _args.isUpdate ? t.woUpdateDetailFailed : t.woCreateDetailFailed,
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _stepLabel(BuildContext context, _StepKey key) {
    final t = AppLocalizations.of(context);

    switch (key) {
      case _StepKey.details:
        return t.woStepDetails;
      case _StepKey.information:
        return isInspection(_args.type)
            ? t.woStepInspection
            : t.woStepInformation;
      case _StepKey.review:
        return t.woStepReview;
    }
  }

  Widget _stepContent(_StepKey key) {
    switch (key) {
      case _StepKey.details:
        return Form(
          key: _stepOneKey,
          child: StepOneForm(
            category: _args.category,
            type: _args.type,
            data: _stepOne,
            controllerFor: _controllerFor,
            licensePlates: ref.watch(workOrderOptionsProvider).licensePlate,
            conditions: _detailOptions.condition,
            onChanged: (patch) => setState(() => _stepOne.addAll(patch)),
          ),
        );

      case _StepKey.information:
        return Form(
          key: _stepTwoKey,
          child: StepTwoForm(
            category: _args.category,
            type: _args.type,
            data: _stepTwo,
            controllerFor: _controllerFor,
            options: _detailOptions,
            vehicleInfo: _vehicleInfo,
            onChanged: (patch) => setState(() => _stepTwo.addAll(patch)),
          ),
        );

      case _StepKey.review:
        return ReviewForm(
          category: _args.category,
          type: _args.type,
          technician: _args.technician,
          stepOne: _stepOne,
          stepTwo: _stepTwo,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final steps = _steps;
    final isFirst = _activeStep == 0;
    final isLast = _activeStep == steps.length - 1;

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppStyles.blackColor),
        title: Text(
          _args.isUpdate ? t.woUpdateDetailTitle : t.woCreateDetailTitle,
          style: AppStyles.textMdBold,
        ),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppStyles.whiteColor,
          border: Border(top: BorderSide(color: AppStyles.borderLightGray)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isFirst || _isBusy
                      ? null
                      : () => setState(() => _activeStep--),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(
                      color: isFirst
                          ? AppStyles.borderLightGray
                          : AppStyles.primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    t.woStepPrev,
                    style: AppStyles.textMd.copyWith(
                      color: isFirst
                          ? AppStyles.textDarkGrayColor
                          : AppStyles.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isBusy ? null : _next,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppStyles.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isLast ? t.woStepSubmit : t.woStepNext,
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: _StepHeader(
                    labels: [
                      for (final step in steps) _stepLabel(context, step),
                    ],
                    activeIndex: _activeStep,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _stepContent(steps[_activeStep]),
                  ),
                ),
              ],
            ),

            if (_isBusy) const Positioned.fill(child: FullScreenLoading()),
          ],
        ),
      ),
    );
  }
}

/// Indikator langkah ringkas (nomor + label + garis penghubung).
class _StepHeader extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;

  const _StepHeader({required this.labels, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            _StepDot(
              index: i,
              label: labels[i],
              isActive: i == activeIndex,
              isDone: i < activeIndex,
            ),
            if (i != labels.length - 1)
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Divider(color: AppStyles.borderLightGray, height: 1),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final filled = isActive || isDone;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: filled
              ? AppStyles.primaryColor
              : AppStyles.borderLightGray,
          child: isDone
              ? const Icon(Icons.check, size: 13, color: AppStyles.whiteColor)
              : Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.whiteColor,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppStyles.textXs.copyWith(
            fontWeight: FontWeight.w700,
            color: filled ? AppStyles.blackColor : AppStyles.textDarkGrayColor,
          ),
        ),
      ],
    );
  }
}
