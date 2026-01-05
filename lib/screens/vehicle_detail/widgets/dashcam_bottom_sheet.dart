import 'package:bitrack_mobile_flutter/base/widgets/app_draggable_sheet.dart';
import 'package:flutter/material.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';

class DashcamBottomSheet extends StatelessWidget {
  const DashcamBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDraggableSheet(
      title: 'Dashcam',
      sliverBuilder: (context, scrollController) {
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DashcamCard(title: 'Dashcam ${index + 1}'),
            );
          },
        );
      },
      bottom: const _BottomActions(),
    );
  }
}

class DashcamCard extends StatelessWidget {
  final String title;
  const DashcamCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppStyles.textMd)),
              Switch(value: false, onChanged: (_) {}),
            ],
          ),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                "Camera is off. Turn it on to view the dashcam.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: AppStyles.whiteColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: const Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.volume_up_outlined,
                label: "Speaker",
                status: "OFF",
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.mic_off_outlined,
                label: "Intercom",
                status: "OFF",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isOff = status.toUpperCase() == "OFF";

    return Material(
      color: AppStyles.whiteColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: AppStyles.textMdBold)),
              Text(
                isOff ? "OFF" : status,
                style: AppStyles.textMdBold.copyWith(
                  color: isOff ? AppStyles.redColor : AppStyles.greenColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
