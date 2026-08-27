# bitrack_apps

Monorepo (melos + pub workspace) berisi tiga aplikasi Flutter yang **fungsi
dan fiturnya identik**. Semua kode ada di satu package bersama; tiap app cuma
shell tipis yang membedakan identitas brand.

```
.
├─ melos.yaml               # script run/build tiap app
├─ pubspec.yaml             # root pub workspace (bukan app)
├─ pubspec.lock             # SATU lock file untuk seluruh workspace
├─ packages/
│  └─ core/                 # package `bitrack_core` — SELURUH logic & UI
│     ├─ l10n.yaml
│     └─ lib/{base,features,l10n,screens}
└─ apps/
   ├─ fixtrack/             # main.dart + assets + android/ + ios/ + .env
   ├─ bitrack/
   └─ bitrack_internal/
```

## Yang berbeda antar app

Hanya enam hal. Selebihnya — tiap baris logic dan UI — dipakai bersama dari
`packages/core`.

| | fixtrack | bitrack | bitrack_internal |
|---|---|---|---|
| Nama app | FixTrack | Bitrack | Bitrack Internal |
| applicationId / bundle ID | `fixtrack.treffix.id` | `com.bitrack.mobile` | `com.treffix.bitrack` |
| Warna primer | `#386AD8` | `#D84040` | `#9E2021` |
| Versi | 1.0.6+7 | 1.0.0+1 | 1.0.0+1 |
| `assets/` | \<— identik —> | \<— identik —> | \<— identik —> |
| `.env` / `.env.prod` | \<— identik —> | \<— identik —> | \<— identik —> |

`assets/`, `.env`, dan `.env.prod` sengaja dibuat **sama persis** di ketiga app
supaya bisa diganti manual per app tanpa menyentuh kode.

## Menjalankan

Melos belum terpasang global, jadi panggil lewat Flutter (penting: `dart run`
memakai Dart standalone 3.8.1 di PATH yang tidak bisa melihat Flutter SDK):

```bash
flutter pub get                       # sekali, resolve seluruh workspace
flutter pub run melos run bitrack     # atau: melos run <script>
```

| Script | Hasil |
|---|---|
| `fixtrack` / `bitrack` / `internal` | `flutter run`, `.env` (dev) |
| `<app>:prod` | `flutter run`, `.env.prod` |
| `<app>:release` | `flutter run --release` |
| `<app>:apk` / `<app>:apk:prod` | `flutter build apk --release` |
| `<app>:aab` | `flutter build appbundle --release` (Play Store, prod) |
| `<app>:ios` / `<app>:ios:prod` | `flutter build ios --release` |
| `analyze` / `test` | di semua app + package |
| `branding` | regenerate splash + launcher icon ketiga app |

Nama script Bitrack Internal disingkat `internal` (`internal:apk`, `internal:aab`, …).

Di VS Code, keenam kombinasi app x env sudah ada di `.vscode/launch.json`.

## Warna primer: kenapa lewat `--dart-define`

`AppStyles.primaryColor` dipakai di ~139 tempat, banyak sebagai argumen
`const` constructor (`const BorderSide(color: AppStyles.primaryColor)`), jadi
nilainya **harus compile-time constant** — tidak bisa di-set lewat pemanggilan
method biasa saat runtime seperti `AppBranding`. Karena itu tiap app mengoper
`--dart-define=APP_PRIMARY_COLOR=0xAARRGGBB` saat run/build; nilainya ada di
`melos.yaml` dan `.vscode/launch.json`.

Konsekuensinya: **`flutter run` polos di dalam `apps/bitrack` menghasilkan app
berwarna biru FixTrack**, bukan merah. Supaya itu tidak lolos diam-diam, tiap
`main.dart` punya `assert` yang membandingkan warna hasil compile dengan warna
brand-nya dan langsung gagal dengan pesan yang menyebut script melos-nya. Assert
hanya aktif di debug — untuk build release, selalu lewat script melos di atas.

Mengganti warna satu app = edit `melos.yaml` + `.vscode/launch.json`, lalu
`melos run branding` untuk splash & icon. Tidak ada kode yang perlu disentuh.

## Menambah app baru

1. `cp -r apps/bitrack apps/<app-baru>` (buang `build/`, `.dart_tool/`).
2. Ganti `name:`, `description:`, `version:`, warna splash & `adaptive_icon_background` di `pubspec.yaml`.
3. Ganti `namespace`/`applicationId` di `android/app/build.gradle.kts`, pindahkan `MainActivity.kt` ke direktori paket baru, ganti `android:label` di `AndroidManifest.xml`.
4. Ganti `PRODUCT_BUNDLE_IDENTIFIER` di `ios/Runner.xcodeproj/project.pbxproj` dan `CFBundleDisplayName`/`CFBundleName` di `ios/Runner/Info.plist`.
5. Ganti `AppBranding.configure(...)` + `_brandPrimaryColor` di `lib/main.dart`.
6. Daftarkan di `workspace:` (`pubspec.yaml` root) dan tambah script di `melos.yaml` + `.vscode/launch.json`.
7. `flutter pub get` lalu `melos run branding`.

## Catatan

- **Platform**: `apps/fixtrack` masih membawa folder `web/`, `linux/`, `macos/`,
  `windows/` dari struktur lama. Dua app baru sengaja Android + iOS saja —
  dependency-nya (google_maps_flutter, media_kit libs, local_auth) memang cuma
  dipakai di mobile.
- **Signing**: `android/key.properties` + `upload-keystore.jks` disalin apa
  adanya, jadi ketiga app dibangun dengan upload key yang sama. Ganti kalau
  tiap app mau punya key sendiri.
- **`bitrack` vs app Cordova lama**: `com.bitrack.mobile` sama dengan
  `Bitrack/bitrack-mobile` (Cordova, versi 1.0.11). Kalau app ini dimaksudkan
  menimpa listing Play Store yang sudah ada, `version:` di
  `apps/bitrack/pubspec.yaml` harus dinaikkan dulu di atas versionCode yang
  sudah terbit — sekarang masih 1.0.0+1.
