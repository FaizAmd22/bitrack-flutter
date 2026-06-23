// lib/screens/notification/widgets/card_notif_popup.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/utils/string_utils.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:ams/screens/notification/models/notes_screen_args.dart';
import 'package:flutter/material.dart';

class CardNotifPopup {
  static Future<void> open(BuildContext context, AlertModel item) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _CardNotifPopupBody(item: item),
    );
  }
}

class _CardNotifPopupBody extends StatelessWidget {
  final AlertModel item;
  const _CardNotifPopupBody({required this.item});

  void _goNotes(BuildContext context, {required bool isValidation}) {
    Navigator.pop(context); // tutup sheet dulu
    Navigator.pushNamed(
      context,
      AppRoutes.notesScreen,
      arguments: NotesScreenArgs(item: item, isValidation: isValidation),
    );
  }

  void _goMapCoordinate(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoutes.mapCoordinateScreen,
      arguments: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header dengan title + garis bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                titleCase(item.eventName ?? '-'),
                style: AppStyles.textLBold,
              ),
            ),
            Container(height: 1, color: AppStyles.borderLightGray),

            const SizedBox(height: 10),

            // Menu: See Notes Verification
            InkWell(
              onTap: () => _goNotes(context, isValidation: false),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Text(t.seeNotesVerification, style: AppStyles.textMd),
              ),
            ),

            // Menu: See Notes Validation
            InkWell(
              onTap: () => _goNotes(context, isValidation: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Text(t.seeNotesValidation, style: AppStyles.textMd),
              ),
            ),

            // Menu: Show Map Coordinate
            InkWell(
              onTap: () => _goMapCoordinate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Text(t.showMapCoordinate, style: AppStyles.textMd),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
