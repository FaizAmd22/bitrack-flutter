// ignore_for_file: deprecated_member_use

import 'package:bitrack_core/base/res/media.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/periodic_track_filter_sheet.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/format_helpers.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/vehicle_detail_safety.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/indicator_card.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/button_card.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class VehicleDetailContent extends StatelessWidget {
  final Map<String, dynamic> detailData;

  final String address;
  final bool loadingAddress;
  final bool hasDashcam;
  final bool dashcamOnline;
  final bool isChiller;
  final bool loadingDashcam;
  final Map<String, dynamic>? vehicleData;

  const VehicleDetailContent({
    super.key,
    required this.detailData,
    required this.address,
    required this.loadingAddress,
    required this.hasDashcam,
    required this.dashcamOnline,
    required this.isChiller,
    required this.loadingDashcam,
    this.vehicleData,
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
    final t = AppLocalizations.of(context);
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
    final ignition = safeIntFrom(detailData, 'ignition') == 1;
    final lastEngineOn = safeTextFrom(detailData, 'last_engine_on');

    List<IndicatorItemData> buildIndicators() {
      final dashcamLabel = !hasDashcam
          ? t.statusNA
          : loadingDashcam
          ? '${t.dashcam}...'
          : (dashcamOnline ? t.dashcam : t.statusNA);

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
          label: ignition ? t.engineOn : t.engineOff,
          background: ignition ? AppStyles.bgGreenColor : AppStyles.bgGrayColor,
          color: ignition ? AppStyles.greenColor : AppStyles.darkGrayColor,
        ),
        IndicatorItemData(
          icon: "chiller.svg",
          label: isChiller ? t.chillerUnit : t.statusNA,
          background: isChiller
              ? AppStyles.bgGreenColor
              : AppStyles.bgGrayColor,
          color: isChiller ? AppStyles.greenColor : AppStyles.darkGrayColor,
        ),
        IndicatorItemData(
          icon: "fuel.svg",
          label: "${detailData['fuel_consumed'] ?? '-'} %",
          background: detailData['fuel_consumed'] >= 50
              ? AppStyles.bgGreenColor
              : detailData['fuel_consumed'] >= 25
              ? AppStyles.bgYellowColor
              : AppStyles.bgRedColor,
          color: detailData['fuel_consumed'] >= 50
              ? AppStyles.greenColor
              : detailData['fuel_consumed'] >= 25
              ? AppStyles.yellowColor
              : AppStyles.redColor,
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
                                loadingAddress ? t.loading : address,
                                style: AppStyles.textSm,
                              ),
                              const SizedBox(height: 10),
                              // Container(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: 18,
                              //     vertical: 8,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.all(
                              //       Radius.circular(16),
                              //     ),
                              //     color: AppStyles.bgGreenColor,
                              //   ),
                              //   child: Text(
                              //     'Moving',
                              //     style: AppStyles.textSmBold.copyWith(
                              //       color: AppStyles.greenColor,
                              //     ),
                              //   ),
                              // ),
                              Text(
                                ignition
                                    ? t.activityMoving
                                    : t.engineLastOn(
                                        getRelativeTime(lastEngineOn),
                                      ),
                                style: AppStyles.textSmBold.copyWith(
                                  color: ignition
                                      ? AppStyles.greenColor
                                      : AppStyles.textLightGrayColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
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
