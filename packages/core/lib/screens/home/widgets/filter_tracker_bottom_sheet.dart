// lib/screens/home/widgets/filter_tracker_bottom_sheet.dart
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/home/models/filter_model.dart';
import 'package:flutter/material.dart';

class TrackerFilterResult {
  final FilterOption selectedType;
  final FilterOption selectedFleetGroup;
  final FilterOption selectedGeofence;

  const TrackerFilterResult({
    required this.selectedType,
    required this.selectedFleetGroup,
    required this.selectedGeofence,
  });
}

class FilterTrackerBottomSheet {
  static Future<TrackerFilterResult?> open(
    BuildContext context, {
    required List<FilterOption> fleetGroups,
    required List<FilterOption> geofences,
    required FilterOption? initialType,
    required FilterOption? initialFleetGroup,
    required FilterOption? initialGeofence,
  }) {
    return showModalBottomSheet<TrackerFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheetBody(
        fleetGroups: fleetGroups,
        geofences: geofences,
        initialType: initialType,
        initialFleetGroup: initialFleetGroup,
        initialGeofence: initialGeofence,
      ),
    );
  }
}

// Jenis filter yang tersedia. Geofence di-comment di Cordova; di sini
// aktif tapi kamu bisa hapus dari list ini kalau belum dipakai.
List<FilterOption> _typeOptions(AppLocalizations t) => [
  FilterOption(value: 'fleetgroup', label: t.filterFleetGroup),
  // FilterOption(value: 'geofence', label: t.filterGeofence),
];

class _FilterSheetBody extends StatefulWidget {
  final List<FilterOption> fleetGroups;
  final List<FilterOption> geofences;
  final FilterOption? initialType;
  final FilterOption? initialFleetGroup;
  final FilterOption? initialGeofence;

  const _FilterSheetBody({
    required this.fleetGroups,
    required this.geofences,
    required this.initialType,
    required this.initialFleetGroup,
    required this.initialGeofence,
  });

  @override
  State<_FilterSheetBody> createState() => _FilterSheetBodyState();
}

class _FilterSheetBodyState extends State<_FilterSheetBody> {
  late FilterOption? _type = widget.initialType;
  late FilterOption? _fleetGroup = widget.initialFleetGroup;
  late FilterOption? _geofence = widget.initialGeofence;

  void _clear() {
    final t = AppLocalizations.of(context);
    Navigator.pop(
      context,
      TrackerFilterResult(
        selectedType: FilterOption(value: null, label: t.filterChooseType),
        selectedFleetGroup: FilterOption(
          value: null,
          label: t.filterAllFleetGroup,
        ),
        selectedGeofence: FilterOption(value: null, label: t.filterAllGeofence),
      ),
    );
  }

  void _apply() {
    final t = AppLocalizations.of(context);
    Navigator.pop(
      context,
      TrackerFilterResult(
        selectedType:
            _type ?? FilterOption(value: null, label: t.filterChooseType),
        selectedFleetGroup:
            _fleetGroup ??
            FilterOption(value: null, label: t.filterAllFleetGroup),
        selectedGeofence:
            _geofence ?? FilterOption(value: null, label: t.filterAllGeofence),
      ),
    );
  }

  Future<void> _pickType() async {
    final t = AppLocalizations.of(context);
    final picked = await _SearchablePicker.open(
      context,
      title: t.filterTypeTitle,
      options: _typeOptions(t),
      selected: _type,
    );
    if (picked != null) setState(() => _type = picked);
  }

  Future<void> _pickFleetGroup() async {
    final t = AppLocalizations.of(context);
    final picked = await _SearchablePicker.open(
      context,
      title: t.filterFleetGroup,
      options: widget.fleetGroups,
      selected: _fleetGroup,
    );
    if (picked != null) setState(() => _fleetGroup = picked);
  }

  Future<void> _pickGeofence() async {
    final t = AppLocalizations.of(context);
    final picked = await _SearchablePicker.open(
      context,
      title: t.filterGeofence,
      options: widget.geofences,
      selected: _geofence,
    );
    if (picked != null) setState(() => _geofence = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final type = _type ?? FilterOption(value: null, label: t.filterChooseType);
    final fleetGroup =
        _fleetGroup ?? FilterOption(value: null, label: t.filterAllFleetGroup);
    final geofence =
        _geofence ?? FilterOption(value: null, label: t.filterAllGeofence);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppStyles.borderLightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(t.filterTitle, style: AppStyles.textLBold),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Label(t.filterTypeLabel),
                  _SelectRow(
                    value: type.value == null ? null : type.label,
                    placeholder: t.filterChooseType,
                    onTap: _pickType,
                  ),
                  if (type.value == 'fleetgroup') ...[
                    const SizedBox(height: 16),
                    _Label(t.filterFleetGroup),
                    _SelectRow(
                      value: fleetGroup.label,
                      placeholder: t.filterChooseFleetGroup,
                      onTap: _pickFleetGroup,
                    ),
                  ],
                  if (type.value == 'geofence') ...[
                    const SizedBox(height: 16),
                    _Label(t.filterGeofence),
                    _SelectRow(
                      value: geofence.label,
                      placeholder: t.filterChooseGeofence,
                      onTap: _pickGeofence,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppStyles.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        t.filterClear,
                        style: AppStyles.textSmBold.copyWith(
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        t.filterApply,
                        style: AppStyles.textSmBold.copyWith(
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
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppStyles.textMdBold),
  );
}

class _SelectRow extends StatelessWidget {
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const _SelectRow({
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppStyles.borderLightGray),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: AppStyles.textSm.copyWith(
                  color: value == null
                      ? AppStyles.textDarkGrayColor
                      : AppStyles.blackColor,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppStyles.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Bagian bawah file filter_tracker_bottom_sheet.dart (atau file sendiri)
class _SearchablePicker extends StatefulWidget {
  final String title;
  final List<FilterOption> options;
  final FilterOption? selected;

  const _SearchablePicker({
    required this.title,
    required this.options,
    this.selected,
  });

  static Future<FilterOption?> open(
    BuildContext context, {
    required String title,
    required List<FilterOption> options,
    FilterOption? selected,
  }) {
    return showModalBottomSheet<FilterOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _SearchablePicker(title: title, options: options, selected: selected),
    );
  }

  @override
  State<_SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<_SearchablePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.options
        : widget.options
              .where((o) => o.label.toLowerCase().contains(q))
              .toList();

    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(widget.title, style: AppStyles.textLBold),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: t.filterSearchHint,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppStyles.primaryColor,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppStyles.borderLightGray,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppStyles.borderLightGray,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          t.filterNoOptions,
                          style: AppStyles.textSm.copyWith(
                            color: AppStyles.textDarkGrayColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final opt = filtered[i];
                          final isSel = opt.value == widget.selected?.value;
                          return ListTile(
                            title: Text(
                              opt.label,
                              style: AppStyles.textSm.copyWith(
                                color: AppStyles.blackColor,
                              ),
                            ),
                            trailing: isSel
                                ? const Icon(
                                    Icons.check,
                                    color: AppStyles.primaryColor,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, opt),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
