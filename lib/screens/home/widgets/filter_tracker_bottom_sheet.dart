// ignore_for_file: deprecated_member_use
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/screens/home/models/filter_model.dart';
import 'package:flutter/material.dart';

enum _View { main, type, fleet, geo }

class FilterTrackerBottomSheet extends StatefulWidget {
  final List<FilterOption> fleetGroups;
  final List<FilterOption> geofences;

  final FilterOption initialType; // value: 'fleetgroup' / 'geofence' / null
  final FilterOption initialFleetGroup;
  final FilterOption initialGeofence;

  const FilterTrackerBottomSheet({
    super.key,
    required this.fleetGroups,
    required this.geofences,
    required this.initialType,
    required this.initialFleetGroup,
    required this.initialGeofence,
  });

  static Future<FilterResult?> open(
    BuildContext context, {
    required List<FilterOption> fleetGroups,
    required List<FilterOption> geofences,
    required FilterOption initialType,
    required FilterOption initialFleetGroup,
    required FilterOption initialGeofence,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterTrackerBottomSheet(
        fleetGroups: fleetGroups,
        geofences: geofences,
        initialType: initialType,
        initialFleetGroup: initialFleetGroup,
        initialGeofence: initialGeofence,
      ),
    );
  }

  @override
  State<FilterTrackerBottomSheet> createState() =>
      _FilterTrackerBottomSheetState();
}

class _FilterTrackerBottomSheetState extends State<FilterTrackerBottomSheet> {
  _View _view = _View.main;

  late FilterOption _selectedType;
  late FilterOption _selectedFleet;
  late FilterOption _selectedGeo;

  String _search = '';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedFleet = widget.initialFleetGroup;
    _selectedGeo = widget.initialGeofence;
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
    Navigator.pop(
      context,
      FilterResult(
        selectedType: _selectedType,
        selectedFleetGroup: _selectedFleet,
        selectedGeofence: _selectedGeo,
      ),
    );
  }

  void _clear() {
    setState(() {
      _selectedType = const FilterOption(
        value: null,
        label: 'Pilih jenis filter',
      );
      _selectedFleet = const FilterOption(
        value: null,
        label: 'Semua Fleet Group',
      );
      _selectedGeo = const FilterOption(value: null, label: 'Semua Geofence');
      _view = _View.main;
      _search = '';
    });
  }

  List<FilterOption> _filtered(List<FilterOption> items) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where((e) => e.label.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          height: mq.size.height * 0.75,
          decoration: BoxDecoration(
            color: AppStyles.whiteColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              _Header(title: _titleByView(), onBack: _back),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: _buildContent(),
                ),
              ),
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
                          side: BorderSide(color: AppStyles.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Hapus Filter',
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
                          'Terapkan Filter',
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
      ),
    );
  }

  String _titleByView() {
    switch (_view) {
      case _View.type:
        return 'Pilihan';
      case _View.fleet:
        return 'Fleet Group';
      case _View.geo:
        return 'Geofence';
      case _View.main:
        return 'Filter';
    }
  }

  Widget _buildContent() {
    if (_view == _View.main) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilihan', style: AppStyles.textMdBold),
          const SizedBox(height: 8),
          _SelectTile(
            label: _selectedType.label,
            onTap: () => setState(() => _view = _View.type),
          ),
          const SizedBox(height: 14),

          if (_selectedType.value == 'fleetgroup') ...[
            Text('Fleet Group', style: AppStyles.textMdBold),
            const SizedBox(height: 8),
            _SelectTile(
              label: _selectedFleet.label,
              onTap: () => setState(() => _view = _View.fleet),
            ),
          ],

          if (_selectedType.value == 'geofence') ...[
            Text('Geofence', style: AppStyles.textMdBold),
            const SizedBox(height: 8),
            _SelectTile(
              label: _selectedGeo.label,
              onTap: () => setState(() => _view = _View.geo),
            ),
          ],
        ],
      );
    }

    final items = switch (_view) {
      _View.type => const [
        FilterOption(value: 'fleetgroup', label: 'Fleet Group'),
        FilterOption(value: 'geofence', label: 'Geofence'),
      ],
      _View.fleet => widget.fleetGroups,
      _View.geo => widget.geofences,
      _ => const <FilterOption>[],
    };

    final list = _filtered(items);

    return Column(
      children: [
        _SearchBox(
          value: _search,
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    'Data tidak tersedia',
                    style: AppStyles.textMd.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, i) {
                    final opt = list[i];
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
                          if (_view == _View.type) {
                            _selectedType = opt;

                            if (opt.value == 'fleetgroup') {
                              _selectedGeo = const FilterOption(
                                value: null,
                                label: 'Semua Geofence',
                              );
                            } else if (opt.value == 'geofence') {
                              _selectedFleet = const FilterOption(
                                value: null,
                                label: 'Semua Fleet Group',
                              );
                            }
                          } else if (_view == _View.fleet) {
                            _selectedFleet = opt;
                          } else if (_view == _View.geo) {
                            _selectedGeo = opt;
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

class _SearchBox extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari',
        prefixIcon: Icon(Icons.search, color: AppStyles.primaryColor),
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
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SelectTile({required this.label, required this.onTap});

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
              Expanded(child: Text(label, style: AppStyles.textMd)),
              Icon(Icons.chevron_right, color: AppStyles.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
