// ignore_for_file: deprecated_member_use

import 'package:bitrack_core/base/res/media.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/periodic_track_filter_sheet.dart';
import 'package:bitrack_core/base/widgets/skeleton_box.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/format_helpers.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/vehicle_detail_safety.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/indicator_card.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/status_label.dart';
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

  /// Layar masih menampilkan data awal dari layar pemanggil; response
  /// `/monitoring/{id}` belum tiba.
  ///
  /// Field yang hanya ada di response itu (model, pengemudi, bahan bakar,
  /// chiller, dashcam, waktu mesin terakhir menyala) diganti skeleton. Tanpa
  /// ini yang tampil adalah `-`, `N/A`, dan `0 %` — semuanya tidak bisa
  /// dibedakan dari data yang memang kosong.
  final bool loadingDetail;

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
    this.loadingDetail = false,
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
    final activity = safeTextFrom(
      detailData,
      'vehicle_activity',
      fallback: '',
    ).toUpperCase();
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
    // Lewat safeDoubleFrom, bukan dibaca langsung dari map: pembandingan
    // `detailData['fuel_consumed'] >= 50` melempar kalau nilainya null.
    final fuel = safeDoubleFrom(detailData, 'fuel_consumed');
    final vehicleCategory = detailData['vehicle_category'] ?? "Truck";

    List<IndicatorItemData> buildIndicators() {
      final dashcamLabel = !hasDashcam
          ? t.statusNA
          : loadingDashcam
          ? '${t.dashcam}...'
          : (dashcamOnline ? t.dashcam : t.statusNA);

      // Latar netral selama memuat: latar merah/kuning membawa arti (bahan
      // bakar menipis) yang belum tentu benar.
      const loadingBg = AppStyles.bgGrayColor;
      const loadingFg = AppStyles.darkGrayColor;

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
          background: loadingDetail
              ? loadingBg
              : (isChiller ? AppStyles.bgGreenColor : AppStyles.bgGrayColor),
          color: loadingDetail
              ? loadingFg
              : (isChiller ? AppStyles.greenColor : AppStyles.darkGrayColor),
          loading: loadingDetail,
        ),
        IndicatorItemData(
          icon: "fuel.svg",
          label: "${detailData['fuel_consumed'] ?? '-'} %",
          background: loadingDetail
              ? loadingBg
              : fuel >= 50
              ? AppStyles.bgGreenColor
              : fuel >= 25
              ? AppStyles.bgYellowColor
              : AppStyles.bgRedColor,
          color: loadingDetail
              ? loadingFg
              : fuel >= 50
              ? AppStyles.greenColor
              : fuel >= 25
              ? AppStyles.yellowColor
              : AppStyles.redColor,
          loading: loadingDetail,
        ),
        IndicatorItemData(
          icon: "webcam.svg",
          label: dashcamLabel,
          background: loadingDetail ? loadingBg : dashcamBg,
          color: loadingDetail ? loadingFg : dashcamFg,
          loading: loadingDetail,
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
                              // Status dari data awal marker home, jadi sudah benar walau model
                              // masih dimuat — hanya teks model yang diganti skeleton.
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                spacing: 5,
                                children: [
                                  if (loadingDetail)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: SkeletonBox(
                                        width: 150,
                                        height: 18,
                                      ),
                                    )
                                  else
                                    Flexible(
                                      child: Text(
                                        model,
                                        style: AppStyles.textLBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  if (activity.isNotEmpty) ...[
                                    StatusLabel(activity: activity),
                                  ],
                                ],
                              ),
                              if (loadingDetail)
                                const SkeletonBox(width: 120, height: 11)
                              else
                                Column(
                                  children: [
                                    const SizedBox(height: 7),
                                    Text(
                                      vehicleCategory,
                                      style: AppStyles.textSmSemibold.copyWith(
                                        color: AppStyles.textLightGrayColor,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 7),
                              // Fleet group ikut dikirim layar pemanggil, jadi
                              // sudah valid sejak frame pertama.
                              Text(fleet, style: AppStyles.textMd),
                              const SizedBox(height: 7),
                              Text(
                                loadingAddress ? t.loading : address,
                                style: AppStyles.textSm,
                              ),
                              if (loadingDetail && !ignition)
                                const SkeletonBox(width: 120, height: 11)
                              else if (!ignition)
                                Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      t.engineLastOn(
                                        getRelativeTime(lastEngineOn),
                                      ),
                                      style: AppStyles.textSmBold.copyWith(
                                        color: AppStyles.textLightGrayColor,
                                      ),
                                    ),
                                  ],
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
                              if (loadingDetail)
                                const SkeletonBox(width: 110, height: 14)
                              else
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
