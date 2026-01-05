// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/indicator_card.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/button_card.dart';
import 'package:flutter/material.dart';

class VehicleDetailContent extends StatelessWidget {
  final Map<String, dynamic> detailData;

  final String address;
  final bool loadingAddress;
  final bool hasDashcam;
  final bool dashcamOnline;
  final bool isChiller;
  final bool loadingDashcam;

  const VehicleDetailContent({
    super.key,
    required this.detailData,
    required this.address,
    required this.loadingAddress,
    required this.hasDashcam,
    required this.dashcamOnline,
    required this.isChiller,
    required this.loadingDashcam,
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

    String safeText(
      Map<String, dynamic> data,
      String key, {
      String fallback = '-',
    }) {
      final v = data[key];
      if (v == null) return fallback;

      final s = v.toString().trim();
      return s.isEmpty ? fallback : s;
    }

    final plate = safeText(detailData, 'license_plate');
    final model = safeText(detailData, 'vehicle_model');
    final fleet = safeText(
      detailData,
      'fleet_group_name',
      fallback: '(unknown)',
    );
    final driver = safeText(detailData, 'driver_name');

    List<IndicatorItemData> buildIndicators() {
      final ignition = detailData['ignition'] == 1;

      final fuel =
          double.tryParse((detailData['fuel_consumed'] ?? '0').toString()) ?? 0;

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
                      spacing: 25,
                      children: [
                        SizedBox(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 7,
                            children: [
                              Text(model, style: AppStyles.textLBold),
                              Text(fleet, style: AppStyles.textMd),
                              Text(
                                loadingAddress ? 'Loading address...' : address,
                                style: AppStyles.textSm,
                              ),
                            ],
                          ),
                        ),

                        IndicatorCard(items: buildIndicators()),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppStyles.whiteColor,
                            boxShadow: _shadow,
                          ),
                          child: Row(
                            spacing: 15,
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
                              Text(driver, style: AppStyles.textMdBold),
                            ],
                          ),
                        ),

                        ButtonCard(
                          hasDashcam: hasDashcam,
                          vehicleId: (detailData['vehicle_id'] ?? '')
                              .toString(),
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
