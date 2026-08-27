# Bitrack Internal

Shell app. Seluruh logic dan UI ada di `packages/core` (package
`bitrack_core`) dan dipakai bersama dengan app lain di monorepo ini — folder
ini cuma memuat yang membedakan Bitrack Internal dari saudaranya:

| | |
|---|---|
| applicationId / bundle ID | `com.treffix.bitrack` |
| Warna primer | `#9E2021` |
| Identitas brand | `AppBranding.configure(...)` di `lib/main.dart` |
| Assets & env | `assets/`, `.env`, `.env.prod` (per app, isinya bisa beda) |

## Menjalankan

Jangan `flutter run` langsung dari folder ini: warna primer dioper lewat
`--dart-define` (lihat README di root), jadi tanpa flag itu app-nya jatuh ke
warna default dan `assert` di `lib/main.dart` akan gagal. Pakai script melos
dari root repo:

```bash
flutter pub run melos run internal          # dev  (.env)
flutter pub run melos run internal:prod     # prod (.env.prod)
flutter pub run melos run internal:apk      # build APK
```

Atau pilih konfigurasi **Bitrack Internal (Dev)** / **Bitrack Internal (Prod)** di VS Code.

Dokumentasi lengkap monorepo: [`../../README.md`](../../README.md).
