# 7. Menjalankan app

[< 6. Bundle id: public vs unlisted](06-bundle-id.md) | [Daftar isi](../README.md) | [8. Arsitektur dan alur kode >](08-arsitektur.md)

Setelah instalasi ([bagian 3](03-instalasi.md)) dan file rahasia ([bagian 2](02-akses-dan-rahasia.md)) siap, app bisa dijalankan dalam empat langkah: clone, taruh `.env`, `flutter pub get`, lalu run.

## 7.1 Persiapan sekali saja

1. Clone repo: `git clone https://github.com/FaizAmd22/bitrack-flutter.git` lalu `cd bitrack-flutter`.
2. Taruh file `.env` dan `.env.prod` ke masing-masing `apps/fixtrack/`, `apps/bitrack/`, `apps/bitrack_internal/`.
3. Untuk peta di Android: tambahkan baris `GOOGLE_MAPS_API_KEY=<key>` di `apps/<app>/android/local.properties` (detail di [5.5](05-konfigurasi.md#55-google-maps-key-tiga-tempat-berbeda)).
4. Dari **root repo**: `flutter pub get`. Ini me-resolve ketiga app + core sekaligus.
5. (Mac, untuk iOS) Biasanya `flutter run` menjalankan `pod install` otomatis. Kalau gagal: `cd apps/<app>/ios && pod install --repo-update`.

## 7.2 Perintah run

Perintahnya ada di [Daftar perintah](../README.md#daftar-perintah) bagian
Development: `melos run <app>` (server dev) atau `melos run <app>:prod`
(server produksi), dari root repo.

Cara lain: di VS Code buka tab Run and Debug, pilih salah satu dari 6 konfigurasi (mis. "Bitrack (Dev)"), pilih device di pojok kanan bawah, tekan F5.

Kalau ada lebih dari satu device tersambung, `flutter run` akan menanyakan device. Untuk memilih langsung, jalankan Flutter tanpa melos dengan flag `-d`:

```
flutter devices                      # lihat id device
cd apps/bitrack
flutter run -d <id-device> --dart-define=APP_PRIMARY_COLOR=0xFFD84040
```

Selama app berjalan dalam mode debug: tekan `r` untuk hot reload, `R` untuk hot restart, `q` untuk keluar.

## 7.3 Android emulator

1. Android Studio > More Actions > Virtual Device Manager > Create Device.
2. Pilih HP (mis. Pixel 7), pilih system image dengan **Google Play** atau **Google APIs** (perlu untuk Google Maps), API 34 atau lebih baru.
3. Klik tombol play untuk menyalakan emulator, tunggu sampai home screen tampil.
4. Jalankan `melos run <app>`. Emulator akan muncul di daftar device.

## 7.4 HP Android fisik

1. Di HP: Settings > About phone, ketuk **Build number** 7 kali sampai muncul "You are now a developer".
2. Settings > System > Developer options, aktifkan **USB debugging**.
3. Sambungkan HP dengan kabel data. Di HP muncul dialog "Allow USB debugging?", pilih Allow (centang "Always allow").
4. Cek dengan `flutter devices` atau `adb devices`. Kalau HP tidak muncul di Windows, install driver USB pabrikan HP (Samsung, Xiaomi, dll).
5. Jalankan `melos run <app>`.

## 7.5 iOS Simulator (Mac)

1. `open -a Simulator`, atau Xcode > Open Developer Tool > Simulator. Pilih model iPhone di menu File > Open Simulator.
2. Jalankan `melos run <app>`.

Catatan: push notification dan Face ID terbatas di Simulator. Uji keduanya di HP fisik.

## 7.6 iPhone fisik (Mac)

1. Sambungkan iPhone dengan kabel. Di iPhone pilih **Trust This Computer**.
2. Aktifkan Developer Mode di iPhone: Settings > Privacy & Security > Developer Mode > On, lalu restart HP.
3. Buka `apps/<app>/ios/Runner.xcworkspace` di Xcode (bukan `.xcodeproj`). Pilih target **Runner** > **Signing & Capabilities**. Pastikan "Automatically manage signing" aktif dan Team = Treffix (`BT5HYZB4PV`). Akun Apple penerus harus sudah ditambahkan di Xcode > Settings > Accounts.
4. Kalau Xcode protes bundle id belum terdaftar, biarkan Xcode membuat profile otomatis (butuh role yang cukup di team). iPhone juga harus terdaftar di team; Xcode menawarkan untuk mendaftarkannya.
5. Jalankan `melos run <app>` dari terminal, atau tombol Run di Xcode.
6. Pertama kali dipasang, iPhone mungkin menolak membuka app: Settings > General > VPN & Device Management > percayai developer.

## 7.7 Login saat development

- Pakai akun uji dari tim backend untuk server dev (`.env`). Akun produksi
  hanya untuk `.env.prod`; jangan mengubah data pelanggan saat mencoba fitur.
- Kalau belum punya akun, aktifkan flag `show_register` di Supabase
  ([5.6](05-konfigurasi.md#56-mengubah-flag-remote-di-supabase)) supaya
  tombol "Lanjut dengan demo" muncul. Mode demo memakai data dummy, jadi
  cocok untuk melihat tampilan, bukan untuk menguji API.
- Label **DEVELOPMENT** di bawah logo login menandakan app memakai `.env` dev.

## 7.8 Melihat log dan debugging

- **Log request API:** di mode debug, setiap request dan response Dio dicetak
  ke terminal tempat `melos run` berjalan (dan ke Debug Console VS Code):
  method, URL, header (termasuk token), body, dan error. Di build release log
  ini mati otomatis (`base/network/api_logger.dart`).
- **Waktu request:** `base/network/api_timing.dart` mencatat lama tiap
  request; berguna saat halaman terasa lambat.
- **Flutter DevTools:** saat app berjalan, tekan `v` di terminal (atau klik
  "Open DevTools" di VS Code) untuk melihat pohon widget, performa, dan
  memori.
- **Log native:** Android lewat `adb logcat` atau tab Logcat di Android
  Studio; iOS lewat Xcode > Window > Devices and Simulators > Open Console.
- **Breakpoint:** jalankan dari VS Code (F5), klik di kiri nomor baris untuk
  memasang breakpoint.

## 7.9 Kalau ada masalah

Semua gejala dan solusinya dikumpulkan di [16. Masalah umum](16-masalah-dan-hal-terbuka.md#167-masalah-umum-dan-solusinya).

---

[< 6. Bundle id: public vs unlisted](06-bundle-id.md) | [Daftar isi](../README.md) | [8. Arsitektur dan alur kode >](08-arsitektur.md)
