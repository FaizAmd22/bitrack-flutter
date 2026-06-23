// ignore_for_file: deprecated_member_use

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/home/models/filter_model.dart';
import 'package:ams/screens/notification/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _View { main, fleet, status, alertType }

class FilterNotifBottomSheet extends StatefulWidget {
  final NotificationFilter initialFilter;
  final List<FilterOption> fleetGroups;
  final List<FilterOption> alertTypes;

  const FilterNotifBottomSheet({
    super.key,
    required this.initialFilter,
    required this.fleetGroups,
    required this.alertTypes,
  });

  static Future<NotificationFilter?> open(
    BuildContext context, {
    required NotificationFilter initialFilter,
    List<FilterOption> fleetGroups = const [],
    List<FilterOption> alertTypes = const [],
  }) {
    return showModalBottomSheet<NotificationFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterNotifBottomSheet(
        initialFilter: initialFilter,
        fleetGroups: fleetGroups,
        alertTypes: alertTypes,
      ),
    );
  }

  @override
  State<FilterNotifBottomSheet> createState() => _FilterNotifBottomSheetState();
}

class _FilterNotifBottomSheetState extends State<FilterNotifBottomSheet> {
  _View _view = _View.main;

  DateTime? _startDate;
  DateTime? _endDate;
  FilterOption? _fleetGroup;
  FilterOption? _status;
  FilterOption? _alertType;

  String _search = '';

