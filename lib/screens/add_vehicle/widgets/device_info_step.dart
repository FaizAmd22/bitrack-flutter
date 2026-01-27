import 'package:bitrack_mobile_flutter/base/constants/select_options.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/tx_inputs.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:flutter/material.dart';

class DeviceInfoStep extends StatefulWidget {
  const DeviceInfoStep({super.key, required this.data, required this.formKey});

  final AddVehicleFormData data;
  final GlobalKey<FormState> formKey;

  @override
  State<DeviceInfoStep> createState() => _DeviceInfoStepState();
}

class _DeviceInfoStepState extends State<DeviceInfoStep> {
  DateTime? _installationDate;
  String? _deviceTypeCode;
  String? _deviceModel;

  late final TextEditingController _simCtrl;
  late final TextEditingController _imeiCtrl;

  @override
  void initState() {
    super.initState();

    _installationDate = widget.data.installationDate;
    _deviceTypeCode = widget.data.deviceTypeCode;
    _deviceModel = widget.data.deviceModel;

    _simCtrl = TextEditingController(text: widget.data.simCardNumber);
    _imeiCtrl = TextEditingController(text: widget.data.imeiObdNumber);
  }

  @override
  void dispose() {
    _simCtrl.dispose();
    _imeiCtrl.dispose();
    super.dispose();
  }

  String? _requiredText(BuildContext context, String? v, String fieldName) {
    final t = AppLocalizations.of(context);
    if (v == null || v.trim().isEmpty) {
      return t.fieldRequired(fieldName);
    }
    return null;
  }

  String? _requiredDropdown(BuildContext context, dynamic v, String fieldName) {
    final t = AppLocalizations.of(context);
    if (v == null) {
      return t.fieldRequired(fieldName);
    }
    return null;
  }

  String? _requiredDate(BuildContext context, DateTime? v, String fieldName) {
    final t = AppLocalizations.of(context);
    if (v == null) {
      return t.fieldRequired(fieldName);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final validCodes = deviceTypeOptions.map((e) => e.value).toSet();
    if (!validCodes.contains(_deviceTypeCode)) {
      _deviceTypeCode = deviceTypeOptions.first.value;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppStyles.whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.only(top: 15),
      child: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TxInputDate(
                label: t.installationDate,
                hintText: t.installationDateHint,
                value: _installationDate,
                validator: (v) => _requiredDate(context, v, t.installationDate),
                onChanged: (d) {
                  setState(() => _installationDate = d);
                  widget.data.installationDate = d;
                },
              ),

              TxInputDropdown<String>(
                label: t.deviceType,
                hintText: t.deviceTypeHint,
                value: _deviceTypeCode,
                items: deviceTypeOptions
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.label),
                      ),
                    )
                    .toList(),
                enabled: false,
                onChanged: (v) {
                  setState(() => _deviceTypeCode = v);
                  widget.data.deviceTypeCode = v ?? 'TELTONIKA';
                },
              ),

              TxInputDropdown<String>(
                label: t.deviceModel,
                hintText: t.deviceModelHint,
                value: _deviceModel,
                items: deviceModelOptions
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.label),
                      ),
                    )
                    .toList(),
                validator: (v) => _requiredDropdown(context, v, t.deviceModel),
                onChanged: (v) {
                  setState(() => _deviceModel = v);
                  widget.data.deviceModel = v;
                },
              ),

              TxInputNumber(
                label: t.simCardNumber,
                hintText: 'Enter SIM Card Number ...',
                controller: _simCtrl,
                validator: (v) => _requiredText(context, v, t.simCardNumber),
                onChanged: (v) => widget.data.simCardNumber = v,
              ),

              TxInputNumber(
                label: t.imeiObdNumber,
                hintText: 'Enter IMEI OBD Number ...',
                controller: _imeiCtrl,
                validator: (v) => _requiredText(context, v, t.imeiObdNumber),
                onChanged: (v) => widget.data.imeiObdNumber = v,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
