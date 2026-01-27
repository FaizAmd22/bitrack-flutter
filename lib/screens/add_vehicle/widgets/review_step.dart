// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key, required this.data});

  final AddVehicleFormData data;

  String _v(String? s) => (s == null || s.trim().isEmpty) ? '-' : s.trim();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final installDate = data.installationDate == null
        ? '-'
        : DateFormat('d MMMM y', locale).format(data.installationDate!);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          _ReviewCard(
            title: t.vehicleInformation,
            rows: [
              _ReviewRow(t.plateNumber, _v(data.plateNumber)),
              _ReviewRow(t.brand, _v(data.brand)),
              _ReviewRow(t.model, _v(data.model)),
              _ReviewRow(t.vehicleType, _v(data.type)),
              _ReviewRow(t.vehicleYear, _v(data.year)),
              _ReviewRow(t.vehicleColor, _v(data.color)),
              _ReviewRow(t.vehicleCategory, _v(data.vehicleCategory)),
              _ReviewRow(t.odometerKm, _v(data.odometerKm)),
              _ReviewRow(t.vin, _v(data.vin)),
              _ReviewRow(t.engineNumber, _v(data.engineNumber)),
            ],
          ),
          const SizedBox(height: 14),
          _ReviewCard(
            title: t.deviceInformation,
            rows: [
              _ReviewRow(t.installationDate, installDate),
              _ReviewRow(t.deviceType, _v(data.deviceTypeCode)),
              _ReviewRow(t.deviceModel, _v(data.deviceModel)),
              _ReviewRow(t.simCardNumber, _v(data.simCardNumber)),
              _ReviewRow(t.imeiObdNumber, _v(data.imeiObdNumber)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.rows});

  final String title;
  final List<_ReviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppStyles.textMdBold),
          const SizedBox(height: 10),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      r.label,
                      style: AppStyles.textSm.copyWith(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r.value,
                      textAlign: TextAlign.right,
                      style: AppStyles.textSm.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;
}
