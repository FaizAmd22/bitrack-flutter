import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/screens/notification/services/fetch_alert_type.dart';

final alertTypeApiProvider = Provider<FetchAlertType>(
  (ref) => FetchAlertType(),
);

final alertTypeProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(alertTypeApiProvider);
  return api.fetch();
});
