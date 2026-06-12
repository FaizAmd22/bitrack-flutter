// ignore_for_file: deprecated_member_use

import 'package:ams/base/res/media.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/periodic_track_filter_sheet.dart';
import 'package:ams/screens/vehicle_detail/utils/vehicle_detail_safety.dart';
import 'package:ams/screens/vehicle_detail/widgets/indicator_card.dart';
import 'package:ams/screens/vehicle_detail/widgets/button_card.dart';
import 'package:flutter/material.dart';

class VehicleDetailContent extends StatelessWidget {
  final Map<String, dynamic> detailData;

  final String address;
  final bool loadingAddress;
  final bool hasDashcam;
  final bool dashcamOnline;
  final bool isChiller;
  final bool loadingDashcam;
  final Map<String, dynamic>? vehicleData; // ← tambahan

  const VehicleDetailContent({
    super.key,
    required this.detailData,
    required this.address,
    required this.loadingAddress,
    required this.hasDashcam,
    required this.dashcamOnline,
    required this.isChiller,
    required this.loadingDashcam,
    this.vehicleData, // ← opsional, null saat masih loading dashcam
  });

  static const _topRadius = BorderRadius.only(
    topLeft: Radius.circular(40),
    topRight: Radius.circular(40),
  );

  static final _shadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final plate = safeTextFrom(detailData, 'license_plate');
    final model = safeTextFrom(detailData, 'vehicle_model');
    final fleet = safeTextFrom(
      detailData,
      'fleet_group_name',
      fallback: '(unknown)',
    );
    final driver = safeTextFrom(detailData, 'driver_name');
    final vehicleId = safeTextFrom(
      detailData,
      'vehicle_id',
      fallback: '',
    ).trim();

    List<IndicatorItemData> buildIndicators() {
      final ignition = safeIntFrom(detailData, 'ignition') == 1;
      final fuel = safeDoubleFrom(detailData, 'fuel_consumed', fallback: 0);

      final dashcamLabel = !hasDashcam
          ? "N/A"
          : loadingDashcam
          ? "Dashcam..."
          : (dashcamOnline ? "Dashcam" : "N/A");

      final dashcamBg = !hasDashcam
          ? AppStyles.bgGrayColor
          : loadingDashcam
          ? AppStyles.bgYellowColor
          : (dashcamOnline ? AppStyles.bgGreenColor : AppStyles.bgGrayColor);

      final dashcamFg = !hasDashcam
          ? AppStyles.darkGrayColor
          : loadingDashcam
          ? AppStyles.yellowColor
          : (dashcamOnline ? AppStyles.greenColor : AppStyles.darkGrayColor);

      return [
        IndicatorItemData(
          icon: "engine.svg",
          label: ignition ? "Engine ON" : "Engine OFF",
          background: ignition ? AppStyles.bgGreenColor : AppStyles.bgGrayColor,
          color: ignition ? AppStyles.greenColor : AppStyles.darkGrayColor,
        ),
        IndicatorItemData(
          icon: "chiller.svg",
          label: isChiller ? "Chiller Unit" : "N/A",
          background: isChiller
              ? AppStyles.bgGreenColor
              : AppStyles.bgGrayColor,
          color: isChiller ? AppStyles.greenColor : AppStyles.darkGrayColor,
        ),
        IndicatorItemData(
          icon: "fuel.svg",
          label: "${fuel.toStringAsFixed(0)} %",
          background: fuel <= 25
              ? AppStyles.bgRedColor
              : fuel <= 50
              ? AppStyles.bgYellowColor
              : AppStyles.bgGreenColor,
          color: fuel <= 25
              ? AppStyles.redColor
              : fuel <= 50
              ? AppStyles.yellowColor
              : AppStyles.greenColor,
        ),
        IndicatorItemData(
          icon: "webcam.svg",
          label: dashcamLabel,
          background: dashcamBg,
          color: dashcamFg,
        ),
      ];
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: size.width,
        height: size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppStyles.blueColor,
          borderRadius: _topRadius,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                plate,
                style: AppStyles.textMdBold.copyWith(
                  color: AppStyles.whiteColor,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 30),
                decoration: const BoxDecoration(
                  borderRadius: _topRadius,
                  color: AppStyles.whiteColor,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 30,
                      top: 10,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(model, style: AppStyles.textLBold),
                              const SizedBox(height: 7),
                              Text(fleet, style: AppStyles.textMd),
                              const SizedBox(height: 7),
                              Text(
                                loadingAddress ? 'Loading...' : address,
                                style: AppStyles.textSm,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        IndicatorCard(items: buildIndicators()),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppStyles.whiteColor,
                            boxShadow: _shadow,
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  AppMedia.userImage,
                                  fit: BoxFit.cover,
                                  width: 45,
                                  height: 45,
                                  cacheWidth: 90,
                                  cacheHeight: 90,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(driver, style: AppStyles.textMdBold),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        ButtonCard(
                          hasDashcam: hasDashcam,
                          vehicleId: vehicleId,
                          vehicleData: vehicleData,
                          onPeriodicTrack: () => PeriodicTrackFilterSheet.open(
                            context,
                            licensePlate:
                                detailData['license_plate']?.toString() ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
