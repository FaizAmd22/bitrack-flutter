import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FixTrack'**
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

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

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

  /// No description provided for @navNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get navNotification;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @notifUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get notifUrgent;

  /// No description provided for @notifSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get notifSummary;

  /// No description provided for @notifNoData.
  ///
  /// In en, this message translates to:
  /// **'No alert data'**
  String get notifNoData;

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
  /// **'Do you want to save your fingerprint for faster login next time?'**
  String get addFingerprintDesc;

  /// No description provided for @addFaceId.
  ///
  /// In en, this message translates to:
  /// **'Add Face ID'**
  String get addFaceId;

  /// No description provided for @addFaceIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save Face ID for faster login next time?'**
  String get addFaceIdDesc;

  /// No description provided for @addBiometric.
  ///
  /// In en, this message translates to:
  /// **'Add Biometric'**
  String get addBiometric;

  /// No description provided for @addBiometricDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save biometric authentication for faster login next time?'**
  String get addBiometricDesc;

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

  /// No description provided for @faceIdLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login using Face ID'**
  String get faceIdLoginLabel;

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
  /// **'Add Vehicle'**
  String get addVehicleConfirmAddTitle;

  /// No description provided for @addVehicleConfirmAddDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to add this vehicle?'**
  String get addVehicleConfirmAddDesc;

  /// No description provided for @addVehicleConfirmUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get addVehicleConfirmUpdateTitle;

  /// No description provided for @addVehicleConfirmUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this vehicle?'**
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

  /// No description provided for @selectModelFirst.
  ///
  /// In en, this message translates to:
  /// **'Select model first'**
  String get selectModelFirst;

  /// No description provided for @selectTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select type ...'**
  String get selectTypeHint;

  /// No description provided for @noTypeAvailable.
  ///
  /// In en, this message translates to:
  /// **'No type available'**
  String get noTypeAvailable;

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

  /// No description provided for @odometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer (KM)'**
  String get odometer;

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

  /// No description provided for @passwordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password. Please try again.'**
  String get passwordUpdateFailed;

  /// No description provided for @passwordChangeSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Change & Save New Password'**
  String get passwordChangeSaveBtn;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @filterStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get filterStartDate;

  /// No description provided for @filterEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get filterEndDate;

  /// No description provided for @filterFleetGroup.
  ///
  /// In en, this message translates to:
  /// **'Fleet Group'**
  String get filterFleetGroup;

  /// No description provided for @filterVerifStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get filterVerifStatus;

  /// No description provided for @filterAlertType.
  ///
  /// In en, this message translates to:
  /// **'Alert Type'**
  String get filterAlertType;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get filterApply;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get filterClear;

  /// No description provided for @filterChooseStartDate.
  ///
  /// In en, this message translates to:
  /// **'Choose start date'**
  String get filterChooseStartDate;

  /// No description provided for @filterChooseEndDate.
  ///
  /// In en, this message translates to:
  /// **'Choose end date'**
  String get filterChooseEndDate;

  /// No description provided for @filterChooseFleetGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose fleet group'**
  String get filterChooseFleetGroup;

  /// No description provided for @filterChooseVerifStatus.
  ///
  /// In en, this message translates to:
  /// **'Choose verification status'**
  String get filterChooseVerifStatus;

  /// No description provided for @filterChooseAlertType.
  ///
  /// In en, this message translates to:
  /// **'Choose alert type'**
  String get filterChooseAlertType;

  /// No description provided for @filterVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get filterVerified;

  /// No description provided for @filterNotYetVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Yet Verified'**
  String get filterNotYetVerified;

  /// No description provided for @filterUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get filterUnverified;

  /// No description provided for @filterNeedVerifications.
  ///
  /// In en, this message translates to:
  /// **'Need Verifications'**
  String get filterNeedVerifications;

  /// No description provided for @filterNeedValidations.
  ///
  /// In en, this message translates to:
  /// **'Need Validations'**
  String get filterNeedValidations;

  /// No description provided for @filterValidated.
  ///
  /// In en, this message translates to:
  /// **'Validated'**
  String get filterValidated;

  /// No description provided for @filterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get filterSearch;

  /// No description provided for @filterNoOptions.
  ///
  /// In en, this message translates to:
  /// **'No options found'**
  String get filterNoOptions;

  /// No description provided for @filterAllFleetGroup.
  ///
  /// In en, this message translates to:
  /// **'All Fleet Group'**
  String get filterAllFleetGroup;

  /// No description provided for @filterAllAlertType.
  ///
  /// In en, this message translates to:
  /// **'All Alert Type'**
  String get filterAllAlertType;

  /// No description provided for @gpsDate.
  ///
  /// In en, this message translates to:
  /// **'GPS Date'**
  String get gpsDate;

  /// No description provided for @alertType.
  ///
  /// In en, this message translates to:
  /// **'Alert Type'**
  String get alertType;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @addVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleTitle;

  /// No description provided for @addVehicleIdentifierTitle.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get addVehicleIdentifierTitle;

  /// No description provided for @addVehicleIdentifierPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter license plate'**
  String get addVehicleIdentifierPlaceholder;

  /// No description provided for @addVehicleRequiredError.
  ///
  /// In en, this message translates to:
  /// **'License plate is required'**
  String get addVehicleRequiredError;

  /// No description provided for @addVehiclePlateExistsError.
  ///
  /// In en, this message translates to:
  /// **'License plate is already registered'**
  String get addVehiclePlateExistsError;

  /// No description provided for @addVehicleCheckFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to check license plate. Please try again'**
  String get addVehicleCheckFailedError;

  /// No description provided for @addVehicleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get addVehicleContinue;

  /// No description provided for @addVehicleChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get addVehicleChecking;

  /// No description provided for @successAddVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle added successfully'**
  String get successAddVehicle;

  /// No description provided for @successUpdateVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated successfully'**
  String get successUpdateVehicle;

  /// No description provided for @errFailedAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add vehicle. Please try again'**
  String get errFailedAdd;

  /// No description provided for @errFailedUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update vehicle. Please try again'**
  String get errFailedUpdate;

  /// No description provided for @errVinUnique.
  ///
  /// In en, this message translates to:
  /// **'VIN already exists. Please enter a different one'**
  String get errVinUnique;

  /// No description provided for @selectFleetGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Select Fleet Group'**
  String get selectFleetGroupHint;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @seeNotesVerification.
  ///
  /// In en, this message translates to:
  /// **'See Notes Verification'**
  String get seeNotesVerification;

  /// No description provided for @seeNotesValidation.
  ///
  /// In en, this message translates to:
  /// **'See Notes Validation'**
  String get seeNotesValidation;

  /// No description provided for @showMapCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Show Map Coordinate'**
  String get showMapCoordinate;

  /// No description provided for @alertNotes.
  ///
  /// In en, this message translates to:
  /// **'Alert Notes'**
  String get alertNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes available'**
  String get noNotes;

  /// No description provided for @noMedia.
  ///
  /// In en, this message translates to:
  /// **'No media available'**
  String get noMedia;

  /// No description provided for @mapCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Map Coordinate'**
  String get mapCoordinate;

  /// No description provided for @copyCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Coordinate copied'**
  String get copyCoordinate;

  /// No description provided for @filterAllStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get filterAllStatus;

  /// No description provided for @registerLinkPrefix.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get registerLinkPrefix;

  /// No description provided for @registerLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get registerLinkAction;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to create a new account'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerFullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter full name ...'**
  String get registerFullNamePlaceholder;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhone;

  /// No description provided for @registerPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number ...'**
  String get registerPhonePlaceholder;

  /// No description provided for @registerPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number can only contain numbers'**
  String get registerPhoneInvalid;

  /// No description provided for @registerCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name (Optional)'**
  String get registerCompanyName;

  /// No description provided for @registerCompanyNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter company name ...'**
  String get registerCompanyNamePlaceholder;

  /// No description provided for @registerSubmitBtn.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerSubmitBtn;

  /// No description provided for @registerPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Confirmation'**
  String get registerPendingTitle;

  /// No description provided for @registerPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Thank you for registering. A confirmation will be sent to your email once your registration is approved.'**
  String get registerPendingDesc;

  /// No description provided for @registerPendingOkBtn.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get registerPendingOkBtn;

  /// No description provided for @navWorkOrder.
  ///
  /// In en, this message translates to:
  /// **'Work Order'**
  String get navWorkOrder;

  /// No description provided for @woSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search Fleet Group ...'**
  String get woSearchPlaceholder;

  /// No description provided for @woNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Work Orders Yet'**
  String get woNoDataTitle;

  /// No description provided for @woNoDataMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any work orders at the moment.\nCreate a new one to get started.'**
  String get woNoDataMessage;

  /// No description provided for @woOptionDetails.
  ///
  /// In en, this message translates to:
  /// **'See Work Details'**
  String get woOptionDetails;

  /// No description provided for @woOptionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Work'**
  String get woOptionDelete;

  /// No description provided for @woDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Work Order'**
  String get woDeleteTitle;

  /// No description provided for @woDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this work order? This action cannot be undone.'**
  String get woDeleteSubtitle;

  /// No description provided for @woDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get woDeleteConfirm;

  /// No description provided for @woDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delete Success!'**
  String get woDeleteSuccess;

  /// No description provided for @woDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete Failed!'**
  String get woDeleteFailed;

  /// No description provided for @woDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Work'**
  String get woDetailDeleteTitle;

  /// No description provided for @woDetailDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this work? This action cannot be undone.'**
  String get woDetailDeleteSubtitle;

  /// No description provided for @woFleetGroup.
  ///
  /// In en, this message translates to:
  /// **'Fleet Group'**
  String get woFleetGroup;

  /// No description provided for @woFleetGroupPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose Fleet Group'**
  String get woFleetGroupPlaceholder;

  /// No description provided for @woTechnician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get woTechnician;

  /// No description provided for @woTechnicianPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose Technician'**
  String get woTechnicianPlaceholder;

  /// No description provided for @woDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get woDate;

  /// No description provided for @woDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get woDatePlaceholder;

  /// No description provided for @woCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Work Order'**
  String get woCreateTitle;

  /// No description provided for @woCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get woCreate;

  /// No description provided for @woCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create work order'**
  String get woCreateFailed;

  /// No description provided for @woWorkListTitle.
  ///
  /// In en, this message translates to:
  /// **'Work List'**
  String get woWorkListTitle;

  /// No description provided for @woWorkListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Work Orders Yet'**
  String get woWorkListEmptyTitle;

  /// No description provided for @woWorkListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any work orders at the moment.\nCreate a new one to get started.'**
  String get woWorkListEmptyMessage;

  /// No description provided for @woAssignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign Work'**
  String get woAssignButton;

  /// No description provided for @woAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Work Order'**
  String get woAssignTitle;

  /// No description provided for @woWorkCategory.
  ///
  /// In en, this message translates to:
  /// **'Work Category'**
  String get woWorkCategory;

  /// No description provided for @woWorkCategoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose Work Order Category'**
  String get woWorkCategoryPlaceholder;

  /// No description provided for @woWorkType.
  ///
  /// In en, this message translates to:
  /// **'Work Type'**
  String get woWorkType;

  /// No description provided for @woWorkTypePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose Work Order Type'**
  String get woWorkTypePlaceholder;

  /// No description provided for @woWorkDate.
  ///
  /// In en, this message translates to:
  /// **'Work Date'**
  String get woWorkDate;

  /// No description provided for @woEvidenceNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Evidence is not uploaded yet.'**
  String get woEvidenceNotUploaded;

  /// No description provided for @woOdometerNotFilled.
  ///
  /// In en, this message translates to:
  /// **'Odometer is not filled yet.'**
  String get woOdometerNotFilled;

  /// No description provided for @woGpsActive.
  ///
  /// In en, this message translates to:
  /// **'GPS is active.'**
  String get woGpsActive;

  /// No description provided for @woGpsNotActive.
  ///
  /// In en, this message translates to:
  /// **'GPS is not active yet.'**
  String get woGpsNotActive;

  /// No description provided for @woDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Details'**
  String get woDetailsTitle;

  /// No description provided for @woTabDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get woTabDetails;

  /// No description provided for @woTabEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get woTabEvidence;

  /// No description provided for @woTabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get woTabNotes;

  /// No description provided for @woDetailsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Work Details'**
  String get woDetailsEdit;

  /// No description provided for @woDetailsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get woDetailsSave;

  /// No description provided for @woSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get woSavedSuccess;

  /// No description provided for @woSavedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save data'**
  String get woSavedFailed;

  /// No description provided for @woCompleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Work marked as complete'**
  String get woCompleteSuccess;

  /// No description provided for @woCompleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete work'**
  String get woCompleteFailed;

  /// No description provided for @woLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this page?'**
  String get woLeaveTitle;

  /// No description provided for @woLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Unsaved data will be lost'**
  String get woLeaveMessage;

  /// No description provided for @woErrorBeforeImage.
  ///
  /// In en, this message translates to:
  /// **'Before Installation Evidence is required'**
  String get woErrorBeforeImage;

  /// No description provided for @woErrorAfterImage.
  ///
  /// In en, this message translates to:
  /// **'After Installation Evidence is required'**
  String get woErrorAfterImage;

  /// No description provided for @woErrorNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes are required'**
  String get woErrorNotes;

  /// No description provided for @woActionSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get woActionSaveDraft;

  /// No description provided for @woActionMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get woActionMarkComplete;

  /// No description provided for @woWorkInformation.
  ///
  /// In en, this message translates to:
  /// **'Work Details Information'**
  String get woWorkInformation;

  /// No description provided for @woInspectionInformation.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Information'**
  String get woInspectionInformation;

  /// No description provided for @woDeviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get woDeviceInformation;

  /// No description provided for @woEvidenceBefore.
  ///
  /// In en, this message translates to:
  /// **'Before Installation Evidence'**
  String get woEvidenceBefore;

  /// No description provided for @woEvidenceAfter.
  ///
  /// In en, this message translates to:
  /// **'After Installation Evidence'**
  String get woEvidenceAfter;

  /// No description provided for @woEvidenceTakeOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Take or Upload Photo'**
  String get woEvidenceTakeOrUpload;

  /// No description provided for @woEvidenceUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Evidence'**
  String get woEvidenceUploadTitle;

  /// No description provided for @woEvidenceProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get woEvidenceProofTitle;

  /// No description provided for @woEvidenceTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get woEvidenceTakePhoto;

  /// No description provided for @woEvidenceFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get woEvidenceFromGallery;

  /// No description provided for @woEvidenceView.
  ///
  /// In en, this message translates to:
  /// **'View Photo'**
  String get woEvidenceView;

  /// No description provided for @woEvidenceReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace Photo'**
  String get woEvidenceReplace;

  /// No description provided for @woEvidenceDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get woEvidenceDelete;

  /// No description provided for @woEvidenceInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format. Please use JPG, JPEG or PNG.'**
  String get woEvidenceInvalidFormat;

  /// No description provided for @woEvidenceProcessFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image'**
  String get woEvidenceProcessFailed;

  /// No description provided for @woNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get woNotesTitle;

  /// No description provided for @woNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the work done...'**
  String get woNotesPlaceholder;

  /// No description provided for @woJobCategory.
  ///
  /// In en, this message translates to:
  /// **'Job Category'**
  String get woJobCategory;

  /// No description provided for @woJobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get woJobType;

  /// No description provided for @woLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get woLicensePlate;

  /// No description provided for @woLicensePlatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter License Plate ...'**
  String get woLicensePlatePlaceholder;

  /// No description provided for @woLicensePlateRequired.
  ///
  /// In en, this message translates to:
  /// **'License plate is required'**
  String get woLicensePlateRequired;

  /// No description provided for @woUseChassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Use Chassis Number'**
  String get woUseChassisNumber;

  /// No description provided for @woChassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Chassis Number'**
  String get woChassisNumber;

  /// No description provided for @woChassisNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. MHFJB8BS0AK000000'**
  String get woChassisNumberPlaceholder;

  /// No description provided for @woOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get woOdometer;

  /// No description provided for @woOdometerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter Odometer ...'**
  String get woOdometerPlaceholder;

  /// No description provided for @woOdometerNumeric.
  ///
  /// In en, this message translates to:
  /// **'Odometer must be numeric'**
  String get woOdometerNumeric;

  /// No description provided for @woDeviceCondition.
  ///
  /// In en, this message translates to:
  /// **'Device Condition'**
  String get woDeviceCondition;

  /// No description provided for @woDeviceConditionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter Device Condition ...'**
  String get woDeviceConditionPlaceholder;

  /// No description provided for @woDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get woDeviceType;

  /// No description provided for @woDeviceModel.
  ///
  /// In en, this message translates to:
  /// **'Device Model'**
  String get woDeviceModel;

  /// No description provided for @woDeviceModelPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Device Model'**
  String get woDeviceModelPlaceholder;

  /// No description provided for @woDeviceModelRequired.
  ///
  /// In en, this message translates to:
  /// **'Device model is required'**
  String get woDeviceModelRequired;

  /// No description provided for @woSimCardNumber.
  ///
  /// In en, this message translates to:
  /// **'SIM Card Number'**
  String get woSimCardNumber;

  /// No description provided for @woSimCardNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'SIM Card Number (Optional)'**
  String get woSimCardNumberOptional;

  /// No description provided for @woSimCardNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter SIM Card Number ...'**
  String get woSimCardNumberPlaceholder;

  /// No description provided for @woSimCardNumeric.
  ///
  /// In en, this message translates to:
  /// **'SIM card number must be numeric'**
  String get woSimCardNumeric;

  /// No description provided for @woImei.
  ///
  /// In en, this message translates to:
  /// **'IMEI OBD Number'**
  String get woImei;

  /// No description provided for @woImeiPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter IMEI OBD Number ...'**
  String get woImeiPlaceholder;

  /// No description provided for @woImeiNumeric.
  ///
  /// In en, this message translates to:
  /// **'IMEI must be numeric'**
  String get woImeiNumeric;

  /// No description provided for @woImeiMaxLength.
  ///
  /// In en, this message translates to:
  /// **'IMEI must be at most 15 digits'**
  String get woImeiMaxLength;

  /// No description provided for @woDashcamType.
  ///
  /// In en, this message translates to:
  /// **'Dashcam Type'**
  String get woDashcamType;

  /// No description provided for @woDashcamTypePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Dashcam Type'**
  String get woDashcamTypePlaceholder;

  /// No description provided for @woDashcamTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Dashcam type is required'**
  String get woDashcamTypeRequired;

  /// No description provided for @woDashcamImei.
  ///
  /// In en, this message translates to:
  /// **'Dashcam IMEI'**
  String get woDashcamImei;

  /// No description provided for @woDashcamImeiPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter Dashcam IMEI'**
  String get woDashcamImeiPlaceholder;

  /// No description provided for @woDashcamImeiNumeric.
  ///
  /// In en, this message translates to:
  /// **'Dashcam IMEI must be numeric'**
  String get woDashcamImeiNumeric;

  /// No description provided for @woCameraPosition.
  ///
  /// In en, this message translates to:
  /// **'Camera Position'**
  String get woCameraPosition;

  /// No description provided for @woCameraPositionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Camera Position'**
  String get woCameraPositionPlaceholder;

  /// No description provided for @woCameraPositionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera position is required'**
  String get woCameraPositionRequired;

  /// No description provided for @woSensorType.
  ///
  /// In en, this message translates to:
  /// **'Sensor Type'**
  String get woSensorType;

  /// No description provided for @woSensorTypePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Sensor Type'**
  String get woSensorTypePlaceholder;

  /// No description provided for @woSensorTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Sensor type is required'**
  String get woSensorTypeRequired;

  /// No description provided for @woSensorSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get woSensorSerialNumber;

  /// No description provided for @woSensorSerialNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter Serial Number'**
  String get woSensorSerialNumberPlaceholder;

  /// No description provided for @woSensorPosition.
  ///
  /// In en, this message translates to:
  /// **'Sensor Position'**
  String get woSensorPosition;

  /// No description provided for @woSensorPositionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Sensor Position'**
  String get woSensorPositionPlaceholder;

  /// No description provided for @woSensorPositionRequired.
  ///
  /// In en, this message translates to:
  /// **'Sensor position is required'**
  String get woSensorPositionRequired;

  /// No description provided for @woSimReplacementTitle.
  ///
  /// In en, this message translates to:
  /// **'New SIM Card Number'**
  String get woSimReplacementTitle;

  /// No description provided for @woSimReplacementPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter New SIM Card Number ...'**
  String get woSimReplacementPlaceholder;

  /// No description provided for @woInspectionAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get woInspectionAction;

  /// No description provided for @woInspectionActionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select Action of Maintenance'**
  String get woInspectionActionPlaceholder;

  /// No description provided for @woInspectionResult.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Result'**
  String get woInspectionResult;

  /// No description provided for @woInspectionResultPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Provide Details of The Maintenance ...'**
  String get woInspectionResultPlaceholder;

  /// No description provided for @woCurrentDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Device Information'**
  String get woCurrentDeviceTitle;

  /// No description provided for @woCurrentDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get woCurrentDeviceType;

  /// No description provided for @woCurrentDeviceModel.
  ///
  /// In en, this message translates to:
  /// **'Device Model'**
  String get woCurrentDeviceModel;

  /// No description provided for @woCurrentDeviceSimCard.
  ///
  /// In en, this message translates to:
  /// **'SIM Card Number'**
  String get woCurrentDeviceSimCard;

  /// No description provided for @woCurrentDeviceImei.
  ///
  /// In en, this message translates to:
  /// **'IMEI OBD Number'**
  String get woCurrentDeviceImei;

  /// No description provided for @woReviewWorkDetails.
  ///
  /// In en, this message translates to:
  /// **'Work Details Information'**
  String get woReviewWorkDetails;

  /// No description provided for @woStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Work Details Information'**
  String get woStepDetails;

  /// No description provided for @woStepInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get woStepInformation;

  /// No description provided for @woStepInspection.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Information'**
  String get woStepInspection;

  /// No description provided for @woStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get woStepReview;

  /// No description provided for @woStepPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get woStepPrev;

  /// No description provided for @woStepNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get woStepNext;

  /// No description provided for @woStepSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Work Order'**
  String get woStepSubmit;

  /// No description provided for @woCreateDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Work Order'**
  String get woCreateDetailTitle;

  /// No description provided for @woUpdateDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Work Order'**
  String get woUpdateDetailTitle;

  /// No description provided for @woSubmitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Order Confirmation'**
  String get woSubmitConfirmTitle;

  /// No description provided for @woSubmitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Please review the details carefully. Confirm that the work order information is correct and ready to proceed.'**
  String get woSubmitConfirmMessage;

  /// No description provided for @woCreateDetailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added detail!'**
  String get woCreateDetailSuccess;

  /// No description provided for @woCreateDetailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add detail!'**
  String get woCreateDetailFailed;

  /// No description provided for @woUpdateDetailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Work order detail updated successfully'**
  String get woUpdateDetailSuccess;

  /// No description provided for @woUpdateDetailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update work order detail'**
  String get woUpdateDetailFailed;

  /// No description provided for @woVehicleInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get vehicle information'**
  String get woVehicleInfoFailed;

  /// No description provided for @vehicleCategoryBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get vehicleCategoryBus;

  /// No description provided for @vehicleCategoryPassenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get vehicleCategoryPassenger;

  /// No description provided for @vehicleCategoryTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get vehicleCategoryTruck;

  /// No description provided for @vehicleCategoryChiller.
  ///
  /// In en, this message translates to:
  /// **'Chiller'**
  String get vehicleCategoryChiller;

  /// No description provided for @vehicleCategoryFreezer.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get vehicleCategoryFreezer;

  /// No description provided for @vehicleCategoryChillerFreezer.
  ///
  /// In en, this message translates to:
  /// **'Chiller & Freezer'**
  String get vehicleCategoryChillerFreezer;

  /// No description provided for @vehicleCategoryFreezerChiller.
  ///
  /// In en, this message translates to:
  /// **'Freezer & Chiller'**
  String get vehicleCategoryFreezerChiller;

  /// No description provided for @periodicMetricIgnition.
  ///
  /// In en, this message translates to:
  /// **'Ignition'**
  String get periodicMetricIgnition;

  /// No description provided for @periodicMetricAccuVoltage.
  ///
  /// In en, this message translates to:
  /// **'Accu Voltage'**
  String get periodicMetricAccuVoltage;

  /// No description provided for @periodicMetricTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get periodicMetricTemperature;

  /// No description provided for @periodicTrack.
  ///
  /// In en, this message translates to:
  /// **'Periodic Track'**
  String get periodicTrack;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noDataAvailable;

  /// No description provided for @periodicStartDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start Date is required'**
  String get periodicStartDateRequired;

  /// No description provided for @periodicEndDateRequired.
  ///
  /// In en, this message translates to:
  /// **'End Date is required'**
  String get periodicEndDateRequired;

  /// No description provided for @periodicEndDateBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End Date cannot be earlier than Start Date'**
  String get periodicEndDateBeforeStart;

  /// No description provided for @periodicMaxRangeExceeded.
  ///
  /// In en, this message translates to:
  /// **'Maximum range is 3 days from Start Date'**
  String get periodicMaxRangeExceeded;

  /// No description provided for @activityAllVehicle.
  ///
  /// In en, this message translates to:
  /// **'All Vehicle'**
  String get activityAllVehicle;

  /// No description provided for @activityInOperation.
  ///
  /// In en, this message translates to:
  /// **'In Operation'**
  String get activityInOperation;

  /// No description provided for @activityMoving.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get activityMoving;

  /// No description provided for @activityIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get activityIdle;

  /// No description provided for @activityStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get activityStop;

  /// No description provided for @activitySilence.
  ///
  /// In en, this message translates to:
  /// **'Silence'**
  String get activitySilence;

  /// No description provided for @activityInRepair.
  ///
  /// In en, this message translates to:
  /// **'In Repair'**
  String get activityInRepair;

  /// No description provided for @filterTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterTypeLabel;

  /// No description provided for @filterChooseType.
  ///
  /// In en, this message translates to:
  /// **'Choose filter type'**
  String get filterChooseType;

  /// No description provided for @filterTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Type'**
  String get filterTypeTitle;

  /// No description provided for @filterGeofence.
  ///
  /// In en, this message translates to:
  /// **'Geofence'**
  String get filterGeofence;

  /// No description provided for @filterChooseGeofence.
  ///
  /// In en, this message translates to:
  /// **'Choose geofence'**
  String get filterChooseGeofence;

  /// No description provided for @filterAllGeofence.
  ///
  /// In en, this message translates to:
  /// **'All Geofence'**
  String get filterAllGeofence;

  /// No description provided for @filterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get filterSearchHint;

  /// No description provided for @dashcam.
  ///
  /// In en, this message translates to:
  /// **'Dashcam'**
  String get dashcam;

  /// No description provided for @dashcamCameraOffline.
  ///
  /// In en, this message translates to:
  /// **'Camera is offline right now.'**
  String get dashcamCameraOffline;

  /// No description provided for @dashcamDeviceBusy.
  ///
  /// In en, this message translates to:
  /// **'Device is busy'**
  String get dashcamDeviceBusy;

  /// No description provided for @dashcamDeviceError.
  ///
  /// In en, this message translates to:
  /// **'Device error occurred'**
  String get dashcamDeviceError;

  /// No description provided for @dashcamWebsocketFailed.
  ///
  /// In en, this message translates to:
  /// **'WebSocket connection failed'**
  String get dashcamWebsocketFailed;

  /// No description provided for @dashcamEnableSpeakerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please turn on speaker first before using microphone'**
  String get dashcamEnableSpeakerFirst;

  /// No description provided for @dashcamNoChannels.
  ///
  /// In en, this message translates to:
  /// **'No dashcam channels available.'**
  String get dashcamNoChannels;

  /// No description provided for @dashcamSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get dashcamSpeaker;

  /// No description provided for @dashcamIntercom.
  ///
  /// In en, this message translates to:
  /// **'Intercom'**
  String get dashcamIntercom;

  /// No description provided for @channelCameraOfflineFallback.
  ///
  /// In en, this message translates to:
  /// **'Camera is offline.'**
  String get channelCameraOfflineFallback;

  /// No description provided for @channelCameraOffToggle.
  ///
  /// In en, this message translates to:
  /// **'Camera is off. Toggle to view.'**
  String get channelCameraOffToggle;

  /// No description provided for @fullscreenMutedHint.
  ///
  /// In en, this message translates to:
  /// **'Muted — use Speaker for audio'**
  String get fullscreenMutedHint;

  /// No description provided for @fullscreenExit.
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get fullscreenExit;

  /// No description provided for @statusOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get statusOn;

  /// No description provided for @statusOff.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get statusOff;

  /// No description provided for @statusNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get statusNA;

  /// No description provided for @engineOn.
  ///
  /// In en, this message translates to:
  /// **'Engine ON'**
  String get engineOn;

  /// No description provided for @engineOff.
  ///
  /// In en, this message translates to:
  /// **'Engine OFF'**
  String get engineOff;

  /// No description provided for @engineLastOn.
  ///
  /// In en, this message translates to:
  /// **'Engine on {time}'**
  String engineLastOn(Object time);

  /// No description provided for @chillerUnit.
  ///
  /// In en, this message translates to:
  /// **'Chiller Unit'**
  String get chillerUnit;

  /// No description provided for @demoVersionBanner.
  ///
  /// In en, this message translates to:
  /// **'DEMO VERSION — Sample Data'**
  String get demoVersionBanner;

  /// No description provided for @mediaLabel.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaLabel;

  /// No description provided for @notifNotYetValidated.
  ///
  /// In en, this message translates to:
  /// **'Not yet validated'**
  String get notifNotYetValidated;

  /// No description provided for @otpEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found.'**
  String get otpEmailNotFound;

  /// No description provided for @otpWaitBeforeResend.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting OTP again.'**
  String get otpWaitBeforeResend;

  /// No description provided for @otpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP.'**
  String get otpSendFailed;

  /// No description provided for @otpSendFailedCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Check your connection.'**
  String get otpSendFailedCheckConnection;

  /// No description provided for @continueWithDemo.
  ///
  /// In en, this message translates to:
  /// **'Continue with Demo'**
  String get continueWithDemo;

  /// No description provided for @woLabelInspectionNote.
  ///
  /// In en, this message translates to:
  /// **'Inspection Note'**
  String get woLabelInspectionNote;

  /// No description provided for @woLabelSensorSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Sensor Serial Number'**
  String get woLabelSensorSerialNumber;

  /// No description provided for @woLabelTechnicianName.
  ///
  /// In en, this message translates to:
  /// **'Technician Name'**
  String get woLabelTechnicianName;

  /// No description provided for @errInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response format'**
  String get errInvalidResponse;

  /// No description provided for @errLoadAlertTypeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alert type'**
  String get errLoadAlertTypeFailed;

  /// No description provided for @errLoadFleetGroupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load fleet group'**
  String get errLoadFleetGroupFailed;

  /// No description provided for @errLoadMonitoringFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading monitoring data'**
  String get errLoadMonitoringFailed;

  /// No description provided for @errLoadVehiclePositionFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading vehicle position'**
  String get errLoadVehiclePositionFailed;

  /// No description provided for @errGenericTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again'**
  String get errGenericTryAgain;

  /// No description provided for @errConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection to server timed out. Check your internet connection and try again.'**
  String get errConnectionTimeout;

  /// No description provided for @errConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Check your internet connection.'**
  String get errConnectionFailed;

  /// No description provided for @errInsecureConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection to the server is not secure. Contact admin.'**
  String get errInsecureConnection;

  /// No description provided for @errRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get errRequestCancelled;

  /// No description provided for @errNoInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errNoInternetConnection;

  /// No description provided for @errFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'{fields} is required.'**
  String errFieldsRequired(Object fields);

  /// No description provided for @errFieldsJoiner.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get errFieldsJoiner;

  /// No description provided for @errIncompleteData.
  ///
  /// In en, this message translates to:
  /// **'The data entered is incomplete.'**
  String get errIncompleteData;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password you entered is incorrect.'**
  String get errInvalidCredentials;

  /// No description provided for @errServerProblem.
  ///
  /// In en, this message translates to:
  /// **'The server is having issues. Please try again in a moment.'**
  String get errServerProblem;

  /// No description provided for @errServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This feature isn\'t available right now. Please try again later or contact your admin.'**
  String get errServiceUnavailable;

  /// No description provided for @errNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this data.'**
  String get errNoAccess;

  /// No description provided for @errDuplicateData.
  ///
  /// In en, this message translates to:
  /// **'This data is already registered. Please use a different one.'**
  String get errDuplicateData;

  /// No description provided for @dashcamServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera service is unavailable right now. Please contact your admin.'**
  String get dashcamServiceUnavailable;

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second ago} other{{count} seconds ago}}'**
  String relativeSeconds(num count);

  /// No description provided for @relativeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String relativeMinutes(num count);

  /// No description provided for @relativeHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String relativeHours(num count);

  /// No description provided for @relativeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String relativeDays(num count);

  /// No description provided for @relativeWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String relativeWeeks(num count);

  /// No description provided for @relativeMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String relativeMonths(num count);

  /// No description provided for @relativeYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String relativeYears(num count);
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
      <String>['en', 'id', 'ja', 'ko', 'zh'].contains(locale.languageCode);

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
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
