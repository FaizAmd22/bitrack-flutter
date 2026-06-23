// ignore_for_file: sort_child_properties_last

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/app_draggable_sheet.dart';
import 'package:ams/base/widgets/segmented_tab_bar.dart';
import 'package:ams/base/widgets/tab_container.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/vehicle_detail/providers/vehicle_information_provider.dart';
import 'package:flutter/material.dart';
// import 'package:ams/base/widgets/app_tab_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

enum VehicleInfoTab { information, status, sensor }

enum RowTextType { text, url }

class VehicleInformationBottomSheet extends ConsumerStatefulWidget {
  const VehicleInformationBottomSheet({super.key});

  @override
  ConsumerState<VehicleInformationBottomSheet> createState() =>
      _VehicleInformationBottomSheetState();
}

class _VehicleInformationBottomSheetState
    extends ConsumerState<VehicleInformationBottomSheet> {
  VehicleInfoTab _activeTab = VehicleInfoTab.information;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int i) {
    setState(() => _activeTab = VehicleInfoTab.values[i]);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int i) {
    if (_activeTab != VehicleInfoTab.values[i]) {
      setState(() => _activeTab = VehicleInfoTab.values[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleId = ref.watch(vehicleIdProvider);
    final t = AppLocalizations.of(context);

    if (vehicleId == null || vehicleId.trim().isEmpty) {
      return AppDraggableSheet(
        title: t.vehicleInformation,
        sliverBuilder: (context, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(16),
          children: [Text(t.vehicleIdNotAvailableDesc)],
        ),
      );
    }

    final async = ref.watch(vehicleDetailByVehicleIdProvider(vehicleId));

    return AppDraggableSheet(
      title: t.vehicleInformation,
      sliverBuilder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(t.vehicleInformation, style: AppStyles.textMdBold),
            const SizedBox(height: 20),
            SegmentedTabBar(
              labels: [t.tabInformation, t.tabStatus, t.tabSensor],
              activeIndex: VehicleInfoTab.values.indexOf(_activeTab),
              onChanged: _onTabChanged,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: async.when(
                loading: () => const TabContainer(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => TabContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.failedLoadData, style: AppStyles.textSm),
                      Text(e.toString(), style: AppStyles.textSm),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(
                            vehicleDetailByVehicleIdProvider(vehicleId),
                          );
                        },
                        child: Text(t.retry),
                      ),
                    ],
                  ),
                ),
                data: (dataVehicle) => SizedBox(
                  height: 340,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildInformationTab(context, dataVehicle),
                      _buildStatusTab(context, dataVehicle),
                      _buildSensorTab(context, dataVehicle),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInformationTab(
    BuildContext context,
    Map<String, dynamic> dataVehicle,
  ) {
    final t = AppLocalizations.of(context);
    return TabContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RowText(
            text1: t.vehicleInfoGpsDate,
            text2: "${dataVehicle['device_time'] ?? '-'}",
          ),
          SizedBox(height: 20),
          RowText(
            text1: 'Fleet Group',
            text2: "${dataVehicle['fleet_group_name'] ?? '-'}",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleInfoLicensePlate,
            text2: "${dataVehicle['license_plate'] ?? '-'}",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleInfoImei,
            text2: "${dataVehicle['imei'] ?? '-'}",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleInfoLatitude,
            text2: "${dataVehicle['latitude'] ?? '-'}",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleInfoLongitude,
            text2: "${dataVehicle['longitude'] ?? '-'}",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleInfoGoogleMap,
            text2:
                "http://www.google.com/maps/place/${dataVehicle['latitude']},${dataVehicle['longitude']}",
            textUri: t.showGoogleMap,
            type: RowTextType.url,
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleInfoStreetView,
            text2:
                "https://www.google.com/maps?q&layer=c&cbll=${dataVehicle['latitude']},${dataVehicle['longitude']}",
            textUri: t.showStreetView,
            type: RowTextType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(
    BuildContext context,
    Map<String, dynamic> dataVehicle,
  ) {
    final t = AppLocalizations.of(context);
    return TabContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RowText(
            text1: t.vehicleStatusSpeed,
            text2: "${dataVehicle['speed'] ?? '-'} KM/H",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleStatusTotalOdometer,
            text2: "${dataVehicle['total_odometer'] ?? '-'} M",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleStatusInternalBattery,
            text2: "${dataVehicle['internal_battery_voltage'] ?? '-'} V",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleStatusExternalBattery,
            text2: "${dataVehicle['external_power_voltage'] ?? '-'} %",
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTab(
    BuildContext context,
    Map<String, dynamic> dataVehicle,
  ) {
    final t = AppLocalizations.of(context);
    return TabContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RowText(
            text1: t.vehicleSensorFuel,
            text2: "${dataVehicle['fuel_consumed'] ?? '-'} %",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleSensorDirection,
            text2: "${dataVehicle['direction'] ?? '-'}°",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleSensorHumidity,
            text2: "${dataVehicle['humidity'] ?? 'NaN'} %",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleSensorLeftDoor,
            text2: "${dataVehicle['dleft'] ?? '-'}",
          ),
          SizedBox(height: 20),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleSensorRightDoor,
            text2: "${dataVehicle['dright'] ?? '-'}",
          ),
          SizedBox(height: 20),
          RowText(
            text1: t.vehicleSensorBackDoor,
            text2: "${dataVehicle['drear'] ?? '-'}",
          ),
        ],
      ),
    );
  }
}

class RowText extends StatelessWidget {
  final String text1;
  final String text2;
  final String textUri;
  final RowTextType type;

  const RowText({
    super.key,
    required this.text1,
    required this.text2,
    this.textUri = "-",
    this.type = RowTextType.text,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = type == RowTextType.text ? text2 : textUri;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT LABEL
        Expanded(
          flex: 4, // ~40%
          child: Text(
            text1,
            style: AppStyles.textSm.copyWith(color: AppStyles.blackColor),
          ),
        ),

        const SizedBox(width: 12),

        /// RIGHT VALUE
        Expanded(
          flex: 6, // ~60%
          child: type == RowTextType.text
              ? Text(
                  text2,
                  style: AppStyles.textSmBold.copyWith(
                    color: AppStyles.blackColor,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                )
              : GestureDetector(
                  onTap: () async {
                    final uri = Uri.tryParse(text2);
                    if (uri != null) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    displayText,
                    style: AppStyles.textSmBold.copyWith(
                      color: AppStyles.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppStyles.primaryColor,
                    ),
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                ),
        ),
      ],
    );
  }
}
