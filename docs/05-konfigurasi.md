# 5. Konfigurasi per app

[< 4. Struktur repo](04-struktur-repo.md) | [Daftar isi](../README.md) | [6. Bundle id: public vs unlisted >](06-bundle-id.md)

Setiap app dikonfigurasi dari tiga sumber: file `.env` (dibaca saat app berjalan), dart-define (ditanam saat compile), dan `AppBranding.configure` di `main.dart`.

## 5.1 Dev vs prod

Tiap app punya dua file env. Yang dipakai ditentukan dart-define `ENV_FILE`:

| Mode | File | Cara memakai |
| --- | --- | --- |
| Dev (default) | `apps/<app>/.env` | Skrip `<app>`, atau konfigurasi "(Dev)" di VS Code |
| Prod | `apps/<app>/.env.prod` | Skrip `<app>:prod`, konfigurasi "(Prod)" di VS Code. Semua build untuk store dan Shorebird **selalu** prod. |

Nama skrip lengkap ada di [Daftar perintah](../README.md#daftar-perintah).

Di halaman login, build dev menampilkan tulisan **DEVELOPMENT** di bawah logo (dari `VITE_APP_TYPES="DEV"`). Kalau tulisan itu muncul di build store, berarti salah file env.

## 5.2 Server backend per app

| App | Dev (`BASE_URL` di `.env`) | Prod (`BASE_URL` di `.env.prod`) | Jenis user (`VITE_APP_USERS`) |
| --- | --- | --- | --- |
| FixTrack | `https://tracking-dev.treffix.id` | `https://tracking.treffix.id` | Customer |
| Bitrack | `https://bitrack-dev-be.treffix.id` | `https://bitrack-be.b-log.dev` | Customer |
| Bitrack Internal | `https://bitrack-dev-be.treffix.id` | `https://bitrack-be.b-log.dev` | Teknisi |

## 5.3 Variabel di `.env`

| Variabel | Dipakai untuk |
| --- | --- |
| `BASE_URL` | Alamat API backend utama (login, kendaraan, notifikasi, work order). |
| `VITE_APP_USERS` | `Customer` atau `Teknisi`. `Teknisi` memunculkan tab Work Order dan Vehicle di bottom navigation. |
| `VITE_APP_TYPES` | `DEV` atau `PROD`. `DEV` memunculkan label DEVELOPMENT di login. |
| `GEO_REVERSE` | Server reverse geocoding (koordinat ke alamat) di detail kendaraan. |
| `GOOGLE_MAP_KEY` | Key untuk tile peta Google di flutter\_map. |
| `METTAXIOT_KEY`, `METTAXIOT_SECRET`, `METTAXIOT_CREATE_TOKEN`, `METTAXIOT_VIDEO`, `METTAXIOT_AUDIO` | Dashcam Mettaxiot: token, URL video live, dan audio (speaker). |
| `CAMERA_URL` | Server stream dashcam Stonkam. |
| `API_METTAXIOT_URL`, `TOKEN_METTAX` | Hanya dibaca kode dashcam lama yang tidak dipakai lagi (`dashcam_service.dart`); boleh kosong. |
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Membaca flag remote dari tabel `app_settings`. Saat ini satu flag: `show_register`, yang memunculkan tombol "Lanjut dengan demo" di login (dipakai reviewer App Store). |
| `ONESIGNAL_APP_ID` | Push notification. Kosong = push nonaktif tanpa error. |
| `ONESIGNAL_AUTH_KEY` | Tidak dibaca app. Kemungkinan catatan untuk backend; jangan andalkan ada di app. |
| `SOCKET_URL`, `VITE_EMAIL_OPTIONS`, `VITE_PASS_OPTIONS` | Sisa dari app Cordova lama, tidak dibaca kode Flutter. |

Penting: `.env` dan `.env.prod` dibundel sebagai asset app (lihat `flutter: assets:` di `pubspec.yaml` app). Siapa pun yang membongkar APK/IPA bisa membaca isinya. Jangan menaruh rahasia server (mis. service\_role key Supabase) di file ini. Konsekuensi lain: kalau salah satu file itu tidak ada, build gagal dengan error asset tidak ditemukan; buat dari `.env.example` bila perlu.

## 5.4 Alamat server yang ditulis di kode (bukan di `.env`)

Tidak semua alamat ada di `.env`. Yang di bawah ini ditulis langsung di kode,
jadi mengubahnya berarti mengubah kode (bisa lewat patch Shorebird karena
kode Dart):

| Alamat | File | Untuk |
| --- | --- | --- |
| `https://bitrack-otp-be.onrender.com` | `packages/core/lib/screens/change_password/services/otp_service.dart` | Kirim dan verifikasi OTP saat ganti password (server `bitrack-be-otp`, lihat [2.2](02-akses-dan-rahasia.md#22-proyek-lain-yang-terkait)). Timeout 10 detik. |

App juga mengizinkan koneksi `http://` (tanpa SSL): `android:usesCleartextTraffic="true"` di `AndroidManifest.xml` dan `NSAllowsArbitraryLoads` di `Info.plist`. Ini dibutuhkan karena `CAMERA_URL` dashcam masih `http://` ke alamat IP. Jangan dihapus sebelum server kamera memakai HTTPS.

## 5.5 Google Maps key: tiga tempat berbeda

App memakai dua jenis peta, dan key-nya dibaca dari tiga tempat. Kalau peta
abu-abu atau kosong, periksa yang sesuai:

| Dipakai oleh | Ditulis di | Diteruskan lewat |
| --- | --- | --- |
| Google Maps SDK Android (`google_maps_flutter`) | `apps/<app>/android/local.properties`, baris `GOOGLE_MAPS_API_KEY=...` (tidak di git) | `build.gradle.kts` -> placeholder di `AndroidManifest.xml` (`com.google.android.geo.API_KEY`) |
| Google Maps SDK iOS | `apps/<app>/ios/Flutter/Env.xcconfig` (di-commit) | `Info.plist` (`GOOGLE_MAPS_API_KEY`) -> `AppDelegate.swift` (`GMSServices.provideAPIKey`) |
| Tile peta Google di `flutter_map` | `GOOGLE_MAP_KEY` di `.env` / `.env.prod` | `base/constants/map_urls.dart` |

## 5.6 Mengubah flag remote di Supabase

Flag dibaca dari tabel `app_settings` (kolom `key`, `value` boolean) lewat
REST API Supabase. Mengubahnya tidak butuh rilis app; halaman login membaca
ulang flag setiap kali dibuka.

Saat ini hanya ada satu flag: `show_register`. Kalau `true`, tombol
"Lanjut dengan demo" muncul di halaman login. Untuk mengubahnya, pakai
`service_role` key (jangan pernah ditaruh di `.env` app):

```
curl -X PATCH "https://svwlhxxlqekedafazwsj.supabase.co/rest/v1/app_settings?key=eq.show_register" \
  -H "apikey: <SERVICE_ROLE_KEY>" \
  -H "Authorization: Bearer <SERVICE_ROLE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"value": true}'
```

Cara lain: buka dashboard Supabase > Table Editor > `app_settings`, lalu ubah
nilainya langsung.

## 5.7 Warna primer lewat dart-define

Warna utama tiap app (`AppStyles.primaryColor`) dibaca dari `--dart-define=APP_PRIMARY_COLOR=0xAARRGGBB` saat compile, karena dipakai di ratusan konstruktor `const`. Nilainya ada di tiga tempat yang harus selalu sama:

- `melos.yaml` (perintah run/build biasa)
- `.vscode/launch.json` (tombol Run di VS Code)
- `apps/<app>/dart_defines.prod.json` (build rilis Shorebird)

Akibatnya, `flutter run` polos di folder `apps/bitrack` menghasilkan app berwarna biru FixTrack. Untuk mencegahnya, `main.dart` punya `assert` yang langsung gagal di mode debug dengan pesan menyebut perintah melos yang benar. Selalu jalankan app lewat melos atau VS Code.

Mengganti warna satu app: ubah nilai di ketiga tempat di atas, juga
`_brandPrimaryColor` di `apps/<app>/lib/main.dart` (dipakai assert), warna
`flutter_native_splash` / `adaptive_icon_background` di `pubspec.yaml` app,
lalu jalankan `melos run branding`.

## 5.8 Branding lain

- **Nama, user agent peta, ukuran logo splash:** `AppBranding.configure(...)` di `apps/<app>/lib/main.dart`.
- **Logo, splash screen, launcher icon:** ganti `apps/<app>/assets/logos/logo.png`, sesuaikan warna di bagian `flutter_native_splash` dan `flutter_icons` di `pubspec.yaml` app, lalu jalankan `melos run branding`. Perintah itu menulis ulang file native di `android/app/src/main/res` dan `ios/Runner/Assets.xcassets`; hasilnya di-commit.
- **Nama app di HP:** `android:label` di `android/app/src/main/AndroidManifest.xml` dan `CFBundleDisplayName` di `ios/Runner/Info.plist`.

---

[< 4. Struktur repo](04-struktur-repo.md) | [Daftar isi](../README.md) | [6. Bundle id: public vs unlisted >](06-bundle-id.md)
