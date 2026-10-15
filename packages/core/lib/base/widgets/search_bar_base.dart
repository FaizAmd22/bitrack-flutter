import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/plate_search_bar.dart';
import 'package:flutter/material.dart';

/// Baris pencarian standar di atas halaman daftar/peta: kolom cari plat
/// nomor ([PlateSearchBar], dengan saran plat) + tombol filter opsional, dan
/// slot widget tambahan di bawahnya ([below]).
///
/// Dipakai di Home, Notifikasi, Vehicle, dan Work Order.
class SearchBarBase extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final List<String> suggestionPlates;
  final String? hintText;
  final bool showFilter;
  final EdgeInsetsGeometry padding;

  /// Dipanggil saat tombol filter ditekan; tiap halaman membuka bottom sheet
  /// filternya sendiri. Null = tombol tampil tapi tidak bisa ditekan.
  final Future<void> Function(BuildContext context)? onOpenFilter;

  /// Widget tambahan di bawah baris pencarian, mis. chip aktivitas di Home.
  final Widget? below;

  const SearchBarBase({
    super.key,
    this.value,
    this.onChanged,
    this.suggestionPlates = const [],
    this.hintText,
    this.showFilter = true,
    this.onOpenFilter,
    this.below,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: PlateSearchBar(
                  value: value,
                  onChanged: onChanged,
                  suggestionPlates: suggestionPlates,
                  hintText: hintText,
                ),
              ),
              if (showFilter) ...[
                const SizedBox(width: 10),
                _FilterButton(
                  onTap: onOpenFilter == null
                      ? null
                      : () => onOpenFilter!(context),
                ),
              ],
            ],
          ),
          if (below != null) ...[const SizedBox(height: 10), below!],
        ],
      ),
    );
  }
}

/// Tombol kotak berikon filter di sebelah kanan kolom cari.
class _FilterButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _FilterButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppStyles.whiteColor,
          border: Border.all(color: AppStyles.borderLightGray, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: AppStyles.primaryColor,
          size: 22,
        ),
      ),
    );
  }
}
