import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/option_picker_sheet.dart';
import 'package:ams/base/widgets/picker_field.dart';
import 'package:ams/base/widgets/plate_input_formatter.dart';
import 'package:ams/base/widgets/tx_inputs.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/models/work_order_options.dart';
import 'package:ams/screens/work_order/utils/work_order_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Padanan `pages/create-detail-wo/components/step-one-form.jsx`.
class StepOneForm extends StatefulWidget {
  final String category;
  final String type;
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> patch) onChanged;
  final TextEditingController Function(String key) controllerFor;
  final List<OptionItem> licensePlates;
  final List<OptionItem> conditions;

  const StepOneForm({
    super.key,
    required this.category,
    required this.type,
    required this.data,
    required this.onChanged,
    required this.controllerFor,
    required this.licensePlates,
    required this.conditions,
  });

  @override
  State<StepOneForm> createState() => _StepOneFormState();
}

class _StepOneFormState extends State<StepOneForm> {
  bool _useChassisNumber = false;

  String get _normalizedCategory => widget.category.toLowerCase();
  String get _normalizedType => widget.type.toLowerCase();

  /// Untuk pemasangan baru, kendaraan belum tentu terdaftar sehingga plat
  /// diketik manual (atau pakai nomor rangka).
  bool get _isFreeTextPlate =>
      (_normalizedCategory == 'gps' || _normalizedCategory == 'dashcam') &&
      _normalizedType == 'installation';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final gps = _normalizedCategory == 'gps';
    final dismantle = isDismantle(widget.type);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        _DisabledField(
          label: t.woJobCategory,
          value:
              (widget.data['work_category_label'] ??
                      widget.data['work_category'] ??
                      '')
                  .toString(),
        ),
        _DisabledField(
          label: t.woJobType,
          value:
              (widget.data['work_type_label'] ?? widget.data['work_type'] ?? '')
                  .toString(),
        ),

        if (_isFreeTextPlate) ...[
          CheckboxListTile(
            value: _useChassisNumber,
            onChanged: (value) {
              setState(() => _useChassisNumber = value ?? false);
              widget.controllerFor('license_plate').clear();
              widget.onChanged({'license_plate': ''});
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            activeColor: AppStyles.primaryColor,
            title: Text(
              t.woUseChassisNumber,
              style: AppStyles.textSm.copyWith(
                color: AppStyles.textDarkGrayColor,
              ),
            ),
          ),
          TxInputText(
            label: _useChassisNumber ? t.woChassisNumber : t.woLicensePlate,
            hintText: _useChassisNumber
                ? t.woChassisNumberPlaceholder
                : t.woLicensePlatePlaceholder,
            controller: widget.controllerFor('license_plate'),
            textInputAction: TextInputAction.next,
            inputFormatters: _useChassisNumber
                ? [UpperCaseTextFormatter()]
                : const [PlateInputFormatter()],
            validator: (value) =>
                WoValidators.requiredField(value, t.woLicensePlateRequired),
            onChanged: (value) => widget.onChanged({'license_plate': value}),
          ),
        ] else
          PickerField(
            label: t.woLicensePlate,
            hintText: t.woLicensePlatePlaceholder,
            searchable: true,
            searchHint: t.filterSearch,
            value: widget.data['license_plate']?.toString(),
            options: widget.licensePlates
                .map((o) => PickerOption(value: o.value, label: o.label))
                .toList(),
            validator: (value) =>
                WoValidators.requiredField(value, t.woLicensePlateRequired),
            onSelected: (o) => widget.onChanged({
              'license_plate': o.value,
              'license_plate_label': o.label,
            }),
          ),

        if (gps && !dismantle)
          TxInputNumber(
            label: t.woOdometer,
            hintText: t.woOdometerPlaceholder,
            controller: widget.controllerFor('odometer'),
            validator: (value) =>
                WoValidators.numeric(value, t.woOdometerNumeric),
            onChanged: (value) => widget.onChanged({'odometer': value}),
          ),

        _DisabledField(
          label: t.woTechnician,
          value: (widget.data['technician'] ?? '').toString(),
        ),

        if (gps && dismantle)
          PickerField(
            label: t.woDeviceCondition,
            hintText: t.woDeviceConditionPlaceholder,
            value: widget.data['device_condition']?.toString(),
            options: widget.conditions
                .map((o) => PickerOption(value: o.value, label: o.label))
                .toList(),
            onSelected: (o) => widget.onChanged({
              'device_condition': o.value,
              'device_condition_label': o.label,
            }),
          ),
      ],
    );
  }
}

/// Field read-only bergaya sama dengan input lain (kategori/tipe/teknisi
/// sudah ditentukan saat penugasan, jadi tidak bisa diubah di sini).
class _DisabledField extends StatelessWidget {
  final String label;
  final String value;

  const _DisabledField({required this.label, required this.value});

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
              value.isEmpty ? '-' : value,
              style: AppStyles.textMd.copyWith(color: AppStyles.darkGrayColor),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
