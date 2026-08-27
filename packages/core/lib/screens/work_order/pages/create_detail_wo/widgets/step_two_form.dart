import 'package:bitrack_core/base/constants/select_options.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/option_picker_sheet.dart';
import 'package:bitrack_core/base/widgets/picker_field.dart';
import 'package:bitrack_core/base/widgets/tx_inputs.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/work_order/services/work_order_api.dart';
import 'package:bitrack_core/screens/work_order/utils/work_order_validation.dart';
import 'package:bitrack_core/screens/work_order/widgets/card_section.dart';
import 'package:flutter/material.dart';

/// Padanan `pages/create-detail-wo/components/step-two-form.jsx` beserta
/// seluruh form turunannya (GPS, dashcam, sensor, SIM, inspeksi).
class StepTwoForm extends StatelessWidget {
  final String category;
  final String type;
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> patch) onChanged;
  final TextEditingController Function(String key) controllerFor;
  final WorkOrderDetailOptions options;
  final Map<String, dynamic>? vehicleInfo;

  const StepTwoForm({
    super.key,
    required this.category,
    required this.type,
    required this.data,
    required this.onChanged,
    required this.controllerFor,
    required this.options,
    this.vehicleInfo,
  });

  @override
  Widget build(BuildContext context) {
    final kind = resolveFormKind(category, type);
    final showCurrentDevice =
        isGpsCategory(category) && type.toLowerCase() != 'installation';

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        if (showCurrentDevice) _CurrentDeviceCard(vehicleInfo: vehicleInfo),
        ..._fields(context, kind),
      ],
    );
  }

  List<Widget> _fields(BuildContext context, WorkDetailFormKind kind) {
    final t = AppLocalizations.of(context);

    switch (kind) {
      case WorkDetailFormKind.gpsInspection:
      case WorkDetailFormKind.inspection:
        return _inspectionFields(context, isGps: isGpsCategory(category));

      case WorkDetailFormKind.simCardReplacement:
        return [
          TxInputNumber(
            label: t.woSimReplacementTitle,
            hintText: t.woSimReplacementPlaceholder,
            controller: controllerFor('simcard_number'),
            validator: (v) => WoValidators.numeric(v, t.woSimCardNumeric),
            onChanged: (v) => onChanged({'simcard_number': v}),
          ),
        ];

      case WorkDetailFormKind.gpsInstallationReplacement:
        return _gpsFields(context);

      case WorkDetailFormKind.dashcamInstallationReplacement:
        return _dashcamFields(context);

      case WorkDetailFormKind.sensorInstallationReplacement:
        return _sensorFields(context);

      case WorkDetailFormKind.none:
        return const [];
    }
  }

  List<Widget> _inspectionFields(BuildContext context, {required bool isGps}) {
    final t = AppLocalizations.of(context);

    // Field SIM & IMEI hanya relevan saat hasil inspeksi GPS butuh penggantian.
    final needReplacement = data['action']?.toString() == 'NEED_REPLACEMENT';

    return [
      PickerField(
        label: t.woInspectionAction,
        hintText: t.woInspectionActionPlaceholder,
        value: data['action']?.toString(),
        options: options.action
            .map((o) => PickerOption(value: o.value, label: o.label))
            .toList(),
        onSelected: (o) {
          final patch = <String, dynamic>{
            'action': o.value,
            'action_label': o.label,
          };

          if (isGps && o.value == 'NEED_REPLACEMENT' && vehicleInfo != null) {
            patch['simcard_number'] =
                vehicleInfo?['simcard_number']?.toString() ?? '';
            patch['imei'] = vehicleInfo?['imei_obd_number']?.toString() ?? '';
          } else if (o.value != 'NEED_REPLACEMENT') {
            patch['simcard_number'] = '';
            patch['imei'] = '';
          }

          controllerFor('simcard_number').text =
              patch['simcard_number']?.toString() ??
              controllerFor('simcard_number').text;
          controllerFor('imei').text =
              patch['imei']?.toString() ?? controllerFor('imei').text;

          onChanged(patch);
        },
      ),
      _Textarea(
        label: t.woInspectionResult,
        hintText: t.woInspectionResultPlaceholder,
        controller: controllerFor('result'),
        onChanged: (v) => onChanged({'result': v}),
      ),
      if (isGps && needReplacement) ...[
        TxInputNumber(
          label: t.woSimCardNumber,
          hintText: t.woSimCardNumberPlaceholder,
          controller: controllerFor('simcard_number'),
          validator: (v) => WoValidators.numeric(v, t.woSimCardNumeric),
          onChanged: (v) => onChanged({'simcard_number': v}),
        ),
        TxInputNumber(
          label: t.woImei,
          hintText: t.woImeiPlaceholder,
          controller: controllerFor('imei'),
          validator: WoValidators.chain([
            (v) => WoValidators.numeric(v, t.woImeiNumeric),
            (v) => WoValidators.maxLength(v, 15, t.woImeiMaxLength),
          ]),
          onChanged: (v) => onChanged({'imei': v}),
        ),
      ],
    ];
  }

  List<Widget> _gpsFields(BuildContext context) {
    final t = AppLocalizations.of(context);

    return [
      _ReadOnlyField(
        label: t.woDeviceType,
        value: (data['device_type'] ?? 'Teltonika').toString(),
      ),
      PickerField(
        label: t.woDeviceModel,
        hintText: t.woDeviceModelPlaceholder,
        value: data['device_model']?.toString(),
        options: deviceModelOptions
            .map((o) => PickerOption(value: o.value, label: o.label))
            .toList(),
        validator: (v) =>
            WoValidators.requiredField(v, t.woDeviceModelRequired),
        onSelected: (o) => onChanged({'device_model': o.value}),
      ),
      TxInputNumber(
        label: t.woSimCardNumber,
        hintText: t.woSimCardNumberPlaceholder,
        controller: controllerFor('simcard_number'),
        validator: (v) => WoValidators.numeric(v, t.woSimCardNumeric),
        onChanged: (v) => onChanged({'simcard_number': v}),
      ),
      TxInputNumber(
        label: t.woImei,
        hintText: t.woImeiPlaceholder,
        controller: controllerFor('imei'),
        validator: WoValidators.chain([
          (v) => WoValidators.numeric(v, t.woImeiNumeric),
          (v) => WoValidators.maxLength(v, 15, t.woImeiMaxLength),
        ]),
        onChanged: (v) => onChanged({'imei': v}),
      ),
    ];
  }

  List<Widget> _dashcamFields(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isReplacement = type.toLowerCase() == 'replacement';

    return [
      PickerField(
        label: t.woDashcamType,
        hintText: t.woDashcamTypePlaceholder,
        value: data['dashcam_type']?.toString(),
        options: options.option
            .map((o) => PickerOption(value: o.value, label: o.label))
            .toList(),
        validator: (v) =>
            WoValidators.requiredField(v, t.woDashcamTypeRequired),
        onSelected: (o) =>
            onChanged({'dashcam_type': o.value, 'dashcam_type_label': o.label}),
      ),
      TxInputNumber(
        label: t.woDashcamImei,
        hintText: t.woDashcamImeiPlaceholder,
        controller: controllerFor('imei'),
        validator: (v) => WoValidators.numeric(v, t.woDashcamImeiNumeric),
        onChanged: (v) => onChanged({'imei': v}),
      ),
      TxInputNumber(
        label: isReplacement ? t.woSimCardNumberOptional : t.woSimCardNumber,
        hintText: t.woSimCardNumberPlaceholder,
        controller: controllerFor('simcard_number'),
        validator: (v) => WoValidators.numeric(v, t.woSimCardNumeric),
        onChanged: (v) => onChanged({'simcard_number': v}),
      ),
      PickerField(
        label: t.woCameraPosition,
        hintText: t.woCameraPositionPlaceholder,
        value: data['dashcam_position']?.toString(),
        options: options.position
            .map((o) => PickerOption(value: o.value, label: o.label))
            .toList(),
        validator: (v) =>
            WoValidators.requiredField(v, t.woCameraPositionRequired),
        onSelected: (o) => onChanged({
          'dashcam_position': o.value,
          'dashcam_position_label': o.label,
        }),
      ),
    ];
  }

  List<Widget> _sensorFields(BuildContext context) {
    final t = AppLocalizations.of(context);

    // Hanya eye sensor yang punya nomor seri terpisah.
    final showSerialNumber = data['sensor_type']?.toString() == 'EYE_SENSOR';

    return [
      PickerField(
        label: t.woSensorType,
        hintText: t.woSensorTypePlaceholder,
        value: data['sensor_type']?.toString(),
        options: options.option
            .map((o) => PickerOption(value: o.value, label: o.label))
            .toList(),
        validator: (v) => WoValidators.requiredField(v, t.woSensorTypeRequired),
        onSelected: (o) =>
            onChanged({'sensor_type': o.value, 'sensor_type_label': o.label}),
      ),
      if (showSerialNumber)
        TxInputText(
          label: t.woSensorSerialNumber,
          hintText: t.woSensorSerialNumberPlaceholder,
          controller: controllerFor('sensor_serial_number'),
          onChanged: (v) => onChanged({'sensor_serial_number': v}),
        ),
      PickerField(
        label: t.woSensorPosition,
        hintText: t.woSensorPositionPlaceholder,
        value: data['sensor_position']?.toString(),
        options: options.position
            .map((o) => PickerOption(value: o.value, label: o.label))
            .toList(),
        validator: (v) =>
            WoValidators.requiredField(v, t.woSensorPositionRequired),
        onSelected: (o) => onChanged({
          'sensor_position': o.value,
          'sensor_position_label': o.label,
        }),
      ),
    ];
  }
}

