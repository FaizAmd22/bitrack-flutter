import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/plate_search_bar.dart';
import 'package:flutter/material.dart';

class SearchBarBase extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final List<String> suggestionPlates;
  final String? hintText;
  final bool showFilter;
  final EdgeInsetsGeometry padding;

  /// Padanan `renderFilter` Cordova — tiap halaman membuka sheet-nya sendiri.
  final Future<void> Function(BuildContext context)? onOpenFilter;

  /// Padanan `renderBelow` Cordova — mis. activity chips di HomeScreen.
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
                  hintText: hintText ?? 'Search...',
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
