import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pembungkus halaman khusus tamu (Login, Register).
///
/// Kalau user ternyata sudah login (ada `auth_token` di secure storage), ia
/// langsung dipindah ke Home. Kebalikan dari [AuthGuard]. Dipasang di
/// `routes:` `main.dart` tiap app.
class GuestGuard extends StatefulWidget {
  final Widget child;
  const GuestGuard({super.key, required this.child});

  @override
  State<GuestGuard> createState() => _GuestGuardState();
}

class _GuestGuardState extends State<GuestGuard> {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  bool _loading = true;
  bool _allowAccess = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final token = (await _storage.read(key: 'auth_token'))?.trim() ?? '';
    if (!mounted) return;

    if (token.isNotEmpty) {
      // Sudah login: ganti seluruh tumpukan halaman dengan Home.
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeScreen,
        (route) => false,
      );
      return;
    }

    setState(() {
      _loading = false;
      _allowAccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_allowAccess) {
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
