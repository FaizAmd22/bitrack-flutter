# 11. Signing iOS

[< 10. Keystore dan signing Android](10-signing-android.md) | [Daftar isi](../README.md) | [12. Rilis Android >](12-rilis-android.md)

Di iOS tidak ada file keystore yang harus dijaga: sertifikat dan provisioning profile dikelola Apple, dan ketiga app memakai **Automatic signing** dengan Team `BT5HYZB4PV`. Yang perlu diserahkan hanyalah akses akun Apple Developer dengan role yang cukup.

## 11.1 Yang dibutuhkan penerus

1. Apple ID pribadi penerus diundang ke team Treffix di App Store Connect (Users and Access). Untuk membuat sertifikat distribusi dan profile otomatis, role minimal **App Manager** dengan akses "Certificates, Identifiers & Profiles", atau **Admin**.
2. Di Mac: Xcode > Settings > Accounts > tambah Apple ID tersebut. Team Treffix akan muncul.
3. Buka `apps/<app>/ios/Runner.xcworkspace`, target Runner > Signing & Capabilities: centang "Automatically manage signing", pilih Team Treffix. Xcode akan membuat sertifikat Apple Development / Apple Distribution dan profile untuk bundle id app itu.

## 11.2 Bundle id yang harus terdaftar di Apple

Setiap bundle id di [tabel 6.1](06-bundle-id.md#61-tabel-lengkap) harus terdaftar sebagai App ID di developer.apple.com > Certificates, Identifiers & Profiles > Identifiers, dan punya record app di App Store Connect:

- Unlisted: `fixtrack.treffix.id`, `com.bitrack.mobile`, `com.treffix.bitrack`
- Public: `com.treffix.fixtrack`, `bitrack.treffix.id`

Capability yang dipakai (sudah diatur di proyek, ikut terbawa saat signing otomatis):

| Capability | Untuk | Lokasi di proyek |
| --- | --- | --- |
| Push Notifications | OneSignal | `ios/Runner/Runner.entitlements` (`aps-environment`) |
| Background Modes > Remote notifications | Notifikasi saat app di background | `ios/Runner/Info.plist` (`UIBackgroundModes`) |

Izin yang diminta ke user (teks di `Info.plist`): Face ID untuk login, mikrofon untuk intercom dashcam, kamera dan galeri untuk foto evidence work order. Kalau menambah fitur yang butuh izin baru, teks izinnya wajib ditambahkan di `Info.plist` atau app akan crash dan ditolak review.

## 11.3 Push notification iOS (OneSignal)

OneSignal butuh kunci APNs (file `.p8`, "Apple Push Notifications service key") dari Team `BT5HYZB4PV` yang diunggah di dashboard OneSignal > Settings > Push & In-App > Apple iOS, beserta bundle id app. Satu kunci `.p8` bisa dipakai semua app di team. Kalau push iOS tidak sampai setelah bundle id diganti, periksa bundle id yang terdaftar di app OneSignal-nya.

Nilai `aps-environment` di `Runner.entitlements` tertulis `development`; Xcode otomatis mengubahnya menjadi `production` saat archive diekspor untuk App Store.

## 11.4 Versi di iOS

`CFBundleShortVersionString` dan `CFBundleVersion` di `Info.plist` diisi otomatis dari `version:` di `pubspec.yaml` app (`1.1.0+13` menjadi versi 1.1.0 build 13). Jangan mengubah versi di Xcode secara manual; ubah `pubspec.yaml`.

## 11.5 Kalau signing error

Pesan error Xcode yang umum dan solusinya ada di [16. Masalah umum](16-masalah-dan-hal-terbuka.md#167-masalah-umum-dan-solusinya).

## 11.6 Perlu Mac untuk apa saja

Semua pekerjaan signing dan rilis iOS butuh Mac: membuka Xcode, membuat
sertifikat, build IPA (`shorebird release ios`), patch iOS
(`shorebird patch ios`), dan upload lewat Transporter. Pekerjaan kode Dart
biasa tetap bisa dilakukan di Windows dan diuji di Android.

---

[< 10. Keystore dan signing Android](10-signing-android.md) | [Daftar isi](../README.md) | [12. Rilis Android >](12-rilis-android.md)
