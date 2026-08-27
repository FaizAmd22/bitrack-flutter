/// Padanan `workOrderOptionsSlice` di bitrack-mobile: kumpulan option yang
/// dipakai lintas halaman Work Order (filter, create, dan form detail).
class OptionItem {
  final String value;
  final String label;

  const OptionItem({required this.value, required this.label});

  factory OptionItem.fromJson(Map json) {
    final value = (json['value'] ?? json['id'] ?? '').toString();
    final label = (json['label'] ?? json['name'] ?? value).toString();
    return OptionItem(value: value, label: label);
  }

  static List<OptionItem> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(OptionItem.fromJson)
        .toList(growable: false);
  }
}

class WorkCategoryOption {
  final String name;
  final List<OptionItem> workType;

  const WorkCategoryOption({required this.name, required this.workType});

  factory WorkCategoryOption.fromJson(Map json) {
    return WorkCategoryOption(
      name: (json['name'] ?? json['label'] ?? '').toString(),
      workType: OptionItem.listFrom(json['work_type']),
    );
  }
}

class WorkOrderOptions {
  final List<OptionItem> fleetGroup;
  final List<OptionItem> technician;
  final List<OptionItem> licensePlate;
  final List<WorkCategoryOption> workCategory;

  const WorkOrderOptions({
    required this.fleetGroup,
    required this.technician,
    required this.licensePlate,
    required this.workCategory,
  });

  static const empty = WorkOrderOptions(
    fleetGroup: [],
    technician: [],
    licensePlate: [],
    workCategory: [],
  );

  factory WorkOrderOptions.fromJson(Map json) {
    final rawCategory = json['work_category'];

    return WorkOrderOptions(
      fleetGroup: OptionItem.listFrom(json['fleet_group']),
      technician: OptionItem.listFrom(json['technician']),
      licensePlate: OptionItem.listFrom(json['license_plate']),
      workCategory: rawCategory is List
          ? rawCategory
                .whereType<Map>()
                .map(WorkCategoryOption.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  String fleetGroupLabel(String? id) {
    if (id == null) return '-';
    for (final f in fleetGroup) {
      if (f.value == id) return f.label;
    }
    return '-';
  }

  String technicianLabel(String? id) {
    if (id == null || id.isEmpty) return '-';
    for (final t in technician) {
      if (t.value == id) return t.label;
    }
    return id;
  }

  /// Cocokkan `work_category` dari API (mis. "SIM_CARD") dengan option yang
  /// namanya bisa berbeda spasi/underscore-nya.
  WorkCategoryOption? categoryOf(String? rawCategory) {
    final key = _normalizeKey(rawCategory);
    if (key.isEmpty) return null;
    for (final c in workCategory) {
      if (_normalizeKey(c.name) == key) return c;
    }
    return null;
  }

  String categoryLabel(String? rawCategory) =>
      categoryOf(rawCategory)?.name ?? (rawCategory ?? '-');

  String workTypeLabel(String? rawCategory, String? rawType) {
    final category = categoryOf(rawCategory);
    if (category != null) {
      for (final t in category.workType) {
        if (t.value == rawType) return t.label;
      }
    }
    return _titleCase(rawType);
  }
}

String _normalizeKey(String? value) =>
    (value ?? '').toLowerCase().replaceAll(RegExp(r'[_\s]'), '');

String _titleCase(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value
      .toLowerCase()
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
