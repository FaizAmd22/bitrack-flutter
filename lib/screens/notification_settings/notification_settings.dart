import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/tx_toggle_tile.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool alert = true;
  bool softwareUpdate = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        surfaceTintColor: AppStyles.bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t.notificationSettings, style: AppStyles.textLBold),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),

            TxToggleTile(
              title: t.alert,
              value: alert,
              onChanged: (v) => setState(() => alert = v),
            ),

            TxToggleTile(
              title: t.softwareUpdate,
              value: softwareUpdate,
              onChanged: (v) => setState(() => softwareUpdate = v),
            ),
          ],
        ),
      ),
    );
  }
}
