# 2. Akses, akun, dan file rahasia

[< 1. Istilah dasar untuk pemula](01-istilah.md) | [Daftar isi](../README.md) | [3. Instalasi tools dari nol >](03-instalasi.md)

Tanpa daftar di bawah, penerus tidak bisa menjalankan app dengan benar, apalagi merilis. Serahkan **sebelum** hari terakhir, dan pastikan penerus sudah mencoba login ke setiap akun.

## 2.1 Akun dan layanan

| Layanan | Untuk apa | Yang perlu diberikan |
| --- | --- | --- |
| GitHub `FaizAmd22/bitrack-flutter` | Kode sumber | Undang penerus sebagai collaborator (atau transfer repo ke akun organisasi Treffix). |
| Google Play Console | Rilis Android FixTrack dan Bitrack (Bitrack Internal tidak di Play Store) | Undang email penerus di Users and permissions, minimal role Release manager. |
| Apple Developer + App Store Connect (Team ID `BT5HYZB4PV`) | Rilis iOS, signing | Undang penerus di App Store Connect > Users and Access, role App Manager atau Admin. Untuk signing otomatis di Xcode penerus juga butuh akses ke team developer yang sama. |
| Shorebird (console.shorebird.dev) | OTA patch | Undang penerus ke organisasi Shorebird yang memiliki 3 app (app\_id ada di `apps/<app>/shorebird.yaml`). |
| OneSignal | Push notification | Undang penerus ke organisasi OneSignal. Ada App ID terpisah untuk FixTrack dan Bitrack; Bitrack Internal belum punya (kosong). |
| Supabase (`svwlhxxlqekedafazwsj.supabase.co`) | Flag remote, mis. tombol demo/register di halaman login (tabel `app_settings`) | Akses project Supabase, atau minimal `service_role` key untuk mengubah flag. |
| Google Cloud (Maps API key) | Peta Google di Android dan iOS | Akses project Google Cloud pemilik key, untuk memantau kuota dan membatasi key. |
| Mettaxiot | Video dan audio dashcam live | Kredensial `METTAXIOT_*` (sudah ada di `.env`). Kontak vendor bila key diganti. |
| Backend tracking | API utama app | Kontak tim backend untuk `tracking.treffix.id`, `tracking-dev.treffix.id`, `bitrack-be.b-log.dev`, `bitrack-dev-be.treffix.id`. |
| Server OTP (Render) | OTP email untuk **ganti password**, di `https://bitrack-otp-be.onrender.com` | Akses akun Render yang menjalankan server, repo `FaizAmd22/Bitrack-Otp-be`, akun Redis, dan akun Brevo (pengirim email). Lihat 2.2. |
| GitHub Pages `FaizAmd22/privacy-policy-fixtrack` | Halaman kebijakan privasi FixTrack (`https://faizamd22.github.io/privacy-policy-fixtrack/`), wajib aktif untuk listing store | Transfer repo ke akun perusahaan atau undang penerus. Kalau repo dihapus, listing store bisa ditolak saat review berikutnya. |

## 2.2 Proyek lain yang terkait

Folder `BITRACK APP/` di mesin lama juga berisi proyek lain. Hanya dua yang
masih dipakai app Flutter ini:

| Proyek | Dipakai app Flutter? | Keterangan |
| --- | --- | --- |
| `bitrack-be-otp` (`github.com/FaizAmd22/Bitrack-Otp-be`) | **Ya** | Server Node.js + Redis + Brevo untuk `POST /otp/send` dan `/otp/verify`. |
| `privacy-policy-fixtrack` (`github.com/FaizAmd22/privacy-policy-fixtrack`) | **Ya** (listing store) | Halaman kebijakan privasi FixTrack. |
| `Bitrack/bitrack-mobile` (`github.com/FaizAmd22/bitrack-mobile`) | Tidak, tapi **keystore Bitrack + passwordnya ada di sini** | App Cordova lama yang digantikan app Flutter. Jangan dihapus sebelum keystore di-backup. |
| `flv-to-hls` (`github.com/FaizAmd22/flv-to-hls`) | Tidak | Konversi stream FLV ke HLS untuk iOS Safari di app lama. App Flutter memutar FLV langsung lewat media_kit. |
| `bitrack-v2`, `bitrack-v2-gitlab` (`gitlab.com/treffix1/bitrack-v2`), `Bitrack/treffix-fe` | Tidak | Proyek web / frontend lain. |

