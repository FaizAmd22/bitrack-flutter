// lib/screens/notification/notes/notes_screen.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final item = ModalRoute.of(context)?.settings.arguments as AlertModel?;

    final note = item?.note?.trim();
    final attachments = item?.attachment;

    final firstImage = (attachments != null && attachments.isNotEmpty)
        ? attachments.first
        : null;

    return Scaffold(
      backgroundColor: AppStyles.whiteColor,
      appBar: AppBar(
        backgroundColor: AppStyles.whiteColor,
        elevation: 0,
        surfaceTintColor: AppStyles.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t.alertNotes, style: AppStyles.textLBold),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ListView(
          children: [
            Text(t.notes, style: AppStyles.textMdBold),
            const SizedBox(height: 10),
            Text(
              (note == null || note.isEmpty) ? t.noNotes : note,
              style: AppStyles.textSm,
            ),

            const SizedBox(height: 20),
            Text('Media', style: AppStyles.textMdBold),
            const SizedBox(height: 10),

            if (firstImage != null)
              GestureDetector(
                onTap: () => _openFullImage(context, firstImage),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    firstImage,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      alignment: Alignment.center,
                      color: AppStyles.inputDisableBg,
                      child: Text(t.noMedia, style: AppStyles.textSm),
                    ),
                  ),
                ),
              )
            else
              Text(t.noMedia, style: AppStyles.textSm),
          ],
        ),
      ),
    );
  }

  void _openFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Center(child: Image.network(url, fit: BoxFit.contain)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
