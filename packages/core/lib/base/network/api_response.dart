import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:dio/dio.dart';

/// Helper baca response backend TANPA bergantung pada field `status` di body.
///
/// Sumber kebenaran sukses/gagal cuma satu: HTTP status code. Dio sudah
/// menolak semua respons non-2xx jadi DioException lewat `validateStatus`
/// bawaannya, jadi kalau eksekusi sampai ke parser berarti request-nya sukses
/// — tidak perlu diverifikasi ulang lewat body.
///
/// Ini disengaja: bentuk field `status` berubah-ubah antar-endpoint dan
/// antar-versi backend (pernah boolean `true`, sekarang string `"success"`).
/// Setiap kali app ikut mengunci nilainya, perubahan kecil di backend memaksa
/// rilis ulang aplikasi. Body sekarang cuma dibaca untuk dua hal: mengambil
/// `data`, dan mengambil `message` saat request-nya memang gagal.

/// Ambil `data` sebagai list of map.
///
/// List kosong itu hasil yang sah (memang belum ada isinya) dan diteruskan
/// apa adanya. Yang dilempar cuma kalau `data` bukan list sama sekali —
/// itu berarti bentuk response-nya di luar dugaan, bukan sekadar kosong.
List<Map<String, dynamic>> apiDataList(
  dynamic body, {
  required String onInvalid,
}) {
  final raw = body is Map ? body['data'] : null;
  if (raw is! List) throw Exception(onInvalid);

  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}

/// Ubah error apa pun jadi teks yang bisa dimengerti user.
///
/// Ini satu-satunya pintu untuk menampilkan error jaringan ke UI. Jangan
/// pernah menaruh `e.toString()` langsung di widget: untuk DioException
/// hasilnya adalah paragraf teknis berbahasa Inggris ("DioException [bad
/// response]: ... validateStatus was configured to throw...") yang tidak
/// berarti apa-apa buat user.
///
/// Pesan dari backend dipakai kalau ada dan HTTP-nya memang gagal. Selain itu
/// jatuh ke pesan per-jenis kegagalan, lalu ke [fallback] yang kontekstual
/// (mis. "Gagal memuat data kendaraan").
String apiErrorText(Object error, [String? fallback]) {
  final t = currentL10n();
  final generic = fallback ?? t.errGenericTryAgain;

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return t.errConnectionTimeout;
      case DioExceptionType.connectionError:
        return t.errConnectionFailed;
      case DioExceptionType.badCertificate:
        return t.errInsecureConnection;
      case DioExceptionType.cancel:
        return t.errRequestCancelled;
      case DioExceptionType.unknown:
        return t.errNoInternetConnection;
      case DioExceptionType.badResponse:
        return _badResponseText(error, t, generic);
    }
  }

  if (error is Exception) {
    final msg = error.toString().replaceFirst('Exception: ', '').trim();
    // Exception yang isinya cuma DioException yang di-toString di tempat lain
    // tetap harus disaring, jangan diteruskan mentah-mentah ke user.
    if (msg.isNotEmpty && !msg.startsWith('DioException')) return msg;
  }

  return generic;
}

String _badResponseText(DioException e, AppLocalizations t, String fallback) {
  final data = e.response?.data;

  // Kode dulu, baru HTTP status. Kode itu makna bisnis ("kendaraan tidak
  // ada"), HTTP status itu makna transport ("endpoint-nya tidak ada") — dua
  // hal berbeda yang kebetulan sama-sama 404.
  final byCode = messageForApiCode(data is Map ? data['code'] : null, t);
  if (byCode != null) return byCode;

  final code = e.response?.statusCode;
  if (code == null) return fallback;
  if (code == 401 || code == 403) return t.errNoAccess;
  // 404 tanpa kode yang dikenali berarti endpoint-nya memang tidak ada —
  // itu masalah konfigurasi/backend, jadi jangan bilang datanya kosong.
  if (code == 404) return t.errServiceUnavailable;
  if (code == 409) return t.errDuplicateData;
  if (code == 422 || code == 400) return t.errIncompleteData;
  if (code >= 500) return t.errServerProblem;
  return fallback;
}