## 2.3 File rahasia yang TIDAK ada di git

File berikut sengaja di-ignore oleh `.gitignore`, jadi tidak ikut ter-clone. Kirim lewat jalur aman (password manager, drive terenkripsi), **jangan** lewat chat biasa atau email tanpa enkripsi.

| File | Lokasi di repo | Isi |
| --- | --- | --- |
| `.env` dan `.env.prod` | `apps/<app>/` (6 file) | URL server dan kunci API. Lihat [5. Konfigurasi](05-konfigurasi.md). |
| `key.properties` | `apps/<app>/android/` | Password dan alias keystore Android. |
| `upload-keystore.jks` | `apps/fixtrack/android/app/` dan `apps/bitrack_internal/android/app/` | Kunci signing Android FixTrack. Bitrack Internal memakai salinan file yang sama untuk menandatangani APK yang dibagikan langsung. |
| `android.keystore` (keystore Cordova lama) | di luar repo: `D:\Work\Treffix.id\BITRACK APP\Bitrack\bitrack-mobile\cordova\android.keystore` | Kunci signing Android **Bitrack**. Lihat [10. Keystore Android](10-signing-android.md). |
| `build.json` (proyek Cordova lama) | di luar repo: `...\Bitrack\bitrack-mobile\cordova\build.json` | Store password dan key password keystore Bitrack (field `storePassword` dan `password`). Sudah diverifikasi berfungsi 15 Okt 2026. |
| `local.properties` | `apps/<app>/android/` | Path Android SDK mesin lokal + `GOOGLE_MAPS_API_KEY` untuk Android. Path SDK dibuat ulang otomatis, tapi baris `GOOGLE_MAPS_API_KEY` harus ditambah manual. |
| Folder `rilis/` | root repo | Salinan AAB/IPA yang sudah di-release ke Shorebird. Dibutuhkan bila ingin memverifikasi build lama. |

Catatan: Google Maps API key untuk iOS ada di `apps/<app>/ios/Flutter/Env.xcconfig` dan **sudah ter-commit** di git sejak sebelum monorepo. Kalau key itu ingin dicabut dari repo, key harus dirotasi di Google Cloud; menghapus filenya saja tidak cukup karena key-nya masih ada di riwayat git.

## 2.4 Dampak kalau sesuatu hilang

| Yang hilang | Dampak | Bisa dipulihkan? |
| --- | --- | --- |
| Keystore Android / passwordnya | Update ke Play Store ditolak; APK Bitrack Internal baru tidak bisa dipasang di atas versi lama. | Untuk listing Play: ya, lewat reset upload key oleh pemilik akun (1-2 hari). Untuk APK Bitrack Internal: tidak; user harus uninstall dulu. |
| File `.env` | App tidak bisa di-build (asset tidak ditemukan) atau tidak bisa menghubungi server. | Ya, kalau URL dan key diketahui; tanyakan tim backend dan vendor. |
| Akses Play Console / App Store Connect | Tidak bisa merilis sama sekali. | Ya, lewat pemilik akun perusahaan (Account Owner). Pastikan akun perusahaan, bukan akun pribadi, yang menjadi pemilik. |
| Akses Shorebird | Tidak bisa membuat patch. App tetap jalan normal. | Ya, lewat pemilik organisasi Shorebird. |
| Folder `rilis/` | Tidak bisa memverifikasi binary release lama dengan `sb:verify`. Patch tetap bisa dibuat. | Tidak, tapi tidak fatal. |

## 2.5 Cara mengirim file rahasia

1. Kumpulkan semua file di tabel 2.3 dalam satu folder.
2. Kompres dengan password (mis. 7-Zip, enkripsi AES-256), atau simpan di
   password manager tim (1Password, Bitwarden) sebagai lampiran.
