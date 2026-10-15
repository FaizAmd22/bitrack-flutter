# 3. Instalasi tools dari nol

[< 2. Akses, akun, dan file rahasia](02-akses-dan-rahasia.md) | [Daftar isi](../README.md) | [4. Struktur repo >](04-struktur-repo.md)

Android bisa dikerjakan di Windows, macOS, atau Linux. **iOS hanya bisa di-build di Mac** (Xcode tidak ada untuk Windows). Jadi untuk merilis ketiga app ke dua toko, penerus butuh akses ke satu Mac.

## 3.1 Versi yang dipakai proyek

| Tool | Versi | Catatan |
| --- | --- | --- |
| Flutter | **3.38.7** (Dart 3.10.7) | Wajib persis. Shorebird me-release dengan versi ini (`_flutterVersion` di `tool/shorebird.dart`). |
| JDK | 17 (Temurin 17 dipakai di mesin lama) | Kode Android menargetkan Java 11, tapi Android Gradle Plugin 8.9 butuh JDK 17 untuk berjalan. |
| Android Gradle Plugin / Gradle / Kotlin | 8.9.1 / 8.12 / 2.4.0 | Diunduh otomatis oleh Gradle saat build pertama. |
| Android NDK | 28.2.13676358 | Install lewat Android Studio > SDK Manager > SDK Tools > NDK (Side by side). |
| Xcode | versi terbaru yang mendukung iOS target 13+ | Minimum iOS app: 13.0 (Podfile: 14.0). |
| CocoaPods | terbaru | Untuk dependency native iOS. |
| Melos | **6.x** (6.3.3) | Sudah jadi dev\_dependency di `pubspec.yaml` root. Jangan pakai Melos 7, format konfigurasinya berbeda. |
| Shorebird CLI | 1.6.x (1.6.123 dipakai terakhir) | Untuk release dan patch. |

## 3.2 Langkah instalasi (Windows / Mac)

1. **Git.** Install dari git-scm.com. Di Windows, Git Bash ikut terpasang.
2. **Flutter 3.38.7.** Unduh arsip versi 3.38.7 dari halaman Flutter SDK archive (docs.flutter.dev/release/archive), ekstrak ke folder tanpa spasi (mis. `C:\Android\flutter` atau `~/flutter`), lalu tambahkan folder `bin` di dalamnya ke PATH (caranya di [3.4](#34-cara-menambah-folder-ke-path)). Alternatif: `git clone https://github.com/flutter/flutter.git -b 3.38.7`. Cek dengan `flutter --version`.
3. **Android Studio.** Install dari developer.android.com/studio. Saat pertama dibuka, ikuti wizard untuk memasang Android SDK. Lalu buka SDK Manager dan pastikan terpasang: Android SDK Platform terbaru, Android SDK Command-line Tools, Android SDK Build-Tools, Android Emulator, dan NDK 28.2.13676358.
4. **JDK 17.** Android Studio sudah membawa JDK sendiri. Kalau `java -version` di terminal bukan 17, install Temurin 17 (adoptium.net) atau jalankan `flutter config --jdk-dir <path-jdk-17>`.
5. **Terima lisensi Android:** `flutter doctor --android-licenses`, jawab `y` untuk semua.
6. **(Mac saja) Xcode.** Install dari App Store. Setelah itu jalankan `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` dan `sudo xcodebuild -runFirstLaunch`. Buka Xcode sekali, lalu Settings > Components untuk mengunduh iOS Simulator.
7. **(Mac saja) CocoaPods:** `sudo gem install cocoapods` atau `brew install cocoapods`.
8. **VS Code** (disarankan) + extension **Flutter** dan **Dart**. Repo sudah punya `.vscode/launch.json` untuk menjalankan keenam kombinasi app.
9. **Melos.** Paling aman memakai Melos dari dev\_dependency repo, dengan Dart bawaan Flutter:
   - dari root repo: `flutter pub run melos run <nama-script>`
   - atau pasang global: `dart pub global activate melos 6.3.3`, lalu tambahkan folder pub-cache `bin` ke PATH (Windows: `%LOCALAPPDATA%\Pub\Cache\bin`; Mac: `~/.pub-cache/bin`), sehingga bisa memanggil `melos run <script>`.
10. **Shorebird CLI.** Ikuti docs.shorebird.dev/getting-started. Windows (PowerShell): `Set-ExecutionPolicy RemoteSigned -scope CurrentUser; iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' | iex`. Mac: `curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash`. Lalu `shorebird login` dengan akun yang sudah diundang ke organisasi.

## 3.3 Verifikasi

Jalankan `flutter doctor -v`. Yang harus centang hijau: Flutter, Android toolchain, Android Studio, VS Code, Connected device. Di Mac juga Xcode. Item Chrome, Visual Studio (Windows desktop), dan Linux boleh merah karena tidak dipakai.

Jalankan juga `shorebird doctor`. Peringatan soal versi Flutter Shorebird boleh diabaikan: Shorebird memakai Flutter versinya sendiri, tapi skrip di repo selalu memaksa 3.38.7.

**Jebakan Windows:** kalau ada Dart standalone lain di PATH (mis. `C:\tools\dart-sdk`, Dart 3.8.1 di mesin lama), perintah `dart run melos` akan gagal karena repo butuh Dart 3.10. Pastikan folder `flutter\bin` berada di urutan lebih awal di PATH, atau pakai `flutter pub run melos ...`.

## 3.4 Cara menambah folder ke PATH

PATH adalah daftar folder tempat terminal mencari perintah. Setelah folder
ditambahkan, **tutup dan buka ulang terminal / VS Code** supaya berlaku.

**Windows:**

1. Tekan tombol Windows, ketik "environment variables", pilih
   "Edit the system environment variables".
2. Klik **Environment Variables...**.
3. Di bagian "User variables", pilih `Path` > **Edit** > **New**, lalu isi
   path folder, mis. `C:\Android\flutter\bin`.
4. Pakai **Move Up** supaya folder Flutter berada di atas folder Dart lain
   (lihat jebakan Windows di atas).
5. OK di semua jendela. Cek di terminal baru: `where flutter` lalu
   `flutter --version`.

**Mac (zsh, bawaan macOS):**

1. Buka Terminal, jalankan `nano ~/.zshrc`.
2. Tambahkan baris di akhir file, mis.
   `export PATH="$HOME/flutter/bin:$HOME/.pub-cache/bin:$PATH"`.
3. Simpan (Ctrl+O, Enter, Ctrl+X), lalu `source ~/.zshrc`.
4. Cek dengan `which flutter` lalu `flutter --version`.

## 3.5 Kebutuhan perangkat

- **Laptop development:** RAM 16 GB disarankan (emulator Android, Android
  Studio, dan VS Code cukup berat). Siapkan ruang disk kosong sekitar 40 GB
  untuk Flutter, Android SDK, emulator, Xcode, dan cache build.
- **Mac:** wajib untuk build, uji Simulator, dan rilis iOS. Mac Apple Silicon
  (M1 ke atas) jauh lebih cepat untuk build iOS.
- **HP uji:** minimal satu HP Android fisik dan satu iPhone. Push
  notification, biometric, kamera, dan dashcam tidak bisa diuji penuh di
  emulator/simulator.
- **Waktu instalasi pertama:** perkirakan setengah sampai satu hari kerja,
  terutama karena unduhan Xcode dan Android SDK besar.

---

[< 2. Akses, akun, dan file rahasia](02-akses-dan-rahasia.md) | [Daftar isi](../README.md) | [4. Struktur repo >](04-struktur-repo.md)
