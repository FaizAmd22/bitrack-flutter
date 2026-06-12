// ignore_for_file: deprecated_member_use

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/vehicle_detail/models/dashcam_models.dart';
import 'package:ams/screens/vehicle_detail/widgets/dashcam_bottom_sheet.dart';
import 'package:ams/screens/vehicle_detail/widgets/vehicle_information_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonCard extends StatelessWidget {
  const ButtonCard({
    super.key,
    required this.hasDashcam,
    required this.vehicleId,
    this.vehicleData,
    this.onPeriodicTrack,
  });

  final bool hasDashcam;
  final String vehicleId;
  final Map<String, dynamic>? vehicleData;
  final VoidCallback? onPeriodicTrack;

  Future<void> _showSheet(BuildContext context, Widget sheet) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = vehicleId.trim();
    final translate = AppLocalizations.of(context);

    final dashcamConfig = (hasDashcam && id.isNotEmpty && vehicleData != null)
        ? DashcamConfig.fromVehicleDetail(vehicleData!)
        : null;

    final dashcamEnabled = dashcamConfig != null;

    return LayoutBuilder(
      builder: (context, c) {
        const spacing = 10.0;
        final itemWidth = (c.maxWidth - spacing) / 2;

        return Column(
          children: [
            _MenuCard(
              icon: 'truck-regular.svg',
              label: translate.vehicleInformation,
              onTap: () =>
                  _showSheet(context, const VehicleInformationBottomSheet()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _MenuCard(
                    icon: 'route-regular.svg',
                    label: 'Periodic Track',
                    onTap: onPeriodicTrack,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: itemWidth,
                  child: _MenuCard(
                    icon: 'webcam.svg',
                    label: 'Dashcam',
                    enabled: dashcamEnabled,
                    onTap: dashcamEnabled
                        ? () => _showSheet(
                            context,
                            DashcamBottomSheet(dashcamConfig: dashcamConfig),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? AppStyles.blackColor : Colors.black38;
    final arrow = enabled ? AppStyles.primaryColor : Colors.black26;

    return SizedBox(
      height: 70,
      child: Material(
        color: AppStyles.whiteColor,
        elevation: 6,
        shadowColor: AppStyles.blackColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/$icon',
                  width: 20,
                  height: 20,
                  color: fg,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppStyles.textSm.copyWith(color: fg),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: arrow),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
