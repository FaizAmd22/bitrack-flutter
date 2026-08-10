// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FixTrack';

  @override
  String get language => '语言';

  @override
  String get english => '英语';

  @override
  String get indonesian => '印尼语';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日语';

  @override
  String get korean => '韩语';

  @override
  String get navTracker => '追踪';

  @override
  String get navVehicle => '车辆';

  @override
  String get navNotification => '通知';

  @override
  String get navProfile => '个人资料';

  @override
  String get notifUrgent => '紧急';

  @override
  String get notifSummary => '摘要';

  @override
  String get notifNoData => '暂无提醒数据';

  @override
  String get login => '登录';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get emailPlaceholder => '请输入邮箱……';

  @override
  String get passwordPlaceholder => '请输入密码……';

  @override
  String get emailRequired => '邮箱不能为空';

  @override
  String get emailInvalid => '邮箱格式无效';

  @override
  String fieldRequired(Object name) {
    return '$name不能为空';
  }

  @override
  String get addFingerprint => '添加指纹';

  @override
  String get addFingerprintDesc => '是否保存指纹以便下次快速登录？';

  @override
  String get addFaceId => '添加面容ID';

  @override
  String get addFaceIdDesc => '是否保存面容ID以便下次快速登录？';

  @override
  String get addBiometric => '添加生物识别';

  @override
  String get addBiometricDesc => '是否保存生物识别认证以便下次快速登录？';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get biometricLoginLabel => '使用生物识别方式登录';

  @override
  String get faceIdLoginLabel => '使用面容ID登录';

  @override
  String get biometricNotSupported => '此设备不支持生物识别登录';

  @override
  String get biometricReason => '使用生物识别登录';

  @override
  String get biometricCredNotFound => '未找到生物识别登录数据';

  @override
  String get loginFailedTryAgain => '登录失败，请重试';

  @override
  String errorPrefix(Object message) {
    return '发生错误：$message';
  }

  @override
  String get notificationSettings => '通知设置';

  @override
  String get alert => '提醒';

  @override
  String get softwareUpdate => '软件更新';

  @override
  String get profileChangePassword => '修改密码';

  @override
  String get profileNotificationSetting => '通知设置';

  @override
  String get profileLanguage => '语言';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutTitle => '退出账户';

  @override
  String get signOutDesc => '确定要退出登录吗？';

  @override
  String get logout => '退出登录';

  @override
  String get searchLicensePlate => '搜索车牌号……';

  @override
  String get noVehicleYet => '暂无车辆数据';

  @override
  String get dataNotFound => '未找到数据';

  @override
  String get showPlate => '显示车牌';

  @override
  String get hidePlate => '隐藏车牌';

  @override
  String get vehicleDataCantLoaded => '无法加载车辆数据。';

  @override
  String get pleaseTryAgain => '请重试。';

  @override
  String get tryAgain => '重试。';

  @override
  String get vehicleInformation => '车辆信息';

  @override
  String get deviceInformation => '设备信息';

  @override
  String get review => '审核';

  @override
  String get tabInformation => '信息';

  @override
  String get tabStatus => '状态';

  @override
  String get tabSensor => '传感器';

  @override
  String get vehicleIdNotAvailableDesc =>
      'vehicle_id 不可用。\n请关闭此弹窗，然后从车辆详情重新打开。';

  @override
  String get failedLoadData => '加载数据失败';

  @override
  String get retry => '重试';

  @override
  String get vehicleInfoGpsDate => 'GPS日期';

  @override
  String get vehicleInfoFleetGroup => '车队组';

  @override
  String get vehicleInfoLicensePlate => '车牌号';

  @override
  String get vehicleInfoImei => 'IMEI';

  @override
  String get vehicleInfoLatitude => '纬度';

  @override
  String get vehicleInfoLongitude => '经度';

  @override
  String get vehicleInfoGoogleMap => '谷歌地图';

  @override
  String get vehicleInfoStreetView => '街景视图';

  @override
  String get showGoogleMap => '显示谷歌地图';

  @override
  String get showStreetView => '显示街景视图';

  @override
  String get vehicleStatusSpeed => '速度';

  @override
  String get vehicleStatusTotalOdometer => '总里程表';

  @override
  String get vehicleStatusInternalBattery => '内部电池';

  @override
  String get vehicleStatusExternalBattery => '外部电池';

  @override
  String get vehicleSensorFuel => '燃油';

  @override
  String get vehicleSensorDirection => '方向';

  @override
  String get vehicleSensorHumidity => '湿度';

  @override
  String get vehicleSensorLeftDoor => '左门';

  @override
  String get vehicleSensorRightDoor => '右门';

  @override
  String get vehicleSensorBackDoor => '后门';

  @override
  String get active => '启用';

  @override
  String get inactive => '停用';

  @override
  String get createdAt => '创建时间';

  @override
  String get addNewVehicleTitle => '添加新车辆';

  @override
  String get updateVehicleTitle => '更新车辆';

  @override
  String get addVehicleCta => '添加车辆';

  @override
  String get updateVehicleCta => '更新车辆';

  @override
  String get confirm => '确认';

  @override
  String get addVehicleConfirmAddTitle => '确定添加此车辆？';

  @override
  String get addVehicleConfirmAddDesc => '请花点时间确认详细信息。提交后，此车辆将添加到您的车队列表中。';

  @override
  String get addVehicleConfirmUpdateTitle => '确定更新此车辆？';

  @override
  String get addVehicleConfirmUpdateDesc => '请花点时间核实这些更改。提交后将更新车队列表中此车辆的信息。';

  @override
  String get createTodo => '添加（待办）';

  @override
  String get updateTodo => '更新（待办）';

  @override
  String get plateNumber => '车牌号';

  @override
  String get plateNumberHint => '请输入车辆车牌号……';

  @override
  String get fieldCantEmpty => '此字段不能为空';

  @override
  String get brand => '品牌';

  @override
  String get model => '型号';

  @override
  String get selectBrandHint => '选择品牌……';

  @override
  String get selectModelHint => '选择型号……';

  @override
  String get selectBrandFirst => '请先选择品牌';

  @override
  String get selectModelFirst => '请先选择型号';

  @override
  String get selectTypeHint => '选择类型……';

  @override
  String get noTypeAvailable => '暂无可用类型';

  @override
  String get vehicleType => '类型';

  @override
  String get vehicleTypeHint => '请输入车辆类型……';

  @override
  String get vehicleYear => '年份';

  @override
  String get vehicleYearHint => '请输入车辆年份……';

  @override
  String get vehicleColor => '颜色';

  @override
  String get vehicleColorHint => '请输入车辆颜色……';

  @override
  String get vehicleCategory => '车辆类别';

  @override
  String get selectVehicleCategoryHint => '选择车辆类别……';

  @override
  String get odometer => '里程表（公里）';

  @override
  String get odometerHint => '请输入车辆里程……';

  @override
  String get vin => '车架号（VIN）';

  @override
  String get vinHint => '请输入车辆VIN……';

  @override
  String get engineNumber => '发动机号';

  @override
  String get engineNumberHint => '请输入车辆发动机号……';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get installationDate => '安装日期';

  @override
  String get installationDateHint => '选择安装日期……';

  @override
  String get deviceType => '设备类型';

  @override
  String get deviceTypeHint => '选择设备类型';

  @override
  String get deviceModel => '设备型号';

  @override
  String get deviceModelHint => '选择设备型号……';

  @override
  String get simCardNumber => 'SIM卡号';

  @override
  String get simCardNumberHint => '请输入SIM卡号……';

  @override
  String get imeiObdNumber => 'IMEI OBD编号';

  @override
  String get imeiObdNumberHint => '请输入IMEI OBD编号……';

  @override
  String get otpEnterVerificationCodeTitle => '输入验证码';

  @override
  String otpSentToEmail(Object email) {
    return '验证码已发送至\n$email';
  }

  @override
  String get otpEnter5Digits => '请输入5位验证码。';

  @override
  String get otpInvalidTryAgain => '验证码无效，请重试。';

  @override
  String get otpNotReceivedEmailPrefix => '没有收到邮件？';

  @override
  String get otpTryAgain => '重新发送验证码。';

  @override
  String otpTryAgainCountdown(Object seconds) {
    return '重新发送验证码。（$seconds秒）';
  }

  @override
  String get otpCodeResentDummy => '验证码已重新发送。';

  @override
  String get otpVerifyCodeBtn => '验证验证码';

  @override
  String get passwordNewTitle => '新密码';

  @override
  String get passwordNewHint => '请输入新密码……';

  @override
  String get passwordReEnterTitle => '重新输入新密码';

  @override
  String get passwordReEnterHint => '请再次输入新密码……';

  @override
  String get passwordRuleMin8 => '至少需要8个字符';

  @override
  String get passwordRuleUpper => '至少包含1个大写字母（A-Z）';

  @override
  String get passwordRuleNumber => '至少包含1个数字（0-9）';

  @override
  String get passwordRuleSymbol => '至少包含1个符号（!、@、# 等）';

  @override
  String get passwordFillAllFields => '请填写所有字段。';

  @override
  String get passwordNotMeetRequirements => '密码不符合要求。';

  @override
  String get passwordNotMatch => '两次密码不一致。';

  @override
  String get passwordUpdatedDummy => '密码更新成功。';

  @override
  String get passwordUpdateFailed => '密码更新失败，请重试。';

  @override
  String get passwordChangeSaveBtn => '修改并保存新密码';

  @override
  String get filterTitle => '筛选';

  @override
  String get filterStartDate => '开始日期';

  @override
  String get filterEndDate => '结束日期';

  @override
  String get filterFleetGroup => '车队组';

  @override
  String get filterVerifStatus => '验证状态';

  @override
  String get filterAlertType => '提醒类型';

  @override
  String get filterApply => '应用筛选';

  @override
  String get filterClear => '清除筛选';

  @override
  String get filterChooseStartDate => '选择开始日期';

  @override
  String get filterChooseEndDate => '选择结束日期';

  @override
  String get filterChooseFleetGroup => '选择车队组';

  @override
  String get filterChooseVerifStatus => '选择验证状态';

  @override
  String get filterChooseAlertType => '选择提醒类型';

  @override
  String get filterVerified => '已验证';

  @override
  String get filterNotYetVerified => '尚未验证';

  @override
  String get filterUnverified => '未验证';

  @override
  String get filterNeedVerifications => '需要验证';

  @override
  String get filterNeedValidations => '需要审核';

  @override
  String get filterValidated => '已审核';

  @override
  String get filterSearch => '搜索';

  @override
  String get filterNoOptions => '未找到选项';

  @override
  String get filterAllFleetGroup => '所有车队组';

  @override
  String get filterAllAlertType => '所有提醒类型';

  @override
  String get gpsDate => 'GPS日期';

  @override
  String get alertType => '提醒类型';

  @override
  String get speed => '速度';

  @override
  String get addVehicleTitle => '添加车辆';

  @override
  String get addVehicleIdentifierTitle => '车牌号';

  @override
  String get addVehicleIdentifierPlaceholder => '请输入车牌号';

  @override
  String get addVehicleRequiredError => '车牌号为必填项';

  @override
  String get addVehiclePlateExistsError => '该车牌号已被注册';

  @override
  String get addVehicleCheckFailedError => '检查车牌号失败，请重试';

  @override
  String get addVehicleContinue => '继续';

  @override
  String get addVehicleChecking => '正在检查……';

  @override
  String get successAddVehicle => '车辆添加成功';

  @override
  String get successUpdateVehicle => '车辆更新成功';

  @override
  String get errFailedAdd => '添加车辆失败，请重试';

  @override
  String get errFailedUpdate => '更新车辆失败，请重试';

  @override
  String get errVinUnique => '该VIN已存在，请输入其他VIN';

  @override
  String get selectFleetGroupHint => '选择车队组';

  @override
  String get loading => '加载中……';

  @override
  String get seeNotesVerification => '查看验证备注';

  @override
  String get seeNotesValidation => '查看审核备注';

  @override
  String get showMapCoordinate => '显示地图坐标';

  @override
  String get alertNotes => '提醒备注';

  @override
  String get notes => '备注';

  @override
  String get noNotes => '暂无备注';

  @override
  String get noMedia => '暂无媒体';

  @override
  String get mapCoordinate => '地图坐标';

  @override
  String get copyCoordinate => '坐标已复制';

  @override
  String get filterAllStatus => '所有状态';

  @override
  String get registerLinkPrefix => '还没有账户？';

  @override
  String get registerLinkAction => '在此注册';

  @override
  String get registerTitle => '创建账户';

  @override
  String get registerSubtitle => '填写以下信息以创建新账户';

  @override
  String get registerFullName => '姓名';

  @override
  String get registerFullNamePlaceholder => '请输入姓名……';

  @override
  String get registerPhone => '电话号码';

  @override
  String get registerPhonePlaceholder => '请输入电话号码……';

  @override
  String get registerPhoneInvalid => '电话号码只能包含数字';

  @override
  String get registerCompanyName => '公司名称（选填）';

  @override
  String get registerCompanyNamePlaceholder => '请输入公司名称……';

  @override
  String get registerSubmitBtn => '注册';

  @override
  String get registerPendingTitle => '等待确认';

  @override
  String get registerPendingDesc => '感谢您的注册。注册通过后，确认信息将发送至您的邮箱。';

  @override
  String get registerPendingOkBtn => '知道了';
}
