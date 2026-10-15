# 1. Istilah dasar untuk pemula

[Daftar isi](../README.md) | [2. Akses, akun, dan file rahasia >](02-akses-dan-rahasia.md)

Istilah di bawah dipakai di semua file dokumentasi ini. Kalau Anda belum
pernah memegang app mobile, baca sekali sampai habis; sisanya bisa dipakai
sebagai kamus.

## 1.1 Flutter dan kode

| Istilah | Artinya di proyek ini |
| --- | --- |
| Flutter | Framework dari Google untuk membuat app Android dan iOS dari satu kode. Proyek ini terkunci di Flutter **3.38.7**. Versi lain bisa membuat build atau patch Shorebird gagal. |
| Dart | Bahasa pemrograman yang dipakai Flutter. Semua file `.dart` adalah kode app. |
| Widget | Potongan tampilan di Flutter: tombol, teks, satu halaman penuh, semuanya widget. Halaman app ini ada di `packages/core/lib/screens/`. |
| Hot reload / hot restart | Saat app berjalan dalam mode debug, tekan `r` di terminal untuk memuat ulang perubahan kode dalam 1-2 detik tanpa menutup app, atau `R` untuk memulai ulang app dari awal. |
| State / provider (Riverpod) | "State" = data yang bisa berubah dan memengaruhi tampilan (mis. daftar kendaraan). Riverpod adalah library untuk menyimpan dan membagikan state itu lewat "provider". |
| Package / pub | Library Dart. Daftarnya di `pubspec.yaml`, diunduh dengan `flutter pub get`. Versi yang terkunci ada di `pubspec.lock` (satu file di root repo). |
| Plugin (package native) | Package yang membawa kode Android/iOS asli, mis. kamera, biometric, peta. Penting untuk Shorebird: plugin baru tidak bisa dikirim lewat patch. |
| Monorepo | Satu repo berisi beberapa app plus kode bersama. Di sini: 3 app di `apps/`, 1 package bersama di `packages/core`. |
| Melos | Alat untuk menjalankan perintah di monorepo. Semua perintah run/build/rilis didefinisikan di `melos.yaml`, dipanggil dengan `melos run <nama>`. |
| `.env` | File konfigurasi berisi URL server dan kunci API. Tidak masuk git; harus diserahkan terpisah. Ada dua per app: `.env` (dev) dan `.env.prod` (produksi). |
| dart-define | Nilai yang ditanam ke app saat compile, mis. warna primer app. Dioper otomatis oleh perintah melos. |

## 1.2 Menjalankan dan membangun app

| Istilah | Artinya |
| --- | --- |
| Emulator (Android) / Simulator (iOS) | HP virtual di komputer. Emulator dibuat di Android Studio; Simulator ikut Xcode (hanya di Mac). |
| Real device | HP fisik yang disambung lewat kabel USB (atau Wi-Fi). |
| Debug vs release build | Debug = untuk development (bisa hot reload, lebih lambat, ada banner debug). Release = versi final yang di-upload ke store (cepat, dioptimasi). |
| Gradle | Sistem build untuk bagian Android. Berjalan otomatis saat `flutter run` / `flutter build`; konfigurasinya di `apps/<app>/android/`. |
| CocoaPods / Podfile | Pengelola dependency native iOS. Berjalan otomatis saat build iOS; konfigurasinya di `apps/<app>/ios/Podfile`. |
| Xcode | Aplikasi Apple untuk membangun app iOS. Hanya ada di Mac. |
| APK | File app Android yang bisa dipasang langsung ke HP ("sideload"). Dipakai untuk Bitrack Internal. |
| AAB (App Bundle) | Format file app Android yang wajib di-upload ke Google Play. Tidak bisa dipasang langsung ke HP. |
| IPA | File app iOS untuk di-upload ke App Store Connect. |

## 1.3 Identitas app dan versi

