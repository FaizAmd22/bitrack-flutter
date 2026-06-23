// lib/screens/notification/notes/notes_screen.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:ams/screens/notification/models/notes_screen_args.dart';
import 'package:ams/screens/notification/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _service = NotificationService();
  Future<AlertModel?>? _future;
  bool _isValidation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    final item = args is NotesScreenArgs ? args.item : args as AlertModel?;
    _isValidation = args is NotesScreenArgs ? args.isValidation : false;

    final id = item?.id;

    // List alert tidak membawa note/attachment; ambil detail lengkap
    // lewat /transaction-alert/{id} supaya keduanya terisi.
    _future = (id == null || id.isEmpty)
        ? Future.value(item)
        : _service.fetchAlertDetail(id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

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
        title: Text(
          _isValidation ? t.seeNotesValidation : t.seeNotesVerification,
          style: AppStyles.textLBold,
        ),
      ),
      body: FutureBuilder<AlertModel?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = snapshot.data;
          final note = _isValidation
              ? item?.noteValidation?.trim()
              : item?.note?.trim();
          final attachments = _isValidation
              ? item?.attachmentValidation
              : item?.attachment;

          final firstImage = (attachments != null && attachments.isNotEmpty)
              ? attachments.first
              : null;

          return Padding(
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
          );
        },
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