/// Terjemahkan `code` dari envelope backend jadi pesan berbahasa user.
///
/// Backend mengirim `message` dalam Bahasa Indonesia, jadi meneruskannya apa
/// adanya membuat user Korea/Jepang/China melihat UI campur dua bahasa.
/// Yang dipetakan adalah `code`-nya, karena itu identifier yang stabil dan
/// tidak ikut berubah kalau redaksi pesannya diperbaiki.
///
/// Pencocokan sengaja berbasis pola, bukan daftar tertutup: kode backend
/// memakai SCREAMING_SNAKE yang deskriptif dan berprefiks domain
/// (`COMMON_NOT_FOUND`, `VEHICLE_NOT_FOUND`, `WORK_ORDER_NOT_FOUND`), jadi
/// kode baru ikut tertangani tanpa perlu app dirilis ulang. Kode yang benar-
/// benar tidak dikenali jatuh ke pesan berdasarkan HTTP status.
String? messageForApiCode(dynamic rawCode, AppLocalizations t) {
  final code = rawCode?.toString().toUpperCase().trim();
  if (code == null || code.isEmpty) return null;

  // Kode sukses tidak pernah jadi pesan error.
  if (code.endsWith('_OK') || code.endsWith('_SUCCESS')) return null;

  bool has(String needle) => code.contains(needle);

  if (has('NOT_FOUND') || has('NOT_EXIST')) return t.dataNotFound;
  if (has('FORBIDDEN') ||
      has('UNAUTHORIZED') ||
      has('ACCESS_DENIED') ||
      has('PERMISSION')) {
    return t.errNoAccess;
  }
  if (has('DUPLICATE') || has('ALREADY_EXIST') || has('CONFLICT')) {
    return t.errDuplicateData;
  }
  if (has('VALIDATION') || has('INVALID') || has('BAD_REQUEST')) {
    return t.errIncompleteData;
  }
  if (has('TIMEOUT')) return t.errConnectionTimeout;
  if (has('UNAVAILABLE') || has('NOT_IMPLEMENTED')) {
    return t.errServiceUnavailable;
  }
  if (has('INTERNAL') || has('SERVER_ERROR')) return t.errServerProblem;

  return null;
}

/// Baca angka dari metadata yang nama field-nya bisa beda-beda.
int? metaInt(Map<dynamic, dynamic> meta, List<String> keys) {
  for (final key in keys) {
    final v = meta[key];
    if (v is int) return v;
    final parsed = int.tryParse('$v');
    if (parsed != null) return parsed;
  }
  return null;
}

/// Server menjawab (HTTP 2xx) tapi menolak permintaannya lewat body, dengan
/// envelope lama `{"status": false, "data": [], "error_msg": "..."}`.
///
/// Ini TIDAK bertentangan dengan prinsip di atas file ini. Yang dihindari di
/// sana adalah mengunci nilai SUKSES (pernah `true`, sekarang `"success"`) —
/// yang memang terus berubah. Di sini yang dikenali hanya satu hal: boolean
/// `false` yang eksplisit. Tidak ada versi backend yang memakai `false` untuk
/// "berhasil", jadi tidak ada nilai sukses yang ikut terkunci.
///
/// Tanpa ini, request yang ditolak dengan HTTP 200 lolos sebagai sukses dan
/// user melihat toast "berhasil" padahal datanya tidak tersimpan.
class ApiRejectedException implements Exception {
  const ApiRejectedException([this.message]);

  /// `error_msg` dari server, atau null kalau server tidak mengirimnya.
  final String? message;

  @override
  String toString() => message ?? 'ApiRejectedException';
}

/// Lempar [ApiRejectedException] kalau body berisi `status: false`.
///
/// Dipanggil setelah request yang body-nya tidak dibaca apa pun selain untuk
/// memastikan server tidak menolaknya.
void throwIfRejected(dynamic body) {
  if (body is Map && body['status'] == false) {
    throw ApiRejectedException(_errorMsg(body));
  }
}

/// Pesan penolakan dari server untuk ditampilkan apa adanya, atau null.
///
/// Menangani dua jalur yang sama-sama dipakai backend untuk envelope ini:
/// HTTP 2xx + `status: false` (lewat [throwIfRejected]), dan HTTP 4xx yang
/// body-nya membawa `error_msg`. Null berarti tidak ada pesan dari server,
/// sehingga pemanggil memakai pesan default miliknya sendiri.
String? apiRejectionMessage(Object error) {
  if (error is ApiRejectedException) return error.message;
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map) return _errorMsg(body);
  }
  return null;
}

String? _errorMsg(Map<dynamic, dynamic> body) {
  final msg = body['error_msg']?.toString().trim() ?? '';
  return msg.isEmpty ? null : msg;
}
