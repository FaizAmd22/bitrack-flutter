// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'FixTrack';

  @override
  String get language => 'Bahasa';

  @override
  String get english => 'Inggris';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get navTracker => 'Tracker';

  @override
  String get navVehicle => 'Kendaraan';

  @override
  String get navNotification => 'Notifikasi';

  @override
  String get navProfile => 'Profil';

  @override
  String get notifUrgent => 'Urgen';

  @override
  String get notifSummary => 'Ringkasan';

  @override
  String get notifNoData => 'Tidak ada data peringatan';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailPlaceholder => 'Masukkan email ...';

  @override
  String get passwordPlaceholder => 'Masukkan password ...';

  @override
  String get emailRequired => 'Email tidak boleh kosong';

  @override
  String get emailInvalid => 'Format email tidak valid';

  @override
  String fieldRequired(Object name) {
    return '$name tidak boleh kosong';
  }

  @override
  String get addFingerprint => 'Tambahkan Fingerprint';

  @override
  String get addFingerprintDesc =>
      'Apakah Anda ingin menambahkan fingerprint untuk login selanjutnya?';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get biometricLoginLabel => 'Login menggunakan metode biometrik';

  @override
  String get faceIdLoginLabel => 'Login menggunakan Face ID';

  @override
  String get biometricNotSupported =>
      'Perangkat tidak mendukung login biometrik';

  @override
  String get biometricReason => 'Gunakan biometrik untuk login';

  @override
  String get biometricCredNotFound => 'Data login biometrik tidak ditemukan';

  @override
  String get loginFailedTryAgain => 'Login gagal, coba lagi';

  @override
  String errorPrefix(Object message) {
    return 'Terjadi error: $message';
  }

  @override
  String get notificationSettings => 'Pengaturan Notifikasi';

  @override
  String get alert => 'Peringatan';

  @override
  String get softwareUpdate => 'Pembaruan Perangkat Lunak';

  @override
  String get profileChangePassword => 'Ubah Password';

  @override
  String get profileNotificationSetting => 'Pengaturan Notifikasi';

  @override
  String get profileLanguage => 'Bahasa';

  @override
  String get signOut => 'Keluar';

  @override
  String get signOutTitle => 'Keluar Akun';

  @override
  String get signOutDesc => 'Apakah Anda yakin ingin keluar dari akun?';

  @override
  String get logout => 'Keluar';

  @override
  String get searchLicensePlate => 'Cari Plat Nomor Kendaraan ...';

  @override
  String get noVehicleYet => 'Belum ada data kendaraan';

  @override
  String get dataNotFound => 'Data tidak ditemukan';

  @override
  String get showPlate => 'Tampilkan Plat';

  @override
  String get hidePlate => 'Sembunyikan Plat';

  @override
  String get vehicleDataCantLoaded => 'Data kendaraan tidak bisa dimuat.';

  @override
  String get pleaseTryAgain => 'Silakan coba lagi.';

  @override
  String get tryAgain => 'Coba lagi.';

  @override
  String get vehicleInformation => 'Informasi Kendaraan';

  @override
  String get deviceInformation => 'Informasi Perangkat';

  @override
  String get review => 'Tinjau';

  @override
  String get tabInformation => 'Informasi';

  @override
  String get tabStatus => 'Status';

  @override
  String get tabSensor => 'Sensor';

  @override
  String get vehicleIdNotAvailableDesc =>
      'vehicle_id belum tersedia.\nTutup modal lalu buka lagi dari Vehicle Detail.';

  @override
  String get failedLoadData => 'Gagal memuat data';

  @override
  String get retry => 'Coba lagi';

  @override
  String get vehicleInfoGpsDate => 'Tanggal GPS';

  @override
  String get vehicleInfoFleetGroup => 'Grup Armada';

  @override
  String get vehicleInfoLicensePlate => 'Plat Nomor';

  @override
  String get vehicleInfoImei => 'IMEI';

  @override
  String get vehicleInfoLatitude => 'Latitude';

  @override
  String get vehicleInfoLongitude => 'Longitude';

  @override
  String get vehicleInfoGoogleMap => 'Google Map';

  @override
  String get vehicleInfoStreetView => 'Street View';

  @override
  String get showGoogleMap => 'Tampilkan Google Map';

  @override
  String get showStreetView => 'Tampilkan Street View';

  @override
  String get vehicleStatusSpeed => 'Kecepatan';

  @override
  String get vehicleStatusTotalOdometer => 'Total Odometer';

  @override
  String get vehicleStatusInternalBattery => 'Baterai Internal';

  @override
  String get vehicleStatusExternalBattery => 'Baterai Eksternal';

  @override
  String get vehicleSensorFuel => 'Bahan Bakar';

  @override
  String get vehicleSensorDirection => 'Arah';

  @override
  String get vehicleSensorHumidity => 'Kelembapan';

  @override
  String get vehicleSensorLeftDoor => 'Pintu Kiri';

  @override
  String get vehicleSensorRightDoor => 'Pintu Kanan';

  @override
  String get vehicleSensorBackDoor => 'Pintu Belakang';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Nonaktif';

  @override
  String get createdAt => 'Dibuat pada';

  @override
  String get addNewVehicleTitle => 'Tambah Kendaraan Baru';

  @override
  String get updateVehicleTitle => 'Ubah Kendaraan';

  @override
  String get addVehicleCta => 'Tambah Kendaraan';

  @override
  String get updateVehicleCta => 'Ubah Kendaraan';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get addVehicleConfirmAddTitle => 'Tambah Kendaraan';

  @override
  String get addVehicleConfirmAddDesc =>
      'Apakah Anda yakin ingin menambahkan kendaraan ini?';

  @override
  String get addVehicleConfirmUpdateTitle => 'Perbarui Kendaraan';

  @override
  String get addVehicleConfirmUpdateDesc =>
      'Apakah Anda yakin ingin memperbarui kendaraan ini?';

  @override
  String get createTodo => 'Tambah (TODO)';

  @override
  String get updateTodo => 'Ubah (TODO)';

  @override
  String get plateNumber => 'Plat Nomor';

  @override
  String get plateNumberHint => 'Masukkan plat nomor kendaraan ...';

  @override
  String get fieldCantEmpty => 'Field tidak boleh kosong';

  @override
  String get brand => 'Merek';

  @override
  String get model => 'Model';

  @override
  String get selectBrandHint => 'Pilih merek ...';

  @override
  String get selectModelHint => 'Pilih model ...';

  @override
  String get selectBrandFirst => 'Pilih merek terlebih dahulu';

  @override
  String get selectModelFirst => 'Pilih model terlebih dahulu';

  @override
  String get selectTypeHint => 'Pilih tipe ...';

  @override
  String get noTypeAvailable => 'Tipe tidak tersedia';

  @override
  String get vehicleType => 'Tipe';

  @override
  String get vehicleTypeHint => 'Masukkan tipe kendaraan ...';

  @override
  String get vehicleYear => 'Tahun';

  @override
  String get vehicleYearHint => 'Masukkan tahun kendaraan ...';

  @override
  String get vehicleColor => 'Warna';

  @override
  String get vehicleColorHint => 'Masukkan warna kendaraan ...';

  @override
  String get vehicleCategory => 'Kategori Kendaraan';

  @override
  String get selectVehicleCategoryHint => 'Pilih kategori kendaraan ...';

  @override
  String get odometer => 'Odometer (M)';

  @override
  String get odometerHint => 'Masukkan odometer kendaraan ...';

  @override
  String get vin => 'VIN';

  @override
  String get vinHint => 'Masukkan VIN kendaraan ...';

  @override
  String get engineNumber => 'Nomor Mesin';

  @override
  String get engineNumberHint => 'Masukkan nomor mesin kendaraan ...';

  @override
  String get next => 'Selanjutnya';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get installationDate => 'Tanggal Instalasi';

  @override
  String get installationDateHint => 'Pilih tanggal instalasi ...';

  @override
  String get deviceType => 'Tipe Perangkat';

  @override
  String get deviceTypeHint => 'Pilih tipe perangkat';

  @override
  String get deviceModel => 'Model Perangkat';

  @override
  String get deviceModelHint => 'Pilih model perangkat ...';

  @override
  String get simCardNumber => 'Nomor SIM Card';

  @override
  String get simCardNumberHint => 'Masukkan Nomor SIM Card...';

  @override
  String get imeiObdNumber => 'Nomor IMEI OBD';

  @override
  String get imeiObdNumberHint => 'Masukkan Nomor IMEI OBD...';

  @override
  String get otpEnterVerificationCodeTitle => 'Masukkan Kode Verifikasi';

  @override
  String otpSentToEmail(Object email) {
    return 'Kode verifikasi telah dikirim ke\n$email';
  }

  @override
  String get otpEnter5Digits => 'Silakan masukkan kode 5 digit.';

  @override
  String get otpInvalidTryAgain =>
      'Kode verifikasi tidak valid. Silakan coba lagi.';

  @override
  String get otpNotReceivedEmailPrefix => 'Belum menerima email? ';

  @override
  String get otpTryAgain => 'Kirim Ulang.';

  @override
  String otpTryAgainCountdown(Object seconds) {
    return 'Kirim Ulang. (${seconds}d)';
  }

  @override
  String get otpCodeResentDummy => 'Kode dikirim ulang.';

  @override
  String get otpVerifyCodeBtn => 'Verifikasi Kode';

  @override
  String get passwordNewTitle => 'Password Baru';

  @override
  String get passwordNewHint => 'Masukkan password baru ...';

  @override
  String get passwordReEnterTitle => 'Ulangi Password Baru';

  @override
  String get passwordReEnterHint => 'Masukkan ulang password baru ...';

  @override
  String get passwordRuleMin8 => 'Minimal 8 karakter';

  @override
  String get passwordRuleUpper => 'Harus ada minimal 1 huruf besar (A-Z)';

  @override
  String get passwordRuleNumber => 'Harus ada minimal 1 angka (0-9)';

  @override
  String get passwordRuleSymbol => 'Harus ada minimal 1 simbol (!, @, #, dll.)';

  @override
  String get passwordFillAllFields => 'Silakan isi semua field.';

  @override
  String get passwordNotMeetRequirements =>
      'Password belum memenuhi ketentuan.';

  @override
  String get passwordNotMatch => 'Password tidak sama.';

  @override
  String get passwordUpdatedDummy => 'Password berhasil diperbarui.';

  @override
  String get passwordUpdateFailed =>
      'Gagal memperbarui password. Silakan coba lagi.';

  @override
  String get passwordChangeSaveBtn => 'Ubah & Simpan Password Baru';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterStartDate => 'Tanggal Mulai';

  @override
  String get filterEndDate => 'Tanggal Akhir';

  @override
  String get filterFleetGroup => 'Fleet Group';

  @override
  String get filterVerifStatus => 'Status Verifikasi';

  @override
  String get filterAlertType => 'Tipe Peringatan';

  @override
  String get filterApply => 'Terapkan Filter';

  @override
  String get filterClear => 'Hapus Filter';

  @override
  String get filterChooseStartDate => 'Pilih tanggal mulai';

  @override
  String get filterChooseEndDate => 'Pilih tanggal akhir';

  @override
  String get filterChooseFleetGroup => 'Pilih fleet group';

  @override
  String get filterChooseVerifStatus => 'Pilih status verifikasi';

  @override
  String get filterChooseAlertType => 'Pilih tipe peringatan';

  @override
  String get filterVerified => 'Terverifikasi';

  @override
  String get filterNotYetVerified => 'Belum Terverifikasi';

  @override
  String get filterUnverified => 'Tidak Terverifikasi';

  @override
  String get filterNeedVerifications => 'Perlu Verifikasi';

  @override
  String get filterNeedValidations => 'Perlu Validasi';

  @override
  String get filterValidated => 'Tervalidasi';

  @override
  String get filterSearch => 'Cari';

  @override
  String get filterNoOptions => 'Tidak ada pilihan';

  @override
  String get filterAllFleetGroup => 'Semua Fleet Group';

  @override
  String get filterAllAlertType => 'Semua Tipe Peringatan';

  @override
  String get gpsDate => 'Tanggal GPS';

  @override
  String get alertType => 'Jenis Peringatan';

  @override
  String get speed => 'Kecepatan';

  @override
  String get addVehicleTitle => 'Tambah Kendaraan';

  @override
  String get addVehicleIdentifierTitle => 'Plat Nomor';

  @override
  String get addVehicleIdentifierPlaceholder => 'Masukkan plat nomor';

  @override
  String get addVehicleRequiredError => 'Plat nomor wajib diisi';

  @override
  String get addVehiclePlateExistsError => 'Plat nomor sudah terdaftar';

  @override
  String get addVehicleCheckFailedError =>
      'Gagal memeriksa plat nomor. Silakan coba lagi';

  @override
  String get addVehicleContinue => 'Lanjutkan';

  @override
  String get addVehicleChecking => 'Memeriksa...';

  @override
  String get successAddVehicle => 'Kendaraan berhasil ditambahkan';

  @override
  String get successUpdateVehicle => 'Kendaraan berhasil diperbarui';

  @override
  String get errFailedAdd => 'Gagal menambahkan kendaraan. Silakan coba lagi';

  @override
  String get errFailedUpdate =>
      'Gagal memperbarui kendaraan. Silakan coba lagi';

  @override
  String get errVinUnique => 'VIN sudah terdaftar. Silakan masukkan yang lain';

  @override
  String get selectFleetGroupHint => 'Pilih Fleet Group';

  @override
  String get loading => 'Memuat...';

  @override
  String get seeNotesVerification => 'Lihat Catatan Verifikasi';

  @override
  String get seeNotesValidation => 'Lihat Catatan Validasi';

  @override
  String get showMapCoordinate => 'Lihat Koordinat Peta';

  @override
  String get alertNotes => 'Catatan Peringatan';

  @override
  String get notes => 'Catatan';

  @override
  String get noNotes => 'Tidak ada catatan';

  @override
  String get noMedia => 'Tidak ada media';

  @override
  String get mapCoordinate => 'Koordinat Peta';

  @override
  String get copyCoordinate => 'Koordinat disalin';

  @override
  String get filterAllStatus => 'Semua Status';
}
