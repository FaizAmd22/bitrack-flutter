# 17. Tugas umum developer

[< 16. Masalah umum dan hal terbuka](16-masalah-dan-hal-terbuka.md) | [Daftar isi](../README.md)

Resep langkah demi langkah untuk perubahan yang paling sering dilakukan.
Setiap resep diakhiri dengan cara mengecek hasilnya dan apakah perubahan itu
bisa dikirim lewat patch Shorebird atau butuh rilis store.

## 17.1 Memanggil endpoint API baru

Pola yang dipakai di seluruh app (contoh nyata:
`screens/notification/services/fetch_alert_type.dart`):

```dart
class FetchSesuatu {
  Future<List<Map<String, dynamic>>> fetch() async {
    // 1. Mode demo tidak boleh memanggil server.
    if (DemoMode.isActive) return DemoData.sesuatu();

    try {
      // 2. Selalu lewat ApiClient.dio: BASE_URL + token sudah otomatis.
      final res = await ApiClient.dio.get('/path-endpoint');
      return apiDataList(res.data, onInvalid: currentL10n().errInvalidResponse);
    } on DioException catch (e) {
      // 3. Pesan error seragam + terjemahan.
      throw Exception(apiErrorText(e, currentL10n().errLoadSesuatuFailed));
    }
  }
}
```

Langkah:
1. Buat file di `packages/core/lib/screens/<halaman>/services/`.
2. Tambahkan data dummy di `base/services/demo_data.dart` supaya mode demo
   (dipakai reviewer App Store) tetap berfungsi.
3. Tambahkan teks error baru ke semua file `.arb` (resep 17.3).
4. Panggil service dari halaman atau provider Riverpod.
5. Cek: jalankan `melos run <app>` dan lihat log request di terminal.

Patch Shorebird: **bisa** (hanya kode Dart).

## 17.2 Menambah halaman baru

1. Buat folder `packages/core/lib/screens/<nama_halaman>/` berisi file
   halaman (`<nama_halaman>.dart`) dan bila perlu `widgets/`, `services/`,
   `models/`, `providers/`.
2. Tambahkan nama route di `packages/core/lib/base/routes/app_routes.dart`,
   mis. `static const reportScreen = '/report';`.
3. **Daftarkan route di ketiga `main.dart`**: `apps/fixtrack/lib/main.dart`,
   `apps/bitrack/lib/main.dart`, `apps/bitrack_internal/lib/main.dart`, di
   map `routes:`. Bungkus dengan `AuthGuard` kalau halaman butuh login:
    ```dart
    AppRoutes.reportScreen: (_) => const AuthGuard(child: ReportScreen()),
    ```
   Kalau halaman butuh argumen, daftarkan lewat `_workOrderRoute` /
   `onGenerateRoute` seperti halaman work order.
4. Buka halaman dengan `Navigator.pushNamed(context, AppRoutes.reportScreen)`.
5. Cek: buka halaman di ketiga app (minimal jalankan `melos run analyze`
   untuk memastikan ketiga `main.dart` tidak error).

Patch Shorebird: **bisa**, selama tidak menambah plugin native.

## 17.3 Menambah atau mengubah teks (terjemahan)

1. Tambahkan key baru ke `packages/core/lib/l10n/app_en.arb` (template):
    ```json
    "reportTitle": "Report",
    ```
2. Tambahkan key yang sama ke `app_id.arb`, `app_ja.arb`, `app_ko.arb`,
   `app_zh.arb`. Kalau belum ada terjemahan, isi sementara dengan teks
   Inggris, tapi jangan lewatkan file mana pun.
3. Dari folder `packages/core`: `flutter gen-l10n`.
4. Pakai di kode: `AppLocalizations.of(context).reportTitle`, atau di luar
   widget: `currentL10n().reportTitle`.
5. Commit file `.arb` **dan** file `app_localizations*.dart` hasil generate.

Patch Shorebird: **bisa**.

## 17.4 Mengganti URL server atau key di `.env`

1. Edit `apps/<app>/.env` (dev) dan/atau `.env.prod` (prod).
2. Jalankan ulang app (`R` saja tidak cukup; hentikan lalu `melos run`
   lagi), karena `.env` dibaca saat app dimulai.
3. Kalau variabel baru, tambahkan juga ke `apps/<app>/.env.example` (tanpa
   nilai rahasia) dan ke tabel di [5. Konfigurasi](05-konfigurasi.md).

Patch Shorebird: **tidak bisa**. `.env` adalah asset, jadi user baru
mendapatkannya lewat rilis store berikutnya.

## 17.5 Mengganti logo, warna, atau nama app

- **Logo + icon + splash:** ganti `apps/<app>/assets/logos/logo.png`, lalu
  `melos run branding`. Commit semua file native yang berubah.
