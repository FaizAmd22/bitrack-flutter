// lib/screens/home/widgets/filter_tracker_bottom_sheet.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/screens/home/models/filter_model.dart';
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
    required FilterOption initialType,
    required FilterOption initialFleetGroup,
    required FilterOption initialGeofence,
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
const _kTypeOptions = <FilterOption>[
  FilterOption(value: 'fleetgroup', label: 'Fleet Group'),
  // FilterOption(value: 'geofence', label: 'Geofence'),
];

class _FilterSheetBody extends StatefulWidget {
  final List<FilterOption> fleetGroups;
  final List<FilterOption> geofences;
  final FilterOption initialType;
  final FilterOption initialFleetGroup;
  final FilterOption initialGeofence;

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
  late FilterOption _type = widget.initialType;
  late FilterOption _fleetGroup = widget.initialFleetGroup;
  late FilterOption _geofence = widget.initialGeofence;

  static const _allFleet = FilterOption(
    value: null,
    label: 'Semua Fleet Group',
  );
  static const _allGeo = FilterOption(value: null, label: 'Semua Geofence');
  static const _noType = FilterOption(value: null, label: 'Pilih jenis filter');

  void _clear() {
    Navigator.pop(
      context,
      const TrackerFilterResult(
        selectedType: _noType,
        selectedFleetGroup: _allFleet,
        selectedGeofence: _allGeo,
      ),
    );
  }

  void _apply() {
    Navigator.pop(
      context,
      TrackerFilterResult(
        selectedType: _type,
        selectedFleetGroup: _fleetGroup,
        selectedGeofence: _geofence,
      ),
    );
  }

  Future<void> _pickType() async {
    final picked = await _SearchablePicker.open(
      context,
      title: 'Jenis Filter',
      options: _kTypeOptions,
      selected: _type,
    );
    if (picked != null) setState(() => _type = picked);
  }

  Future<void> _pickFleetGroup() async {
    final picked = await _SearchablePicker.open(
      context,
      title: 'Fleet Group',
      options: widget.fleetGroups,
      selected: _fleetGroup,
    );
    if (picked != null) setState(() => _fleetGroup = picked);
  }

  Future<void> _pickGeofence() async {
    final picked = await _SearchablePicker.open(
      context,
      title: 'Geofence',
      options: widget.geofences,
      selected: _geofence,
    );
    if (picked != null) setState(() => _geofence = picked);
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text('Filter', style: AppStyles.textLBold),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Label('Jenis'),
                  _SelectRow(
                    value: _type.value == null ? null : _type.label,
                    placeholder: 'Pilih jenis filter',
                    onTap: _pickType,
                  ),
                  if (_type.value == 'fleetgroup') ...[
                    const SizedBox(height: 16),
                    _Label('Fleet Group'),
                    _SelectRow(
                      value: _fleetGroup.label,
                      placeholder: 'Pilih Fleet Group',
                      onTap: _pickFleetGroup,
                    ),
                  ],
                  if (_type.value == 'geofence') ...[
                    const SizedBox(height: 16),
                    _Label('Geofence'),
                    _SelectRow(
                      value: _geofence.label,
                      placeholder: 'Pilih Geofence',
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
                        'Hapus Filter',
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
                        'Terapkan',
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
                    hintText: 'Cari...',
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
                          'Tidak ada opsi',
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
