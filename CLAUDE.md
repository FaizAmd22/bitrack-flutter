# CLAUDE.md

Aturan untuk AI agent yang bekerja di repo ini. Pintu masuk dokumentasi
adalah `README.md` di root (termasuk satu-satunya daftar perintah melos);
detailnya di `docs/01-*.md` sampai `docs/17-*.md` (troubleshooting di
`docs/16-*`, resep perubahan umum di `docs/17-*`). Komentar kode berbahasa
Indonesia dan sengaja detail: baca komentar di atas kode sebelum
mengubahnya.

## Bentuk proyek

- Monorepo Flutter (pub workspace + Melos 6). Tiga app dengan fitur identik:
  `apps/fixtrack`, `apps/bitrack`, `apps/bitrack_internal`.
- SEMUA logic dan UI ada di `packages/core` (package `bitrack_core`). Folder
  `apps/<app>` hanya shell: `main.dart`, identitas brand, `android/`, `ios/`,
  assets, `.env`.
- Flutter dikunci di **3.38.7**. Jangan upgrade Flutter atau mengganti versi di
  `tool/shorebird.dart` tanpa diminta.

## Perintah

Daftar lengkap ada di bagian "Daftar perintah" di `README.md` root. Yang
paling sering dipakai agent: `flutter pub get` (di root), `melos run analyze`,
`melos run test`. Kalau `melos` tidak ada di PATH, pakai
`flutter pub run melos run <script>`.

- Jangan pakai `flutter run` polos: warna primer dioper lewat
  `--dart-define=APP_PRIMARY_COLOR`, dan `main.dart` sengaja assert-gagal
  tanpa itu.

## Aturan kode

- Ubah fitur/UI di `packages/core`, bukan di `apps/<app>/lib`.
- Dependency baru masuk ke `packages/core/pubspec.yaml`. Package dengan kode
  native (plugin) TIDAK bisa dikirim lewat patch Shorebird: sebutkan ini ke
  user setiap kali menambahkannya.
- `AppStyles.primaryColor` harus tetap compile-time constant. Jangan diubah
  jadi nilai runtime.
- Teks UI lewat `AppLocalizations`. Tambah key ke SEMUA file
  `packages/core/lib/l10n/app_*.arb` (id, en, ja, ko, zh; template
  `app_en.arb`), lalu `flutter gen-l10n` di `packages/core`. File hasil
  generate ikut di-commit; jangan diedit manual.
- HTTP lewat `ApiClient.dio` (token + logout 401 otomatis). Logout hanya lewat
  `ApiClient.logout()`.
- Ikuti gaya sekitar: komentar Bahasa Indonesia yang menjelaskan "kenapa".
- Setelah mengubah kode Dart, jalankan `melos run analyze` dan tes yang
  relevan sebelum menyatakan selesai.

## Jangan pernah

- Membaca, mencetak, menyalin ke chat, atau meng-commit isi `.env`,
  `.env.prod`, `key.properties`, `*.jks`, `*.keystore`, atau
  `cordova/build.json` (berisi password keystore). Semua sudah di-gitignore;
  jangan ubah `.gitignore` untuk memasukkannya.
- Membuat, mengganti, atau menghapus keystore. Keystore yang salah = Play
  menolak update (Bitrack memakai keystore Cordova lama, alias `treffix`,
  SHA1 `42:07:E2...`; FixTrack dan Bitrack Internal `upload-keystore.jks`,
  SHA1 `43:B3:20...`).
- Mengubah `applicationId` Android atau `PRODUCT_BUNDLE_IDENTIFIER` iOS tanpa
  perintah eksplisit. iOS punya dua set id: unlisted (`fixtrack.treffix.id`,
  `com.bitrack.mobile`) dan public (`com.treffix.fixtrack`,
  `bitrack.treffix.id`). Konfirmasi ke user listing mana yang dituju.
- Mengubah `app_id` atau `auto_update: false` di `apps/<app>/shorebird.yaml`.
- Menghapus folder `rilis/` (satu-satunya salinan AAB/IPA yang cocok dengan
  release Shorebird).
- Menjalankan perintah yang menerbitkan sesuatu tanpa izin user:
  `*:sb:release:*`, `*:sb:patch:*`, `*:sb:promote`, upload ke store, push ke
  `main`, force push.

## Versi, rilis, dan Shorebird

- Versi ada di `version: x.y.z+N` di `apps/<app>/pubspec.yaml`, terpisah per
  app. Rilis store = naikkan build number `N`.
- Build untuk store HARUS lewat `melos run <app>:sb:release:<android|ios>`,
  bukan `*:aab` / `flutter build`. File yang di-upload adalah
  `rilis/<app>-<versi>.aab|ipa`, bukan isi `build/`.
- Patch: JANGAN ubah `version:`; jalankan dari commit release yang dituju.
  Urutan: `sb:patch:*:staging` -> `sb:preview:*:staging` ->
  `sb:promote <nomor>`.
- Yang bisa di-patch hanya kode Dart. Perubahan `android/`, `ios/`, assets,
  `.env`, `shorebird.yaml`, plugin native, atau versi Flutter butuh rilis
  store baru.
- Selalu panggil Shorebird lewat skrip melos (`tool/shorebird.dart`), bukan
  `shorebird` langsung.
- Di Windows `shorebird.bat` selalu exit 0. Jangan anggap `SUCCESS` dari melos
  sebagai bukti; cari baris `Published Release ...` / `Published Patch ...`.
- Bitrack Internal Android tidak di Play Store (APK dibagikan langsung,
  `melos run internal:apk:prod`); iOS-nya ada di App Store.

## Jebakan lingkungan

- iOS hanya bisa di-build di Mac.
- Di Windows, Dart standalone lama di PATH bisa membuat `dart run melos`
  gagal (butuh Dart 3.10 dari Flutter). Pakai `flutter pub run melos ...`.
- Build iOS gagal karena sisa `build/native_assets`: hapus folder itu (skrip
  melos `*:ios` dan `*:sb:*:ios` sudah melakukannya).
- `.env` dibundel sebagai asset app: jangan menaruh secret server di sana, dan
  build gagal kalau file itu tidak ada.
