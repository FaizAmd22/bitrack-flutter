// ignore_for_file: deprecated_member_use
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/plate_search_bar.dart';

class MonitoringSearchBar extends StatelessWidget {
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;

  final String selectedActivity;
  final ValueChanged<String>? onActivityChanged;

  final int totalVehicle;
  final List<String> suggestionPlates;

  final VoidCallback? onTapFilter;

  const MonitoringSearchBar({
    super.key,
    this.searchQuery,
    this.onSearchChanged,
    required this.selectedActivity,
    this.onActivityChanged,
    required this.totalVehicle,
    required this.suggestionPlates,
    this.onTapFilter,
  });

  static const Map<String, String> _activities = {
    'allVehicle': 'All Vehicle',
    'inOperation': 'In Operation',
    'moving': 'Moving',
    'idle': 'Idle',
    'stop': 'Stop',
    'silence': 'Silence',
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlateSearchBar(
            value: searchQuery,
            onChanged: onSearchChanged,
            suggestionPlates: suggestionPlates,
            onTapFilter: onTapFilter,
            hintText: t.searchLicensePlate,
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _activities.entries
                  .map((entry) {
                    final isSelected = entry.key == selectedActivity;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onActivityChanged?.call(entry.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppStyles.primaryColor
                                : AppStyles.whiteColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            isSelected
                                ? "${entry.value} ($totalVehicle)"
                                : entry.value,
                            style: AppStyles.textSm.copyWith(
                              color: isSelected
                                  ? AppStyles.whiteColor
                                  : AppStyles.blackColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