- **Warna primer:** lihat
  [5.7](05-konfigurasi.md#57-warna-primer-lewat-dart-define); ada lima tempat
  yang harus diubah bersamaan.
- **Nama di HP:** `android:label` di
  `apps/<app>/android/app/src/main/AndroidManifest.xml` dan
  `CFBundleDisplayName` + `CFBundleName` di `apps/<app>/ios/Runner/Info.plist`.
  Juga `appName` di `AppBranding.configure` (`main.dart`).

Patch Shorebird: **tidak bisa** (asset dan file native). Butuh rilis store.

## 17.6 Menambah package / plugin

1. Tambahkan ke `packages/core/pubspec.yaml` (bukan ke pubspec app).
2. `flutter pub get` di root repo.
3. Kalau plugin butuh izin (kamera, lokasi, dsb.): tambahkan izin di
   `AndroidManifest.xml` **ketiga** app dan teks `NS...UsageDescription` di
   `Info.plist` **ketiga** app.
4. Uji di Android dan iOS (Mac), karena plugin native sering butuh langkah
   setup per platform; baca README plugin di pub.dev.

Patch Shorebird: **tidak bisa** bila plugin punya kode native. Package Dart
murni (tanpa folder `android/` / `ios/`) bisa.

## 17.7 Mengubah sesuatu hanya untuk satu jenis app

Kode di `packages/core` dipakai ketiga app. Untuk perilaku berbeda, gunakan
konfigurasi yang sudah ada, jangan menyalin kode:
- Customer vs Teknisi: `AppUsers.isTechnicianApp` (dari `VITE_APP_USERS`).
- Dev vs prod: `VITE_APP_TYPES`.
- Identitas brand: `AppBranding` (nama, user agent peta, ukuran logo).

Kalau perlu pembeda baru, tambahkan variabel ke `.env` ketiga app atau ke
`AppBranding.configure` di ketiga `main.dart`.

## 17.8 Menulis dan menjalankan tes

- Tes ada di `packages/core/test/`. Contoh yang bisa ditiru:
  `push_notification_service_test.dart` (mengganti plugin dengan versi palsu)
  dan `patch_update_test.dart`.
- Jalankan satu file: `cd packages/core && flutter test test/<file>_test.dart`.
- Jalankan semua: `melos run test`.
- Jalankan `melos run analyze` sebelum commit; harus "No issues found".

## 17.9 Alur kerja git yang disarankan

1. Buat branch dari `main`: `git checkout -b feature/<nama-singkat>`.
2. Commit kecil dan sering, pesan dalam format yang sudah dipakai repo
   (`feat: ...`, `fix: ...`, `updated: ...`).
3. Push dan buat Pull Request ke `main`; minta review bila ada rekan.
4. Setelah merge, rilis mengikuti [15. Checklist](15-checklist.md).
5. Tag setiap commit rilis (`<app>-<versi>`) supaya patch bisa dibuat dari
   kode yang tepat.

## 17.10 Menambah app (brand) baru

Untuk brand keempat dengan fitur yang sama:

1. `cp -r apps/bitrack apps/<app-baru>`, lalu hapus `build/` dan
   `.dart_tool/` di salinannya.
2. Di `apps/<app-baru>/pubspec.yaml`: ganti `name:`, `description:`,
   `version:`, warna `flutter_native_splash` dan `adaptive_icon_background`.
3. Android: ganti `namespace` dan `applicationId` di
   `android/app/build.gradle.kts`, pindahkan `MainActivity.kt` ke folder
   paket baru, ganti `android:label` di `AndroidManifest.xml`. Buat keystore
   baru dan `key.properties` ([10](10-signing-android.md)).
4. iOS: ganti `PRODUCT_BUNDLE_IDENTIFIER` di
   `ios/Runner.xcodeproj/project.pbxproj` dan `CFBundleDisplayName` /
   `CFBundleName` di `ios/Runner/Info.plist`.
5. Ganti `AppBranding.configure(...)` dan `_brandPrimaryColor` di
   `lib/main.dart`.
6. Daftarkan di `workspace:` (`pubspec.yaml` root), tambah skrip di
   `melos.yaml`, konfigurasi di `.vscode/launch.json`, dan buat
   `dart_defines.prod.json`.
7. Shorebird: `shorebird init` di folder app baru untuk mendapat `app_id`
   sendiri, lalu set `auto_update: false` di `shorebird.yaml` seperti app lain.
8. Buat `.env` / `.env.prod`, lalu `flutter pub get` di root dan
   `melos run branding`.
9. Tambahkan app baru ke tabel di `README.md` root dan di
   [6. Bundle id](06-bundle-id.md) / [10. Keystore](10-signing-android.md).

---

[< 16. Masalah umum dan hal terbuka](16-masalah-dan-hal-terbuka.md) | [Daftar isi](../README.md)