  final _dateFmt = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    _startDate = f.startDate;
    _endDate = f.endDate;
    if (f.fleetGroup != null) {
      _fleetGroup = FilterOption(
        value: f.fleetGroup,
        label: f.fleetGroupLabel ?? f.fleetGroup!,
      );
    }
    if (f.status != null) {
      _status = FilterOption(
        value: f.status,
        label: f.statusLabel ?? f.status!,
      );
    }
    if (f.alertType != null) {
      _alertType = FilterOption(
        value: f.alertType,
        label: f.alertTypeLabel ?? f.alertType!,
      );
    }
  }

  void _back() {
    if (_view != _View.main) {
      setState(() {
        _view = _View.main;
        _search = '';
      });
      return;
    }
    Navigator.pop(context);
  }

  void _apply() {
    final normalizedStart = _startDate != null
        ? DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            0,
            0,
            0,
          )
        : null;
    final normalizedEnd = _endDate != null
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
        : null;

    Navigator.pop(
      context,
      NotificationFilter(
        startDate: normalizedStart,
        endDate: normalizedEnd,
        fleetGroup: _fleetGroup?.value,
        fleetGroupLabel: _fleetGroup?.label,
        status: _status?.value,
        statusLabel: _status?.label,
        alertType: _alertType?.value,
        alertTypeLabel: _alertType?.label,
      ),
    );
  }

  void _clear() {
    Navigator.pop(context, const NotificationFilter());
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppStyles.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: _startDate ?? DateTime(2020),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppStyles.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _endDate = picked);
    }
  }

  List<FilterOption> _currentOptions(AppLocalizations t) {
    switch (_view) {
      case _View.fleet:
        return [
          FilterOption(value: null, label: t.filterAllFleetGroup),
          ...widget.fleetGroups,
        ];
      case _View.status:
        return [
          FilterOption(value: null, label: t.filterAllStatus),
          FilterOption(value: 'verified', label: t.filterVerified),
          FilterOption(value: 'not_verify', label: t.filterUnverified),
        ];
      case _View.alertType:
        return [
          FilterOption(value: null, label: t.filterAllAlertType),
          ...widget.alertTypes,
        ];
      case _View.main:
        return const [];
    }
  }

  List<FilterOption> _filteredOptions(AppLocalizations t) {
    final opts = _currentOptions(t);
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return opts;
    return opts.where((e) => e.label.toLowerCase().contains(q)).toList();
  }

  String _titleForView(AppLocalizations t) {
    switch (_view) {
      case _View.fleet:
        return t.filterFleetGroup;
      case _View.status:
        return t.filterVerifStatus;
      case _View.alertType:
        return t.filterAlertType;
      case _View.main:
        return t.filterTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final mq = MediaQuery.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        height: mq.size.height * 0.82,
        decoration: const BoxDecoration(
          color: AppStyles.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              _Header(title: _titleForView(t), onBack: _back),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _view == _View.main ? _buildMain(t) : _buildSubView(t),
                ),
              ),
              if (_view == _View.main)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    16 + mq.viewInsets.bottom,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clear,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppStyles.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            t.filterClear,
                            style: AppStyles.textMd.copyWith(
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            t.filterApply,
                            style: AppStyles.textMd.copyWith(
                              color: AppStyles.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
        ),
      ),
    );
  }

  Widget _buildMain(AppLocalizations t) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Start Date ──────────────────────────────────────────────────────
          Text(
            t.filterStartDate,
            style: AppStyles.textSmBold.copyWith(
              color: AppStyles.textBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _DateTile(
            label: _startDate != null
                ? _dateFmt.format(_startDate!)
                : t.filterChooseStartDate,
            hasValue: _startDate != null,
            onTap: _pickStartDate,
          ),
          const SizedBox(height: 14),

          // ── End Date ────────────────────────────────────────────────────────
          Text(
            t.filterEndDate,
            style: AppStyles.textSmBold.copyWith(
              color: AppStyles.textBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _DateTile(
            label: _endDate != null
                ? _dateFmt.format(_endDate!)
                : t.filterChooseEndDate,
            hasValue: _endDate != null,
            onTap: _pickEndDate,
          ),
          const SizedBox(height: 14),

          // ── Fleet Group ─────────────────────────────────────────────────────
          Text(
            t.filterFleetGroup,
            style: AppStyles.textSmBold.copyWith(
              color: AppStyles.textBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _SelectTile(
            label: _fleetGroup?.label ?? t.filterAllFleetGroup,
            hasValue: true,
            onTap: () => setState(() => _view = _View.fleet),
          ),
          const SizedBox(height: 14),

          // ── Verification Status ─────────────────────────────────────────────
          Text(
            t.filterVerifStatus,
            style: AppStyles.textSmBold.copyWith(
              color: AppStyles.textBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _SelectTile(
            label: _status?.label ?? t.filterAllStatus,
            hasValue: true,
            onTap: () => setState(() => _view = _View.status),
          ),
          const SizedBox(height: 14),

          // ── Alert Type ──────────────────────────────────────────────────────
          Text(
            t.filterAlertType,
            style: AppStyles.textSmBold.copyWith(
              color: AppStyles.textBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _SelectTile(
            label: _alertType?.label ?? t.filterAllAlertType,
            hasValue: true,
            onTap: () => setState(() => _view = _View.alertType),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubView(AppLocalizations t) {
    final opts = _filteredOptions(t);

    return Column(
      children: [
        TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(
            hintText: t.filterSearch,
            prefixIcon: const Icon(Icons.search, color: AppStyles.primaryColor),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppStyles.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: opts.isEmpty
              ? Center(
                  child: Text(
                    t.filterNoOptions,
                    style: AppStyles.textMd.copyWith(
                      color: AppStyles.textDarkGrayColor,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: opts.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, i) {
                    final opt = opts[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        opt.label,
                        style: AppStyles.textMd.copyWith(
                          color: AppStyles.blackColor,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          switch (_view) {
                            case _View.fleet:
                              _fleetGroup = opt.value == null ? null : opt;
                              break;
                            case _View.status:
                              _status = opt.value == null ? null : opt;
                              break;
                            case _View.alertType:
                              _alertType = opt.value == null ? null : opt;
                              break;
                            case _View.main:
                              break;
                          }
                          _view = _View.main;
                          _search = '';
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Private reusable tiles ────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          Material(
            color: Colors.grey.shade100,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppStyles.textMdBold),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String label;
  final bool hasValue;
  final VoidCallback onTap;
  const _SelectTile({
    required this.label,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.textMd.copyWith(
                    color: hasValue
                        ? AppStyles.textBlackColor
                        : AppStyles.textLightGrayColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppStyles.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final bool hasValue;
  final VoidCallback onTap;
  const _DateTile({
    required this.label,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppStyles.primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.textMd.copyWith(
                    color: hasValue
                        ? AppStyles.textBlackColor
                        : AppStyles.textLightGrayColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppStyles.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
