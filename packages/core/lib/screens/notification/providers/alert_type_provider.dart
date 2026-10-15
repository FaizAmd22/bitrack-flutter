import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_core/screens/notification/services/fetch_alert_type.dart';

/// Service jenis alert (bisa diganti versi palsu di tes).
final alertTypeApiProvider = Provider<FetchAlertType>(
  (ref) => FetchAlertType(),
);

/// Daftar jenis alert (`value`/`label`) untuk filter notifikasi. Di-cache
/// selama app berjalan.
final alertTypeProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(alertTypeApiProvider);
  return api.fetch();
});
