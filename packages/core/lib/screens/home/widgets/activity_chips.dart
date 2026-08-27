import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ActivityOption {
  final String value;
  final String label;
  const ActivityOption(this.value, this.label);
}

List<ActivityOption> activityOptions(AppLocalizations t) => [
  ActivityOption('allVehicle', t.activityAllVehicle),
  ActivityOption('inOperation', t.activityInOperation),
  ActivityOption('moving', t.activityMoving),
  ActivityOption('idle', t.activityIdle),
  ActivityOption('stop', t.activityStop),
  ActivityOption('silence', t.activitySilence),
  ActivityOption('repair', t.activityInRepair),
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
    final options = activityOptions(AppLocalizations.of(context));
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = options[i];
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
