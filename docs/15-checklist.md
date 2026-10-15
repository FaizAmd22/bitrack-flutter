# 15. Checklist rilis dan patch

[< 14. Shorebird: release dan patch](14-shorebird.md) | [Daftar isi](../README.md) | [16. Masalah umum dan hal terbuka >](16-masalah-dan-hal-terbuka.md)

Salin checklist ini setiap kali merilis. Checklist ini sengaja tidak
mengulang perintah: setiap butir menunjuk langkah yang menjelaskannya, dan
perintahnya ada di [Daftar perintah](../README.md#daftar-perintah).

## 15.1 Rilis store (per app, per platform)

- [ ] Kode di branch rilis; `analyze` dan `test` lolos
- [ ] Diuji di HP fisik dengan server produksi (`<app>:prod`)
- [ ] (iOS) Bundle id sesuai listing tujuan ([6.3](06-bundle-id.md#63-cara-pindah-antara-unlisted-dan-public))
- [ ] Versi dinaikkan sesuai aturan ([12.5](12-rilis-android.md#125-menentukan-nomor-versi))
- [ ] Commit + tag `<app>-<versi>` di-push
- [ ] (Android) Keystore + `key.properties` yang benar ada ([10.1](10-signing-android.md#101-peta-keystore-per-app))
- [ ] `sb:release` berhasil: ada baris `Published Release <versi>`
- [ ] (Android) `sb:verify` keluar `COCOK`
- [ ] File yang di-upload berasal dari `rilis/`
- [ ] Release notes diisi; flag demo aktif bila reviewer butuh akses
- [ ] Submit review dan pantau sampai live ([12.1](12-rilis-android.md#121-langkah-demi-langkah) / [13.1](13-rilis-ios.md#131-langkah-demi-langkah))
- [ ] Folder `rilis/` di-backup

## 15.2 Patch Shorebird

Langkah lengkap: [14.4](14-shorebird.md#144-alur-patch-langkah-demi-langkah).

- [ ] Checkout tag release yang dituju, buat branch hotfix
- [ ] Perubahan hanya kode Dart ([14.2](14-shorebird.md#142-yang-bisa-dan-tidak-bisa-di-patch))
- [ ] `version:` tidak diubah
- [ ] Patch ke staging, catat nomor patch
- [ ] Preview staging di HP, cek nomor patch di halaman Profil
- [ ] Promote nomor patch itu
- [ ] Ulangi untuk platform lain bila perlu (Android dan iOS punya patch masing-masing)
- [ ] Merge hotfix ke `main`

## 15.3 APK Bitrack Internal (Android)

Langkah lengkap: [12.4](12-rilis-android.md#124-bitrack-internal-android-apk-dibagikan-langsung).

- [ ] Build number lebih besar dari APK terakhir
- [ ] Keystore `upload-keystore.jks` + `key.properties` ada
- [ ] SHA1 APK = `43:B3:20...`
- [ ] APK diberi nama berisi versi, mis. `bitrack-internal-1.0.1+2.apk`
- [ ] Dicoba dipasang di atas versi lama di satu HP sebelum dibagikan

## 15.4 Sebelum menyerahkan pekerjaan ke orang lain

- [ ] Semua perubahan sudah di-commit dan di-push
- [ ] Tag rilis sudah di-push (`git push --tags`)
- [ ] Folder `rilis/` dan keystore sudah di-backup
- [ ] Dokumentasi diperbarui bila ada perubahan proses, versi, atau akun

---

[< 14. Shorebird: release dan patch](14-shorebird.md) | [Daftar isi](../README.md) | [16. Masalah umum dan hal terbuka >](16-masalah-dan-hal-terbuka.md)
