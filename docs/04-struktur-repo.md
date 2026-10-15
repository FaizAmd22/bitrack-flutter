# 4. Struktur repo

[< 3. Instalasi tools dari nol](03-instalasi.md) | [Daftar isi](../README.md) | [5. Konfigurasi per app >](05-konfigurasi.md)

Repo ini adalah monorepo: root-nya bukan app, melainkan wadah tiga app plus satu package bersama. Semua dependency di-resolve sekaligus dengan satu `flutter pub get` di root, menghasilkan satu `pubspec.lock` bersama.

```
bitrack_mobile_flutter/
├─ pubspec.yaml            # root pub workspace: daftar anggota (3 app + core), bukan app
├─ pubspec.lock            # SATU lock untuk seluruh workspace (di-commit)
├─ melos.yaml              # semua perintah run / build / rilis / Shorebird
├─ README.md               # pintu masuk dokumentasi + daftar perintah
├─ .vscode/launch.json     # 6 konfigurasi Run di VS Code (3 app x dev/prod)
├─ tool/
│  ├─ shorebird.dart       # pembungkus perintah Shorebird (dipanggil melos)
│  └─ package_config.json  # config kosong agar skrip di atas jalan di Dart mana pun
├─ rilis/                  # (tidak di git) salinan AAB/IPA hasil Shorebird release
├─ CLAUDE.md               # aturan untuk AI agent
├─ docs/
│  ├─ 01-istilah.md ... 17-tugas-umum.md   # dokumentasi ini
│  └─ privacy-policy-bitrack.html          # kebijakan privasi untuk listing store
├─ packages/
│  └─ core/                # package `bitrack_core`: SELURUH logic dan UI
│     ├─ pubspec.yaml      # semua dependency app ada di sini
│     ├─ l10n.yaml         # konfigurasi terjemahan
│     ├─ lib/
│     │  ├─ base/          # fondasi: network, routes, services, widgets, styles
│     │  ├─ features/      # API + provider Riverpod (auth, monitoring, app_config)
│     │  ├─ l10n/          # file terjemahan .arb (id, en, ja, ko, zh) + hasil generate
│     │  └─ screens/       # tiap halaman app, satu folder per halaman
│     └─ test/             # unit + widget test
└─ apps/
   ├─ fixtrack/            # shell app FixTrack
   ├─ bitrack/             # shell app Bitrack
   └─ bitrack_internal/    # shell app Bitrack Internal
```

## 4.1 Isi satu folder app (`apps/<app>/`)

Tiap app hanyalah "shell" tipis. Isinya:

| Path | Fungsi |
| --- | --- |
| `lib/main.dart` | Titik mulai app: set identitas brand (`AppBranding.configure`), muat `.env`, muat token login, baca nomor patch Shorebird, mulai OneSignal, lalu daftarkan semua route halaman. Ketiga file hampir identik; bedanya hanya nama, warna, dan ukuran logo splash. |
| `pubspec.yaml` | Nama, **versi app** (`version:`), warna splash dan icon, daftar asset. |
| `.env`, `.env.prod` | Konfigurasi server (tidak di git). Ikut dibundel sebagai asset app. |
| `.env.example` | Template kosong `.env`. |
| `dart_defines.prod.json` | Nilai dart-define untuk build rilis Shorebird (`ENV_FILE` dan `APP_PRIMARY_COLOR`). |
| `shorebird.yaml` | `app_id` Shorebird app ini + `auto_update: false`. |
| `assets/` | Logo, icon SVG, gambar truk, animasi loading. Isinya identik antar app, kecuali logo. |
| `android/` | Proyek native Android: `app/build.gradle.kts` (applicationId, signing), `AndroidManifest.xml` (nama app, izin, Maps key), `key.properties` + `.jks` (tidak di git). |
| `ios/` | Proyek native iOS: `Runner.xcodeproj` (bundle id, team), `Runner/Info.plist` (nama app, izin), `Flutter/Env.xcconfig` (Maps key iOS), `Podfile`. |
| `test/widget_test.dart` | Tes bawaan template, tidak penting. |

`apps/fixtrack` juga masih membawa folder `web/`, `linux/`, `macos/`, `windows/` dari struktur lama. Folder itu tidak dipakai; app hanya ditujukan untuk Android dan iOS.

## 4.2 Aturan emas

- Mengubah fitur atau tampilan = mengubah `packages/core`. Jangan menaruh logic di `apps/<app>/lib`.
- Mengubah identitas satu app (nama, id, warna, logo, versi, signing) = mengubah folder `apps/<app>` saja.
- Menambah dependency = tambahkan di `packages/core/pubspec.yaml`, lalu `flutter pub get` di root.
- Ketiga app selalu ikut berubah bersama. Kalau sebuah fitur hanya boleh
  muncul di satu jenis app, pakai pengecekan konfigurasi yang sudah ada
  (mis. `AppUsers.isTechnicianApp` untuk build Teknisi), jangan menyalin
  kode ke folder app.

## 4.3 File yang dibuat otomatis (jangan diedit manual)

| File / folder | Dibuat oleh | Cara memperbarui |
| --- | --- | --- |
| `packages/core/lib/l10n/app_localizations*.dart` | `flutter gen-l10n` | Edit file `.arb`, lalu jalankan `flutter gen-l10n` di `packages/core`. Hasilnya di-commit. |
| `apps/<app>/android/app/src/main/res/mipmap-*`, `drawable*`, `ios/Runner/Assets.xcassets/*` | `melos run branding` (flutter_launcher_icons + flutter_native_splash) | Ganti `assets/logos/logo.png` atau warna di `pubspec.yaml` app, lalu jalankan ulang. Hasilnya di-commit. |
| `pubspec.lock` | `flutter pub get` | Jangan diedit tangan. Commit setiap kali berubah. |
| `apps/<app>/ios/Podfile.lock`, `ios/Pods/` | CocoaPods | `Podfile.lock` di-commit, `Pods/` tidak. |
| `build/`, `.dart_tool/` | Flutter | Tidak di-commit. Aman dihapus kapan saja (`flutter clean`). |

## 4.4 File yang sengaja tidak ada di git

`.env`, `.env.prod`, `key.properties`, `*.jks`, `local.properties`, dan
folder `rilis/` ada di `.gitignore`. Setelah clone, file-file ini harus
ditaruh manual; daftar dan isinya ada di
[2. Akses dan rahasia](02-akses-dan-rahasia.md). Pengecualian:
`ios/Flutter/Env.xcconfig` (Google Maps key iOS) sengaja tetap di-commit
karena sudah ada di riwayat git sejak sebelum monorepo.

---

[< 3. Instalasi tools dari nol](03-instalasi.md) | [Daftar isi](../README.md) | [5. Konfigurasi per app >](05-konfigurasi.md)
