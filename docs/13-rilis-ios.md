# 13. Rilis iOS ke App Store

[< 12. Rilis Android](12-rilis-android.md) | [Daftar isi](../README.md) | [14. Shorebird: release dan patch >](14-shorebird.md)

Rilis iOS dikerjakan di Mac, dengan aturan yang sama seperti Android: build untuk store **harus** dari `melos run <app>:sb:release:ios`. Sebelum mulai, pastikan bundle id di `project.pbxproj` sesuai listing tujuan (public atau unlisted, [bagian 6](06-bundle-id.md)).

## 13.1 Langkah demi langkah

1. **Cek bundle id dan versi.** Buka `apps/<app>/ios/Runner.xcodeproj/project.pbxproj`, pastikan `PRODUCT_BUNDLE_IDENTIFIER` = id listing tujuan. Naikkan `version:` di `apps/<app>/pubspec.yaml`: versi harus lebih besar dari versi terakhir di App Store Connect untuk listing itu, dan build number harus unik per versi.
2. **Commit + tag** seperti Android (mis. `bitrack-ios-2.0.1+3`).
3. **Signing:** buka `apps/<app>/ios/Runner.xcworkspace` di Xcode sekali untuk memastikan signing otomatis tidak error ([bagian 11](11-signing-ios.md)).
4. **Release ke Shorebird:**

   ```
   melos run bitrack:sb:release:ios     # atau fixtrack:... / internal:...
   ```

   Skrip menghapus `build/native_assets`, menjalankan `shorebird release ios` dengan Flutter 3.38.7 dan `dart_defines.prod.json`, lalu menyalin IPA ke `rilis/<app>-<versi>.ipa`. Pastikan output memuat `Published Release <versi>`.
5. **Upload IPA ke App Store Connect.** Pilih salah satu:
   - **Transporter** (gratis di Mac App Store): login Apple ID, seret file `rilis/<app>-<versi>.ipa`, klik Deliver.
   - **Xcode Organizer:** buka archive yang dibuat Shorebird (`apps/<app>/build/ios/archive/Runner.xcarchive`) di Xcode > Window > Organizer, lalu Distribute App > App Store Connect > Upload.
   - Command line: `xcrun altool --upload-app -f rilis/<app>-<versi>.ipa -t ios --apiKey <key> --apiIssuer <issuer>` (butuh App Store Connect API key).
6. **Tunggu processing** di App Store Connect > app > TestFlight (biasanya 10-30 menit). Jawab pertanyaan Export Compliance (app hanya memakai enkripsi standar HTTPS).
7. **(Disarankan) Uji lewat TestFlight:** tambahkan tester internal, pasang app TestFlight di iPhone, uji build tersebut.
8. **Submit review:** App Store Connect > app > Distribution > tambah versi baru (tombol + di samping iOS App) > isi "What's New" > pilih build > isi App Review Information (akun demo atau instruksi tombol demo) > Add for Review > Submit.
9. **Review Apple** biasanya 1-3 hari. Kalau ditolak, alasannya muncul di Resolution Center; perbaiki lalu submit ulang.
10. **Rilis:** setelah disetujui, rilis manual atau otomatis sesuai pilihan di halaman versi.

## 13.2 Public vs unlisted

|  | Public | Unlisted |
| --- | --- | --- |
| Bundle id | Lihat [tabel 6.1](06-bundle-id.md#61-tabel-lengkap) kolom public | Lihat [tabel 6.1](06-bundle-id.md#61-tabel-lengkap) kolom unlisted |
| Terlihat di pencarian App Store | Ya | Tidak, hanya lewat link langsung |
| Cara mendapatkannya | Rilis biasa | App harus lolos review dulu, lalu ajukan lewat formulir Apple "Unlisted App Distribution" (developer.apple.com/support/unlisted-app-distribution). Setelah disetujui, update berikutnya tetap unlisted. |
| Kebutuhan review | Review penuh, termasuk akses ke fitur tanpa akun. Itu alasan mode demo dibuat. | Tetap direview, tapi kriteria akses akun lebih longgar karena untuk audiens tertentu. |

Karena keduanya listing terpisah, setiap update yang ingin sampai ke kedua kelompok user harus di-build dan di-upload dua kali, sekali per bundle id.

## 13.3 Tips review Apple untuk app ini

- Aktifkan flag `show_register` di Supabase ([5.6](05-konfigurasi.md#56-mengubah-flag-remote-di-supabase)) sebelum submit agar tombol demo muncul untuk reviewer, dan sebutkan di App Review Information (contoh teks di 13.4).
- Jelaskan bahwa app adalah layanan B2B untuk pelanggan armada yang akunnya dibuat admin.
- Pastikan URL kebijakan privasi aktif.

## 13.4 Contoh teks App Review Information

Isi kolom "Notes" di App Review Information, misalnya:

```
This app is a fleet monitoring service for our business customers. Accounts
are created by our admin team, so public sign-up is not available.

To review all features without an account, tap "Continue with demo" on the
login screen. Demo mode shows sample vehicles, alerts, periodic tracks and
work orders.
```

Sesuaikan nama tombol dengan teks yang tampil di bahasa perangkat reviewer
(biasanya Inggris).

## 13.5 Alasan penolakan yang umum

| Alasan (guideline) | Artinya | Yang dilakukan |
| --- | --- | --- |
| 2.1 App Completeness | Reviewer tidak bisa masuk atau menemukan bug | Pastikan flag demo aktif, uji build TestFlight yang sama persis. |
| 5.1.1 Data Collection | Teks izin (kamera, mikrofon, Face ID) kurang jelas | Perjelas teks `NS...UsageDescription` di `Info.plist`, perlu rilis baru. |
| 4.2 Minimum Functionality | App dianggap terlalu terbatas tanpa akun | Jelaskan konteks B2B dan mode demo di Notes; pertimbangkan unlisted. |
| 5.1.1(v) Account Deletion | App dengan akun wajib menyediakan cara menghapus akun | Jelaskan bahwa akun dikelola admin perusahaan, atau sediakan jalur permintaan hapus akun. |

## 13.6 Setelah rilis

- Pantau crash di App Store Connect > app > TestFlight / Analytics, atau
  Xcode > Window > Organizer > Crashes.
- Bug di kode Dart bisa diperbaiki lewat patch Shorebird iOS
  (`melos run <app>:sb:patch:ios:staging`, di Mac) tanpa review ulang.

---

[< 12. Rilis Android](12-rilis-android.md) | [Daftar isi](../README.md) | [14. Shorebird: release dan patch >](14-shorebird.md)
