// ignore_for_file: deprecated_member_use

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:ams/screens/notification/widgets/card_notif_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Status logic (mirrors React getCardStatus) ───────────────────────────────

enum _CardStatus { verified, warning, danger }

_CardStatus _getStatus(AlertModel item) {
  final v = item.verifiedBy?.trim() ?? '';
  if (v.isNotEmpty) return _CardStatus.verified;

  final raw = item.deviceTime;
  if (raw == null || raw.isEmpty) return _CardStatus.warning;

  DateTime? dt;
  try {
    dt = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(raw.trim());
  } catch (_) {
    try {
      dt = DateTime.parse(raw.trim().replaceFirst(' ', 'T'));
    } catch (_) {}
  }

  if (dt == null) return _CardStatus.warning;
  final hours = DateTime.now().difference(dt).inMinutes / 60.0;
  return hours > 4 ? _CardStatus.danger : _CardStatus.warning;
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  final String label;
  const _StatusStyle({required this.bg, required this.fg, required this.label});
}

_StatusStyle _styleFor(_CardStatus status, String? verifiedBy) {
  switch (status) {
    case _CardStatus.verified:
      return _StatusStyle(
        bg: const Color(0xFFE3F2FD),
        fg: const Color(0xFF2196F3),
        label: 'Verified by ${verifiedBy ?? ''}',
      );
    case _CardStatus.warning:
      return _StatusStyle(
        bg: AppStyles.bgYellowColor,
        fg: AppStyles.yellowColor,
        label: 'Not yet verified',
      );
    case _CardStatus.danger:
      return _StatusStyle(
        bg: AppStyles.bgRedColor,
        fg: AppStyles.redColor,
        label: 'Not verified',
      );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fmtDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  try {
    final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(raw.trim());
    return DateFormat('d MMM yyyy').format(dt);
  } catch (_) {
    try {
      final dt = DateTime.parse(raw.trim().replaceFirst(' ', 'T'));
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return '-';
    }
  }
}

String _fmtTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  try {
    final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(raw.trim());
    return DateFormat('HH:mm').format(dt);
  } catch (_) {
    try {
      final dt = DateTime.parse(raw.trim().replaceFirst(' ', 'T'));
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }
}

String _fmtDuration(int? secs) {
  if (secs == null || secs <= 0) return '-';
  final h = secs ~/ 3600;
  final m = (secs % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

bool _isOverstay(String? eventType) =>
    eventType == 'OVERSTAY_ENGINE_ON' || eventType == 'OVERSTAY_ENGINE_OFF';

// ─── Widget ───────────────────────────────────────────────────────────────────

class CardNotif extends StatelessWidget {
  final AlertModel item;

  const CardNotif({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = _getStatus(item);
    final style = _styleFor(status, item.verifiedBy);
    final muted = AppStyles.darkGrayColor.withOpacity(0.6);

    final rightCell = _isOverstay(item.eventType)
        ? _fmtDuration(item.duration)
        : item.speed != null
        ? '${item.speed!.toStringAsFixed(0)} KM/H'
        : '-';

    return GestureDetector(
      onTap: () => CardNotifPopup.open(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppStyles.whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: date+time  |  status badge ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            _fmtDate(item.deviceTime),
                            style: AppStyles.textXs.copyWith(
                              color: AppStyles.textBlackColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _fmtTime(item.deviceTime),
                            style: AppStyles.textXs.copyWith(
                              color: AppStyles.textBlackColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 160),
                      margin: const EdgeInsets.only(
                        right: 5,
                        top: 8,
                        bottom: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        style.label,
                        style: AppStyles.textXs.copyWith(
                          color: style.fg,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divider ──
              Container(
                height: 2,
                width: double.infinity,
                color: AppStyles.inputDisableBg,
              ),

              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event name
                    Text(
                      item.eventName?.isNotEmpty == true
                          ? item.eventName!
                          : (item.eventType ?? '-'),
                      style: AppStyles.textMdBold.copyWith(
                        color: AppStyles.textBlackColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Row 1: driver name | license plate
                    Row(
                      children: [
                        Expanded(
                          flex: 65,
                          child: Text(
                            item.driverName?.isNotEmpty == true
                                ? item.driverName!
                                : '-',
                            style: AppStyles.textSm.copyWith(color: muted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 35,
                          child: Text(
                            item.licensePlate ?? '-',
                            style: AppStyles.textSm.copyWith(
                              color: AppStyles.textBlackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Row 2: fleet group | speed or duration
                    Row(
                      children: [
                        Expanded(
                          flex: 65,
                          child: Text(
                            item.fleetGroupName?.isNotEmpty == true
                                ? item.fleetGroupName!
                                : '-',
                            style: AppStyles.textSm.copyWith(color: muted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 35,
                          child: Text(
                            rightCell,
                            style: AppStyles.textSm.copyWith(
                              color: AppStyles.textBlackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Address
                    // if (item.address != null && item.address!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.address ?? '-',
                      style: AppStyles.textXs.copyWith(color: muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
