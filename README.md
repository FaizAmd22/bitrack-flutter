# BITRACK Mobile (Flutter)

Monorepo berisi **tiga aplikasi mobile (Android + iOS) dengan fitur dan kode
yang identik**: FixTrack, Bitrack, dan Bitrack Internal. Ketiganya adalah app
pemantauan armada (fleet tracking): posisi kendaraan di peta, notifikasi
alert, riwayat perjalanan (periodic track), dashcam live, dan work order untuk
teknisi.

Semua logic dan tampilan ada di satu package bersama, `packages/core`. Folder
`apps/<app>` hanya berisi identitas tiap app, jadi satu perbaikan di
`packages/core` berlaku untuk ketiga app sekaligus.

Dokumentasi lengkap ada di folder [`docs/`](docs/). Kalau Anda baru pertama
kali memegang proyek ini (atau app mobile), mulai dari [Daftar isi](#daftar-isi).
Hal yang masih harus diselesaikan saat serah terima ada di
[16.1 Wajib sebelum handover](docs/16-masalah-dan-hal-terbuka.md#161-wajib-sebelum-handover).

Terakhir diperbarui: 15 Oktober 2026 · Penulis: Faizhal Ahmad Siddiq

## Tiga app dalam satu tabel

| | FixTrack | Bitrack | Bitrack Internal |
| --- | --- | --- | --- |
| Folder | `apps/fixtrack` | `apps/bitrack` | `apps/bitrack_internal` |
| Nama skrip melos | `fixtrack` | `bitrack` | `internal` |
| Warna primer | biru `#386AD8` | merah `#D84040` | merah gelap `#9E2021` |
| Versi di `main` | 1.1.0+13 | 2.0.0+2 | 1.0.0+1 |
| applicationId Android | `fixtrack.treffix.id` | `com.bitrack.mobile` | `com.treffix.bitrack` |
| Bundle id iOS | lihat [06. Bundle id](docs/06-bundle-id.md) | lihat [06. Bundle id](docs/06-bundle-id.md) | `com.treffix.bitrack` |
| Jenis user | Customer | Customer | Teknisi (ada tab Work Order + Vehicle) |
| Distribusi Android | Google Play | Google Play | APK dibagikan langsung |
| Distribusi iOS | App Store | App Store | App Store |

Teknologi: Flutter **3.38.7** (Dart), Riverpod, Dio, Google Maps +
flutter_map, OneSignal (push), Shorebird (update tanpa store), Melos 6.

## Mulai cepat

Butuh tools dari [03. Instalasi](docs/03-instalasi.md) dan file rahasia dari
[02. Akses dan rahasia](docs/02-akses-dan-rahasia.md).

```bash
git clone https://github.com/FaizAmd22/bitrack-flutter.git
cd bitrack-flutter
# taruh .env dan .env.prod di apps/fixtrack, apps/bitrack, apps/bitrack_internal
flutter pub get          # sekali, di root: resolve ketiga app + core
melos run bitrack        # jalankan Bitrack (dev) di device yang tersambung
```

Penjelasan lengkap (emulator, HP fisik, iPhone) ada di
[07. Menjalankan app](docs/07-menjalankan-app.md).

## Daftar perintah

Ini **satu-satunya** daftar perintah; file lain di `docs/` merujuk ke sini.
Jalankan dari root repo. Kalau `melos` belum ada di PATH, pakai
`flutter pub run melos run <script>`. Ganti `<app>` dengan `fixtrack`,
`bitrack`, atau `internal`.

**Development**

| Perintah | Fungsi |
| --- | --- |
| `flutter pub get` | Resolve dependency seluruh workspace (jalankan di root). |
| `melos run <app>` | Jalankan app, server dev (`.env`). |
| `melos run <app>:prod` | Jalankan app, server produksi (`.env.prod`). |
| `melos run <app>:release` | Jalankan dalam mode release (performa asli, tanpa hot reload). |
| `melos run analyze` | `flutter analyze` di semua app + package. |
| `melos run test` | Semua tes (`packages/core/test`). |
| `melos run branding` | Buat ulang splash screen + launcher icon ketiga app dari `assets/logos/logo.png`. |

Di VS Code, enam konfigurasi (3 app x dev/prod) sudah ada di tab Run and
Debug. Jangan jalankan `flutter run` polos: warna app dioper lewat
dart-define dari melos / VS Code ([05.7](docs/05-konfigurasi.md#57-warna-primer-lewat-dart-define)).

**Rilis ke store (dengan Shorebird)** — urutan lengkap di
[12. Rilis Android](docs/12-rilis-android.md) dan
[13. Rilis iOS](docs/13-rilis-ios.md)

| Perintah | Fungsi |
| --- | --- |
| `melos run <app>:sb:release:android` | Build AAB + daftarkan release ke Shorebird, salin ke `rilis/<app>-<versi>.aab`. File itu yang di-upload ke Play. |
| `melos run <app>:sb:release:ios` | Sama untuk iOS (Mac), hasil di `rilis/<app>-<versi>.ipa`. |
| `melos run <app>:sb:verify` | Pastikan AAB di `rilis/` cocok dengan release di Shorebird. |
| `melos run <app>:sb:preview:android` / `:ios` | Pasang release ke HP, persis seperti yang diterima user. |

**Patch Shorebird** — urutan lengkap di [14. Shorebird](docs/14-shorebird.md)

| Perintah | Fungsi |
| --- | --- |
| `melos run <app>:sb:patch:android:staging` / `:ios:staging` | Kirim patch ke track staging (hanya HP uji). |
| `melos run <app>:sb:preview:android:staging` / `:ios:staging` | Pasang release + patch staging ke HP untuk dites. |
| `melos run <app>:sb:promote <nomor>` | Aktifkan patch untuk semua user versi itu. |

**Build tanpa Shorebird** (APK Bitrack Internal, atau darurat)

| Perintah | Fungsi |
| --- | --- |
| `melos run <app>:apk:prod` | APK produksi di `apps/<app>/build/app/outputs/flutter-apk/app-release.apk`. Dipakai untuk Bitrack Internal. |
| `melos run <app>:apk` | APK dengan server dev, untuk tester. |
| `melos run <app>:aab` | AAB produksi tanpa Shorebird. Versi ini **tidak bisa** menerima patch. |
| `melos run <app>:ios` / `:ios:prod` | Build iOS tanpa Shorebird (Mac). |

## Daftar isi

**Mulai di sini** (baca berurutan kalau baru pertama kali):

| No | File | Isi |
| --- | --- | --- |
| 01 | [Istilah dasar untuk pemula](docs/01-istilah.md) | Kosakata mobile yang dipakai di semua file. |
| 02 | [Akses, akun, dan file rahasia](docs/02-akses-dan-rahasia.md) | Apa saja yang harus diterima dari pemilik lama. |
| 03 | [Instalasi tools dari nol](docs/03-instalasi.md) | Flutter, Android Studio, Xcode, Melos, Shorebird. |
| 04 | [Struktur repo](docs/04-struktur-repo.md) | Isi tiap folder dan aturan di mana kode ditaruh. |
| 05 | [Konfigurasi per app](docs/05-konfigurasi.md) | `.env`, dev vs prod, Maps key, flag Supabase, warna, logo. |
| 06 | [Bundle id: public vs unlisted](docs/06-bundle-id.md) | Id app di store dan perbedaan branch. |
| 07 | [Menjalankan app](docs/07-menjalankan-app.md) | Emulator, simulator, HP Android, iPhone, log. |

**Memahami dan mengubah kode:**

| No | File | Isi |
| --- | --- | --- |
| 08 | [Arsitektur dan alur kode](docs/08-arsitektur.md) | Alur app dari dibuka sampai logout. |
| 09 | [Fitur per halaman](docs/09-fitur.md) | Isi tiap halaman, file, dan endpoint-nya. |
| 17 | [Tugas umum developer](docs/17-tugas-umum.md) | Resep: endpoint baru, halaman baru, terjemahan, logo, package, app baru. |

**Rilis dan perawatan:**

| No | File | Isi |
| --- | --- | --- |
| 10 | [Keystore dan signing Android](docs/10-signing-android.md) | File paling berharga di proyek ini. |
| 11 | [Signing iOS](docs/11-signing-ios.md) | Sertifikat dan akun Apple. |
| 12 | [Rilis Android](docs/12-rilis-android.md) | Google Play, APK Bitrack Internal, aturan versi. |
| 13 | [Rilis iOS ke App Store](docs/13-rilis-ios.md) | Transporter, TestFlight, review. |
| 14 | [Shorebird: release dan patch](docs/14-shorebird.md) | Kirim perbaikan tanpa review store. |
| 15 | [Checklist rilis dan patch](docs/15-checklist.md) | Salin setiap kali rilis. |
| 16 | [Masalah umum dan hal terbuka](docs/16-masalah-dan-hal-terbuka.md) | Semua troubleshooting di satu tempat + pekerjaan yang belum beres. |

## Lima hal yang paling penting

1. **Jangan kehilangan keystore Android.** Tanpanya update ke Play Store
   ditolak ([10](docs/10-signing-android.md)).
2. **Jalankan app lewat melos atau VS Code**, bukan `flutter run` polos.
3. **Build untuk store harus lewat `<app>:sb:release:*`**, dan yang di-upload
   adalah file di `rilis/`. Kalau tidak, patch tidak akan sampai ke user
   ([14](docs/14-shorebird.md)).
4. **Patch Shorebird hanya untuk kode Dart.** Perubahan native, asset,
   `.env`, atau plugin baru butuh rilis store.
5. **Bundle id iOS menentukan listing App Store** (public atau unlisted). Cek
   sebelum build iOS ([06](docs/06-bundle-id.md)).

## Dokumentasi lain di repo

- [`CLAUDE.md`](CLAUDE.md): aturan singkat untuk AI agent (Claude Code, dsb.).
- Komentar di `melos.yaml` dan `tool/shorebird.dart`: alasan di balik tiap
  perintah rilis.
- Komentar kode: sengaja detail dan berbahasa Indonesia. Baca komentar di
  atas kode sebelum mengubahnya.
