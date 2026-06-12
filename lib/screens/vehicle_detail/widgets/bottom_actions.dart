import 'package:flutter/material.dart';
import 'package:ams/base/res/styles/app_styles.dart';

class BottomActions extends StatelessWidget {
  final bool isSpeaker;
  final bool isSpeakerLoading;
  final bool isMicrophone;
  final VoidCallback onSpeakerTap;
  final VoidCallback onMicrophoneTap;
  final double bottomInset;

  const BottomActions({
    super.key,
    required this.isSpeaker,
    required this.isSpeakerLoading,
    required this.isMicrophone,
    required this.onSpeakerTap,
    required this.onMicrophoneTap,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 14 + bottomInset),
      decoration: const BoxDecoration(
        color: AppStyles.whiteColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: isSpeaker
                  ? Icons.volume_up_outlined
                  : Icons.volume_off_outlined,
              label: 'Speaker',
              isOn: isSpeaker,
              isLoading: isSpeakerLoading,
              onTap: onSpeakerTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: isMicrophone ? Icons.mic_outlined : Icons.mic_off_outlined,
              label: 'Intercom',
              isOn: isMicrophone,
              onTap: onMicrophoneTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isOn,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyles.whiteColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppStyles.textBlackColor),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: AppStyles.textMdBold)),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppStyles.primaryColor,
                  ),
                )
              else
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: AppStyles.textMdBold.copyWith(
                    color: isOn ? AppStyles.greenColor : AppStyles.redColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
