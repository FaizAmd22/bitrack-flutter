import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/utils/format_label.dart';
import 'package:ams/screens/work_order/utils/work_order_validation.dart';
import 'package:ams/screens/work_order/widgets/card_section.dart';
import 'package:flutter/material.dart';

/// Padanan `pages/work-details/components/details-tab.jsx`.
class DetailsTab extends StatelessWidget {
  final String categoryLabel;
  final String typeLabel;
  final String rawCategory;
  final String rawType;
  final String licensePlate;
  final String technician;
  final Map<String, dynamic> activity;

  const DetailsTab({
    super.key,
    required this.categoryLabel,
    required this.typeLabel,
    required this.rawCategory,
    required this.rawType,
    required this.licensePlate,
    required this.technician,
    required this.activity,
  });

  String? _s(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }

  List<Widget> _informationRows(AppLocalizations t) {
    switch (resolveFormKind(rawCategory, rawType)) {
      case WorkDetailFormKind.gpsInspection:
        return [
          RowItem(
            label: t.woInspectionAction,
            value: formatStatus(_s(activity['action'])),
          ),
          RowItem(
            label: t.woLabelInspectionNote,
            value: _s(activity['result']),
          ),
          RowItem(
            label: t.simCardNumber,
            value: _s(activity['simcard_number']),
          ),
          RowItem(label: t.vehicleInfoImei, value: _s(activity['imei'])),
        ];

      case WorkDetailFormKind.inspection:
        return [
          RowItem(
            label: t.woInspectionAction,
            value: formatStatus(_s(activity['action'])),
          ),
          RowItem(
            label: t.woLabelInspectionNote,
            value: _s(activity['result']),
          ),
        ];

      case WorkDetailFormKind.simCardReplacement:
        return [
          RowItem(
            label: t.woSimReplacementTitle,
            value: _s(activity['simcard_number']),
          ),
        ];

      case WorkDetailFormKind.gpsInstallationReplacement:
        return [
          RowItem(label: t.deviceType, value: _s(activity['device_type'])),
          RowItem(label: t.deviceModel, value: _s(activity['device_model'])),
          RowItem(label: t.vehicleInfoImei, value: _s(activity['imei'])),
          RowItem(
            label: t.simCardNumber,
            value: _s(activity['simcard_number']),
          ),
        ];

      case WorkDetailFormKind.dashcamInstallationReplacement:
        return [
          RowItem(label: t.woDashcamType, value: _s(activity['dashcam_type'])),
          RowItem(label: t.woDashcamImei, value: _s(activity['imei'])),
          RowItem(
            label: t.woSimCardNumberOptional,
            value: _s(activity['simcard_number']),
          ),
          RowItem(
            label: t.woCameraPosition,
            value: _s(activity['dashcam_position']),
          ),
        ];

      case WorkDetailFormKind.sensorInstallationReplacement:
        return [
          RowItem(
            label: t.woSensorPosition,
            value: formatStatus(_s(activity['sensor_position'])),
          ),
          RowItem(
            label: t.woLabelSensorSerialNumber,
            value: _s(activity['sensor_serial_number']),
          ),
          RowItem(
            label: t.woSensorType,
            value: formatStatus(_s(activity['sensor_type'])),
          ),
        ];

      case WorkDetailFormKind.none:
        // Tipe pekerjaan lain (mis. dismantle) tidak punya blok informasi.
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final dismantle = isDismantle(rawType);
    final gps = rawCategory.toUpperCase() == 'GPS';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        CardSection(
          title: t.woWorkInformation,
          children: [
            RowItem(label: t.woJobCategory, value: categoryLabel),
            RowItem(label: t.woJobType, value: typeLabel),
            RowItem(label: t.woLicensePlate, value: licensePlate),
            if (gps && !dismantle)
              RowItem(label: t.woOdometer, value: _s(activity['odometer'])),
            RowItem(label: t.woLabelTechnicianName, value: technician),
            if (dismantle)
              RowItem(
                label: t.woDeviceCondition,
                value: formatStatus(_s(activity['device_condition'])),
              ),
          ],
        ),

        if (!dismantle)
          CardSection(
            title: isInspection(rawType)
                ? t.woInspectionInformation
                : t.woDeviceInformation,
            children: _informationRows(t),
          ),
      ],
    );
  }
}
