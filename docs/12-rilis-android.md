# 12. Rilis Android

[< 11. Signing iOS](11-signing-ios.md) | [Daftar isi](../README.md) | [13. Rilis iOS ke App Store >](13-rilis-ios.md)

Setiap rilis ke Play Store **harus** dibuat lewat `melos run <app>:sb:release:android`. Build biasa (`<app>:aab`) tidak membawa engine Shorebird, jadi versi itu tidak akan pernah menerima patch ([14](14-shorebird.md)).

## 12.1 Langkah demi langkah

1. **Pastikan kode siap:** sudah di-merge ke branch rilis, `melos run analyze` dan `melos run test` lolos, dan app sudah dicoba di HP dengan `melos run <app>:prod`.
2. **Naikkan versi** di `apps/<app>/pubspec.yaml`. Build number (angka setelah `+`) wajib lebih besar dari build terakhir di Play Console. Contoh: `1.1.0+13` menjadi `1.1.1+14`. Versi tiap app independen.
3. **Commit** perubahan versi, dan beri tag supaya commit rilis mudah ditemukan saat membuat patch nanti: `git tag fixtrack-1.1.1+14 && git push --tags`.
4. **Pastikan signing siap:** `apps/<app>/android/key.properties` + keystore yang benar ada ([bagian 10](10-signing-android.md)).
5. **Release ke Shorebird:** dari root repo jalankan

   ```
   melos run fixtrack:sb:release:android     # atau bitrack:... / internal:...
   ```

   Skrip ini memanggil `shorebird release android --flutter-version 3.38.7 --dart-define-from-file dart_defines.prod.json`, lalu menyalin AAB ke `rilis/<app>-<versi>.aab`. Berhasil hanya jika output memuat baris **`Published Release <versi>`** dan pesan "Release ... tersimpan di: rilis/..." (tulisan `SUCCESS` dari melos tidak cukup, lihat [14.6](14-shorebird.md#146-jebakan-shorebird-yang-sudah-pernah-terjadi)).
6. **Verifikasi AAB** (disarankan): `melos run fixtrack:sb:verify`. Skrip membandingkan kode Dart di `rilis/<app>-<versi>.aab` dengan release di server Shorebird. Harus keluar `COCOK`.
7. **(Opsional) Coba di HP** persis seperti yang akan diterima user: `melos run fixtrack:sb:preview:android`.
8. **Upload ke Play Console:**
   1. Buka play.google.com/console, pilih app.
   2. Untuk uji dulu: Test and release > Testing > Internal testing > Create new release. Untuk langsung ke user: Test and release > Production > Create new release.
   3. Upload file **`rilis/<app>-<versi>.aab`** (jangan file di folder `build/`, karena file itu tertimpa saat membuat patch).
   4. Isi release notes (Bahasa Indonesia dan/atau Inggris), klik Next, periksa peringatan, lalu Save and publish / Start rollout.
9. **Tunggu review Google:** biasanya beberapa jam sampai 1-3 hari. Status terlihat di Publishing overview.
10. **Simpan folder `rilis/`**: jangan dihapus. AAB di sana adalah satu-satunya salinan binary yang cocok dengan release Shorebird.

## 12.2 Hal yang perlu diperhatikan di Play Console

- **Kebijakan dan formulir:** kebijakan privasi (Bitrack: `docs/privacy-policy-bitrack.html`, harus di-host di URL publik), Data safety, target audience, dan akses akun untuk reviewer. Untuk akses reviewer, aktifkan flag Supabase `show_register` agar tombol demo muncul, atau berikan akun uji.
- **Target API level:** Google mewajibkan target SDK terbaru setiap tahun. Nilainya mengikuti Flutter (`flutter.targetSdkVersion`); kalau Play memperingatkan target SDK usang, upgrade Flutter (dan uji ulang) atau set `targetSdk` manual di `build.gradle.kts`.
- **Staged rollout:** untuk update besar, mulai dari 10-20% user lalu naikkan bertahap.

## 12.3 Build tanpa Shorebird (darurat)

Perintah `<app>:aab` dan `<app>:apk:prod` ada di [Daftar perintah](../README.md#daftar-perintah). Versi yang di-upload tanpa Shorebird tidak bisa menerima patch, jadi pakai hanya bila Shorebird sedang tidak bisa dipakai.

## 12.4 Bitrack Internal Android: APK dibagikan langsung

Bitrack Internal di Android tidak di-upload ke Play Store. Alurnya:

1. Naikkan `version:` di `apps/bitrack_internal/pubspec.yaml`, termasuk build number. Android menolak memasang APK dengan build number lebih kecil di atas versi yang sudah terpasang.
2. Pastikan `apps/bitrack_internal/android/key.properties` + `upload-keystore.jks` ada ([bagian 10](10-signing-android.md)), supaya APK bisa dipasang di atas versi lama.
3. Build: `melos run internal:apk:prod`. Hasilnya `apps/bitrack_internal/build/app/outputs/flutter-apk/app-release.apk`. Ganti namanya, mis. `bitrack-internal-1.0.1+2.apk`.
4. Bagikan file itu (drive, chat). Di HP user, izinkan "Install unknown apps" untuk aplikasi yang dipakai membuka file, lalu pasang.

Catatan Shorebird: APK dari `internal:apk:prod` dibangun tanpa Shorebird, jadi **tidak bisa menerima patch**. Kalau ingin Bitrack Internal Android bisa di-patch, build APK lewat Shorebird. Skrip melos belum mendukung APK, jadi jalankan manual dari `apps/bitrack_internal`:

```
shorebird release android --artifact apk --flutter-version 3.38.7 --dart-define-from-file dart_defines.prod.json
```

Pastikan output memuat `Published Release <versi>`, lalu salin `build/app/outputs/flutter-apk/app-release.apk` ke `rilis/` **sebelum** membuat patch apa pun (patch menimpa folder `build/`). Setelah itu, patch dibuat dengan `melos run internal:sb:patch:android:staging` seperti biasa ([bagian 14](14-shorebird.md)).

## 12.5 Menentukan nomor versi

Format `version: MAYOR.MINOR.PATCH+BUILD`, mis. `1.1.0+13`.

| Jenis perubahan | Yang dinaikkan | Contoh |
| --- | --- | --- |
| Perbaikan bug kecil | PATCH + BUILD | `1.1.0+13` -> `1.1.1+14` |
| Fitur baru | MINOR + BUILD (PATCH kembali 0) | `1.1.1+14` -> `1.2.0+15` |
| Perubahan besar / tampilan baru total | MAYOR + BUILD | `1.2.0+15` -> `2.0.0+16` |
| Upload ulang versi yang sama (mis. build pertama ditolak) | BUILD saja | `1.2.0+15` -> `1.2.0+16` |

Aturan wajib:
- **BUILD selalu naik** untuk setiap file yang di-upload ke store atau
  dibagikan, tidak pernah turun dan tidak pernah dipakai ulang.
- Versi tiap app independen. Rilis FixTrack tidak mengharuskan Bitrack ikut
  naik versi.
- **Patch Shorebird tidak mengubah versi.**

## 12.6 Template release notes

```
Versi 1.2.0
- Perbaikan tampilan peta saat kendaraan banyak
- Notifikasi kini bisa difilter per jenis alert
- Perbaikan bug dan peningkatan performa
```

Play Console menerima release notes per bahasa (tag `<id-ID>` dan
`<en-US>`). Maksimal 500 karakter per bahasa.

## 12.7 Setelah rilis

- Pantau **Android vitals** di Play Console (crash rate, ANR) 1-3 hari
  pertama.
- Kalau ada bug kritis di kode Dart, perbaiki lewat patch Shorebird
  ([bagian 14](14-shorebird.md)) tanpa menunggu review.
- Kalau bug ada di bagian native, hentikan staged rollout (Production >
  Halt rollout), perbaiki, lalu rilis versi dengan BUILD baru.

---

[< 11. Signing iOS](11-signing-ios.md) | [Daftar isi](../README.md) | [13. Rilis iOS ke App Store >](13-rilis-ios.md)
