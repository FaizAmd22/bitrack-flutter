import 'package:bitrack_core/features/app_config/data/app_config_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Menentukan apakah link "Daftar" ditampilkan di halaman login.
/// Nilainya disimpan di tabel `app_settings` (key = `show_register`) di
/// Supabase, dan bisa diubah lewat Postman tanpa perlu rilis ulang aplikasi.
/// Default tersembunyi (false) selama Supabase belum dikonfigurasi/gagal
/// diambil, supaya aman untuk rilis publik.
///
/// `autoDispose` itu penting: tanpa itu FutureProvider men-cache hasil fetch
/// pertama selama proses app hidup, jadi flag yang diubah di Supabase baru
/// terbaca setelah app di-kill total — bukan saat halaman login dibuka lagi.
/// Dengan autoDispose provider dibuang begitu halaman login lepas dari stack
/// (login sukses memakai pushNamedAndRemoveUntil), lalu di-fetch ulang saat
/// login tampil lagi. FormLogin juga meng-invalidate ini di initState untuk
/// menjamin fetch ulang walau widget-nya kebetulan masih hidup.
final showRegisterLinkProvider = FutureProvider.autoDispose<bool>((ref) {
  return AppConfigApi.fetchFlag('show_register', fallback: false);
});