3. Kirim password arsip lewat jalur yang **berbeda** dari arsipnya
   (mis. arsip lewat drive, password lewat telepon).
4. Setelah penerus mengonfirmasi bisa build, simpan salinan kedua di tempat
   yang dikelola perusahaan, bukan di laptop pribadi.

## 2.6 Kepemilikan dan kontak (diisi pemilik lama sebelum handover)

Tabel ini **harus diisi** sebelum serah terima. Tanpa ini, penerus tidak tahu
harus menghubungi siapa saat akses hilang atau layanan bermasalah.

| Akun / pihak | Pemilik (Account Owner) | Email login | Biaya / tanggal perpanjangan |
| --- | --- | --- | --- |
| Google Play Console | BELUM DIISI | BELUM DIISI | Sekali bayar (tidak ada perpanjangan) |
| Apple Developer Program (Team `BT5HYZB4PV`) | BELUM DIISI | BELUM DIISI | Tahunan, BELUM DIISI tanggal jatuh tempo. Kalau lewat, app hilang dari App Store. |
| GitHub (repo `bitrack-flutter`, `Bitrack-Otp-be`, `privacy-policy-fixtrack`, `bitrack-mobile`) | `FaizAmd22` (akun pribadi) | BELUM DIISI | Disarankan transfer ke organisasi perusahaan |
| Shorebird | BELUM DIISI | BELUM DIISI | BELUM DIISI paket / batas |
| OneSignal | BELUM DIISI | BELUM DIISI | BELUM DIISI |
| Supabase | BELUM DIISI | BELUM DIISI | BELUM DIISI (paket gratis di-pause otomatis bila tidak ada aktivitas) |
| Render (server OTP) | BELUM DIISI | BELUM DIISI | BELUM DIISI |
| Brevo (email OTP) + Redis | BELUM DIISI | BELUM DIISI | BELUM DIISI |
| Google Cloud (Maps API key) | BELUM DIISI | BELUM DIISI | Bayar per pemakaian, BELUM DIISI akun billing |

| Kontak | Nama | Untuk urusan |
| --- | --- | --- |
| Tim backend | BELUM DIISI | Endpoint API, akun uji, perubahan server |
| Vendor dashcam (Mettaxiot / Stonkam) | BELUM DIISI | Kredensial dan masalah video/audio |
| Pemilik produk / atasan | BELUM DIISI | Keputusan fitur, rilis, dan listing store |
| Pemilik lama (Faizhal) | BELUM DIISI | Pertanyaan darurat setelah handover |

## 2.7 Checklist serah terima akses

- [ ] Penerus bisa clone repo dan push ke branch baru
- [ ] Penerus bisa membuka FixTrack dan Bitrack di Google Play Console
- [ ] Penerus bisa membuka ketiga app di App Store Connect dan TestFlight
- [ ] Penerus sudah login Shorebird CLI (`shorebird login`) dan melihat ketiga app
- [ ] Penerus punya akses OneSignal, Supabase, dan Google Cloud
- [ ] Penerus punya akses Render, Redis, dan Brevo (server OTP), atau server OTP sudah dipindah ke infrastruktur perusahaan
- [ ] Repo GitHub pribadi yang masih dipakai (`bitrack-flutter`, `Bitrack-Otp-be`, `privacy-policy-fixtrack`) sudah ditransfer atau penerus sudah diundang
- [ ] Tabel 2.6 (kepemilikan dan kontak) sudah terisi, tidak ada lagi "BELUM DIISI"
- [ ] Ke-6 file `.env` / `.env.prod` sudah diterima
- [ ] Keystore FixTrack/Bitrack Internal (`upload-keystore.jks`) dan keystore Bitrack (`android.keystore`) + semua password sudah diterima, dan sudah ada backup di tempat kedua
- [ ] Penerus sudah berhasil build release Android minimal satu app (bukti keystore benar)

---

[< 1. Istilah dasar untuk pemula](01-istilah.md) | [Daftar isi](../README.md) | [3. Instalasi tools dari nol >](03-instalasi.md)
