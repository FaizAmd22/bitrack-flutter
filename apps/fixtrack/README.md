# FixTrack

Shell app. Seluruh logic dan UI ada di `packages/core` (package
`bitrack_core`) dan dipakai bersama dengan app lain di monorepo ini — folder
ini cuma memuat yang membedakan FixTrack dari saudaranya:

| | |
|---|---|
| applicationId / bundle ID | `fixtrack.treffix.id` |
| Warna primer | `#386AD8` |
| Identitas brand | `AppBranding.configure(...)` di `lib/main.dart` |
| Assets & env | `assets/`, `.env`, `.env.prod` (per app, isinya bisa beda) |

## Menjalankan

Jangan `flutter run` langsung dari folder ini: warna primer dioper lewat
`--dart-define` (lihat README di root), jadi tanpa flag itu app-nya jatuh ke
warna default dan `assert` di `lib/main.dart` akan gagal. Pakai script melos
dari root repo:

```bash
flutter pub run melos run fixtrack          # dev  (.env)
flutter pub run melos run fixtrack:prod     # prod (.env.prod)
flutter pub run melos run fixtrack:apk      # build APK
```

Atau pilih konfigurasi **FixTrack (Dev)** / **FixTrack (Prod)** di VS Code.

Dokumentasi lengkap monorepo: [`../../README.md`](../../README.md).
