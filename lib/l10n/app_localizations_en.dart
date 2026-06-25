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
      'Do you want to add fingerprint for future login?';

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
  String get odometer => 'Odometer (M)';

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
}
