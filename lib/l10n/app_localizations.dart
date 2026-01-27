import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bitrack'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @navTracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get navTracker;

  /// No description provided for @navVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get navVehicle;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Input your email ...'**
  String get emailPlaceholder;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Input your password ...'**
  String get passwordPlaceholder;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get emailInvalid;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{name} cannot be empty'**
  String fieldRequired(Object name);

  /// No description provided for @addFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Add Fingerprint'**
  String get addFingerprint;

  /// No description provided for @addFingerprintDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to add fingerprint for future login?'**
  String get addFingerprintDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @biometricLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login using biometric method'**
  String get biometricLoginLabel;

  /// No description provided for @biometricNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support biometric login'**
  String get biometricNotSupported;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to login'**
  String get biometricReason;

  /// No description provided for @biometricCredNotFound.
  ///
  /// In en, this message translates to:
  /// **'Biometric login data was not found'**
  String get biometricCredNotFound;

  /// No description provided for @loginFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Login failed, please try again'**
  String get loginFailedTryAgain;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {message}'**
  String errorPrefix(Object message);

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @softwareUpdate.
  ///
  /// In en, this message translates to:
  /// **'Software Update'**
  String get softwareUpdate;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileNotificationSetting.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get profileNotificationSetting;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out Account'**
  String get signOutTitle;

  /// No description provided for @signOutDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of the account?'**
  String get signOutDesc;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @searchLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'Search Vehicle License Plate ...'**
  String get searchLicensePlate;

  /// No description provided for @noVehicleYet.
  ///
  /// In en, this message translates to:
  /// **'No vehicle data yet'**
  String get noVehicleYet;

  /// No description provided for @dataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Data not found'**
  String get dataNotFound;

  /// No description provided for @showPlate.
  ///
  /// In en, this message translates to:
  /// **'Show Plate'**
  String get showPlate;

  /// No description provided for @hidePlate.
  ///
  /// In en, this message translates to:
  /// **'Hide Plate'**
  String get hidePlate;

  /// No description provided for @vehicleDataCantLoaded.
  ///
  /// In en, this message translates to:
  /// **'Vehicle data could not be loaded.'**
  String get vehicleDataCantLoaded;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again.'**
  String get tryAgain;

  /// No description provided for @vehicleInformation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformation;

  /// No description provided for @deviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInformation;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @tabInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get tabInformation;

  /// No description provided for @tabStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tabStatus;

  /// No description provided for @tabSensor.
  ///
  /// In en, this message translates to:
  /// **'Sensor'**
  String get tabSensor;

  /// No description provided for @vehicleIdNotAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'vehicle_id is not available.\nClose this modal and open again from Vehicle Detail.'**
  String get vehicleIdNotAvailableDesc;

  /// No description provided for @failedLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedLoadData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @vehicleInfoGpsDate.
  ///
  /// In en, this message translates to:
  /// **'GPS Date'**
  String get vehicleInfoGpsDate;

  /// No description provided for @vehicleInfoFleetGroup.
  ///
  /// In en, this message translates to:
  /// **'Fleet Group'**
  String get vehicleInfoFleetGroup;

  /// No description provided for @vehicleInfoLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get vehicleInfoLicensePlate;

  /// No description provided for @vehicleInfoImei.
  ///
  /// In en, this message translates to:
  /// **'IMEI'**
  String get vehicleInfoImei;

  /// No description provided for @vehicleInfoLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get vehicleInfoLatitude;

  /// No description provided for @vehicleInfoLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get vehicleInfoLongitude;

  /// No description provided for @vehicleInfoGoogleMap.
  ///
  /// In en, this message translates to:
  /// **'Google Map'**
  String get vehicleInfoGoogleMap;

  /// No description provided for @vehicleInfoStreetView.
  ///
  /// In en, this message translates to:
  /// **'Street View'**
  String get vehicleInfoStreetView;

  /// No description provided for @showGoogleMap.
  ///
  /// In en, this message translates to:
  /// **'Show Google Map'**
  String get showGoogleMap;

  /// No description provided for @showStreetView.
  ///
  /// In en, this message translates to:
  /// **'Show Street View'**
  String get showStreetView;

  /// No description provided for @vehicleStatusSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get vehicleStatusSpeed;

  /// No description provided for @vehicleStatusTotalOdometer.
  ///
  /// In en, this message translates to:
  /// **'Total Odometer'**
  String get vehicleStatusTotalOdometer;

  /// No description provided for @vehicleStatusInternalBattery.
  ///
  /// In en, this message translates to:
  /// **'Internal Battery'**
  String get vehicleStatusInternalBattery;

  /// No description provided for @vehicleStatusExternalBattery.
  ///
  /// In en, this message translates to:
  /// **'External Battery'**
  String get vehicleStatusExternalBattery;

  /// No description provided for @vehicleSensorFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get vehicleSensorFuel;

  /// No description provided for @vehicleSensorDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get vehicleSensorDirection;

  /// No description provided for @vehicleSensorHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get vehicleSensorHumidity;

  /// No description provided for @vehicleSensorLeftDoor.
  ///
  /// In en, this message translates to:
  /// **'Left Door'**
  String get vehicleSensorLeftDoor;

  /// No description provided for @vehicleSensorRightDoor.
  ///
  /// In en, this message translates to:
  /// **'Right Door'**
  String get vehicleSensorRightDoor;

  /// No description provided for @vehicleSensorBackDoor.
  ///
  /// In en, this message translates to:
  /// **'Back Door'**
  String get vehicleSensorBackDoor;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @addNewVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Vehicle'**
  String get addNewVehicleTitle;

  /// No description provided for @updateVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get updateVehicleTitle;

  /// No description provided for @addVehicleCta.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleCta;

  /// No description provided for @updateVehicleCta.
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get updateVehicleCta;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @addVehicleConfirmAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Add This Vehicle?'**
  String get addVehicleConfirmAddTitle;

  /// No description provided for @addVehicleConfirmAddDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to confirm the details. Once submitted, this vehicle will be added to your fleet list.'**
  String get addVehicleConfirmAddDesc;

  /// No description provided for @addVehicleConfirmUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Update This Vehicle?'**
  String get addVehicleConfirmUpdateTitle;

  /// No description provided for @addVehicleConfirmUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to verify these changes. Submitting will update this vehicle\'s information in your fleet list.'**
  String get addVehicleConfirmUpdateDesc;

  /// No description provided for @createTodo.
  ///
  /// In en, this message translates to:
  /// **'Create (TODO)'**
  String get createTodo;

  /// No description provided for @updateTodo.
  ///
  /// In en, this message translates to:
  /// **'Update (TODO)'**
  String get updateTodo;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// No description provided for @plateNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle plate number ...'**
  String get plateNumberHint;

  /// No description provided for @fieldCantEmpty.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be empty'**
  String get fieldCantEmpty;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @selectBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Select brand ...'**
  String get selectBrandHint;

  /// No description provided for @selectModelHint.
  ///
  /// In en, this message translates to:
  /// **'Select model ...'**
  String get selectModelHint;

  /// No description provided for @selectBrandFirst.
  ///
  /// In en, this message translates to:
  /// **'Select brand first'**
  String get selectBrandFirst;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get vehicleType;

  /// No description provided for @vehicleTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle type ...'**
  String get vehicleTypeHint;

  /// No description provided for @vehicleYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get vehicleYear;

  /// No description provided for @vehicleYearHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle year ...'**
  String get vehicleYearHint;

  /// No description provided for @vehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get vehicleColor;

  /// No description provided for @vehicleColorHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle color ...'**
  String get vehicleColorHint;

  /// No description provided for @vehicleCategory.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Category'**
  String get vehicleCategory;

  /// No description provided for @selectVehicleCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle category ...'**
  String get selectVehicleCategoryHint;

  /// No description provided for @odometerKm.
  ///
  /// In en, this message translates to:
  /// **'Odometer (KM)'**
  String get odometerKm;

  /// No description provided for @odometerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle odometer ...'**
  String get odometerHint;

  /// No description provided for @vin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vin;

  /// No description provided for @vinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle VIN ...'**
  String get vinHint;

  /// No description provided for @engineNumber.
  ///
  /// In en, this message translates to:
  /// **'Engine Number'**
  String get engineNumber;

  /// No description provided for @engineNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle engine number ...'**
  String get engineNumberHint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @installationDate.
  ///
  /// In en, this message translates to:
  /// **'Installation Date'**
  String get installationDate;

  /// No description provided for @installationDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select installation date ...'**
  String get installationDateHint;

  /// No description provided for @deviceType.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get deviceType;

  /// No description provided for @deviceTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select device type'**
  String get deviceTypeHint;

  /// No description provided for @deviceModel.
  ///
  /// In en, this message translates to:
  /// **'Device Model'**
  String get deviceModel;

  /// No description provided for @deviceModelHint.
  ///
  /// In en, this message translates to:
  /// **'Select device model ...'**
  String get deviceModelHint;

  /// No description provided for @simCardNumber.
  ///
  /// In en, this message translates to:
  /// **'SIM Card Number'**
  String get simCardNumber;

  /// No description provided for @simCardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter SIM Card Number ...'**
  String get simCardNumberHint;

  /// No description provided for @imeiObdNumber.
  ///
  /// In en, this message translates to:
  /// **'IMEI OBD Number'**
  String get imeiObdNumber;

  /// No description provided for @imeiObdNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter IMEI OBD Number ...'**
  String get imeiObdNumberHint;

  /// No description provided for @otpEnterVerificationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the Verification Code'**
  String get otpEnterVerificationCodeTitle;

  /// No description provided for @otpSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'The verification code has been sent to\n{email}'**
  String otpSentToEmail(Object email);

  /// No description provided for @otpEnter5Digits.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 5-digit code.'**
  String get otpEnter5Digits;

  /// No description provided for @otpInvalidTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get otpInvalidTryAgain;

  /// No description provided for @otpNotReceivedEmailPrefix.
  ///
  /// In en, this message translates to:
  /// **'Haven\'t received the email? '**
  String get otpNotReceivedEmailPrefix;

  /// No description provided for @otpTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Re-send Code.'**
  String get otpTryAgain;

  /// No description provided for @otpTryAgainCountdown.
  ///
  /// In en, this message translates to:
  /// **'Re-send Code. ({seconds}s)'**
  String otpTryAgainCountdown(Object seconds);

  /// No description provided for @otpCodeResentDummy.
  ///
  /// In en, this message translates to:
  /// **'Code resent.'**
  String get otpCodeResentDummy;

  /// No description provided for @otpVerifyCodeBtn.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get otpVerifyCodeBtn;

  /// No description provided for @passwordNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get passwordNewTitle;

  /// No description provided for @passwordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password ...'**
  String get passwordNewHint;

  /// No description provided for @passwordReEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-Enter New Password'**
  String get passwordReEnterTitle;

  /// No description provided for @passwordReEnterHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password ...'**
  String get passwordReEnterHint;

  /// No description provided for @passwordRuleMin8.
  ///
  /// In en, this message translates to:
  /// **'Must have at least 8 characters'**
  String get passwordRuleMin8;

  /// No description provided for @passwordRuleUpper.
  ///
  /// In en, this message translates to:
  /// **'Must include at least 1 uppercase letter (A-Z)'**
  String get passwordRuleUpper;

  /// No description provided for @passwordRuleNumber.
  ///
  /// In en, this message translates to:
  /// **'Must include at least 1 number (0-9)'**
  String get passwordRuleNumber;

  /// No description provided for @passwordRuleSymbol.
  ///
  /// In en, this message translates to:
  /// **'Must include at least 1 punctuation mark (!, @, #, etc.)'**
  String get passwordRuleSymbol;

  /// No description provided for @passwordFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get passwordFillAllFields;

  /// No description provided for @passwordNotMeetRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password does not meet the requirements.'**
  String get passwordNotMeetRequirements;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordNotMatch;

  /// No description provided for @passwordUpdatedDummy.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get passwordUpdatedDummy;

  /// No description provided for @passwordChangeSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Change & Save New Password'**
  String get passwordChangeSaveBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
