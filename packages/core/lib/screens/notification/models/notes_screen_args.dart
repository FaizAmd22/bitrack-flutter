import 'package:bitrack_core/screens/notification/models/alert_model.dart';

/// Argumen route halaman Notes. [isValidation] true = tampilkan catatan dan
/// lampiran tahap validasi, bukan tahap tindak lanjut.
class NotesScreenArgs {
  final AlertModel item;
  final bool isValidation;

  const NotesScreenArgs({required this.item, this.isValidation = false});
}