| Istilah | Artinya |
| --- | --- |
| applicationId (Android) / bundle id (iOS) | Nama unik app di toko aplikasi, mis. `fixtrack.treffix.id`. Kalau berubah, toko menganggapnya app yang berbeda sama sekali (user tidak menerima update). |
| Versi (`version:`) | Ditulis di `apps/<app>/pubspec.yaml` sebagai `version: 1.1.0+13`. `1.1.0` = versi yang dilihat user (versionName / CFBundleShortVersionString). `13` = build number (versionCode / CFBundleVersion) yang wajib selalu naik setiap upload ke store. |
| Public vs unlisted (iOS) | Public: app bisa dicari siapa saja di App Store. Unlisted: app tidak muncul di pencarian, hanya bisa dibuka lewat link langsung. Proyek ini punya bundle id iOS terpisah untuk keduanya, lihat [6. Bundle id](06-bundle-id.md). |

## 1.4 Signing (tanda tangan app)

Setiap app harus "ditandatangani" secara digital sebelum bisa dipasang atau
di-upload. Tanda tangan membuktikan bahwa update berasal dari pembuat yang
sama.

| Istilah | Artinya |
| --- | --- |
| Keystore (`.jks` / `.keystore`) | File berisi kunci untuk menandatangani app Android, dilindungi password. Google Play hanya menerima update yang ditandatangani kunci yang sama. Lihat [10. Keystore Android](10-signing-android.md). |
| Upload key vs app signing key | Dengan Play App Signing, Google memegang kunci final (app signing key), dan kita hanya memegang upload key. Upload key yang hilang masih bisa di-reset lewat Google. |
| SHA1 / fingerprint | "Sidik jari" sertifikat sebuah keystore, mis. `42:07:E2:...`. Dipakai untuk mengecek apakah keystore yang dipegang adalah yang benar. |
| Certificate + provisioning profile | Padanan keystore di iOS. Dikelola Apple lewat akun Apple Developer; Xcode bisa mengurusnya otomatis. Lihat [11. Signing iOS](11-signing-ios.md). |
| Team ID | Id tim Apple Developer pemilik app. Proyek ini: `BT5HYZB4PV`. |

## 1.5 Toko aplikasi dan distribusi

| Istilah | Artinya |
| --- | --- |
| Google Play Console | Website (play.google.com/console) untuk mengelola app Android di Play Store: upload, rilis, review. |
| App Store Connect | Website (appstoreconnect.apple.com) untuk mengelola app iOS. |
| TestFlight | Fitur App Store Connect untuk membagikan versi uji iOS ke tester sebelum rilis. |
| Review | Pemeriksaan oleh Google/Apple sebelum versi baru terbit. Google: beberapa jam sampai 3 hari. Apple: biasanya 1-3 hari. |
| Internal testing / Production (Play) | "Track" di Play Console. Internal testing untuk tester terbatas, Production untuk semua user. |

## 1.6 Shorebird (update tanpa store)

| Istilah | Artinya |
| --- | --- |
| Shorebird | Layanan "code push": mengirim perubahan kode Dart langsung ke HP user tanpa lewat review store. Lihat [14. Shorebird](14-shorebird.md). |
| Release (Shorebird) | Build lengkap yang dicatat di server Shorebird dan di-upload ke store. Hanya versi hasil release Shorebird yang bisa menerima patch. |
| Patch | Perubahan kode Dart untuk satu versi release tertentu, diunduh app di HP user saat dibuka. |
| Track staging / stable | Patch dikirim ke `staging` dulu (hanya HP uji), lalu dipindah ke `stable` (semua user). |

## 1.7 Git

| Istilah | Artinya |
| --- | --- |
| Branch | Cabang kode. `main` adalah cabang utama. Lihat [6. Bundle id](06-bundle-id.md) untuk perbedaan branch public/unlisted. |
| Tag | Penanda pada satu commit, mis. `fixtrack-1.1.1+14`. Dipakai untuk menemukan kode persis yang dirilis ketika membuat patch. |
| Commit / push / merge | Menyimpan perubahan / mengirim ke GitHub / menggabungkan branch. |

---

[Daftar isi](../README.md) | [2. Akses, akun, dan file rahasia >](02-akses-dan-rahasia.md)
