import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_providers.dart';

final userEmailProvider = FutureProvider<String>((ref) async {
  final FlutterSecureStorage storage = ref.read(secureStorageProvider);
  return (await storage.read(key: 'user_email')) ?? '';
});
