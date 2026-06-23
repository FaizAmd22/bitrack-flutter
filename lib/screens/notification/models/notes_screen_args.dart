import 'package:ams/screens/notification/models/alert_model.dart';

class NotesScreenArgs {
  final AlertModel item;
  final bool isValidation;

  const NotesScreenArgs({required this.item, this.isValidation = false});
}
