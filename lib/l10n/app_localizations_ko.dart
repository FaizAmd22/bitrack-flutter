// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'FixTrack';

  @override
  String get language => '언어';

  @override
  String get english => '영어';

  @override
  String get indonesian => '인도네시아어';

  @override
  String get chinese => '중국어';

  @override
  String get japanese => '일본어';

  @override
  String get korean => '한국어';

  @override
  String get navTracker => '트래커';

  @override
  String get navVehicle => '차량';

  @override
  String get navNotification => '알림';

  @override
  String get navProfile => '프로필';

  @override
  String get notifUrgent => '긴급';

  @override
  String get notifSummary => '요약';

  @override
  String get notifNoData => '알림 데이터가 없습니다';

  @override
  String get login => '로그인';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get emailPlaceholder => '이메일을 입력하세요 ...';

  @override
  String get passwordPlaceholder => '비밀번호를 입력하세요 ...';

  @override
  String get emailRequired => '이메일을 입력해 주세요';

  @override
  String get emailInvalid => '이메일 형식이 올바르지 않습니다';

  @override
  String fieldRequired(Object name) {
    return '$name을(를) 입력해 주세요';
  }

  @override
  String get addFingerprint => '지문 추가';

  @override
  String get addFingerprintDesc => '다음 로그인을 빠르게 하기 위해 지문을 저장하시겠습니까?';

  @override
  String get addFaceId => 'Face ID 추가';

  @override
  String get addFaceIdDesc => '다음 로그인을 빠르게 하기 위해 Face ID를 저장하시겠습니까?';

  @override
  String get addBiometric => '생체 인증 추가';

  @override
  String get addBiometricDesc => '다음 로그인을 빠르게 하기 위해 생체 인증을 저장하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get biometricLoginLabel => '생체 인증으로 로그인';

  @override
  String get faceIdLoginLabel => 'Face ID로 로그인';

  @override
  String get biometricNotSupported => '이 기기는 생체 인증 로그인을 지원하지 않습니다';

  @override
  String get biometricReason => '생체 인증을 사용하여 로그인하세요';

  @override
  String get biometricCredNotFound => '생체 인증 로그인 정보를 찾을 수 없습니다';

  @override
  String get loginFailedTryAgain => '로그인에 실패했습니다. 다시 시도해 주세요';

  @override
  String errorPrefix(Object message) {
    return '오류가 발생했습니다: $message';
  }

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get alert => '알림';

  @override
  String get softwareUpdate => '소프트웨어 업데이트';

  @override
  String get profileChangePassword => '비밀번호 변경';

  @override
  String get profileNotificationSetting => '알림 설정';

  @override
  String get profileLanguage => '언어';

  @override
  String get signOut => '로그아웃';

  @override
  String get signOutTitle => '계정 로그아웃';

  @override
  String get signOutDesc => '정말 로그아웃하시겠습니까?';

  @override
  String get logout => '로그아웃';

  @override
  String get searchLicensePlate => '차량 번호판 검색 ...';

  @override
  String get noVehicleYet => '아직 차량 데이터가 없습니다';

  @override
  String get dataNotFound => '데이터를 찾을 수 없습니다';

  @override
  String get showPlate => '번호판 표시';

  @override
  String get hidePlate => '번호판 숨기기';

  @override
  String get vehicleDataCantLoaded => '차량 데이터를 불러올 수 없습니다.';

  @override
  String get pleaseTryAgain => '다시 시도해 주세요.';

  @override
  String get tryAgain => '다시 시도하세요.';

  @override
  String get vehicleInformation => '차량 정보';

  @override
  String get deviceInformation => '기기 정보';

  @override
  String get review => '검토';

  @override
  String get tabInformation => '정보';

  @override
  String get tabStatus => '상태';

  @override
  String get tabSensor => '센서';

  @override
  String get vehicleIdNotAvailableDesc =>
      'vehicle_id를 사용할 수 없습니다.\n이 모달을 닫고 차량 상세 정보에서 다시 열어주세요.';

  @override
  String get failedLoadData => '데이터 로드에 실패했습니다';

  @override
  String get retry => '재시도';

  @override
  String get vehicleInfoGpsDate => 'GPS 날짜';

  @override
  String get vehicleInfoFleetGroup => '차량 그룹';

  @override
  String get vehicleInfoLicensePlate => '번호판';

  @override
  String get vehicleInfoImei => 'IMEI';

  @override
  String get vehicleInfoLatitude => '위도';

  @override
  String get vehicleInfoLongitude => '경도';

  @override
  String get vehicleInfoGoogleMap => '구글 지도';

  @override
  String get vehicleInfoStreetView => '스트리트 뷰';

  @override
  String get showGoogleMap => '구글 지도 표시';

  @override
  String get showStreetView => '스트리트 뷰 표시';

  @override
  String get vehicleStatusSpeed => '속도';

  @override
  String get vehicleStatusTotalOdometer => '총 주행거리';

  @override
  String get vehicleStatusInternalBattery => '내부 배터리';

  @override
  String get vehicleStatusExternalBattery => '외부 배터리';

  @override
  String get vehicleSensorFuel => '연료';

  @override
  String get vehicleSensorDirection => '방향';

  @override
  String get vehicleSensorHumidity => '습도';

  @override
  String get vehicleSensorLeftDoor => '왼쪽 문';

  @override
  String get vehicleSensorRightDoor => '오른쪽 문';

  @override
  String get vehicleSensorBackDoor => '뒷문';

  @override
  String get active => '활성';

  @override
  String get inactive => '비활성';

  @override
  String get createdAt => '생성일';

  @override
  String get addNewVehicleTitle => '새 차량 추가';

  @override
  String get updateVehicleTitle => '차량 업데이트';

  @override
  String get addVehicleCta => '차량 추가';

  @override
  String get updateVehicleCta => '차량 업데이트';

  @override
  String get confirm => '확인';

  @override
  String get addVehicleConfirmAddTitle => '이 차량을 추가하시겠습니까?';

  @override
  String get addVehicleConfirmAddDesc =>
      '세부 정보를 확인해 주세요. 제출하면 이 차량이 차량 목록에 추가됩니다.';

  @override
  String get addVehicleConfirmUpdateTitle => '이 차량을 업데이트하시겠습니까?';

  @override
  String get addVehicleConfirmUpdateDesc =>
      '변경 사항을 확인해 주세요. 제출하면 차량 목록의 이 차량 정보가 업데이트됩니다.';

  @override
  String get createTodo => '추가 (TODO)';

  @override
  String get updateTodo => '업데이트 (TODO)';

  @override
  String get plateNumber => '번호판';

  @override
  String get plateNumberHint => '차량 번호판을 입력하세요 ...';

  @override
  String get fieldCantEmpty => '이 필드는 비워둘 수 없습니다';

  @override
  String get brand => '브랜드';

  @override
  String get model => '모델';

  @override
  String get selectBrandHint => '브랜드를 선택하세요 ...';

  @override
  String get selectModelHint => '모델을 선택하세요 ...';

  @override
  String get selectBrandFirst => '먼저 브랜드를 선택하세요';

  @override
  String get selectModelFirst => '먼저 모델을 선택하세요';

  @override
  String get selectTypeHint => '유형을 선택하세요 ...';

  @override
  String get noTypeAvailable => '사용 가능한 유형이 없습니다';

  @override
  String get vehicleType => '유형';

  @override
  String get vehicleTypeHint => '차량 유형을 입력하세요 ...';

  @override
  String get vehicleYear => '연식';

  @override
  String get vehicleYearHint => '차량 연식을 입력하세요 ...';

  @override
  String get vehicleColor => '색상';

  @override
  String get vehicleColorHint => '차량 색상을 입력하세요 ...';

  @override
  String get vehicleCategory => '차량 카테고리';

  @override
  String get selectVehicleCategoryHint => '차량 카테고리를 선택하세요 ...';

  @override
  String get odometer => '주행거리 (KM)';

  @override
  String get odometerHint => '차량 주행거리를 입력하세요 ...';

  @override
  String get vin => '차대번호(VIN)';

  @override
  String get vinHint => '차량 VIN을 입력하세요 ...';

  @override
  String get engineNumber => '엔진 번호';

  @override
  String get engineNumberHint => '차량 엔진 번호를 입력하세요 ...';

  @override
  String get next => '다음';

  @override
  String get previous => '이전';

  @override
  String get installationDate => '설치일';

  @override
  String get installationDateHint => '설치일을 선택하세요 ...';

  @override
  String get deviceType => '기기 유형';

  @override
  String get deviceTypeHint => '기기 유형을 선택하세요';

  @override
  String get deviceModel => '기기 모델';

  @override
  String get deviceModelHint => '기기 모델을 선택하세요 ...';

  @override
  String get simCardNumber => 'SIM 카드 번호';

  @override
  String get simCardNumberHint => 'SIM 카드 번호를 입력하세요 ...';

  @override
  String get imeiObdNumber => 'IMEI OBD 번호';

  @override
  String get imeiObdNumberHint => 'IMEI OBD 번호를 입력하세요 ...';

  @override
  String get otpEnterVerificationCodeTitle => '인증 코드 입력';

  @override
  String otpSentToEmail(Object email) {
    return '인증 코드가\n$email(으)로 전송되었습니다';
  }

  @override
  String get otpEnter5Digits => '5자리 코드를 입력해 주세요.';

  @override
  String get otpInvalidTryAgain => '인증 코드가 올바르지 않습니다. 다시 시도해 주세요.';

  @override
  String get otpNotReceivedEmailPrefix => '이메일을 받지 못하셨나요? ';

  @override
  String get otpTryAgain => '코드 재전송.';

  @override
  String otpTryAgainCountdown(Object seconds) {
    return '코드 재전송. ($seconds초)';
  }

  @override
  String get otpCodeResentDummy => '코드가 재전송되었습니다.';

  @override
  String get otpVerifyCodeBtn => '코드 확인';

  @override
  String get passwordNewTitle => '새 비밀번호';

  @override
  String get passwordNewHint => '새 비밀번호를 입력하세요 ...';

  @override
  String get passwordReEnterTitle => '새 비밀번호 재입력';

  @override
  String get passwordReEnterHint => '새 비밀번호를 다시 입력하세요 ...';

  @override
  String get passwordRuleMin8 => '최소 8자 이상이어야 합니다';

  @override
  String get passwordRuleUpper => '대문자(A-Z)를 1자 이상 포함해야 합니다';

  @override
  String get passwordRuleNumber => '숫자(0-9)를 1자 이상 포함해야 합니다';

  @override
  String get passwordRuleSymbol => '특수문자(!, @, # 등)를 1자 이상 포함해야 합니다';

  @override
  String get passwordFillAllFields => '모든 항목을 입력해 주세요.';

  @override
  String get passwordNotMeetRequirements => '비밀번호가 요구 사항을 충족하지 않습니다.';

  @override
  String get passwordNotMatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get passwordUpdatedDummy => '비밀번호가 성공적으로 업데이트되었습니다.';

  @override
  String get passwordUpdateFailed => '비밀번호 업데이트에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get passwordChangeSaveBtn => '새 비밀번호 변경 및 저장';

  @override
  String get filterTitle => '필터';

  @override
  String get filterStartDate => '시작일';

  @override
  String get filterEndDate => '종료일';

  @override
  String get filterFleetGroup => '차량 그룹';

  @override
  String get filterVerifStatus => '인증 상태';

  @override
  String get filterAlertType => '알림 유형';

  @override
  String get filterApply => '필터 적용';

  @override
  String get filterClear => '필터 지우기';

  @override
  String get filterChooseStartDate => '시작일 선택';

  @override
  String get filterChooseEndDate => '종료일 선택';

  @override
  String get filterChooseFleetGroup => '차량 그룹 선택';

  @override
  String get filterChooseVerifStatus => '인증 상태 선택';

  @override
  String get filterChooseAlertType => '알림 유형 선택';

  @override
  String get filterVerified => '인증됨';

  @override
  String get filterNotYetVerified => '미인증';

  @override
  String get filterUnverified => '인증되지 않음';

  @override
  String get filterNeedVerifications => '인증 필요';

  @override
  String get filterNeedValidations => '검증 필요';

  @override
  String get filterValidated => '검증됨';

  @override
  String get filterSearch => '검색';

  @override
  String get filterNoOptions => '옵션을 찾을 수 없습니다';

  @override
  String get filterAllFleetGroup => '모든 차량 그룹';

  @override
  String get filterAllAlertType => '모든 알림 유형';

  @override
  String get gpsDate => 'GPS 날짜';

  @override
  String get alertType => '알림 유형';

  @override
  String get speed => '속도';

  @override
  String get addVehicleTitle => '차량 추가';

  @override
  String get addVehicleIdentifierTitle => '번호판';

  @override
  String get addVehicleIdentifierPlaceholder => '번호판을 입력하세요';

  @override
  String get addVehicleRequiredError => '번호판은 필수입니다';

  @override
  String get addVehiclePlateExistsError => '이미 등록된 번호판입니다';

  @override
  String get addVehicleCheckFailedError => '번호판 확인에 실패했습니다. 다시 시도해 주세요';

  @override
  String get addVehicleContinue => '계속';

  @override
  String get addVehicleChecking => '확인 중 ...';

  @override
  String get successAddVehicle => '차량이 성공적으로 추가되었습니다';

  @override
  String get successUpdateVehicle => '차량이 성공적으로 업데이트되었습니다';

  @override
  String get errFailedAdd => '차량 추가에 실패했습니다. 다시 시도해 주세요';

  @override
  String get errFailedUpdate => '차량 업데이트에 실패했습니다. 다시 시도해 주세요';

  @override
  String get errVinUnique => '이미 존재하는 VIN입니다. 다른 VIN을 입력해 주세요';

  @override
  String get selectFleetGroupHint => '차량 그룹 선택';

  @override
  String get loading => '로딩 중 ...';

  @override
  String get seeNotesVerification => '인증 메모 보기';

  @override
  String get seeNotesValidation => '검증 메모 보기';

  @override
  String get showMapCoordinate => '지도 좌표 표시';

  @override
  String get alertNotes => '알림 메모';

  @override
  String get notes => '메모';

  @override
  String get noNotes => '메모가 없습니다';

  @override
  String get noMedia => '미디어가 없습니다';

  @override
  String get mapCoordinate => '지도 좌표';

  @override
  String get copyCoordinate => '좌표가 복사되었습니다';

  @override
  String get filterAllStatus => '모든 상태';

  @override
  String get registerLinkPrefix => '계정이 없으신가요? ';

  @override
  String get registerLinkAction => '여기서 등록하세요';

  @override
  String get registerTitle => '계정 생성';

  @override
  String get registerSubtitle => '새 계정을 만들려면 아래 정보를 입력하세요';

  @override
  String get registerFullName => '이름';

  @override
  String get registerFullNamePlaceholder => '이름을 입력하세요 ...';

  @override
  String get registerPhone => '전화번호';

  @override
  String get registerPhonePlaceholder => '전화번호를 입력하세요 ...';

  @override
  String get registerPhoneInvalid => '전화번호는 숫자만 입력할 수 있습니다';

  @override
  String get registerCompanyName => '회사명 (선택 사항)';

  @override
  String get registerCompanyNamePlaceholder => '회사명을 입력하세요 ...';

  @override
  String get registerSubmitBtn => '등록';

  @override
  String get registerPendingTitle => '확인 대기 중';

  @override
  String get registerPendingDesc =>
      '등록해 주셔서 감사합니다. 등록이 승인되면 이메일로 확인 메일을 보내드립니다.';

  @override
  String get registerPendingOkBtn => '확인했습니다';
}
