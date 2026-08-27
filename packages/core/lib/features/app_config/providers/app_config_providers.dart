import 'package:bitrack_core/features/app_config/data/app_config_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Menentukan apakah link "Daftar" ditampilkan di halaman login.
/// Nilainya disimpan di tabel `app_settings` (key = `show_register`) di
/// Supabase, dan bisa diubah lewat Postman tanpa perlu rilis ulang aplikasi.
/// Default tersembunyi (false) selama Supabase belum dikonfigurasi/gagal
/// diambil, supaya aman untuk rilis publik.
final showRegisterLinkProvider = FutureProvider<bool>((ref) {
  return AppConfigApi.fetchFlag('show_register', fallback: false);
});
