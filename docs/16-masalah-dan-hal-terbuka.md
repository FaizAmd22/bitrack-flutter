# 16. Masalah umum dan hal terbuka

[< 15. Checklist rilis dan patch](15-checklist.md) | [Daftar isi](../README.md) | [17. Tugas umum developer >](17-tugas-umum.md)

Bagian ini berisi hal yang belum beres atau perlu dikonfirmasi saat serah terima. Kerjakan butir "Wajib sebelum handover" bersama pemilik lama.

## 16.1 Wajib sebelum handover

- [ ] **Konfirmasi bundle id iOS di `main`.** `main` saat ini memakai id public (`com.treffix.fixtrack`, `bitrack.treffix.id`) karena commit `8dd2b5c` dari `ios-public` sudah ter-merge, sedangkan rencananya `main` = unlisted. Putuskan branch mana untuk listing mana, lalu buat branch unlisted yang jelas bila masih dibutuhkan ([bagian 6.3](06-bundle-id.md#63-cara-pindah-antara-unlisted-dan-public)).
- [ ] **Keystore Bitrack.** `apps/bitrack/android/key.properties` dan keystore-nya tidak ada di folder repo mesin lama, jadi build release Bitrack saat ini akan gagal. Keystore (`Bitrack/bitrack-mobile/cordova/android.keystore`, alias `treffix`, SHA1 `42:07:E2...`) dan passwordnya (`cordova/build.json`) masih ada dan sudah diverifikasi. Serahkan keduanya, buat backup kedua, lalu siapkan sesuai [10.3](10-signing-android.md#103-menyiapkan-keystore-bitrack).
- [ ] **Cek key APK Bitrack Internal** yang sudah dibagikan ke user: `keytool -printcert -jarfile <apk>` harus menunjukkan SHA1 `43:B3:20...` (key `upload-keystore.jks`). Kalau beda, APK berikutnya harus ditandatangani key yang dipakai APK lama, atau user harus uninstall dulu.
- [ ] **Isi tabel kepemilikan dan kontak** di [2.6](02-akses-dan-rahasia.md#26-kepemilikan-dan-kontak-diisi-pemilik-lama-sebelum-handover) sampai tidak ada lagi "BELUM DIISI".
- [ ] **Isi tabel status store** di 16.3 (versi yang sedang live di tiap store, dan link listing).
- [ ] **Serahkan server OTP** (Render + Redis + Brevo, repo `Bitrack-Otp-be`) atau pindahkan ke infrastruktur perusahaan. Tanpanya fitur ganti password berhenti bekerja saat akun pribadi dinonaktifkan.
- [ ] **Serahkan semua password** keystore, `.env`, dan akses akun ([bagian 2](02-akses-dan-rahasia.md)).

## 16.2 Status release Shorebird (per 15 Okt 2026)

| App | Release Shorebird yang ada | Catatan |
| --- | --- | --- |
| FixTrack | Android `1.1.0+11`, `1.1.0+12`, `1.1.0+13` (Flutter 3.38.7); AAB-nya di `rilis/` | Belum ada release iOS. |
| Bitrack | Belum ada | Versi `2.0.0+2` yang beredar (bila ada) tidak bisa di-patch. Rilis berikutnya harus lewat `bitrack:sb:release:*`. |
| Bitrack Internal | Belum ada | Android dibagikan sebagai APK. APK dari `internal:apk:prod` tidak bisa di-patch; lihat [12.4](12-rilis-android.md#124-bitrack-internal-android-apk-dibagikan-langsung) untuk build APK lewat Shorebird. iOS ada di App Store. |

Perubahan terakhir di `main` (label versi di Login dan Profil, commit `e512d42`) menambah package native `package_info_plus`, jadi tidak bisa dikirim sebagai patch ke release lama. Harus masuk lewat rilis store baru.

## 16.3 Status store saat ini (diisi pemilik lama)

Versi yang live di store menentukan versi mana yang bisa di-patch dan nomor
build berikutnya.

| App | Platform | Listing (link) | Versi live | Lewat Shorebird? |
| --- | --- | --- | --- | --- |
| FixTrack | Google Play | BELUM DIISI | BELUM DIISI | Ya bila `1.1.0+11` s.d. `+13` |
| FixTrack | App Store (public, `com.treffix.fixtrack`) | BELUM DIISI | BELUM DIISI | Tidak (belum ada release iOS) |
| FixTrack | App Store (unlisted, `fixtrack.treffix.id`) | BELUM DIISI | BELUM DIISI | Tidak |
| Bitrack | Google Play | BELUM DIISI | BELUM DIISI | Tidak |
| Bitrack | App Store (public, `bitrack.treffix.id`) | BELUM DIISI | BELUM DIISI | Tidak |
| Bitrack | App Store (unlisted, `com.bitrack.mobile`) | BELUM DIISI | BELUM DIISI | Tidak |
| Bitrack Internal | APK langsung | - | BELUM DIISI | Tidak |
| Bitrack Internal | App Store (BELUM DIISI: public/unlisted) | BELUM DIISI | BELUM DIISI | Tidak |

## 16.4 Fitur yang belum selesai

- **Register** masih dummy (tidak mengirim ke backend) dan tidak ditautkan dari Login.
- **Pengaturan notifikasi** (toggle Alert / Software Update) belum tersimpan ke mana pun.
- **Bitrack Internal** belum punya `ONESIGNAL_APP_ID`, jadi push notification nonaktif di app itu.
- **Intercom dashcam** (tombol mikrofon di sheet Dashcam) belum diimplementasikan: tombolnya hanya mengubah status ON/OFF tanpa mengirim suara. Lihat TODO di `_handleMicrophone` (`vehicle_detail/widgets/dashcam_bottom_sheet.dart`).

## 16.5 Risiko keamanan dan operasional

- Google Maps API key ter-commit di `apps/<app>/ios/Flutter/Env.xcconfig` dan di `apps/<app>/.env.example`. Batasi key di Google Cloud (per applicationId/bundle id dan per API), atau rotasi key bila perlu.
- Isi `.env` ikut terbundel di APK/IPA dan bisa dibaca siapa pun yang membongkar app. Jangan menaruh secret server di sana.
- `ONESIGNAL_AUTH_KEY` (REST API key) ada di `.env` walau tidak dipakai app. Sebaiknya dihapus dari `.env` app dan hanya disimpan di backend.
- **Server OTP bisa "tidur".** `bitrack-otp-be.onrender.com` butuh sekitar 22 detik untuk merespons setelah lama tidak dipakai (diukur 15 Okt 2026), sedangkan timeout app hanya 10 detik. Akibatnya permintaan OTP pertama bisa gagal dan user harus menekan ulang. Solusi: paket Render berbayar, server lain, atau menaikkan timeout di `otp_service.dart`.
- **Supabase paket gratis di-pause** bila tidak ada aktivitas beberapa hari. Kalau ter-pause, flag `show_register` gagal dibaca dan tombol demo hilang (app tetap jalan). Cek dashboard Supabase sebelum submit review.
- **Tidak ada crash reporting** (Crashlytics, Sentry, dsb.). Crash hanya terlihat di Play Console (Android vitals) dan App Store Connect / Xcode Organizer.
- **Koneksi `http://` diizinkan** di ketiga app karena server kamera belum HTTPS ([5.4](05-konfigurasi.md#54-alamat-server-yang-ditulis-di-kode-bukan-di-env)).
- **Banyak layanan memakai akun pribadi pemilik lama** (GitHub, Render, GitHub Pages kebijakan privasi). Pindahkan ke akun perusahaan agar tidak hilang saat akun pribadi ditutup.

## 16.6 Kebersihan repo

- Branch remote `monorepo` dan `google-maps` sudah lama tidak dipakai; `features/ota-shorebird` sudah ter-merge ke `main`. Boleh dihapus setelah dikonfirmasi.
- `apps/fixtrack/android/build/` (2 file) ter-commit tidak sengaja; boleh dihapus dari git.
- Folder `web/`, `linux/`, `macos/`, `windows/` di `apps/fixtrack` tidak dipakai.
- Kode yang tidak dipakai di mana pun (sudah ditandai di komentarnya, aman dihapus setelah dicek): `DashcamService` dan `StonkamStreamService` (vehicle_detail/services), `MonitoringSearchBar` (home/widgets), `AppTabBar` (base/widgets), `models/dashcam_data.dart` (kosong), `fleetGroupMapProvider`, `isLikelyPlate` / `normalizePlateForApi`, serta beberapa fungsi di `vehicle_detail/utils/format_helpers.dart`.

## 16.7 Masalah umum dan solusinya

Ini satu-satunya daftar troubleshooting; file lain merujuk ke sini.

**Menjalankan app**

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| Assert gagal "APP_PRIMARY_COLOR tidak ter-set", atau app Bitrack berwarna biru | Dijalankan dengan `flutter run` polos | Pakai melos atau VS Code ([Daftar perintah](../README.md#daftar-perintah)). |
| "Unable to load asset: .env" | File `.env` / `.env.prod` belum ada di `apps/<app>/` | Taruh file dari pemilik lama, atau salin dari `.env.example`. |
| Peta abu-abu / kosong | Maps key tidak ada atau dibatasi | Cek ketiga tempat di [5.5](05-konfigurasi.md#55-google-maps-key-tiga-tempat-berbeda) dan pembatasan key di Google Cloud. |
| `dart run melos` error versi SDK | Ada Dart lama di PATH | Lihat jebakan Windows di [3.3](03-instalasi.md#33-verifikasi). |
| Build iOS gagal dengan error native_assets | Sisa build lama | Hapus `apps/<app>/build/native_assets` (skrip `*:ios` dan `*:sb:*:ios` melakukannya otomatis). |
| Error CocoaPods | Pods usang | `cd apps/<app>/ios && pod deintegrate && pod install --repo-update`. |
| Apa pun yang aneh setelah ganti branch | Cache build | `flutter clean` di folder app, lalu `flutter pub get` di root. |
| Push notification tidak masuk | `ONESIGNAL_APP_ID` kosong, izin ditolak, atau bundle id di OneSignal beda | Cek `.env`, izin notifikasi di HP, dan konfigurasi app di OneSignal. |

**Signing iOS (Xcode)**

| Pesan error | Penyebab | Solusi |
| --- | --- | --- |
| "No account for team BT5HYZB4PV" | Apple ID belum ditambahkan di Xcode | Xcode > Settings > Accounts > tambah Apple ID yang sudah diundang ke team. |
| "No profiles for '...' were found" | Profile belum dibuat, atau role tidak cukup | Aktifkan "Automatically manage signing"; pastikan role Admin / App Manager dengan akses Certificates. Klik "Try Again". |
| "Failed to register bundle identifier" | Id sudah dipakai team atau akun lain | Pakai id dari [tabel 6.1](06-bundle-id.md#61-tabel-lengkap), jangan buat id baru. |
| "Device not registered" | iPhone uji belum terdaftar | Sambungkan iPhone, Xcode menawarkan mendaftarkannya. |
| "Signing certificate is invalid / revoked" | Sertifikat dicabut atau kedaluwarsa (berlaku 1 tahun) | Xcode > Settings > Accounts > Manage Certificates > tambah sertifikat baru. |
| Push tidak masuk di build TestFlight / App Store | Capability Push tidak aktif di App ID, atau kunci APNs di OneSignal salah | Cek Identifiers > App ID > Push Notifications; cek kunci `.p8` dan bundle id di OneSignal. |

**Rilis dan Shorebird**

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| Play menolak AAB: "signed with the wrong key" | Keystore salah | Cocokkan SHA1 yang disebut Play dengan [tabel 10.1](10-signing-android.md#101-peta-keystore-per-app). |
| Play menolak: "version code already used" | Build number tidak dinaikkan | Naikkan angka setelah `+` ([12.5](12-rilis-android.md#125-menentukan-nomor-versi)). |
| Build release Android gagal soal `keyAlias` | `key.properties` tidak ada | Siapkan sesuai [10.2](10-signing-android.md#102-cara-kerja-signing-di-repo) / [10.3](10-signing-android.md#103-menyiapkan-keystore-bitrack). |
| Skrip release: "sudah pernah dirilis" | `rilis/<app>-<versi>` sudah ada | Naikkan build number. |
| Melos menulis SUCCESS tapi tidak ada release/patch | Exit code Shorebird di Windows selalu 0 | Cari baris `Published Release` / `Published Patch` di output ([14.6](14-shorebird.md#146-jebakan-shorebird-yang-sudah-pernah-terjadi)). |
| Patch tidak pernah sampai ke HP user | File yang di-upload bukan dari `rilis/`, atau versi store dibuat tanpa Shorebird | Jalankan `sb:verify`; bila tidak cocok, rilis store baru lewat `sb:release`. |
| Tulisan DEVELOPMENT muncul di build store | Build memakai `.env` dev | Rilis selalu lewat `sb:release` (memakai `.env.prod`). |
| APK Bitrack Internal tidak mau terpasang di atas versi lama | Build number lebih kecil, atau key berbeda | Naikkan build number; tandatangani dengan `upload-keystore.jks` ([10.1](10-signing-android.md#101-peta-keystore-per-app)). |

---

[< 15. Checklist rilis dan patch](15-checklist.md) | [Daftar isi](../README.md) | [17. Tugas umum developer >](17-tugas-umum.md)
