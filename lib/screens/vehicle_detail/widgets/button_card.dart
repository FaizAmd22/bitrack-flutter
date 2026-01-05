// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/dashcam_bottom_sheet.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/vehicle_information_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonCard extends StatelessWidget {
  final bool hasDashcam;
  final String vehicleId;

  const ButtonCard({
    super.key,
    required this.hasDashcam,
    required this.vehicleId,
  });

  Future<void> _showSheet(BuildContext context, Widget sheet) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          _MenuCard(
            icon: "truck-regular.svg",
            label: "Vehicle Information",
            onTap: () => _showSheet(
              context,
              VehicleInformationBottomSheet(vehicleId: vehicleId),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (hasDashcam) ...[
                Flexible(
                  child: _MenuCard(
                    icon: "webcam.svg",
                    label: "Dashcam",
                    onTap: () =>
                        _showSheet(context, const DashcamBottomSheet()),
                  ),
                ),
                const SizedBox(width: 5),
              ],

              Flexible(
                child: _MenuCard(
                  icon: "route-regular.svg",
                  label: "Periodic Track",
                  onTap: () {
                    // TODO
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Material(
        color: AppStyles.whiteColor,
        elevation: 6,
        shadowColor: AppStyles.blackColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/$icon',
                  width: 20,
                  height: 20,
                  color: AppStyles.blackColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppStyles.textSm.copyWith(
                      color: AppStyles.blackColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppStyles.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
