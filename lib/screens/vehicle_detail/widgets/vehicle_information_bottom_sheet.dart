// ignore_for_file: sort_child_properties_last

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/app_draggable_sheet.dart';
import 'package:bitrack_mobile_flutter/base/widgets/tab_container.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/providers/vehicle_information_provider.dart';
import 'package:flutter/material.dart';
import 'package:bitrack_mobile_flutter/base/widgets/app_tab_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

enum VehicleInfoTab { information, status, sensor }

class VehicleInformationBottomSheet extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleInformationBottomSheet({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleInformationBottomSheet> createState() =>
      _VehicleInformationBottomSheetState();
}

class _VehicleInformationBottomSheetState
    extends ConsumerState<VehicleInformationBottomSheet> {
  VehicleInfoTab _activeTab = VehicleInfoTab.information;

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(vehicleInformationProvider(widget.vehicleId));
    final h = MediaQuery.sizeOf(context).height;

    return AppDraggableSheet(
      title: 'Vehicle Information',
      sliverBuilder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const SizedBox(height: 8),
            const Text(
              "Vehicle Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            AppTabBar<VehicleInfoTab>(
              tabs: const [
                AppTabItem(
                  value: VehicleInfoTab.information,
                  label: 'Information',
                ),
                AppTabItem(value: VehicleInfoTab.status, label: 'Status'),
                AppTabItem(value: VehicleInfoTab.sensor, label: 'Sensor'),
              ],
              activeValue: _activeTab,
              onChanged: (tab) => setState(() => _activeTab = tab),
              padding: const EdgeInsets.all(4),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: h * 0.35,
              width: double.infinity,
              child: asyncState.when(
                loading: () => const TabContainer(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => TabContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gagal load data", style: AppStyles.textMd),
                      const SizedBox(height: 8),
                      Text(e.toString(), style: AppStyles.textSm),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(
                                vehicleInformationProvider(
                                  widget.vehicleId,
                                ).notifier,
                              )
                              .load(widget.vehicleId);
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
                data: (state) => _buildTabContent(context, state.detailVehicle),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    Map<String, dynamic> dataVehicle,
  ) {
    switch (_activeTab) {
      case VehicleInfoTab.information:
        return TabContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowText(
                text1: "GPS Date",
                text2: "${dataVehicle['device_time'] ?? '-'}",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Fleet Group",
                text2: "${dataVehicle['fleet_group_name'] ?? '-'}",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "License Plate",
                text2: "${dataVehicle['license_plate'] ?? '-'}",
              ),
              const SizedBox(height: 8),
              RowText(text1: "IMEI", text2: "${dataVehicle['imei'] ?? '-'}"),
              const SizedBox(height: 8),
              RowText(
                text1: "Latitude",
                text2: "${dataVehicle['latitude'] ?? '-'}",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Longitude",
                text2: "${dataVehicle['longitude'] ?? '-'}",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Google Map",
                text2:
                    "http://www.google.com/maps/place/${dataVehicle['latitude']},${dataVehicle['longitude']}",
                type: RowTextType.url,
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Street View",
                text2:
                    "https://www.google.com/maps?q&layer=c&cbll=${dataVehicle['latitude']},${dataVehicle['longitude']}",
                type: RowTextType.url,
              ),
            ],
          ),
        );

      case VehicleInfoTab.status:
        return TabContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowText(
                text1: "Speed",
                text2: "${dataVehicle['speed'] ?? '-'} KM/Jam",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Total Odometer",
                text2: "${dataVehicle['total_odometer'] ?? '-'} KM",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Internal Battery",
                text2: "${dataVehicle['internal_battery_voltage'] ?? '-'} V",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "External Battery",
                text2: "${dataVehicle['external_power_voltage'] ?? '-'} V",
              ),
            ],
          ),
        );

      case VehicleInfoTab.sensor:
        return TabContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowText(
                text1: "Fuel",
                text2: "${dataVehicle['fuel_consumed'] ?? '-'} %",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Direction",
                text2: "${dataVehicle['direction'] ?? '-'}°",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Humidity",
                text2: "${dataVehicle['humidity'] ?? 'NaN'} %",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Left Door",
                text2: "${dataVehicle['dleft'] ?? '-'}",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Right Door",
                text2: "${dataVehicle['dright'] ?? '-'}",
              ),
              const SizedBox(height: 8),
              RowText(
                text1: "Back Door",
                text2: "${dataVehicle['drear'] ?? '-'}",
              ),
            ],
          ),
        );
    }
  }
}

enum RowTextType { text, url }

class RowText extends StatelessWidget {
  final String text1;
  final String text2;
  final RowTextType type;

  const RowText({
    super.key,
    required this.text1,
    required this.text2,
    this.type = RowTextType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110, // biar kolom kiri rapih
          child: Text(text1, style: AppStyles.textMd),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: type == RowTextType.text
              ? Text(text2, style: AppStyles.textMd)
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
                    text2,
                    style: AppStyles.textMd.copyWith(
                      color: AppStyles.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
