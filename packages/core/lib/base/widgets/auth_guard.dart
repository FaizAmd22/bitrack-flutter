import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  bool _loading = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    // AuthGuard merender spinner-nya sendiri sampai pembacaan ini selesai,
    // jadi layar anak (mis. VehicleDetail) belum dibuat dan request pertamanya
    // belum terkirim. Durasinya dicatat supaya terlihat kalau langkah serial
    // ini ikut menyumbang lamanya loading.
    final started = DateTime.now();
    final token = (await _storage.read(key: 'auth_token'))?.trim() ?? '';
    debugPrint(
      '[AUTHGUARD] baca token selesai dalam '
      '${DateTime.now().difference(started).inMilliseconds}ms',
    );
    if (!mounted) return;

    if (token.isEmpty) {
      setState(() {
        _loading = false;
        _authed = false;
      });
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
        (route) => false,
      );
      return;
    }

    setState(() {
      _loading = false;
      _authed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_authed) {
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}
