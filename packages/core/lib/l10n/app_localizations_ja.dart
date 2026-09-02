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

  @override
  String get navWorkOrder => '作業指示書';

  @override
  String get woSearchPlaceholder => 'フリートグループを検索…';

  @override
  String get woNoDataTitle => '作業指示書がまだありません';

  @override
  String get woNoDataMessage => '現在、作業指示書はありません。\n新規作成して始めましょう。';

  @override
  String get woOptionDetails => '作業詳細を見る';

  @override
  String get woOptionDelete => '作業を削除';

  @override
  String get woDeleteTitle => '作業指示書を削除';

  @override
  String get woDeleteSubtitle => 'この作業指示書を削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get woDeleteConfirm => '削除';

  @override
  String get woDeleteSuccess => '削除に成功しました！';

  @override
  String get woDeleteFailed => '削除に失敗しました！';

  @override
  String get woDetailDeleteTitle => '作業を削除';

  @override
  String get woDetailDeleteSubtitle => 'この作業を削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get woFleetGroup => 'フリートグループ';

  @override
  String get woFleetGroupPlaceholder => 'フリートグループを選択';

  @override
  String get woTechnician => '技術者';

  @override
  String get woTechnicianPlaceholder => '技術者を選択';

  @override
  String get woDate => '日付';

  @override
  String get woDatePlaceholder => '日付を選択';

  @override
  String get woCreateTitle => '作業指示書を作成';

  @override
  String get woCreate => '作成';

  @override
  String get woCreateFailed => '作業指示書の作成に失敗しました';

  @override
  String get woWorkListTitle => '作業リスト';

  @override
  String get woWorkListEmptyTitle => '作業指示書がまだありません';

  @override
  String get woWorkListEmptyMessage => '現在、作業指示書はありません。\n新規作成して始めましょう。';

  @override
  String get woAssignButton => '作業を割り当てる';

  @override
  String get woAssignTitle => '作業指示書を作成';

  @override
  String get woWorkCategory => '作業カテゴリ';

  @override
  String get woWorkCategoryPlaceholder => '作業指示書のカテゴリを選択';

  @override
  String get woWorkType => '作業タイプ';

  @override
  String get woWorkTypePlaceholder => '作業指示書のタイプを選択';

  @override
  String get woWorkDate => '作業日';

  @override
  String get woEvidenceNotUploaded => '証拠写真がまだアップロードされていません。';

  @override
  String get woOdometerNotFilled => '走行距離が未入力です。';

  @override
  String get woGpsActive => 'GPSは有効です。';

  @override
  String get woGpsNotActive => 'GPSはまだ有効になっていません。';

  @override
  String get woDetailsTitle => '作業詳細';

  @override
  String get woTabDetails => '詳細';

  @override
  String get woTabEvidence => '証拠写真';

  @override
  String get woTabNotes => 'メモ';

  @override
  String get woDetailsEdit => '作業詳細を編集';

  @override
  String get woDetailsSave => '保存';

  @override
  String get woSavedSuccess => 'データを保存しました';

  @override
  String get woSavedFailed => 'データの保存に失敗しました';

  @override
  String get woCompleteSuccess => '作業を完了としてマークしました';

  @override
  String get woCompleteFailed => '作業の完了処理に失敗しました';

  @override
  String get woLeaveTitle => 'このページを離れてもよろしいですか？';

  @override
  String get woLeaveMessage => '保存されていないデータは失われます';

  @override
  String get woErrorBeforeImage => '設置前の証拠写真が必要です';

  @override
  String get woErrorAfterImage => '設置後の証拠写真が必要です';

  @override
  String get woErrorNotes => 'メモの入力が必要です';

  @override
  String get woActionSaveDraft => '下書きとして保存';

  @override
  String get woActionMarkComplete => '完了としてマーク';

  @override
  String get woWorkInformation => '作業詳細情報';

  @override
  String get woInspectionInformation => 'メンテナンス情報';

  @override
  String get woDeviceInformation => 'デバイス情報';

  @override
  String get woEvidenceBefore => '設置前の証拠写真';

  @override
  String get woEvidenceAfter => '設置後の証拠写真';

  @override
  String get woEvidenceTakeOrUpload => '写真を撮影またはアップロード';

  @override
  String get woEvidenceUploadTitle => '証拠写真をアップロード';

  @override
  String get woEvidenceProofTitle => '証拠写真';

  @override
  String get woEvidenceTakePhoto => '写真を撮影';

  @override
  String get woEvidenceFromGallery => 'ギャラリーから選択';

  @override
  String get woEvidenceView => '写真を見る';

  @override
  String get woEvidenceReplace => '写真を差し替える';

  @override
  String get woEvidenceDelete => '写真を削除';

  @override
  String get woEvidenceInvalidFormat =>
      '対応していないファイル形式です。JPG、JPEG、PNGのいずれかをご使用ください。';

  @override
  String get woEvidenceProcessFailed => '画像の処理に失敗しました';

  @override
  String get woNotesTitle => 'メモ';

  @override
  String get woNotesPlaceholder => '実施した作業内容を記入してください…';

  @override
  String get woJobCategory => '作業カテゴリ';

  @override
  String get woJobType => '作業タイプ';

  @override
  String get woLicensePlate => 'ナンバープレート';

  @override
  String get woLicensePlatePlaceholder => 'ナンバープレートを入力…';

  @override
  String get woLicensePlateRequired => 'ナンバープレートは必須です';

  @override
  String get woUseChassisNumber => '車台番号を使用';

  @override
  String get woChassisNumber => '車台番号';

  @override
  String get woChassisNumberPlaceholder => '例：MHFJB8BS0AK000000';

  @override
  String get woOdometer => '走行距離';

  @override
  String get woOdometerPlaceholder => '走行距離を入力…';

  @override
  String get woOdometerNumeric => '走行距離は数字で入力してください';

  @override
  String get woDeviceCondition => 'デバイスの状態';

  @override
  String get woDeviceConditionPlaceholder => 'デバイスの状態を入力…';

  @override
  String get woDeviceType => 'デバイスタイプ';

  @override
  String get woDeviceModel => 'デバイスモデル';

  @override
  String get woDeviceModelPlaceholder => 'デバイスモデルを選択';

  @override
  String get woDeviceModelRequired => 'デバイスモデルは必須です';

  @override
  String get woSimCardNumber => 'SIMカード番号';

  @override
  String get woSimCardNumberOptional => 'SIMカード番号（任意）';

  @override
  String get woSimCardNumberPlaceholder => 'SIMカード番号を入力…';

  @override
  String get woSimCardNumeric => 'SIMカード番号は数字で入力してください';

  @override
  String get woImei => 'IMEI OBD番号';

  @override
  String get woImeiPlaceholder => 'IMEI OBD番号を入力…';

  @override
  String get woImeiNumeric => 'IMEIは数字で入力してください';

  @override
  String get woImeiMaxLength => 'IMEIは15桁以内で入力してください';

  @override
  String get woDashcamType => 'ドライブレコーダーの種類';

  @override
  String get woDashcamTypePlaceholder => 'ドライブレコーダーの種類を選択';

  @override
  String get woDashcamTypeRequired => 'ドライブレコーダーの種類は必須です';

  @override
  String get woDashcamImei => 'ドライブレコーダーIMEI';

  @override
  String get woDashcamImeiPlaceholder => 'ドライブレコーダーIMEIを入力';

  @override
  String get woDashcamImeiNumeric => 'ドライブレコーダーIMEIは数字で入力してください';

  @override
  String get woCameraPosition => 'カメラの位置';

  @override
  String get woCameraPositionPlaceholder => 'カメラの位置を選択';

  @override
  String get woCameraPositionRequired => 'カメラの位置は必須です';

  @override
  String get woSensorType => 'センサーの種類';

  @override
  String get woSensorTypePlaceholder => 'センサーの種類を選択';

  @override
  String get woSensorTypeRequired => 'センサーの種類は必須です';

  @override
  String get woSensorSerialNumber => 'シリアル番号';

  @override
  String get woSensorSerialNumberPlaceholder => 'シリアル番号を入力';

  @override
  String get woSensorPosition => 'センサーの位置';

  @override
  String get woSensorPositionPlaceholder => 'センサーの位置を選択';

  @override
  String get woSensorPositionRequired => 'センサーの位置は必須です';

  @override
  String get woSimReplacementTitle => '新しいSIMカード番号';

  @override
  String get woSimReplacementPlaceholder => '新しいSIMカード番号を入力…';

  @override
  String get woInspectionAction => '対応内容';

  @override
  String get woInspectionActionPlaceholder => 'メンテナンスの対応内容を選択';

  @override
  String get woInspectionResult => 'メンテナンス結果';

  @override
  String get woInspectionResultPlaceholder => 'メンテナンスの詳細を記入してください…';

  @override
  String get woCurrentDeviceTitle => '現在のデバイス情報';

  @override
  String get woCurrentDeviceType => 'デバイスタイプ';

  @override
  String get woCurrentDeviceModel => 'デバイスモデル';

  @override
  String get woCurrentDeviceSimCard => 'SIMカード番号';

  @override
  String get woCurrentDeviceImei => 'IMEI OBD番号';

  @override
  String get woReviewWorkDetails => '作業詳細情報';

  @override
  String get woStepDetails => '作業詳細情報';

  @override
  String get woStepInformation => 'デバイス情報';

  @override
  String get woStepInspection => 'メンテナンス情報';

  @override
  String get woStepReview => '確認';

  @override
  String get woStepPrev => '戻る';

  @override
  String get woStepNext => '次へ';

  @override
  String get woStepSubmit => '作業指示書を送信';

  @override
  String get woCreateDetailTitle => '作業指示書を作成';

  @override
  String get woUpdateDetailTitle => '作業指示書を更新';

  @override
  String get woSubmitConfirmTitle => '作業指示書の確認';

  @override
  String get woSubmitConfirmMessage =>
      '内容をよくご確認ください。作業指示書の情報が正しいことを確認して送信してください。';

  @override
  String get woCreateDetailSuccess => '詳細を追加しました！';

  @override
  String get woCreateDetailFailed => '詳細の追加に失敗しました！';

  @override
  String get woUpdateDetailSuccess => '作業指示書の詳細を更新しました';

  @override
  String get woUpdateDetailFailed => '作業指示書の詳細の更新に失敗しました';

  @override
  String get woVehicleInfoFailed => '車両情報の取得に失敗しました';

  @override
  String get vehicleCategoryBus => 'バス';

  @override
  String get vehicleCategoryPassenger => '乗用車';

  @override
  String get vehicleCategoryTruck => 'トラック';

  @override
  String get vehicleCategoryChiller => 'チラー車';

  @override
  String get vehicleCategoryFreezer => 'フリーザー車';

  @override
  String get vehicleCategoryChillerFreezer => 'チラー＆フリーザー車';

  @override
  String get vehicleCategoryFreezerChiller => 'フリーザー＆チラー車';

  @override
  String get periodicMetricIgnition => 'イグニッション';

  @override
  String get periodicMetricAccuVoltage => 'バッテリー電圧';

  @override
  String get periodicMetricTemperature => '温度';

  @override
  String get periodicTrack => '定期トラッキング';

  @override
  String get noDataAvailable => 'データがありません';

  @override
  String get periodicStartDateRequired => '開始日を選択してください';

  @override
  String get periodicEndDateRequired => '終了日を選択してください';

  @override
  String get periodicEndDateBeforeStart => '終了日は開始日より前にできません';

  @override
  String get periodicMaxRangeExceeded => '開始日から最大3日間までの範囲を選択できます';

  @override
  String get activityAllVehicle => 'すべての車両';

  @override
  String get activityInOperation => '稼働中';

  @override
  String get activityMoving => '走行中';

  @override
  String get activityIdle => 'アイドリング';

  @override
  String get activityStop => '停止中';

  @override
  String get activitySilence => '無通信';

  @override
  String get activityInRepair => '修理中';

  @override
  String get filterTypeLabel => '種類';

  @override
  String get filterChooseType => 'フィルターの種類を選択';

  @override
  String get filterTypeTitle => 'フィルターの種類';

  @override
  String get filterGeofence => 'ジオフェンス';

  @override
  String get filterChooseGeofence => 'ジオフェンスを選択';

  @override
  String get filterAllGeofence => 'すべてのジオフェンス';

  @override
  String get filterSearchHint => '検索…';

  @override
  String get dashcam => 'ドライブレコーダー';

  @override
  String get dashcamCameraOffline => 'カメラは現在オフラインです。';

  @override
  String get dashcamDeviceBusy => 'デバイスが混雑しています';

  @override
  String get dashcamDeviceError => 'デバイスでエラーが発生しました';

  @override
  String get dashcamWebsocketFailed => 'WebSocket接続に失敗しました';

  @override
  String get dashcamEnableSpeakerFirst => 'マイクを使用する前にスピーカーをオンにしてください';

  @override
  String get dashcamNoChannels => '利用可能なドライブレコーダーのチャンネルがありません。';

  @override
  String get dashcamSpeaker => 'スピーカー';

  @override
  String get dashcamIntercom => 'インターホン';

  @override
  String get channelCameraOfflineFallback => 'カメラはオフラインです。';

  @override
  String get channelCameraOffToggle => 'カメラはオフです。タップして表示してください。';

  @override
  String get fullscreenMutedHint => 'ミュート中 — 音声にはスピーカーを使用してください';

  @override
  String get fullscreenExit => 'フルスクリーンを終了';

  @override
  String get statusOn => 'ON';

  @override
  String get statusOff => 'OFF';

  @override
  String get statusNA => '該当なし';

  @override
  String get engineOn => 'エンジン始動中';

  @override
  String get engineOff => 'エンジン停止中';

  @override
  String engineLastOn(Object time) {
    return 'エンジン始動（$time）';
  }

  @override
  String get chillerUnit => 'チラーユニット';

  @override
  String get demoVersionBanner => 'デモ版 — サンプルデータ';

  @override
  String get mediaLabel => 'メディア';

  @override
  String get notifNotYetValidated => '未承認';

  @override
  String get otpEmailNotFound => 'メールアドレスが見つかりません。';

  @override
  String get otpWaitBeforeResend => 'コードの再送信まで少々お待ちください。';

  @override
  String get otpSendFailed => 'コードの送信に失敗しました。';

  @override
  String get otpSendFailedCheckConnection => 'コードの送信に失敗しました。接続をご確認ください。';

  @override
  String get continueWithDemo => 'デモ版で続ける';

  @override
  String get woLabelInspectionNote => '点検メモ';

  @override
  String get woLabelSensorSerialNumber => 'センサーシリアル番号';

  @override
  String get woLabelTechnicianName => '技術者氏名';

  @override
  String get errInvalidResponse => 'レスポンスの形式が無効です';

  @override
  String get errLoadAlertTypeFailed => 'アラートタイプの読み込みに失敗しました';

  @override
  String get errLoadFleetGroupFailed => 'フリートグループの読み込みに失敗しました';

  @override
  String get errLoadMonitoringFailed => 'モニタリングデータの読み込み中にエラーが発生しました';

  @override
  String get errLoadVehiclePositionFailed => '車両位置の読み込み中にエラーが発生しました';

  @override
  String get errGenericTryAgain => 'エラーが発生しました。もう一度お試しください';

  @override
  String get errConnectionTimeout =>
      'サーバーへの接続がタイムアウトしました。インターネット接続を確認して再度お試しください。';

  @override
  String get errConnectionFailed => 'サーバーに接続できません。インターネット接続を確認してください。';

  @override
  String get errInsecureConnection => 'サーバーへの接続が安全ではありません。管理者に連絡してください。';

  @override
  String get errRequestCancelled => 'リクエストがキャンセルされました。';

  @override
  String get errNoInternetConnection =>
      'インターネットに接続されていません。ネットワークを確認して再度お試しください。';

  @override
  String errFieldsRequired(Object fields) {
    return '$fieldsを入力してください。';
  }

  @override
  String get errFieldsJoiner => 'および';

  @override
  String get errIncompleteData => '入力内容が不完全です。';

  @override
  String get errInvalidCredentials => '入力されたメールアドレスまたはパスワードが正しくありません。';

  @override
  String get errServerProblem => 'サーバーで問題が発生しています。しばらくしてから再度お試しください。';

  @override
  String get errServiceUnavailable =>
      'この機能は現在ご利用いただけません。しばらくしてから再度お試しいただくか、管理者にお問い合わせください。';

  @override
  String get errNoAccess => 'このデータにアクセスする権限がありません。';

  @override
  String get errDuplicateData => 'このデータはすでに登録されています。別のデータを使用してください。';

  @override
  String get dashcamServiceUnavailable =>
      'カメラサービスは現在ご利用いただけません。管理者にお問い合わせください。';

  @override
  String get relativeJustNow => 'たった今';

  @override
  String get relativeYesterday => '昨日';

  @override
  String relativeSeconds(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count秒前',
    );
    return '$_temp0';
  }

  @override
  String relativeMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分前',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間前',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日前',
    );
    return '$_temp0';
  }

  @override
  String relativeWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count週間前',
    );
    return '$_temp0';
  }

  @override
  String relativeMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか月前',
    );
    return '$_temp0';
  }

  @override
  String relativeYears(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年前',
    );
    return '$_temp0';
  }
}
