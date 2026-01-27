// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';

class CardVehicle extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final String language;
  final VoidCallback? onTap;

  const CardVehicle({
    super.key,
    required this.vehicle,
    this.language = 'id',
    this.onTap,
  });

  bool _isActive(dynamic status) {
    final s = status is int ? status : int.tryParse('$status') ?? 1;
    return s == 1;
  }

  String _s(dynamic v, {String fallback = '-'}) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _formatDateCard(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';
    final locale = (language == 'id') ? 'en_US' : 'en_US';
    final raw = dateStr.trim();

    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(raw);
      return DateFormat('d MMM yyyy', locale).format(dt);
    } catch (_) {
      try {
        final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
        return DateFormat('d MMM yyyy', locale).format(dt);
      } catch (_) {
        return raw;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _isActive(vehicle['status']);
    final translate = AppLocalizations.of(context);

    final badgeBg = active ? AppStyles.bgGreenColor : AppStyles.bgRedColor;
    final badgeFg = active ? AppStyles.greenColor : AppStyles.redColor;
    final badgeText = active ? translate.active : translate.inactive;

    final createdAt = _formatDateCard(vehicle['created_at']?.toString());

    final plate = _s(vehicle['license_plate']);
    final brand = _s(vehicle['vehicle_brand'], fallback: '');
    final model = _s(vehicle['vehicle_model'], fallback: '');
    final year = _s(vehicle['vehicle_year'], fallback: '');

    final fleetName = _s(vehicle['fleet_group_name'], fallback: '-');

    final muted = AppStyles.darkGrayColor.withOpacity(0.65);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppStyles.whiteColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              translate.createdAt,
                              style: AppStyles.textSm.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                createdAt,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.textSm.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: AppStyles.textSm.copyWith(
                            color: badgeFg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.06),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plate,
                          style: AppStyles.textMdBold.copyWith(
                            color: AppStyles.blackColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          [
                            brand,
                            model,
                            year,
                          ].where((e) => e.trim().isNotEmpty).join(' '),
                          style: AppStyles.textSm.copyWith(
                            color: AppStyles.blackColor.withOpacity(0.72),
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          fleetName,
                          style: AppStyles.textSm.copyWith(
                            color: AppStyles.blackColor.withOpacity(0.72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
