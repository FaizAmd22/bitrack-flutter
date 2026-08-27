// lib/screens/periodic_track/widgets/periodic_alert_sheet.dart
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/periodic_track/models/periodic_point.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PeriodicAlertSheet {
  static Future<void> open(BuildContext context, PeriodicPoint point) {
    return showModalBottomSheet(
      context: context,
      // backdrop=false di Cordova → biar map tetap terlihat
      barrierColor: AppStyles.blackColor.withValues(alpha: 0.2),
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _AlertSheetBody(point: point),
    );
  }
}

class _AlertSheetBody extends StatelessWidget {
  final PeriodicPoint point;
  const _AlertSheetBody({required this.point});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isSampling = point.eventType == 'SAMPLING';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(point.eventName, style: AppStyles.textLBold),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppStyles.bgGrayColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                spacing: 20,
                children: [
                  _Row(label: t.gpsDate, value: '${point.deviceTime} WIB'),
                  if (!isSampling)
                    _Row(label: t.alertType, value: point.eventName),
                  _Row(label: t.speed, value: '${point.speed} Km/h'),
                  _Row(
                    label: t.vehicleInfoLatitude,
                    value: '${point.latitude}',
                  ),
                  _Row(
                    label: t.vehicleInfoLongitude,
                    value: '${point.longitude}',
                  ),
                  _GoogleMapRow(
                    label: t.vehicleInfoGoogleMap,
                    text: t.showGoogleMap,
                    lat: point.latitude,
                    lng: point.longitude,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.textSm),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppStyles.textSm,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMapRow extends StatelessWidget {
  final String label;
  final String text;
  final double lat;
  final double lng;

  const _GoogleMapRow({
    required this.label,
    required this.text,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.textSm),
          InkWell(
            onTap: () async {
              final uri = Uri.parse(
                'http://www.google.com/maps/place/$lat,$lng',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              text,
              style: AppStyles.textSmBold.copyWith(
                color: AppStyles.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
