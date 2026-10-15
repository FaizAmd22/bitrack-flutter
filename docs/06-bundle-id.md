# 6. Bundle id: public vs unlisted

[< 5. Konfigurasi per app](05-konfigurasi.md) | [Daftar isi](../README.md) | [7. Menjalankan app >](07-menjalankan-app.md)

Android memakai satu applicationId per app di semua branch, karena listing Play Store FixTrack dan Bitrack sudah public, dan Bitrack Internal tidak ada di Play Store (APK dibagikan langsung). iOS punya **dua set bundle id** untuk FixTrack dan Bitrack: satu untuk listing App Store yang **unlisted** (tidak muncul di pencarian) dan satu untuk listing **public**. Bitrack Internal memakai id yang sama di Android dan iOS dan tidak punya versi public.

## 6.1 Tabel lengkap

| App | Android applicationId (semua branch) | iOS bundle id: unlisted | iOS bundle id: public |
| --- | --- | --- | --- |
| FixTrack | `fixtrack.treffix.id` | `fixtrack.treffix.id` | `com.treffix.fixtrack` |
| Bitrack | `com.bitrack.mobile` | `com.bitrack.mobile` | `bitrack.treffix.id` |
| Bitrack Internal | `com.treffix.bitrack` | `com.treffix.bitrack` | (tidak ada versi public) |

Apple Team ID untuk semuanya: `BT5HYZB4PV`, signing otomatis (`CODE_SIGN_STYLE = Automatic`).

Pola gampangnya: id **unlisted iOS = sama dengan id Android**. Id public iOS adalah id baru yang dibuat khusus saat app didaftarkan ulang sebagai public.

## 6.2 Riwayat branch dan status sekarang

- Bundle id public diperkenalkan di commit `8dd2b5c` ("updated: setup public for bitrack and fixtrack", 18 Sep 2026) di branch `ios-public`. Commit itu juga menaikkan versi Bitrack ke 2.0.0+2 dan FixTrack ke 1.0.9+10, serta menambah `docs/privacy-policy-bitrack.html`.
- **Commit itu sudah ter-merge ke `main`** (lewat merge `7cd7263`, lalu `3fc7865` dan seterusnya). Akibatnya, `main` saat ini (`e512d42`) memakai bundle id **public**: `com.treffix.fixtrack` dan `bitrack.treffix.id`.
- Branch `ios-public` sudah dihapus dari GitHub. Salinan lokalnya menunjuk ke `3fc7865`, yang sudah termasuk di `main`.

> Status ini perlu dikonfirmasi pemilik proyek sebelum handover: rencana awalnya `main` = unlisted dan `ios-public` = public, tapi kode di `main` sekarang sudah public. Lihat [bagian 16](16-masalah-dan-hal-terbuka.md).

## 6.3 Cara pindah antara unlisted dan public

Id iOS ditulis di `apps/<app>/ios/Runner.xcodeproj/project.pbxproj`, baris `PRODUCT_BUNDLE_IDENTIFIER`. Ada 6 baris per app: 3 untuk target `Runner` (Debug, Release, Profile) dan 3 untuk `RunnerTests` (berakhiran `.RunnerTests`).

1. Buka `project.pbxproj` app yang ingin diubah, atau buka `ios/Runner.xcworkspace` di Xcode > target Runner > Signing & Capabilities > Bundle Identifier.
2. Ganti keenam nilai ke id tujuan dari [tabel 6.1](06-bundle-id.md#61-tabel-lengkap) (misalnya FixTrack: `com.treffix.fixtrack` untuk public, `fixtrack.treffix.id` untuk unlisted). Jangan ubah `applicationId` Android.
3. Di Xcode, pastikan Team `BT5HYZB4PV` terpilih dan "Automatically manage signing" aktif, supaya provisioning profile untuk id itu dibuat ulang.
4. Naikkan `version:` di `apps/<app>/pubspec.yaml` sesuai versi terakhir **listing tujuan** di App Store Connect (setiap listing punya riwayat versinya sendiri).
5. Build dan upload seperti biasa ([bagian 13](13-rilis-ios.md)). Ingat bahwa listing tujuan harus sudah ada di App Store Connect dengan bundle id yang sama persis.

**Cek cepat id yang sedang terpasang** (dari root repo, Git Bash / Mac):

```
grep -h "PRODUCT_BUNDLE_IDENTIFIER" apps/*/ios/Runner.xcodeproj/project.pbxproj | sort | uniq -c
```

**Ganti otomatis** (contoh FixTrack ke unlisted; jalankan di Mac atau Git
Bash, lalu periksa `git diff` sebelum commit):

```
sed -i.bak 's/com\.treffix\.fixtrack/fixtrack.treffix.id/g' apps/fixtrack/ios/Runner.xcodeproj/project.pbxproj
rm apps/fixtrack/ios/Runner.xcodeproj/project.pbxproj.bak
```

Untuk arah sebaliknya, tukar kedua id. Untuk Bitrack: `bitrack\.treffix\.id`
(public) dan `com.bitrack.mobile` (unlisted).

Saran untuk penerus: daripada bolak-balik mengganti id di satu branch, simpan dua branch yang jelas, mis. `main` (public) dan `ios-unlisted`, lalu rebase atau cherry-pick perubahan `packages/core` ke keduanya. Perbedaan antar branch sebaiknya hanya baris `PRODUCT_BUNDLE_IDENTIFIER` dan `version:`.

## 6.4 Dampak ke layanan lain saat bundle id berubah

- **Shorebird:** `apps/<app>/shorebird.yaml` hanya punya satu `app_id`, dipakai kedua varian iOS. Release Shorebird dicatat per nomor versi, jadi listing public dan unlisted **tidak boleh** memakai `version:` yang sama, atau release kedua akan ditolak/bentrok. Alternatif yang lebih bersih: buat app Shorebird terpisah untuk varian unlisted (`shorebird init` di branch unlisted, lalu simpan `app_id`-nya).
- **OneSignal (iOS):** push iOS memakai kunci APNs dari Team `BT5HYZB4PV` dan bundle id yang terdaftar di dashboard OneSignal. Pastikan app OneSignal yang dipakai varian tersebut terdaftar dengan bundle id yang sama.
- **Google Maps:** jika API key dibatasi per bundle id di Google Cloud, tambahkan kedua id ke daftar yang diizinkan.

---

[< 5. Konfigurasi per app](05-konfigurasi.md) | [Daftar isi](../README.md) | [7. Menjalankan app >](07-menjalankan-app.md)
