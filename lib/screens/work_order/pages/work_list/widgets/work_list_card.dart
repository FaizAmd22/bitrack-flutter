// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/models/work_order_options.dart';
import 'package:ams/screens/work_order/providers/work_order_providers.dart';
import 'package:ams/screens/work_order/utils/format_date.dart';
import 'package:ams/screens/work_order/utils/format_label.dart';
import 'package:ams/screens/work_order/widgets/work_order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Padanan `pages/work-list/components/work-list-card.jsx`.
class WorkListCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final WorkOrderOptions options;
  final void Function(String title, String subtitle) onTap;

  const WorkListCard({
    super.key,
    required this.data,
    required this.options,
    required this.onTap,
  });

  @override
  ConsumerState<WorkListCard> createState() => _WorkListCardState();
}

class _WorkListCardState extends ConsumerState<WorkListCard> {
  Timer? _gpsTimer;
  bool _isGpsActive = false;

  Map<String, dynamic> get _activity {
    final raw = widget.data['activity'];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  String get _categoryLabel =>
      widget.options.categoryLabel(widget.data['work_category']?.toString());

  bool get _isGpsCategory => _categoryLabel.toUpperCase() == 'GPS';

  @override
  void initState() {
    super.initState();
    if (_isGpsCategory) _startGpsPolling();
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  /// Sinyal GPS di-poll tiap 10 detik seperti di work-list-card.jsx supaya
  /// teknisi tahu perangkat yang baru dipasang sudah mengirim data.
  void _startGpsPolling() {
    _pollGps();
    _gpsTimer = Timer.periodic(const Duration(seconds: 10), (_) => _pollGps());
  }

  Future<void> _pollGps() async {
    final imei = _activity['imei']?.toString();
    if (imei == null || imei.isEmpty) return;

    try {
      final active = await ref.read(workOrderApiProvider).gpsSignal(imei);
      if (!mounted) return;
      setState(() => _isGpsActive = active);
    } catch (_) {
      // Sinyal dianggap belum aktif kalau endpoint gagal.
    }
  }

  ({int before, int after}) get _evidenceCount {
    final evidence = _activity['evidence'];
    if (evidence is! Map) return (before: 0, after: 0);

    int count(dynamic v) => v is List ? v.length : 0;
    return (before: count(evidence['before']), after: count(evidence['after']));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    final typeLabel = widget.options.workTypeLabel(
      widget.data['work_category']?.toString(),
      widget.data['work_type']?.toString(),
    );

    final title =
        '${formatStatus(_categoryLabel)} - ${formatStatus(typeLabel)}';
    final licensePlate = (widget.data['license_plate'] ?? '-').toString();
    final status = widget.data['status']?.toString();
    final evidence = _evidenceCount;

    final rawType = (widget.data['work_type'] ?? '').toString().toUpperCase();
    final rawCategory = (widget.data['work_category'] ?? '')
        .toString()
        .toUpperCase();

    final warnings = <String>[
      if (evidence.before <= 0 || evidence.after <= 0) t.woEvidenceNotUploaded,
      if (rawCategory == 'GPS' &&
          rawType != 'DISMANTLE' &&
          (_activity['odometer'] == null ||
              _activity['odometer'].toString().trim().isEmpty))
        t.woOdometerNotFilled,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onTap(title, licensePlate),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppStyles.whiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppStyles.textMdBold.copyWith(
                              color: AppStyles.blackColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            licensePlate,
                            style: AppStyles.textXs.copyWith(
                              color: AppStyles.textDarkGrayColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    WorkOrderStatusBadge(status: status),
                  ],
                ),

                if (status == 'COMPLETED') ...[
                  const SizedBox(height: 10),
                  Text(
                    '${t.woWorkDate}: '
                    '${formatDateCard(widget.data['work_date']?.toString(), languageCode)}',
                    style: AppStyles.textXs.copyWith(
                      color: AppStyles.textDarkGrayColor,
                    ),
                  ),
                ],

                for (final warning in warnings) ...[
                  const SizedBox(height: 6),
                  _AlertText(text: warning),
                ],

                if (rawCategory == 'GPS') ...[
                  const SizedBox(height: 6),
                  _isGpsActive
                      ? Row(
                          children: [
                            const Icon(
                              Icons.check,
                              size: 14,
                              color: AppStyles.greenColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              t.woGpsActive,
                              style: AppStyles.textXs.copyWith(
                                color: AppStyles.greenColor,
                              ),
                            ),
                          ],
                        )
                      : _AlertText(text: t.woGpsNotActive),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertText extends StatelessWidget {
  final String text;

  const _AlertText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 15,
          color: AppStyles.yellowColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppStyles.textXs.copyWith(color: AppStyles.yellowColor),
          ),
        ),
      ],
    );
  }
}
