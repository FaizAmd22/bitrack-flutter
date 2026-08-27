import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/work_order/utils/format_label.dart';
import 'package:bitrack_core/screens/work_order/utils/work_order_validation.dart';
import 'package:bitrack_core/screens/work_order/widgets/card_section.dart';
import 'package:flutter/material.dart';

/// Padanan `pages/create-detail-wo/components/review-form.jsx`.
class ReviewForm extends StatelessWidget {
  final String category;
  final String type;
  final String technician;
  final Map<String, dynamic> stepOne;
  final Map<String, dynamic> stepTwo;

  const ReviewForm({
    super.key,
    required this.category,
    required this.type,
    required this.technician,
    required this.stepOne,
    required this.stepTwo,
  });

  String? _s(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Label baris step dua: pakai nama teknis untuk key yang punya arti khusus,
  /// sisanya di-Title Case dari nama field-nya.
  String _labelOf(String key, AppLocalizations t) {
    final normalized = key.toLowerCase();
    final normalizedType = type.toLowerCase();

    if (normalized == 'imei') {
      return category.toLowerCase() == 'dashcam'
          ? t.woDashcamImei
          : t.vehicleInfoImei;
    }
    if (normalized == 'simcard_number') {
      return normalizedType.contains('sim card replacement')
          ? t.woSimReplacementTitle
          : t.simCardNumber;
    }
    return formatStatus(key);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final dismantle = isDismantle(type);
    final gps = isGpsCategory(category);

    final stepTwoRows = stepTwo.entries
        .where((e) => !e.key.endsWith('_label'))
        .map(
          (e) => RowItem(
            label: _labelOf(e.key, t),
            // Kalau ada label tampilannya, pakai itu; kalau tidak, nilai mentah.
            value: _s(stepTwo['${e.key}_label']) ?? _s(e.value),
          ),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        CardSection(
          title: t.woReviewWorkDetails,
          children: [
            RowItem(
              label: t.woJobCategory,
              value: _s(
                stepOne['work_category_label'] ?? stepOne['work_category'],
              ),
            ),
            RowItem(
              label: t.woJobType,
              value: _s(stepOne['work_type_label'] ?? stepOne['work_type']),
            ),
            RowItem(
              label: t.woLicensePlate,
              value:
                  _s(stepOne['license_plate_label']) ??
                  _s(stepOne['license_plate']),
            ),
            if (gps && !dismantle)
              RowItem(label: t.woOdometer, value: _s(stepOne['odometer'])),
            RowItem(label: t.woTechnician, value: technician),
            if (dismantle)
              RowItem(
                label: t.woDeviceCondition,
                value: _s(
                  stepOne['device_condition_label'] ??
                      stepOne['device_condition'],
                ),
              ),
          ],
        ),

        if (!dismantle && stepTwoRows.isNotEmpty)
          CardSection(
            title: isInspection(type)
                ? t.woInspectionInformation
                : t.woDeviceInformation,
            children: stepTwoRows,
          ),
      ],
    );
  }
}
