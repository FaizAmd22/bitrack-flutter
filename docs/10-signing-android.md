# 10. Keystore dan signing Android

[< 9. Fitur per halaman](09-fitur.md) | [Daftar isi](../README.md) | [11. Signing iOS >](11-signing-ios.md)

Keystore adalah file paling berharga di proyek ini. Google Play hanya
menerima AAB yang ditandatangani **upload key** yang terdaftar untuk listing
itu, dan Android hanya mau meng-update APK yang ditandatangani key yang sama
dengan versi yang sudah terpasang.

Repo ini memakai **dua keystore berbeda**:
- satu file `upload-keystore.jks` untuk FixTrack dan Bitrack Internal;
- keystore warisan app Cordova lama untuk Bitrack.

## 10.1 Peta keystore per app

| App | applicationId | Keystore | Alias | Pemilik sertifikat | SHA1 |
| --- | --- | --- | --- | --- | --- |
| FixTrack | `fixtrack.treffix.id` | `apps/fixtrack/android/app/upload-keystore.jks` (PKCS12, dibuat 27 Jan 2026) | `upload` | `CN=faizhal` | `43:B3:20:BC:60:4F:36:69:8A:82:26:84:07:40:74:73:7D:55:36:7E` |
| Bitrack | `com.bitrack.mobile` | Keystore Cordova lama: `D:\Work\Treffix.id\BITRACK APP\Bitrack\bitrack-mobile\cordova\android.keystore` (JKS, dibuat 29 Apr 2025, berlaku sampai 2080) | `treffix` | `CN=faizhal treffix, OU=treffix, O=treffix, L=tangsel, ST=banten, C=ID` | `42:07:E2:A0:EA:85:BB:53:8E:C3:54:F2:3B:FE:C9:F7:AF:7B:80:C6` |
| Bitrack Internal | `com.treffix.bitrack` | `apps/bitrack_internal/android/app/upload-keystore.jks` (salinan file FixTrack) | `upload` | `CN=faizhal` | sama dengan FixTrack |

**Kenapa Bitrack berbeda:** package `com.bitrack.mobile` dulu dirilis
sebagai app Cordova (`Bitrack/bitrack-mobile`, `config.xml` dengan widget id
yang sama) memakai keystore itu. App Flutter menggantikan listing yang sama,
jadi wajib memakai keystore yang sama. Saat monorepo dibuat (Agu 2026),
keystore FixTrack sempat ikut disalin ke Bitrack, dan Play menolak AAB-nya.

**Bitrack Internal** tidak punya listing Play Store, jadi tidak ada upload
key yang diharapkan Google. Tapi APK yang sudah terpasang di HP user hanya
bisa di-update oleh APK yang ditandatangani **key yang sama**. Tetap pakai
`apps/bitrack_internal/android/app/upload-keystore.jks` untuk setiap APK
Bitrack Internal. Kalau key diganti, user harus uninstall app lama dulu, dan
sesi login mereka hilang. Kalau suatu saat app ini masuk Play Store, keystore
yang sama bisa dijadikan upload key.

## 10.2 Cara kerja signing di repo

`apps/<app>/android/app/build.gradle.kts` membaca
`apps/<app>/android/key.properties`:

```
storePassword=<password keystore>
keyPassword=<password key>
keyAlias=upload               # Bitrack: treffix
storeFile=upload-keystore.jks # path relatif terhadap folder android/app/
```

Semua build release (`flutter build appbundle`, `flutter build apk`,
`shorebird release android`) otomatis memakai config ini. Kalau
`key.properties` tidak ada, build release **gagal** karena Gradle tidak bisa
membaca `keyAlias`. Build debug (`melos run <app>`) tidak terpengaruh.

## 10.3 Menyiapkan keystore Bitrack

Di mesin lama, `apps/bitrack/android/key.properties` dan keystore-nya **tidak
ada** di folder repo, jadi build release Bitrack akan gagal sampai langkah ini
dilakukan:

1. Salin `Bitrack/bitrack-mobile/cordova/android.keystore` ke
   `apps/bitrack/android/app/bitrack-upload.jks`.
2. Ambil password dari `Bitrack/bitrack-mobile/cordova/build.json`: field
   `storePassword` (password keystore) dan `password` (password key).
   Keduanya sudah diverifikasi berfungsi pada 15 Okt 2026.
3. Buat `apps/bitrack/android/key.properties`:
    ```
    storePassword=<storePassword dari build.json>
    keyPassword=<password dari build.json>
    keyAlias=treffix
    storeFile=bitrack-upload.jks
    ```
4. Cek dengan build: `melos run bitrack:apk:prod`. Lalu cocokkan SHA1 APK-nya
   dengan tabel 10.1 (perintah di 10.5).
5. Simpan kedua password di password manager tim.

Kedua file (`*.jks`, `key.properties`) sudah di-gitignore, jadi tidak akan
ikut ter-commit.

## 10.4 Play App Signing dan reset upload key

Listing FixTrack dan Bitrack memakai Play App Signing. Artinya Google
menyimpan **app signing key** final, dan kita hanya memegang **upload key**.
Cek di Play Console > pilih app > Test and release > App integrity > App
signing. Akibatnya:

- Upload key yang hilang atau bocor **bisa diganti** tanpa memengaruhi user
  (user tidak perlu reinstall, data tidak hilang).
- Yang tidak bisa diganti adalah applicationId. Mengubahnya sama dengan
  membuat app baru dengan listing baru.

Langkah reset upload key (hanya bila keystore benar-benar hilang):

1. Buat keystore baru:
    ```
    keytool -genkeypair -v -keystore upload-keystore-baru.jks -storetype PKCS12 \
      -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```
2. Ekspor sertifikatnya ke file PEM:
    ```
    keytool -export -rfc -keystore upload-keystore-baru.jks -alias upload -file upload_certificate.pem
    ```
3. Pemilik akun Play: Play Console > app > App integrity > App signing >
   **Request upload key reset**, pilih alasan, unggah `upload_certificate.pem`.
4. Tunggu persetujuan Google (biasanya 1-2 hari). Setelah itu, perbarui
   `key.properties` ke keystore baru dan perbarui tabel 10.1.

## 10.5 Memeriksa file ditandatangani key yang benar

Sebelum upload atau membagikan file, cocokkan SHA1 dengan tabel 10.1:

```
# AAB (Mac / Linux / Git Bash)
unzip -p rilis/bitrack-2.0.0+3.aab 'META-INF/*.RSA' | keytool -printcert | grep SHA1

# APK
keytool -printcert -jarfile apps/bitrack_internal/build/app/outputs/flutter-apk/app-release.apk | grep SHA1

# Sidik jari keystore (password akan ditanya)
keytool -list -v -keystore apps/fixtrack/android/app/upload-keystore.jks
```

Kalau Play menolak dengan pesan "signed with the wrong key", pesan itu
menyebut SHA1 yang diharapkan. Cocokkan dengan tabel 10.1 untuk tahu keystore
mana yang benar; jangan menebak dari nama app.

## 10.6 Backup

- Simpan kedua file keystore + semua password di minimal dua tempat terpisah
  (mis. password manager tim dan drive terenkripsi milik perusahaan).
- Keystore Bitrack saat ini hanya ada di mesin pemilik lama (plus salinan di
  dua project Cordova AbsenIn di mesin yang sama). Ini risiko terbesar
  handover; backup sebelum hal lain.
- Jangan pernah meng-commit keystore ke git, walaupun repo private.

---

[< 9. Fitur per halaman](09-fitur.md) | [Daftar isi](../README.md) | [11. Signing iOS >](11-signing-ios.md)
