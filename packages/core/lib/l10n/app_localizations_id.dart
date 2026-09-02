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
  String get chinese => 'Mandarin';

  @override
  String get japanese => 'Jepang';

  @override
  String get korean => 'Korea';

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
      'Apakah Anda ingin menyimpan fingerprint untuk mempercepat login berikutnya?';

  @override
  String get addFaceId => 'Tambahkan Face ID';

  @override
  String get addFaceIdDesc =>
      'Apakah Anda ingin menyimpan Face ID untuk mempercepat login berikutnya?';

  @override
  String get addBiometric => 'Tambahkan Biometrik';

  @override
  String get addBiometricDesc =>
      'Apakah Anda ingin menyimpan autentikasi biometrik untuk mempercepat login berikutnya?';

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
  String get odometer => 'Odometer (KM)';

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

  @override
  String get registerLinkPrefix => 'Belum punya akun? ';

  @override
  String get registerLinkAction => 'Daftar di sini';

  @override
  String get registerTitle => 'Daftar Akun';

  @override
  String get registerSubtitle =>
      'Lengkapi data di bawah untuk membuat akun baru';

  @override
  String get registerFullName => 'Nama Lengkap';

  @override
  String get registerFullNamePlaceholder => 'Masukkan nama lengkap ...';

  @override
  String get registerPhone => 'No. Handphone';

  @override
  String get registerPhonePlaceholder => 'Masukkan no. handphone ...';

  @override
  String get registerPhoneInvalid => 'Nomor telepon hanya boleh berisi angka';

  @override
  String get registerCompanyName => 'Nama Perusahaan (Opsional)';

  @override
  String get registerCompanyNamePlaceholder => 'Masukkan nama perusahaan ...';

  @override
  String get registerSubmitBtn => 'Daftar';

  @override
  String get registerPendingTitle => 'Menunggu Konfirmasi';

  @override
  String get registerPendingDesc =>
      'Terima kasih telah mendaftar. Konfirmasi akan dikirimkan ke email Anda setelah pendaftaran disetujui.';

  @override
  String get registerPendingOkBtn => 'Oke, Mengerti';

  @override
  String get navWorkOrder => 'Work Order';

  @override
  String get woSearchPlaceholder => 'Cari Fleet Group ...';

  @override
  String get woNoDataTitle => 'Belum Ada Work Order';

  @override
  String get woNoDataMessage =>
      'Anda belum memiliki work order saat ini.\nBuat yang baru untuk memulai.';

  @override
  String get woOptionDetails => 'Lihat Detail Pekerjaan';

  @override
  String get woOptionDelete => 'Hapus Pekerjaan';

  @override
  String get woDeleteTitle => 'Hapus Work Order';

  @override
  String get woDeleteSubtitle =>
      'Apakah Anda yakin ingin menghapus work order ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get woDeleteConfirm => 'Hapus';

  @override
  String get woDeleteSuccess => 'Berhasil Dihapus!';

  @override
  String get woDeleteFailed => 'Gagal Menghapus!';

  @override
  String get woDetailDeleteTitle => 'Hapus Pekerjaan';

  @override
  String get woDetailDeleteSubtitle =>
      'Apakah Anda yakin ingin menghapus pekerjaan ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get woFleetGroup => 'Fleet Group';

  @override
  String get woFleetGroupPlaceholder => 'Pilih Fleet Group';

  @override
  String get woTechnician => 'Nama Teknisi';

  @override
  String get woTechnicianPlaceholder => 'Pilih Nama Teknisi';

  @override
  String get woDate => 'Tanggal';

  @override
  String get woDatePlaceholder => 'Pilih tanggal';

  @override
  String get woCreateTitle => 'Buat Work Order';

  @override
  String get woCreate => 'Buat';

  @override
  String get woCreateFailed => 'Gagal membuat work order';

  @override
  String get woWorkListTitle => 'Daftar Pekerjaan';

  @override
  String get woWorkListEmptyTitle => 'Belum Ada Work Order';

  @override
  String get woWorkListEmptyMessage =>
      'Anda belum memiliki work order saat ini.\nBuat yang baru untuk memulai.';

  @override
  String get woAssignButton => 'Tugaskan Pekerjaan';

  @override
  String get woAssignTitle => 'Buat Work Order';

  @override
  String get woWorkCategory => 'Kategori Pekerjaan';

  @override
  String get woWorkCategoryPlaceholder => 'Pilih Kategori Work Order';

  @override
  String get woWorkType => 'Tipe Pekerjaan';

  @override
  String get woWorkTypePlaceholder => 'Pilih Tipe Work Order';

  @override
  String get woWorkDate => 'Tanggal Pekerjaan';

  @override
  String get woEvidenceNotUploaded => 'Bukti belum diunggah.';

  @override
  String get woOdometerNotFilled => 'Odometer belum diisi.';

  @override
  String get woGpsActive => 'GPS aktif.';

  @override
  String get woGpsNotActive => 'GPS belum aktif.';

  @override
  String get woDetailsTitle => 'Detail Pekerjaan';

  @override
  String get woTabDetails => 'Detail';

  @override
  String get woTabEvidence => 'Bukti';

  @override
  String get woTabNotes => 'Catatan';

  @override
  String get woDetailsEdit => 'Edit Detail Pekerjaan';

  @override
  String get woDetailsSave => 'Simpan';

  @override
  String get woSavedSuccess => 'Data berhasil disimpan';

  @override
  String get woSavedFailed => 'Gagal menyimpan data';

  @override
  String get woCompleteSuccess => 'Pekerjaan berhasil diselesaikan';

  @override
  String get woCompleteFailed => 'Gagal menyelesaikan pekerjaan';

  @override
  String get woLeaveTitle => 'Apakah Anda yakin ingin keluar dari halaman ini?';

  @override
  String get woLeaveMessage => 'Data yang belum disimpan akan hilang';

  @override
  String get woErrorBeforeImage => 'Bukti Sebelum Instalasi wajib diisi';

  @override
  String get woErrorAfterImage => 'Bukti Setelah Instalasi wajib diisi';

  @override
  String get woErrorNotes => 'Catatan wajib diisi';

  @override
  String get woActionSaveDraft => 'Simpan sebagai Draft';

  @override
  String get woActionMarkComplete => 'Tandai sebagai Selesai';

  @override
  String get woWorkInformation => 'Informasi Detail Pekerjaan';

  @override
  String get woInspectionInformation => 'Informasi Maintenance';

  @override
  String get woDeviceInformation => 'Informasi Perangkat';

  @override
  String get woEvidenceBefore => 'Bukti Sebelum Instalasi';

  @override
  String get woEvidenceAfter => 'Bukti Setelah Instalasi';

  @override
  String get woEvidenceTakeOrUpload => 'Ambil atau Upload Foto';

  @override
  String get woEvidenceUploadTitle => 'Upload Bukti';

  @override
  String get woEvidenceProofTitle => 'Bukti';

  @override
  String get woEvidenceTakePhoto => 'Ambil Foto';

  @override
  String get woEvidenceFromGallery => 'Pilih dari Galeri';

  @override
  String get woEvidenceView => 'Lihat Foto';

  @override
  String get woEvidenceReplace => 'Ganti Foto';

  @override
  String get woEvidenceDelete => 'Hapus Foto';

  @override
  String get woEvidenceInvalidFormat =>
      'Format file tidak didukung. Gunakan JPG, JPEG atau PNG.';

  @override
  String get woEvidenceProcessFailed => 'Gagal memproses gambar';

  @override
  String get woNotesTitle => 'Catatan';

  @override
  String get woNotesPlaceholder =>
      'Deskripsikan pekerjaan yang telah dilakukan...';

  @override
  String get woJobCategory => 'Kategori Pekerjaan';

  @override
  String get woJobType => 'Tipe Pekerjaan';

  @override
  String get woLicensePlate => 'Plat Nomor';

  @override
  String get woLicensePlatePlaceholder => 'Masukkan Plat Nomor ...';

  @override
  String get woLicensePlateRequired => 'Plat nomor wajib diisi';

  @override
  String get woUseChassisNumber => 'Gunakan Nomor Rangka';

  @override
  String get woChassisNumber => 'Nomor Rangka';

  @override
  String get woChassisNumberPlaceholder => 'cth. MHFJB8BS0AK000000';

  @override
  String get woOdometer => 'Odometer';

  @override
  String get woOdometerPlaceholder => 'Masukkan Odometer ...';

  @override
  String get woOdometerNumeric => 'Odometer harus berupa angka';

  @override
  String get woDeviceCondition => 'Kondisi Perangkat';

  @override
  String get woDeviceConditionPlaceholder => 'Masukkan Kondisi Perangkat ...';

  @override
  String get woDeviceType => 'Tipe Perangkat';

  @override
  String get woDeviceModel => 'Model Perangkat';

  @override
  String get woDeviceModelPlaceholder => 'Pilih Model Perangkat';

  @override
  String get woDeviceModelRequired => 'Model perangkat wajib diisi';

  @override
  String get woSimCardNumber => 'Nomor SIM Card';

  @override
  String get woSimCardNumberOptional => 'Nomor SIM Card (Opsional)';

  @override
  String get woSimCardNumberPlaceholder => 'Masukkan Nomor SIM Card ...';

  @override
  String get woSimCardNumeric => 'Nomor SIM card harus berupa angka';

  @override
  String get woImei => 'Nomor IMEI OBD';

  @override
  String get woImeiPlaceholder => 'Masukkan Nomor IMEI OBD ...';

  @override
  String get woImeiNumeric => 'IMEI harus berupa angka';

  @override
  String get woImeiMaxLength => 'IMEI maksimal 15 digit';

  @override
  String get woDashcamType => 'Tipe Dashcam';

  @override
  String get woDashcamTypePlaceholder => 'Pilih Tipe Dashcam';

  @override
  String get woDashcamTypeRequired => 'Tipe dashcam wajib diisi';

  @override
  String get woDashcamImei => 'Dashcam IMEI';

  @override
  String get woDashcamImeiPlaceholder => 'Masukkan Nomor Dashcam IMEI';

  @override
  String get woDashcamImeiNumeric => 'Dashcam IMEI harus berupa angka';

  @override
  String get woCameraPosition => 'Posisi Kamera';

  @override
  String get woCameraPositionPlaceholder => 'Pilih Posisi Kamera';

  @override
  String get woCameraPositionRequired => 'Posisi kamera wajib diisi';

  @override
  String get woSensorType => 'Tipe Sensor';

  @override
  String get woSensorTypePlaceholder => 'Pilih Tipe Sensor';

  @override
  String get woSensorTypeRequired => 'Tipe sensor wajib diisi';

  @override
  String get woSensorSerialNumber => 'Nomor Seri';

  @override
  String get woSensorSerialNumberPlaceholder => 'Masukkan Nomor Seri';

  @override
  String get woSensorPosition => 'Posisi Sensor';

  @override
  String get woSensorPositionPlaceholder => 'Pilih Posisi Sensor';

  @override
  String get woSensorPositionRequired => 'Posisi sensor wajib diisi';

  @override
  String get woSimReplacementTitle => 'Nomor SIM Card Baru';

  @override
  String get woSimReplacementPlaceholder => 'Masukkan Nomor SIM Card Baru ...';

  @override
  String get woInspectionAction => 'Tindakan';

  @override
  String get woInspectionActionPlaceholder => 'Pilih Tindakan Maintenance';

  @override
  String get woInspectionResult => 'Hasil Maintenance';

  @override
  String get woInspectionResultPlaceholder =>
      'Berikan Detail Hasil Maintenance ...';

  @override
  String get woCurrentDeviceTitle => 'Informasi Perangkat Saat Ini';

  @override
  String get woCurrentDeviceType => 'Tipe Perangkat';

  @override
  String get woCurrentDeviceModel => 'Model Perangkat';

  @override
  String get woCurrentDeviceSimCard => 'Nomor SIM Card';

  @override
  String get woCurrentDeviceImei => 'Nomor IMEI OBD';

  @override
  String get woReviewWorkDetails => 'Informasi Detail Pekerjaan';

  @override
  String get woStepDetails => 'Informasi Detail Pekerjaan';

  @override
  String get woStepInformation => 'Informasi Perangkat';

  @override
  String get woStepInspection => 'Informasi Maintenance';

  @override
  String get woStepReview => 'Tinjauan';

  @override
  String get woStepPrev => 'Sebelumnya';

  @override
  String get woStepNext => 'Lanjut';

  @override
  String get woStepSubmit => 'Kirim Work Order';

  @override
  String get woCreateDetailTitle => 'Buat Work Order';

  @override
  String get woUpdateDetailTitle => 'Edit Work Order';

  @override
  String get woSubmitConfirmTitle => 'Konfirmasi Work Order';

  @override
  String get woSubmitConfirmMessage =>
      'Harap tinjau detail dengan cermat. Konfirmasi bahwa informasi work order sudah benar dan siap untuk diproses.';

  @override
  String get woCreateDetailSuccess => 'Berhasil menambahkan detail!';

  @override
  String get woCreateDetailFailed => 'Gagal menambahkan detail!';

  @override
  String get woUpdateDetailSuccess => 'Detail work order berhasil diperbarui';

  @override
  String get woUpdateDetailFailed => 'Gagal memperbarui detail work order';

  @override
  String get woVehicleInfoFailed => 'Gagal mengambil informasi kendaraan';

  @override
  String get vehicleCategoryBus => 'Bus';

  @override
  String get vehicleCategoryPassenger => 'Penumpang';

  @override
  String get vehicleCategoryTruck => 'Truk';

  @override
  String get vehicleCategoryChiller => 'Chiller';

  @override
  String get vehicleCategoryFreezer => 'Freezer';

  @override
  String get vehicleCategoryChillerFreezer => 'Chiller & Freezer';

  @override
  String get vehicleCategoryFreezerChiller => 'Freezer & Chiller';

  @override
  String get periodicMetricIgnition => 'Ignition';

  @override
  String get periodicMetricAccuVoltage => 'Tegangan Aki';

  @override
  String get periodicMetricTemperature => 'Suhu';

  @override
  String get periodicTrack => 'Periodic Track';

  @override
  String get noDataAvailable => 'Tidak Ada Data';

  @override
  String get periodicStartDateRequired => 'Start Date wajib diisi';

  @override
  String get periodicEndDateRequired => 'End Date wajib diisi';

  @override
  String get periodicEndDateBeforeStart =>
      'End Date tidak boleh lebih kecil dari Start Date';

  @override
  String get periodicMaxRangeExceeded =>
      'Rentang maksimal 3 hari dari Start Date';

  @override
  String get activityAllVehicle => 'Semua Kendaraan';

  @override
  String get activityInOperation => 'Beroperasi';

  @override
  String get activityMoving => 'Bergerak';

  @override
  String get activityIdle => 'Idle';

  @override
  String get activityStop => 'Berhenti';

  @override
  String get activitySilence => 'Silence';

  @override
  String get activityInRepair => 'Dalam Perbaikan';

  @override
  String get filterTypeLabel => 'Jenis';

  @override
  String get filterChooseType => 'Pilih jenis filter';

  @override
  String get filterTypeTitle => 'Jenis Filter';

  @override
  String get filterGeofence => 'Geofence';

  @override
  String get filterChooseGeofence => 'Pilih Geofence';

  @override
  String get filterAllGeofence => 'Semua Geofence';

  @override
  String get filterSearchHint => 'Cari...';

  @override
  String get dashcam => 'Dashcam';

  @override
  String get dashcamCameraOffline => 'Kamera sedang offline.';

  @override
  String get dashcamDeviceBusy => 'Perangkat sedang sibuk';

  @override
  String get dashcamDeviceError => 'Terjadi kesalahan pada perangkat';

  @override
  String get dashcamWebsocketFailed => 'Koneksi WebSocket gagal';

  @override
  String get dashcamEnableSpeakerFirst =>
      'Nyalakan speaker terlebih dahulu sebelum menggunakan mikrofon';

  @override
  String get dashcamNoChannels => 'Tidak ada channel dashcam yang tersedia.';

  @override
  String get dashcamSpeaker => 'Speaker';

  @override
  String get dashcamIntercom => 'Intercom';

  @override
  String get channelCameraOfflineFallback => 'Kamera sedang offline.';

  @override
  String get channelCameraOffToggle =>
      'Kamera nonaktif. Aktifkan untuk melihat.';

  @override
  String get fullscreenMutedHint => 'Senyap — gunakan Speaker untuk audio';

  @override
  String get fullscreenExit => 'Keluar Fullscreen';

  @override
  String get statusOn => 'ON';

  @override
  String get statusOff => 'OFF';

  @override
  String get statusNA => 'N/A';

  @override
  String get engineOn => 'Mesin Menyala';

  @override
  String get engineOff => 'Mesin Mati';

  @override
  String engineLastOn(Object time) {
    return 'Mesin menyala $time';
  }

  @override
  String get chillerUnit => 'Unit Chiller';

  @override
  String get demoVersionBanner => 'VERSI DEMO — Data Contoh';

  @override
  String get mediaLabel => 'Media';

  @override
  String get notifNotYetValidated => 'Belum divalidasi';

  @override
  String get otpEmailNotFound => 'Email tidak ditemukan.';

  @override
  String get otpWaitBeforeResend => 'Tunggu sebelum minta OTP lagi.';

  @override
  String get otpSendFailed => 'Gagal mengirim OTP.';

  @override
  String get otpSendFailedCheckConnection =>
      'Gagal mengirim OTP. Periksa koneksi.';

  @override
  String get continueWithDemo => 'Lanjutkan dengan Demo';

  @override
  String get woLabelInspectionNote => 'Catatan Inspeksi';

  @override
  String get woLabelSensorSerialNumber => 'Nomor Seri Sensor';

  @override
  String get woLabelTechnicianName => 'Nama Teknisi';

  @override
  String get errInvalidResponse => 'Format response tidak valid';

  @override
  String get errLoadAlertTypeFailed => 'Gagal memuat alert type';

  @override
  String get errLoadFleetGroupFailed => 'Gagal memuat fleet group';

  @override
  String get errLoadMonitoringFailed =>
      'Terjadi kesalahan saat memuat monitoring';

  @override
  String get errLoadVehiclePositionFailed =>
      'Terjadi kesalahan saat memuat posisi kendaraan';

  @override
  String get errGenericTryAgain => 'Terjadi kesalahan, coba lagi';

  @override
  String get errConnectionTimeout =>
      'Koneksi ke server timeout. Periksa koneksi internet Anda dan coba lagi.';

  @override
  String get errConnectionFailed =>
      'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

  @override
  String get errInsecureConnection =>
      'Koneksi ke server tidak aman. Hubungi admin.';

  @override
  String get errRequestCancelled => 'Permintaan dibatalkan.';

  @override
  String get errNoInternetConnection =>
      'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.';

  @override
  String errFieldsRequired(Object fields) {
    return '$fields wajib diisi.';
  }

  @override
  String get errFieldsJoiner => 'dan';

  @override
  String get errIncompleteData => 'Data yang dimasukkan belum lengkap.';

  @override
  String get errInvalidCredentials =>
      'Email atau password yang Anda masukkan salah.';

  @override
  String get errServerProblem =>
      'Server sedang bermasalah. Coba lagi beberapa saat lagi.';

  @override
  String get errServiceUnavailable =>
      'Fitur ini sedang tidak tersedia. Coba lagi nanti atau hubungi admin.';

  @override
  String get errNoAccess => 'Anda tidak memiliki akses ke data ini.';

  @override
  String get errDuplicateData =>
      'Data ini sudah terdaftar. Gunakan data yang berbeda.';

  @override
  String get dashcamServiceUnavailable =>
      'Layanan kamera sedang tidak tersedia. Silakan hubungi admin.';

  @override
  String get relativeJustNow => 'baru saja';

  @override
  String get relativeYesterday => 'kemarin';

  @override
  String relativeSeconds(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count detik yang lalu',
    );
    return '$_temp0';
  }

  @override
  String relativeMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menit yang lalu',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jam yang lalu',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari yang lalu',
    );
    return '$_temp0';
  }

  @override
  String relativeWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minggu yang lalu',
    );
    return '$_temp0';
  }

  @override
  String relativeMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bulan yang lalu',
    );
    return '$_temp0';
  }

  @override
  String relativeYears(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tahun yang lalu',
    );
    return '$_temp0';
  }
}
