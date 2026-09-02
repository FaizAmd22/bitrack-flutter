// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FixTrack';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get chinese => 'Chinese';

  @override
  String get japanese => 'Japanese';

  @override
  String get korean => 'Korean';

  @override
  String get navTracker => 'Tracker';

  @override
  String get navVehicle => 'Vehicle';

  @override
  String get navNotification => 'Notification';

  @override
  String get navProfile => 'Profile';

  @override
  String get notifUrgent => 'Urgent';

  @override
  String get notifSummary => 'Summary';

  @override
  String get notifNoData => 'No alert data';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailPlaceholder => 'Input your email ...';

  @override
  String get passwordPlaceholder => 'Input your password ...';

  @override
  String get emailRequired => 'Email cannot be empty';

  @override
  String get emailInvalid => 'Invalid email format';

  @override
  String fieldRequired(Object name) {
    return '$name cannot be empty';
  }

  @override
  String get addFingerprint => 'Add Fingerprint';

  @override
  String get addFingerprintDesc =>
      'Do you want to save your fingerprint for faster login next time?';

  @override
  String get addFaceId => 'Add Face ID';

  @override
  String get addFaceIdDesc =>
      'Do you want to save Face ID for faster login next time?';

  @override
  String get addBiometric => 'Add Biometric';

  @override
  String get addBiometricDesc =>
      'Do you want to save biometric authentication for faster login next time?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get biometricLoginLabel => 'Login using biometric method';

  @override
  String get faceIdLoginLabel => 'Login using Face ID';

  @override
  String get biometricNotSupported =>
      'This device does not support biometric login';

  @override
  String get biometricReason => 'Use biometrics to login';

  @override
  String get biometricCredNotFound => 'Biometric login data was not found';

  @override
  String get loginFailedTryAgain => 'Login failed, please try again';

  @override
  String errorPrefix(Object message) {
    return 'An error occurred: $message';
  }

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get alert => 'Alert';

  @override
  String get softwareUpdate => 'Software Update';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileNotificationSetting => 'Notification Settings';

  @override
  String get profileLanguage => 'Language';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutTitle => 'Sign Out Account';

  @override
  String get signOutDesc => 'Are you sure you want to log out of the account?';

  @override
  String get logout => 'Logout';

  @override
  String get searchLicensePlate => 'Search Vehicle License Plate ...';

  @override
  String get noVehicleYet => 'No vehicle data yet';

  @override
  String get dataNotFound => 'Data not found';

  @override
  String get showPlate => 'Show Plate';

  @override
  String get hidePlate => 'Hide Plate';

  @override
  String get vehicleDataCantLoaded => 'Vehicle data could not be loaded.';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get tryAgain => 'Try again.';

  @override
  String get vehicleInformation => 'Vehicle Information';

  @override
  String get deviceInformation => 'Device Information';

  @override
  String get review => 'Review';

  @override
  String get tabInformation => 'Information';

  @override
  String get tabStatus => 'Status';

  @override
  String get tabSensor => 'Sensor';

  @override
  String get vehicleIdNotAvailableDesc =>
      'vehicle_id is not available.\nClose this modal and open again from Vehicle Detail.';

  @override
  String get failedLoadData => 'Failed to load data';

  @override
  String get retry => 'Retry';

  @override
  String get vehicleInfoGpsDate => 'GPS Date';

  @override
  String get vehicleInfoFleetGroup => 'Fleet Group';

  @override
  String get vehicleInfoLicensePlate => 'License Plate';

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
  String get showGoogleMap => 'Show Google Map';

  @override
  String get showStreetView => 'Show Street View';

  @override
  String get vehicleStatusSpeed => 'Speed';

  @override
  String get vehicleStatusTotalOdometer => 'Total Odometer';

  @override
  String get vehicleStatusInternalBattery => 'Internal Battery';

  @override
  String get vehicleStatusExternalBattery => 'External Battery';

  @override
  String get vehicleSensorFuel => 'Fuel';

  @override
  String get vehicleSensorDirection => 'Direction';

  @override
  String get vehicleSensorHumidity => 'Humidity';

  @override
  String get vehicleSensorLeftDoor => 'Left Door';

  @override
  String get vehicleSensorRightDoor => 'Right Door';

  @override
  String get vehicleSensorBackDoor => 'Back Door';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get createdAt => 'Created At';

  @override
  String get addNewVehicleTitle => 'Add New Vehicle';

  @override
  String get updateVehicleTitle => 'Update Vehicle';

  @override
  String get addVehicleCta => 'Add Vehicle';

  @override
  String get updateVehicleCta => 'Update Vehicle';

  @override
  String get confirm => 'Confirm';

  @override
  String get addVehicleConfirmAddTitle => 'Add Vehicle';

  @override
  String get addVehicleConfirmAddDesc =>
      'Are you sure you want to add this vehicle?';

  @override
  String get addVehicleConfirmUpdateTitle => 'Update Vehicle';

  @override
  String get addVehicleConfirmUpdateDesc =>
      'Are you sure you want to update this vehicle?';

  @override
  String get createTodo => 'Create (TODO)';

  @override
  String get updateTodo => 'Update (TODO)';

  @override
  String get plateNumber => 'Plate Number';

  @override
  String get plateNumberHint => 'Enter vehicle plate number ...';

  @override
  String get fieldCantEmpty => 'Field cannot be empty';

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get selectBrandHint => 'Select brand ...';

  @override
  String get selectModelHint => 'Select model ...';

  @override
  String get selectBrandFirst => 'Select brand first';

  @override
  String get selectModelFirst => 'Select model first';

  @override
  String get selectTypeHint => 'Select type ...';

  @override
  String get noTypeAvailable => 'No type available';

  @override
  String get vehicleType => 'Type';

  @override
  String get vehicleTypeHint => 'Enter vehicle type ...';

  @override
  String get vehicleYear => 'Year';

  @override
  String get vehicleYearHint => 'Enter vehicle year ...';

  @override
  String get vehicleColor => 'Color';

  @override
  String get vehicleColorHint => 'Enter vehicle color ...';

  @override
  String get vehicleCategory => 'Vehicle Category';

  @override
  String get selectVehicleCategoryHint => 'Select vehicle category ...';

  @override
  String get odometer => 'Odometer (KM)';

  @override
  String get odometerHint => 'Enter vehicle odometer ...';

  @override
  String get vin => 'VIN';

  @override
  String get vinHint => 'Enter vehicle VIN ...';

  @override
  String get engineNumber => 'Engine Number';

  @override
  String get engineNumberHint => 'Enter vehicle engine number ...';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get installationDate => 'Installation Date';

  @override
  String get installationDateHint => 'Select installation date ...';

  @override
  String get deviceType => 'Device Type';

  @override
  String get deviceTypeHint => 'Select device type';

  @override
  String get deviceModel => 'Device Model';

  @override
  String get deviceModelHint => 'Select device model ...';

  @override
  String get simCardNumber => 'SIM Card Number';

  @override
  String get simCardNumberHint => 'Enter SIM Card Number ...';

  @override
  String get imeiObdNumber => 'IMEI OBD Number';

  @override
  String get imeiObdNumberHint => 'Enter IMEI OBD Number ...';

  @override
  String get otpEnterVerificationCodeTitle => 'Enter the Verification Code';

  @override
  String otpSentToEmail(Object email) {
    return 'The verification code has been sent to\n$email';
  }

  @override
  String get otpEnter5Digits => 'Please enter the 5-digit code.';

  @override
  String get otpInvalidTryAgain =>
      'Invalid verification code. Please try again.';

  @override
  String get otpNotReceivedEmailPrefix => 'Haven\'t received the email? ';

  @override
  String get otpTryAgain => 'Re-send Code.';

  @override
  String otpTryAgainCountdown(Object seconds) {
    return 'Re-send Code. (${seconds}s)';
  }

  @override
  String get otpCodeResentDummy => 'Code resent.';

  @override
  String get otpVerifyCodeBtn => 'Verify Code';

  @override
  String get passwordNewTitle => 'New Password';

  @override
  String get passwordNewHint => 'Enter your new password ...';

  @override
  String get passwordReEnterTitle => 'Re-Enter New Password';

  @override
  String get passwordReEnterHint => 'Re-enter your new password ...';

  @override
  String get passwordRuleMin8 => 'Must have at least 8 characters';

  @override
  String get passwordRuleUpper =>
      'Must include at least 1 uppercase letter (A-Z)';

  @override
  String get passwordRuleNumber => 'Must include at least 1 number (0-9)';

  @override
  String get passwordRuleSymbol =>
      'Must include at least 1 punctuation mark (!, @, #, etc.)';

  @override
  String get passwordFillAllFields => 'Please fill all fields.';

  @override
  String get passwordNotMeetRequirements =>
      'Password does not meet the requirements.';

  @override
  String get passwordNotMatch => 'Passwords do not match.';

  @override
  String get passwordUpdatedDummy => 'Password updated successfully.';

  @override
  String get passwordUpdateFailed =>
      'Failed to update password. Please try again.';

  @override
  String get passwordChangeSaveBtn => 'Change & Save New Password';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterStartDate => 'Start Date';

  @override
  String get filterEndDate => 'End Date';

  @override
  String get filterFleetGroup => 'Fleet Group';

  @override
  String get filterVerifStatus => 'Verification Status';

  @override
  String get filterAlertType => 'Alert Type';

  @override
  String get filterApply => 'Apply Filter';

  @override
  String get filterClear => 'Clear Filter';

  @override
  String get filterChooseStartDate => 'Choose start date';

  @override
  String get filterChooseEndDate => 'Choose end date';

  @override
  String get filterChooseFleetGroup => 'Choose fleet group';

  @override
  String get filterChooseVerifStatus => 'Choose verification status';

  @override
  String get filterChooseAlertType => 'Choose alert type';

  @override
  String get filterVerified => 'Verified';

  @override
  String get filterNotYetVerified => 'Not Yet Verified';

  @override
  String get filterUnverified => 'Not Verified';

  @override
  String get filterNeedVerifications => 'Need Verifications';

  @override
  String get filterNeedValidations => 'Need Validations';

  @override
  String get filterValidated => 'Validated';

  @override
  String get filterSearch => 'Search';

  @override
  String get filterNoOptions => 'No options found';

  @override
  String get filterAllFleetGroup => 'All Fleet Group';

  @override
  String get filterAllAlertType => 'All Alert Type';

  @override
  String get gpsDate => 'GPS Date';

  @override
  String get alertType => 'Alert Type';

  @override
  String get speed => 'Speed';

  @override
  String get addVehicleTitle => 'Add Vehicle';

  @override
  String get addVehicleIdentifierTitle => 'License Plate';

  @override
  String get addVehicleIdentifierPlaceholder => 'Enter license plate';

  @override
  String get addVehicleRequiredError => 'License plate is required';

  @override
  String get addVehiclePlateExistsError =>
      'License plate is already registered';

  @override
  String get addVehicleCheckFailedError =>
      'Failed to check license plate. Please try again';

  @override
  String get addVehicleContinue => 'Continue';

  @override
  String get addVehicleChecking => 'Checking...';

  @override
  String get successAddVehicle => 'Vehicle added successfully';

  @override
  String get successUpdateVehicle => 'Vehicle updated successfully';

  @override
  String get errFailedAdd => 'Failed to add vehicle. Please try again';

  @override
  String get errFailedUpdate => 'Failed to update vehicle. Please try again';

  @override
  String get errVinUnique => 'VIN already exists. Please enter a different one';

  @override
  String get selectFleetGroupHint => 'Select Fleet Group';

  @override
  String get loading => 'Loading...';

  @override
  String get seeNotesVerification => 'See Notes Verification';

  @override
  String get seeNotesValidation => 'See Notes Validation';

  @override
  String get showMapCoordinate => 'Show Map Coordinate';

  @override
  String get alertNotes => 'Alert Notes';

  @override
  String get notes => 'Notes';

  @override
  String get noNotes => 'No notes available';

  @override
  String get noMedia => 'No media available';

  @override
  String get mapCoordinate => 'Map Coordinate';

  @override
  String get copyCoordinate => 'Coordinate copied';

  @override
  String get filterAllStatus => 'All Status';

  @override
  String get registerLinkPrefix => 'Don\'t have an account? ';

  @override
  String get registerLinkAction => 'Register here';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle =>
      'Fill in the details below to create a new account';

  @override
  String get registerFullName => 'Full Name';

  @override
  String get registerFullNamePlaceholder => 'Enter full name ...';

  @override
  String get registerPhone => 'Phone Number';

  @override
  String get registerPhonePlaceholder => 'Enter phone number ...';

  @override
  String get registerPhoneInvalid => 'Phone number can only contain numbers';

  @override
  String get registerCompanyName => 'Company Name (Optional)';

  @override
  String get registerCompanyNamePlaceholder => 'Enter company name ...';

  @override
  String get registerSubmitBtn => 'Register';

  @override
  String get registerPendingTitle => 'Awaiting Confirmation';

  @override
  String get registerPendingDesc =>
      'Thank you for registering. A confirmation will be sent to your email once your registration is approved.';

  @override
  String get registerPendingOkBtn => 'Got it';

  @override
  String get navWorkOrder => 'Work Order';

  @override
  String get woSearchPlaceholder => 'Search Fleet Group ...';

  @override
  String get woNoDataTitle => 'No Work Orders Yet';

  @override
  String get woNoDataMessage =>
      'You don\'t have any work orders at the moment.\nCreate a new one to get started.';

  @override
  String get woOptionDetails => 'See Work Details';

  @override
  String get woOptionDelete => 'Delete Work';

  @override
  String get woDeleteTitle => 'Delete Work Order';

  @override
  String get woDeleteSubtitle =>
      'Are you sure you want to delete this work order? This action cannot be undone.';

  @override
  String get woDeleteConfirm => 'Delete';

  @override
  String get woDeleteSuccess => 'Delete Success!';

  @override
  String get woDeleteFailed => 'Delete Failed!';

  @override
  String get woDetailDeleteTitle => 'Delete Work';

  @override
  String get woDetailDeleteSubtitle =>
      'Are you sure you want to delete this work? This action cannot be undone.';

  @override
  String get woFleetGroup => 'Fleet Group';

  @override
  String get woFleetGroupPlaceholder => 'Choose Fleet Group';

  @override
  String get woTechnician => 'Technician';

  @override
  String get woTechnicianPlaceholder => 'Choose Technician';

  @override
  String get woDate => 'Date';

  @override
  String get woDatePlaceholder => 'Select Date';

  @override
  String get woCreateTitle => 'Create Work Order';

  @override
  String get woCreate => 'Create';

  @override
  String get woCreateFailed => 'Failed to create work order';

  @override
  String get woWorkListTitle => 'Work List';

  @override
  String get woWorkListEmptyTitle => 'No Work Orders Yet';

  @override
  String get woWorkListEmptyMessage =>
      'You don\'t have any work orders at the moment.\nCreate a new one to get started.';

  @override
  String get woAssignButton => 'Assign Work';

  @override
  String get woAssignTitle => 'Create Work Order';

  @override
  String get woWorkCategory => 'Work Category';

  @override
  String get woWorkCategoryPlaceholder => 'Choose Work Order Category';

  @override
  String get woWorkType => 'Work Type';

  @override
  String get woWorkTypePlaceholder => 'Choose Work Order Type';

  @override
  String get woWorkDate => 'Work Date';

  @override
  String get woEvidenceNotUploaded => 'Evidence is not uploaded yet.';

  @override
  String get woOdometerNotFilled => 'Odometer is not filled yet.';

  @override
  String get woGpsActive => 'GPS is active.';

  @override
  String get woGpsNotActive => 'GPS is not active yet.';

  @override
  String get woDetailsTitle => 'Work Details';

  @override
  String get woTabDetails => 'Details';

  @override
  String get woTabEvidence => 'Evidence';

  @override
  String get woTabNotes => 'Notes';

  @override
  String get woDetailsEdit => 'Edit Work Details';

  @override
  String get woDetailsSave => 'Save';

  @override
  String get woSavedSuccess => 'Data saved successfully';

  @override
  String get woSavedFailed => 'Failed to save data';

  @override
  String get woCompleteSuccess => 'Work marked as complete';

  @override
  String get woCompleteFailed => 'Failed to complete work';

  @override
  String get woLeaveTitle => 'Are you sure you want to leave this page?';

  @override
  String get woLeaveMessage => 'Unsaved data will be lost';

  @override
  String get woErrorBeforeImage => 'Before Installation Evidence is required';

  @override
  String get woErrorAfterImage => 'After Installation Evidence is required';

  @override
  String get woErrorNotes => 'Notes are required';

  @override
  String get woActionSaveDraft => 'Save as Draft';

  @override
  String get woActionMarkComplete => 'Mark as Complete';

  @override
  String get woWorkInformation => 'Work Details Information';

  @override
  String get woInspectionInformation => 'Maintenance Information';

  @override
  String get woDeviceInformation => 'Device Information';

  @override
  String get woEvidenceBefore => 'Before Installation Evidence';

  @override
  String get woEvidenceAfter => 'After Installation Evidence';

  @override
  String get woEvidenceTakeOrUpload => 'Take or Upload Photo';

  @override
  String get woEvidenceUploadTitle => 'Upload Evidence';

  @override
  String get woEvidenceProofTitle => 'Evidence';

  @override
  String get woEvidenceTakePhoto => 'Take Photo';

  @override
  String get woEvidenceFromGallery => 'Choose from Gallery';

  @override
  String get woEvidenceView => 'View Photo';

  @override
  String get woEvidenceReplace => 'Replace Photo';

  @override
  String get woEvidenceDelete => 'Delete Photo';

  @override
  String get woEvidenceInvalidFormat =>
      'Unsupported file format. Please use JPG, JPEG or PNG.';

  @override
  String get woEvidenceProcessFailed => 'Failed to process image';

  @override
  String get woNotesTitle => 'Notes';

  @override
  String get woNotesPlaceholder => 'Describe the work done...';

  @override
  String get woJobCategory => 'Job Category';

  @override
  String get woJobType => 'Job Type';

  @override
  String get woLicensePlate => 'License Plate';

  @override
  String get woLicensePlatePlaceholder => 'Enter License Plate ...';

  @override
  String get woLicensePlateRequired => 'License plate is required';

  @override
  String get woUseChassisNumber => 'Use Chassis Number';

  @override
  String get woChassisNumber => 'Chassis Number';

  @override
  String get woChassisNumberPlaceholder => 'e.g. MHFJB8BS0AK000000';

  @override
  String get woOdometer => 'Odometer';

  @override
  String get woOdometerPlaceholder => 'Enter Odometer ...';

  @override
  String get woOdometerNumeric => 'Odometer must be numeric';

  @override
  String get woDeviceCondition => 'Device Condition';

  @override
  String get woDeviceConditionPlaceholder => 'Enter Device Condition ...';

  @override
  String get woDeviceType => 'Device Type';

  @override
  String get woDeviceModel => 'Device Model';

  @override
  String get woDeviceModelPlaceholder => 'Select Device Model';

  @override
  String get woDeviceModelRequired => 'Device model is required';

  @override
  String get woSimCardNumber => 'SIM Card Number';

  @override
  String get woSimCardNumberOptional => 'SIM Card Number (Optional)';

  @override
  String get woSimCardNumberPlaceholder => 'Enter SIM Card Number ...';

  @override
  String get woSimCardNumeric => 'SIM card number must be numeric';

  @override
  String get woImei => 'IMEI OBD Number';

  @override
  String get woImeiPlaceholder => 'Enter IMEI OBD Number ...';

  @override
  String get woImeiNumeric => 'IMEI must be numeric';

  @override
  String get woImeiMaxLength => 'IMEI must be at most 15 digits';

  @override
  String get woDashcamType => 'Dashcam Type';

  @override
  String get woDashcamTypePlaceholder => 'Select Dashcam Type';

  @override
  String get woDashcamTypeRequired => 'Dashcam type is required';

  @override
  String get woDashcamImei => 'Dashcam IMEI';

  @override
  String get woDashcamImeiPlaceholder => 'Enter Dashcam IMEI';

  @override
  String get woDashcamImeiNumeric => 'Dashcam IMEI must be numeric';

  @override
  String get woCameraPosition => 'Camera Position';

  @override
  String get woCameraPositionPlaceholder => 'Select Camera Position';

  @override
  String get woCameraPositionRequired => 'Camera position is required';

  @override
  String get woSensorType => 'Sensor Type';

  @override
  String get woSensorTypePlaceholder => 'Select Sensor Type';

  @override
  String get woSensorTypeRequired => 'Sensor type is required';

  @override
  String get woSensorSerialNumber => 'Serial Number';

  @override
  String get woSensorSerialNumberPlaceholder => 'Enter Serial Number';

  @override
  String get woSensorPosition => 'Sensor Position';

  @override
  String get woSensorPositionPlaceholder => 'Select Sensor Position';

  @override
  String get woSensorPositionRequired => 'Sensor position is required';

  @override
  String get woSimReplacementTitle => 'New SIM Card Number';

  @override
  String get woSimReplacementPlaceholder => 'Enter New SIM Card Number ...';

  @override
  String get woInspectionAction => 'Action';

  @override
  String get woInspectionActionPlaceholder => 'Select Action of Maintenance';

  @override
  String get woInspectionResult => 'Maintenance Result';

  @override
  String get woInspectionResultPlaceholder =>
      'Provide Details of The Maintenance ...';

  @override
  String get woCurrentDeviceTitle => 'Current Device Information';

  @override
  String get woCurrentDeviceType => 'Device Type';

  @override
  String get woCurrentDeviceModel => 'Device Model';

  @override
  String get woCurrentDeviceSimCard => 'SIM Card Number';

  @override
  String get woCurrentDeviceImei => 'IMEI OBD Number';

  @override
  String get woReviewWorkDetails => 'Work Details Information';

  @override
  String get woStepDetails => 'Work Details Information';

  @override
  String get woStepInformation => 'Device Information';

  @override
  String get woStepInspection => 'Maintenance Information';

  @override
  String get woStepReview => 'Review';

  @override
  String get woStepPrev => 'Previous';

  @override
  String get woStepNext => 'Next';

  @override
  String get woStepSubmit => 'Submit Work Order';

  @override
  String get woCreateDetailTitle => 'Create Work Order';

  @override
  String get woUpdateDetailTitle => 'Update Work Order';

  @override
  String get woSubmitConfirmTitle => 'Work Order Confirmation';

  @override
  String get woSubmitConfirmMessage =>
      'Please review the details carefully. Confirm that the work order information is correct and ready to proceed.';

  @override
  String get woCreateDetailSuccess => 'Successfully added detail!';

  @override
  String get woCreateDetailFailed => 'Failed to add detail!';

  @override
  String get woUpdateDetailSuccess => 'Work order detail updated successfully';

  @override
  String get woUpdateDetailFailed => 'Failed to update work order detail';

  @override
  String get woVehicleInfoFailed => 'Failed to get vehicle information';

  @override
  String get vehicleCategoryBus => 'Bus';

  @override
  String get vehicleCategoryPassenger => 'Passenger';

  @override
  String get vehicleCategoryTruck => 'Truck';

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
  String get periodicMetricAccuVoltage => 'Accu Voltage';

  @override
  String get periodicMetricTemperature => 'Temperature';

  @override
  String get periodicTrack => 'Periodic Track';

  @override
  String get noDataAvailable => 'No Data';

  @override
  String get periodicStartDateRequired => 'Start Date is required';

  @override
  String get periodicEndDateRequired => 'End Date is required';

  @override
  String get periodicEndDateBeforeStart =>
      'End Date cannot be earlier than Start Date';

  @override
  String get periodicMaxRangeExceeded =>
      'Maximum range is 3 days from Start Date';

  @override
  String get activityAllVehicle => 'All Vehicle';

  @override
  String get activityInOperation => 'In Operation';

  @override
  String get activityMoving => 'Moving';

  @override
  String get activityIdle => 'Idle';

  @override
  String get activityStop => 'Stop';

  @override
  String get activitySilence => 'Silence';

  @override
  String get activityInRepair => 'In Repair';

  @override
  String get filterTypeLabel => 'Type';

  @override
  String get filterChooseType => 'Choose filter type';

  @override
  String get filterTypeTitle => 'Filter Type';

  @override
  String get filterGeofence => 'Geofence';

  @override
  String get filterChooseGeofence => 'Choose geofence';

  @override
  String get filterAllGeofence => 'All Geofence';

  @override
  String get filterSearchHint => 'Search...';

  @override
  String get dashcam => 'Dashcam';

  @override
  String get dashcamCameraOffline => 'Camera is offline right now.';

  @override
  String get dashcamDeviceBusy => 'Device is busy';

  @override
  String get dashcamDeviceError => 'Device error occurred';

  @override
  String get dashcamWebsocketFailed => 'WebSocket connection failed';

  @override
  String get dashcamEnableSpeakerFirst =>
      'Please turn on speaker first before using microphone';

  @override
  String get dashcamNoChannels => 'No dashcam channels available.';

  @override
  String get dashcamSpeaker => 'Speaker';

  @override
  String get dashcamIntercom => 'Intercom';

  @override
  String get channelCameraOfflineFallback => 'Camera is offline.';

  @override
  String get channelCameraOffToggle => 'Camera is off. Toggle to view.';

  @override
  String get fullscreenMutedHint => 'Muted — use Speaker for audio';

  @override
  String get fullscreenExit => 'Exit Fullscreen';

  @override
  String get statusOn => 'ON';

  @override
  String get statusOff => 'OFF';

  @override
  String get statusNA => 'N/A';

  @override
  String get engineOn => 'Engine ON';

  @override
  String get engineOff => 'Engine OFF';

  @override
  String engineLastOn(Object time) {
    return 'Engine on $time';
  }

  @override
  String get chillerUnit => 'Chiller Unit';

  @override
  String get demoVersionBanner => 'DEMO VERSION — Sample Data';

  @override
  String get mediaLabel => 'Media';

  @override
  String get notifNotYetValidated => 'Not yet validated';

  @override
  String get otpEmailNotFound => 'Email not found.';

  @override
  String get otpWaitBeforeResend => 'Please wait before requesting OTP again.';

  @override
  String get otpSendFailed => 'Failed to send OTP.';

  @override
  String get otpSendFailedCheckConnection =>
      'Failed to send OTP. Check your connection.';

  @override
  String get continueWithDemo => 'Continue with Demo';

  @override
  String get woLabelInspectionNote => 'Inspection Note';

  @override
  String get woLabelSensorSerialNumber => 'Sensor Serial Number';

  @override
  String get woLabelTechnicianName => 'Technician Name';

  @override
  String get errInvalidResponse => 'Invalid response format';

  @override
  String get errLoadAlertTypeFailed => 'Failed to load alert type';

  @override
  String get errLoadFleetGroupFailed => 'Failed to load fleet group';

  @override
  String get errLoadMonitoringFailed =>
      'An error occurred while loading monitoring data';

  @override
  String get errLoadVehiclePositionFailed =>
      'An error occurred while loading vehicle position';

  @override
  String get errGenericTryAgain => 'An error occurred, please try again';

  @override
  String get errConnectionTimeout =>
      'Connection to server timed out. Check your internet connection and try again.';

  @override
  String get errConnectionFailed =>
      'Could not connect to the server. Check your internet connection.';

  @override
  String get errInsecureConnection =>
      'Connection to the server is not secure. Contact admin.';

  @override
  String get errRequestCancelled => 'Request cancelled.';

  @override
  String get errNoInternetConnection =>
      'No internet connection. Check your network and try again.';

  @override
  String errFieldsRequired(Object fields) {
    return '$fields is required.';
  }

  @override
  String get errFieldsJoiner => 'and';

  @override
  String get errIncompleteData => 'The data entered is incomplete.';

  @override
  String get errInvalidCredentials =>
      'The email or password you entered is incorrect.';

  @override
  String get errServerProblem =>
      'The server is having issues. Please try again in a moment.';

  @override
  String get errServiceUnavailable =>
      'This feature isn\'t available right now. Please try again later or contact your admin.';

  @override
  String get errNoAccess => 'You don\'t have access to this data.';

  @override
  String get errDuplicateData =>
      'This data is already registered. Please use a different one.';

  @override
  String get dashcamServiceUnavailable =>
      'Camera service is unavailable right now. Please contact your admin.';

  @override
  String get relativeJustNow => 'just now';

  @override
  String get relativeYesterday => 'yesterday';

  @override
  String relativeSeconds(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds ago',
      one: '1 second ago',
    );
    return '$_temp0';
  }

  @override
  String relativeMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String relativeWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String relativeMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String relativeYears(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }
}
