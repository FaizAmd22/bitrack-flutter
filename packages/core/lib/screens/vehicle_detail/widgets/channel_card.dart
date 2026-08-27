import 'package:flutter/material.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';

import '../state/channel_state.dart';
import 'flv_player.dart';

class ChannelCard extends StatelessWidget {
  final int index;
  final int channelId;
  final ChannelState state;
  final VoidCallback onToggle;
  final String Function(int) formatTimer;

  const ChannelCard({
    super.key,
    required this.index,
    required this.channelId,
    required this.state,
    required this.onToggle,
    required this.formatTimer,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = state.status == ChannelStatus.active;
    final isLoading = state.status == ChannelStatus.loading;
    final isError = state.status == ChannelStatus.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isActive, isLoading),
          const SizedBox(height: 6),
          _buildVideoContainer(context, isActive, isLoading, isError),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isActive, bool isLoading) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text('${t.dashcam} ${index + 1}', style: AppStyles.textMdBold),
        ),
        Text(
          formatTimer(state.timer),
          style: AppStyles.textSm.copyWith(color: AppStyles.textDarkGrayColor),
        ),
        const SizedBox(width: 10),
        if (isLoading)
          const SizedBox(
            width: 36,
            height: 20,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppStyles.primaryColor,
                ),
              ),
            ),
          )
        else
          Switch(
            value: isActive,
            activeColor: AppStyles.redColor,
            onChanged: (_) => onToggle(),
          ),
      ],
    );
  }

  Widget _buildVideoContainer(
    BuildContext context,
    bool isActive,
    bool isLoading,
    bool isError,
  ) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildVideoContent(context, isActive, isLoading, isError),
    );
  }

  Widget _buildVideoContent(
    BuildContext context,
    bool isActive,
    bool isLoading,
    bool isError,
  ) {
    final t = AppLocalizations.of(context);
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppStyles.primaryColor),
      );
    }
    if (isError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              color: AppStyles.redColor,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              state.errorMessage ?? t.channelCameraOfflineFallback,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppStyles.redColor, fontSize: 12),
            ),
          ],
        ),
      );
    }
    if (isActive && state.streamUrl != null) {
      return FlvPlayer(streamUrl: state.streamUrl!);
    }
    return Center(
      child: Text(
        t.channelCameraOffToggle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black45, fontSize: 12),
      ),
    );
  }
}
