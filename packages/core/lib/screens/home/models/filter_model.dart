/// Satu pilihan filter: [value] dikirim ke API, [label] ditampilkan.
/// [value] null berarti "Semua" (tanpa filter).
class FilterOption {
  final String? value;
  final String label;

  const FilterOption({required this.value, required this.label});
}

/// Pilihan filter peta Home dari bottom sheet filter: jenis/kategori,
/// fleet group, dan geofence.
class FilterResult {
  final FilterOption selectedType;
  final FilterOption selectedFleetGroup;
  final FilterOption selectedGeofence;

  const FilterResult({
    required this.selectedType,
    required this.selectedFleetGroup,
    required this.selectedGeofence,
  });

  FilterResult copyWith({
    FilterOption? selectedType,
    FilterOption? selectedFleetGroup,
    FilterOption? selectedGeofence,
  }) {
    return FilterResult(
      selectedType: selectedType ?? this.selectedType,
      selectedFleetGroup: selectedFleetGroup ?? this.selectedFleetGroup,
      selectedGeofence: selectedGeofence ?? this.selectedGeofence,
    );
  }
}