/// Padanan `current-device-information-card.jsx`: ringkasan perangkat yang
/// saat ini terpasang, supaya teknisi bisa membandingkan sebelum mengganti.
class _CurrentDeviceCard extends StatelessWidget {
  final Map<String, dynamic>? vehicleInfo;

  const _CurrentDeviceCard({required this.vehicleInfo});

  String _value(String key) {
    final raw = vehicleInfo?[key]?.toString().trim();
    return (raw == null || raw.isEmpty) ? '-' : raw;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return CardSection(
      title: t.woCurrentDeviceTitle,
      children: [
        RowItem(
          label: t.woCurrentDeviceType,
          value: _value('device_type_code'),
        ),
        RowItem(
          label: t.woCurrentDeviceModel,
          value: _value('device_model_code'),
        ),
        RowItem(
          label: t.woCurrentDeviceSimCard,
          value: _value('simcard_number'),
        ),
        RowItem(label: t.woCurrentDeviceImei, value: _value('imei_obd_number')),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.textMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: AppStyles.inputDisableBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: AppStyles.textMd.copyWith(color: AppStyles.darkGrayColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _Textarea extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _Textarea({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.textMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 5,
            style: AppStyles.textMd.copyWith(color: AppStyles.blackColor),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppStyles.textMd.copyWith(
                color: AppStyles.textDarkGrayColor,
              ),
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppStyles.borderLightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppStyles.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
