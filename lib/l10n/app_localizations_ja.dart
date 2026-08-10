// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FixTrack';

  @override
  String get language => '言語';

  @override
  String get english => '英語';

  @override
  String get indonesian => 'インドネシア語';

  @override
  String get chinese => '中国語';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '韓国語';

  @override
  String get navTracker => 'トラッカー';

  @override
  String get navVehicle => '車両';

  @override
  String get navNotification => '通知';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get notifUrgent => '緊急';

  @override
  String get notifSummary => '概要';

  @override
  String get notifNoData => 'アラートデータがありません';

  @override
  String get login => 'ログイン';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get emailPlaceholder => 'メールアドレスを入力してください…';

  @override
  String get passwordPlaceholder => 'パスワードを入力してください…';

  @override
  String get emailRequired => 'メールアドレスを入力してください';

  @override
  String get emailInvalid => 'メールアドレスの形式が正しくありません';

  @override
  String fieldRequired(Object name) {
    return '$nameを入力してください';
  }

  @override
  String get addFingerprint => '指紋を追加';

  @override
  String get addFingerprintDesc => '次回のログインを簡単にするため、指紋を保存しますか？';

  @override
  String get addFaceId => 'Face IDを追加';

  @override
  String get addFaceIdDesc => '次回のログインを簡単にするため、Face IDを保存しますか？';

  @override
  String get addBiometric => '生体認証を追加';

  @override
  String get addBiometricDesc => '次回のログインを簡単にするため、生体認証を保存しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get biometricLoginLabel => '生体認証でログイン';

  @override
  String get faceIdLoginLabel => 'Face IDでログイン';

  @override
  String get biometricNotSupported => 'この端末は生体認証ログインに対応していません';

  @override
  String get biometricReason => '生体認証でログインしてください';

  @override
  String get biometricCredNotFound => '生体認証のログイン情報が見つかりません';

  @override
  String get loginFailedTryAgain => 'ログインに失敗しました。もう一度お試しください';

  @override
  String errorPrefix(Object message) {
    return 'エラーが発生しました：$message';
  }

  @override
  String get notificationSettings => '通知設定';

  @override
  String get alert => 'アラート';

  @override
  String get softwareUpdate => 'ソフトウェアアップデート';

  @override
  String get profileChangePassword => 'パスワードの変更';

  @override
  String get profileNotificationSetting => '通知設定';

  @override
  String get profileLanguage => '言語';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signOutTitle => 'アカウントからサインアウト';

  @override
  String get signOutDesc => '本当にサインアウトしますか？';

  @override
  String get logout => 'ログアウト';

  @override
  String get searchLicensePlate => '車両ナンバーを検索…';

  @override
  String get noVehicleYet => '車両データがまだありません';

  @override
  String get dataNotFound => 'データが見つかりません';

  @override
  String get showPlate => 'ナンバープレートを表示';

  @override
  String get hidePlate => 'ナンバープレートを非表示';

  @override
  String get vehicleDataCantLoaded => '車両データを読み込めませんでした。';

  @override
  String get pleaseTryAgain => 'もう一度お試しください。';

  @override
  String get tryAgain => '再試行してください。';

  @override
  String get vehicleInformation => '車両情報';

  @override
  String get deviceInformation => 'デバイス情報';

  @override
  String get review => '確認';

  @override
  String get tabInformation => '情報';

  @override
  String get tabStatus => 'ステータス';

  @override
  String get tabSensor => 'センサー';

  @override
  String get vehicleIdNotAvailableDesc =>
      'vehicle_idが利用できません。\nこのモーダルを閉じて、車両詳細から再度開いてください。';

  @override
  String get failedLoadData => 'データの読み込みに失敗しました';

  @override
  String get retry => '再試行';

  @override
  String get vehicleInfoGpsDate => 'GPS日時';

  @override
  String get vehicleInfoFleetGroup => 'フリートグループ';

  @override
  String get vehicleInfoLicensePlate => 'ナンバープレート';

  @override
  String get vehicleInfoImei => 'IMEI';

  @override
  String get vehicleInfoLatitude => '緯度';

  @override
  String get vehicleInfoLongitude => '経度';

  @override
  String get vehicleInfoGoogleMap => 'Googleマップ';

  @override
  String get vehicleInfoStreetView => 'ストリートビュー';

  @override
  String get showGoogleMap => 'Googleマップを表示';

  @override
  String get showStreetView => 'ストリートビューを表示';

  @override
  String get vehicleStatusSpeed => '速度';

  @override
  String get vehicleStatusTotalOdometer => '総走行距離';

  @override
  String get vehicleStatusInternalBattery => '内部バッテリー';

  @override
  String get vehicleStatusExternalBattery => '外部バッテリー';

  @override
  String get vehicleSensorFuel => '燃料';

  @override
  String get vehicleSensorDirection => '方向';

  @override
  String get vehicleSensorHumidity => '湿度';

  @override
  String get vehicleSensorLeftDoor => '左ドア';

  @override
  String get vehicleSensorRightDoor => '右ドア';

  @override
  String get vehicleSensorBackDoor => '後部ドア';

  @override
  String get active => '有効';

  @override
  String get inactive => '無効';

  @override
  String get createdAt => '作成日';

  @override
  String get addNewVehicleTitle => '新しい車両を追加';

  @override
  String get updateVehicleTitle => '車両を更新';

  @override
  String get addVehicleCta => '車両を追加';

  @override
  String get updateVehicleCta => '車両を更新';

  @override
  String get confirm => '確認';

  @override
  String get addVehicleConfirmAddTitle => 'この車両を追加しますか？';

  @override
  String get addVehicleConfirmAddDesc =>
      '内容をよくご確認ください。送信すると、この車両がフリートリストに追加されます。';

  @override
  String get addVehicleConfirmUpdateTitle => 'この車両を更新しますか？';

  @override
  String get addVehicleConfirmUpdateDesc =>
      '変更内容をよくご確認ください。送信すると、フリートリスト内のこの車両の情報が更新されます。';

  @override
  String get createTodo => '追加（TODO）';

  @override
  String get updateTodo => '更新（TODO）';

  @override
  String get plateNumber => 'ナンバープレート';

  @override
  String get plateNumberHint => '車両のナンバープレートを入力…';

  @override
  String get fieldCantEmpty => 'このフィールドは空にできません';

  @override
  String get brand => 'ブランド';

  @override
  String get model => 'モデル';

  @override
  String get selectBrandHint => 'ブランドを選択…';

  @override
  String get selectModelHint => 'モデルを選択…';

  @override
  String get selectBrandFirst => '先にブランドを選択してください';

  @override
  String get selectModelFirst => '先にモデルを選択してください';

  @override
  String get selectTypeHint => 'タイプを選択…';

  @override
  String get noTypeAvailable => '利用可能なタイプがありません';

  @override
  String get vehicleType => 'タイプ';

  @override
  String get vehicleTypeHint => '車両タイプを入力…';

  @override
  String get vehicleYear => '年式';

  @override
  String get vehicleYearHint => '車両の年式を入力…';

  @override
  String get vehicleColor => '色';

  @override
  String get vehicleColorHint => '車両の色を入力…';

  @override
  String get vehicleCategory => '車両カテゴリ';

  @override
  String get selectVehicleCategoryHint => '車両カテゴリを選択…';

  @override
  String get odometer => '走行距離（KM）';

  @override
  String get odometerHint => '車両の走行距離を入力…';

  @override
  String get vin => '車台番号（VIN）';

  @override
  String get vinHint => '車両のVINを入力…';

  @override
  String get engineNumber => 'エンジン番号';

  @override
  String get engineNumberHint => '車両のエンジン番号を入力…';

  @override
  String get next => '次へ';

  @override
  String get previous => '戻る';

  @override
  String get installationDate => '設置日';

  @override
  String get installationDateHint => '設置日を選択…';

  @override
  String get deviceType => 'デバイスタイプ';

  @override
  String get deviceTypeHint => 'デバイスタイプを選択';

  @override
  String get deviceModel => 'デバイスモデル';

  @override
  String get deviceModelHint => 'デバイスモデルを選択…';

  @override
  String get simCardNumber => 'SIMカード番号';

  @override
  String get simCardNumberHint => 'SIMカード番号を入力…';

  @override
  String get imeiObdNumber => 'IMEI OBD番号';

  @override
  String get imeiObdNumberHint => 'IMEI OBD番号を入力…';

  @override
  String get otpEnterVerificationCodeTitle => '認証コードを入力';

  @override
  String otpSentToEmail(Object email) {
    return '認証コードを\n$email宛に送信しました';
  }

  @override
  String get otpEnter5Digits => '5桁のコードを入力してください。';

  @override
  String get otpInvalidTryAgain => '認証コードが無効です。もう一度お試しください。';

  @override
  String get otpNotReceivedEmailPrefix => 'メールが届きませんか？';

  @override
  String get otpTryAgain => 'コードを再送信。';

  @override
  String otpTryAgainCountdown(Object seconds) {
    return 'コードを再送信。（$seconds秒）';
  }

  @override
  String get otpCodeResentDummy => 'コードを再送信しました。';

  @override
  String get otpVerifyCodeBtn => 'コードを確認';

  @override
  String get passwordNewTitle => '新しいパスワード';

  @override
  String get passwordNewHint => '新しいパスワードを入力…';

  @override
  String get passwordReEnterTitle => '新しいパスワードを再入力';

  @override
  String get passwordReEnterHint => '新しいパスワードをもう一度入力…';

  @override
  String get passwordRuleMin8 => '8文字以上で入力してください';

  @override
  String get passwordRuleUpper => '大文字（A-Z）を1文字以上含めてください';

  @override
  String get passwordRuleNumber => '数字（0-9）を1文字以上含めてください';

  @override
  String get passwordRuleSymbol => '記号（!、@、#など）を1文字以上含めてください';

  @override
  String get passwordFillAllFields => 'すべての項目を入力してください。';

  @override
  String get passwordNotMeetRequirements => 'パスワードが要件を満たしていません。';

  @override
  String get passwordNotMatch => 'パスワードが一致しません。';

  @override
  String get passwordUpdatedDummy => 'パスワードを更新しました。';

  @override
  String get passwordUpdateFailed => 'パスワードの更新に失敗しました。もう一度お試しください。';

  @override
  String get passwordChangeSaveBtn => '変更して新しいパスワードを保存';

  @override
  String get filterTitle => 'フィルター';

  @override
  String get filterStartDate => '開始日';

  @override
  String get filterEndDate => '終了日';

  @override
  String get filterFleetGroup => 'フリートグループ';

  @override
  String get filterVerifStatus => '検証ステータス';

  @override
  String get filterAlertType => 'アラートタイプ';

  @override
  String get filterApply => 'フィルターを適用';

  @override
  String get filterClear => 'フィルターをクリア';

  @override
  String get filterChooseStartDate => '開始日を選択';

  @override
  String get filterChooseEndDate => '終了日を選択';

  @override
  String get filterChooseFleetGroup => 'フリートグループを選択';

  @override
  String get filterChooseVerifStatus => '検証ステータスを選択';

  @override
  String get filterChooseAlertType => 'アラートタイプを選択';

  @override
  String get filterVerified => '検証済み';

  @override
  String get filterNotYetVerified => '未検証';

  @override
  String get filterUnverified => '未検証';

  @override
  String get filterNeedVerifications => '要検証';

  @override
  String get filterNeedValidations => '要承認';

  @override
  String get filterValidated => '承認済み';

  @override
  String get filterSearch => '検索';

  @override
  String get filterNoOptions => 'オプションが見つかりません';

  @override
  String get filterAllFleetGroup => 'すべてのフリートグループ';

  @override
  String get filterAllAlertType => 'すべてのアラートタイプ';

  @override
  String get gpsDate => 'GPS日時';

  @override
  String get alertType => 'アラートタイプ';

  @override
  String get speed => '速度';

  @override
  String get addVehicleTitle => '車両を追加';

  @override
  String get addVehicleIdentifierTitle => 'ナンバープレート';

  @override
  String get addVehicleIdentifierPlaceholder => 'ナンバープレートを入力';

  @override
  String get addVehicleRequiredError => 'ナンバープレートは必須です';

  @override
  String get addVehiclePlateExistsError => 'このナンバープレートはすでに登録されています';

  @override
  String get addVehicleCheckFailedError => 'ナンバープレートの確認に失敗しました。もう一度お試しください';

  @override
  String get addVehicleContinue => '続ける';

  @override
  String get addVehicleChecking => '確認中…';

  @override
  String get successAddVehicle => '車両を追加しました';

  @override
  String get successUpdateVehicle => '車両を更新しました';

  @override
  String get errFailedAdd => '車両の追加に失敗しました。もう一度お試しください';

  @override
  String get errFailedUpdate => '車両の更新に失敗しました。もう一度お試しください';

  @override
  String get errVinUnique => 'このVINはすでに存在します。別のVINを入力してください';

  @override
  String get selectFleetGroupHint => 'フリートグループを選択';

  @override
  String get loading => '読み込み中…';

  @override
  String get seeNotesVerification => '検証メモを見る';

  @override
  String get seeNotesValidation => '承認メモを見る';

  @override
  String get showMapCoordinate => '地図座標を表示';

  @override
  String get alertNotes => 'アラートメモ';

  @override
  String get notes => 'メモ';

  @override
  String get noNotes => 'メモがありません';

  @override
  String get noMedia => 'メディアがありません';

  @override
  String get mapCoordinate => '地図座標';

  @override
  String get copyCoordinate => '座標をコピーしました';

  @override
  String get filterAllStatus => 'すべてのステータス';

  @override
  String get registerLinkPrefix => 'アカウントをお持ちでないですか？';

  @override
  String get registerLinkAction => 'こちらから登録';

  @override
  String get registerTitle => 'アカウントを作成';

  @override
  String get registerSubtitle => '新しいアカウントを作成するために以下の情報を入力してください';

  @override
  String get registerFullName => '氏名';

  @override
  String get registerFullNamePlaceholder => '氏名を入力…';

  @override
  String get registerPhone => '電話番号';

  @override
  String get registerPhonePlaceholder => '電話番号を入力…';

  @override
  String get registerPhoneInvalid => '電話番号は数字のみ入力できます';

  @override
  String get registerCompanyName => '会社名（任意）';

  @override
  String get registerCompanyNamePlaceholder => '会社名を入力…';

  @override
  String get registerSubmitBtn => '登録';

  @override
  String get registerPendingTitle => '確認待ち';

  @override
  String get registerPendingDesc =>
      'ご登録ありがとうございます。登録が承認されると、メールアドレス宛に確認のご案内をお送りします。';

  @override
  String get registerPendingOkBtn => '了解しました';
}
