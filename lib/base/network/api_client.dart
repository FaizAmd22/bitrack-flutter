import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:bitrack_mobile_flutter/base/routes/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: dotenv.env['API_BASE_URL']!,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              if (!options.path.endsWith('/login')) {
                const storage = FlutterSecureStorage();
                final token = await storage.read(key: 'auth_token');

                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
              }
              handler.next(options);
            },

            onError: (DioException e, handler) async {
              if (e.response?.statusCode == 401) {
                const storage = FlutterSecureStorage();

                await storage.delete(key: 'auth_token');
                await storage.delete(key: 'user_id');
                await storage.delete(key: 'user_name');
                await storage.delete(key: 'user_email');
                await storage.delete(key: 'user_role');
                await storage.delete(key: 'user_role_permission');

                final navigator = NavigationService.navigatorKey.currentState;

                if (navigator != null) {
                  navigator.pushNamedAndRemoveUntil(
                    AppRoutes.loginScreen,
                    (route) => false,
                  );
                }
              }

              handler.next(e);
            },
          ),
        );
}
