import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class ActivityOption {
  final String value;
  final String label;
  const ActivityOption(this.value, this.label);
}

const kActivityOptions = <ActivityOption>[
  ActivityOption('allVehicle', 'All Vehicle'),
  ActivityOption('inOperation', 'In Operation'),
  ActivityOption('moving', 'Moving'),
  ActivityOption('idle', 'Idle'),
  ActivityOption('stop', 'Stop'),
  ActivityOption('silence', 'Silence'),
  ActivityOption('repair', 'In Repair'),
];

class ActivityChips extends StatelessWidget {
  final String selectedActivity;
  final ValueChanged<String> onActivityChanged;
  final int totalVehicle;

  const ActivityChips({
    super.key,
    required this.selectedActivity,
    required this.onActivityChanged,
    required this.totalVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kActivityOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = kActivityOptions[i];
          final isActive = selectedActivity == item.value;

          return GestureDetector(
            onTap: () => onActivityChanged(item.value),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive
                    ? AppStyles.primaryColor
                    : AppStyles.whiteColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? '${item.label} ($totalVehicle)' : item.label,
                style: AppStyles.textSm.copyWith(
                  color: isActive ? AppStyles.whiteColor : AppStyles.blackColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
