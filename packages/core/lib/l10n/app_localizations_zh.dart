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

  @override
  String get navWorkOrder => '工单';

  @override
  String get woSearchPlaceholder => '搜索车队组……';

  @override
  String get woNoDataTitle => '暂无工单';

  @override
  String get woNoDataMessage => '您目前还没有任何工单。\n创建一个新工单以开始。';

  @override
  String get woOptionDetails => '查看工作详情';

  @override
  String get woOptionDelete => '删除工作';

  @override
  String get woDeleteTitle => '删除工单';

  @override
  String get woDeleteSubtitle => '确定要删除此工单吗？此操作无法撤销。';

  @override
  String get woDeleteConfirm => '删除';

  @override
  String get woDeleteSuccess => '删除成功！';

  @override
  String get woDeleteFailed => '删除失败！';

  @override
  String get woDetailDeleteTitle => '删除工作';

  @override
  String get woDetailDeleteSubtitle => '确定要删除此工作吗？此操作无法撤销。';

  @override
  String get woFleetGroup => '车队组';

  @override
  String get woFleetGroupPlaceholder => '选择车队组';

  @override
  String get woTechnician => '技术员';

  @override
  String get woTechnicianPlaceholder => '选择技术员';

  @override
  String get woDate => '日期';

  @override
  String get woDatePlaceholder => '选择日期';

  @override
  String get woCreateTitle => '创建工单';

  @override
  String get woCreate => '创建';

  @override
  String get woCreateFailed => '创建工单失败';

  @override
  String get woWorkListTitle => '工作列表';

  @override
  String get woWorkListEmptyTitle => '暂无工单';

  @override
  String get woWorkListEmptyMessage => '您目前还没有任何工单。\n创建一个新工单以开始。';

  @override
  String get woAssignButton => '分配工作';

  @override
  String get woAssignTitle => '创建工单';

  @override
  String get woWorkCategory => '工作类别';

  @override
  String get woWorkCategoryPlaceholder => '选择工单类别';

  @override
  String get woWorkType => '工作类型';

  @override
  String get woWorkTypePlaceholder => '选择工单类型';

  @override
  String get woWorkDate => '工作日期';

  @override
  String get woEvidenceNotUploaded => '尚未上传证明照片。';

  @override
  String get woOdometerNotFilled => '尚未填写里程表。';

  @override
  String get woGpsActive => 'GPS已启用。';

  @override
  String get woGpsNotActive => 'GPS尚未启用。';

  @override
  String get woDetailsTitle => '工作详情';

  @override
  String get woTabDetails => '详情';

  @override
  String get woTabEvidence => '证明照片';

  @override
  String get woTabNotes => '备注';

  @override
  String get woDetailsEdit => '编辑工作详情';

  @override
  String get woDetailsSave => '保存';

  @override
  String get woSavedSuccess => '数据保存成功';

  @override
  String get woSavedFailed => '保存数据失败';

  @override
  String get woCompleteSuccess => '工作已标记为完成';

  @override
  String get woCompleteFailed => '标记完成失败';

  @override
  String get woLeaveTitle => '确定要离开此页面吗？';

  @override
  String get woLeaveMessage => '未保存的数据将会丢失';

  @override
  String get woErrorBeforeImage => '需要提供安装前证明照片';

  @override
  String get woErrorAfterImage => '需要提供安装后证明照片';

  @override
  String get woErrorNotes => '需要填写备注';

  @override
  String get woActionSaveDraft => '保存为草稿';

  @override
  String get woActionMarkComplete => '标记为完成';

  @override
  String get woWorkInformation => '工作详情信息';

  @override
  String get woInspectionInformation => '维护信息';

  @override
  String get woDeviceInformation => '设备信息';

  @override
  String get woEvidenceBefore => '安装前证明照片';

  @override
  String get woEvidenceAfter => '安装后证明照片';

  @override
  String get woEvidenceTakeOrUpload => '拍照或上传照片';

  @override
  String get woEvidenceUploadTitle => '上传证明照片';

  @override
  String get woEvidenceProofTitle => '证明照片';

  @override
  String get woEvidenceTakePhoto => '拍照';

  @override
  String get woEvidenceFromGallery => '从相册选择';

  @override
  String get woEvidenceView => '查看照片';

  @override
  String get woEvidenceReplace => '更换照片';

  @override
  String get woEvidenceDelete => '删除照片';

  @override
  String get woEvidenceInvalidFormat => '不支持的文件格式。请使用JPG、JPEG或PNG格式。';

  @override
  String get woEvidenceProcessFailed => '处理图片失败';

  @override
  String get woNotesTitle => '备注';

  @override
  String get woNotesPlaceholder => '描述已完成的工作……';

  @override
  String get woJobCategory => '工作类别';

  @override
  String get woJobType => '工作类型';

  @override
  String get woLicensePlate => '车牌号';

  @override
  String get woLicensePlatePlaceholder => '请输入车牌号……';

  @override
  String get woLicensePlateRequired => '车牌号为必填项';

  @override
  String get woUseChassisNumber => '使用车架号';

  @override
  String get woChassisNumber => '车架号';

  @override
  String get woChassisNumberPlaceholder => '例如 MHFJB8BS0AK000000';

  @override
  String get woOdometer => '里程表';

  @override
  String get woOdometerPlaceholder => '请输入里程表……';

  @override
  String get woOdometerNumeric => '里程表必须为数字';

  @override
  String get woDeviceCondition => '设备状况';

  @override
  String get woDeviceConditionPlaceholder => '请输入设备状况……';

  @override
  String get woDeviceType => '设备类型';

  @override
  String get woDeviceModel => '设备型号';

  @override
  String get woDeviceModelPlaceholder => '选择设备型号';

  @override
  String get woDeviceModelRequired => '设备型号为必填项';

  @override
  String get woSimCardNumber => 'SIM卡号';

  @override
  String get woSimCardNumberOptional => 'SIM卡号（选填）';

  @override
  String get woSimCardNumberPlaceholder => '请输入SIM卡号……';

  @override
  String get woSimCardNumeric => 'SIM卡号必须为数字';

  @override
  String get woImei => 'IMEI OBD编号';

  @override
  String get woImeiPlaceholder => '请输入IMEI OBD编号……';

  @override
  String get woImeiNumeric => 'IMEI必须为数字';

  @override
  String get woImeiMaxLength => 'IMEI最多15位数字';

  @override
  String get woDashcamType => '行车记录仪类型';

  @override
  String get woDashcamTypePlaceholder => '选择行车记录仪类型';

  @override
  String get woDashcamTypeRequired => '行车记录仪类型为必填项';

  @override
  String get woDashcamImei => '行车记录仪IMEI';

  @override
  String get woDashcamImeiPlaceholder => '请输入行车记录仪IMEI';

  @override
  String get woDashcamImeiNumeric => '行车记录仪IMEI必须为数字';

  @override
  String get woCameraPosition => '摄像头位置';

  @override
  String get woCameraPositionPlaceholder => '选择摄像头位置';

  @override
  String get woCameraPositionRequired => '摄像头位置为必填项';

  @override
  String get woSensorType => '传感器类型';

  @override
  String get woSensorTypePlaceholder => '选择传感器类型';

  @override
  String get woSensorTypeRequired => '传感器类型为必填项';

  @override
  String get woSensorSerialNumber => '序列号';

  @override
  String get woSensorSerialNumberPlaceholder => '请输入序列号';

  @override
  String get woSensorPosition => '传感器位置';

  @override
  String get woSensorPositionPlaceholder => '选择传感器位置';

  @override
  String get woSensorPositionRequired => '传感器位置为必填项';

  @override
  String get woSimReplacementTitle => '新SIM卡号';

  @override
  String get woSimReplacementPlaceholder => '请输入新SIM卡号……';

  @override
  String get woInspectionAction => '操作';

  @override
  String get woInspectionActionPlaceholder => '选择维护操作';

  @override
  String get woInspectionResult => '维护结果';

  @override
  String get woInspectionResultPlaceholder => '请提供维护详情……';

  @override
  String get woCurrentDeviceTitle => '当前设备信息';

  @override
  String get woCurrentDeviceType => '设备类型';

  @override
  String get woCurrentDeviceModel => '设备型号';

  @override
  String get woCurrentDeviceSimCard => 'SIM卡号';

  @override
  String get woCurrentDeviceImei => 'IMEI OBD编号';

  @override
  String get woReviewWorkDetails => '工作详情信息';

  @override
  String get woStepDetails => '工作详情信息';

  @override
  String get woStepInformation => '设备信息';

  @override
  String get woStepInspection => '维护信息';

  @override
  String get woStepReview => '审核';

  @override
  String get woStepPrev => '上一步';

  @override
  String get woStepNext => '下一步';

  @override
  String get woStepSubmit => '提交工单';

  @override
  String get woCreateDetailTitle => '创建工单';

  @override
  String get woUpdateDetailTitle => '更新工单';

  @override
  String get woSubmitConfirmTitle => '工单确认';

  @override
  String get woSubmitConfirmMessage => '请仔细核对详情。确认工单信息正确并准备提交。';

  @override
  String get woCreateDetailSuccess => '成功添加详情！';

  @override
  String get woCreateDetailFailed => '添加详情失败！';

  @override
  String get woUpdateDetailSuccess => '工单详情更新成功';

  @override
  String get woUpdateDetailFailed => '更新工单详情失败';

  @override
  String get woVehicleInfoFailed => '获取车辆信息失败';

  @override
  String get vehicleCategoryBus => '巴士';

  @override
  String get vehicleCategoryPassenger => '乘用车';

  @override
  String get vehicleCategoryTruck => '卡车';

  @override
  String get vehicleCategoryChiller => '冷藏车';

  @override
  String get vehicleCategoryFreezer => '冷冻车';

  @override
  String get vehicleCategoryChillerFreezer => '冷藏冷冻两用车';

  @override
  String get vehicleCategoryFreezerChiller => '冷冻冷藏两用车';

  @override
  String get periodicMetricIgnition => '点火';

  @override
  String get periodicMetricAccuVoltage => '蓄电池电压';

  @override
  String get periodicMetricTemperature => '温度';

  @override
  String get periodicTrack => '周期追踪';

  @override
  String get noDataAvailable => '暂无数据';

  @override
  String get periodicStartDateRequired => '请选择开始日期';

  @override
  String get periodicEndDateRequired => '请选择结束日期';

  @override
  String get periodicEndDateBeforeStart => '结束日期不能早于开始日期';

  @override
  String get periodicMaxRangeExceeded => '距开始日期最长范围为3天';

  @override
  String get activityAllVehicle => '所有车辆';

  @override
  String get activityInOperation => '运营中';

  @override
  String get activityMoving => '行驶中';

  @override
  String get activityIdle => '怠速';

  @override
  String get activityStop => '停止';

  @override
  String get activitySilence => '静默';

  @override
  String get activityInRepair => '维修中';

  @override
  String get filterTypeLabel => '类型';

  @override
  String get filterChooseType => '选择筛选类型';

  @override
  String get filterTypeTitle => '筛选类型';

  @override
  String get filterGeofence => '地理围栏';

  @override
  String get filterChooseGeofence => '选择地理围栏';

  @override
  String get filterAllGeofence => '所有地理围栏';

  @override
  String get filterSearchHint => '搜索……';

  @override
  String get dashcam => '行车记录仪';

  @override
  String get dashcamCameraOffline => '摄像头当前处于离线状态。';

  @override
  String get dashcamDeviceBusy => '设备正忙';

  @override
  String get dashcamDeviceError => '设备发生错误';

  @override
  String get dashcamWebsocketFailed => 'WebSocket连接失败';

  @override
  String get dashcamEnableSpeakerFirst => '使用麦克风前请先开启扬声器';

  @override
  String get dashcamNoChannels => '没有可用的行车记录仪通道。';

  @override
  String get dashcamSpeaker => '扬声器';

  @override
  String get dashcamIntercom => '对讲';

  @override
  String get channelCameraOfflineFallback => '摄像头已离线。';

  @override
  String get channelCameraOffToggle => '摄像头已关闭，点击开启查看。';

  @override
  String get fullscreenMutedHint => '已静音 — 使用扬声器播放音频';

  @override
  String get fullscreenExit => '退出全屏';

  @override
  String get statusOn => '开启';

  @override
  String get statusOff => '关闭';

  @override
  String get statusNA => '无';

  @override
  String get engineOn => '引擎已启动';

  @override
  String get engineOff => '引擎已熄火';

  @override
  String engineLastOn(Object time) {
    return '引擎已启动（$time）';
  }

  @override
  String get chillerUnit => '冷藏机组';

  @override
  String get demoVersionBanner => '演示版本 — 示例数据';

  @override
  String get mediaLabel => '媒体';

  @override
  String get notifNotYetValidated => '尚未审核';

  @override
  String get otpEmailNotFound => '未找到邮箱地址。';

  @override
  String get otpWaitBeforeResend => '请稍候再重新请求验证码。';

  @override
  String get otpSendFailed => '验证码发送失败。';

  @override
  String get otpSendFailedCheckConnection => '验证码发送失败，请检查网络连接。';

  @override
  String get continueWithDemo => '以演示模式继续';

  @override
  String get woLabelInspectionNote => '检查备注';

  @override
  String get woLabelSensorSerialNumber => '传感器序列号';

  @override
  String get woLabelTechnicianName => '技术员姓名';

  @override
  String get errInvalidResponse => '响应格式无效';

  @override
  String get errLoadAlertTypeFailed => '加载提醒类型失败';

  @override
  String get errLoadFleetGroupFailed => '加载车队组失败';

  @override
  String get errLoadMonitoringFailed => '加载监控数据时发生错误';

  @override
  String get errLoadVehiclePositionFailed => '加载车辆位置时发生错误';

  @override
  String get errGenericTryAgain => '发生错误，请重试';

  @override
  String get errConnectionTimeout => '连接服务器超时。请检查您的网络连接后重试。';

  @override
  String get errConnectionFailed => '无法连接到服务器。请检查您的网络连接。';

  @override
  String get errInsecureConnection => '与服务器的连接不安全，请联系管理员。';

  @override
  String get errRequestCancelled => '请求已取消。';

  @override
  String get errNoInternetConnection => '无网络连接。请检查您的网络后重试。';

  @override
  String errFieldsRequired(Object fields) {
    return '$fields为必填项。';
  }

  @override
  String get errFieldsJoiner => '和';

  @override
  String get errIncompleteData => '填写的信息不完整。';

  @override
  String get errInvalidCredentials => '您输入的邮箱或密码不正确。';

  @override
  String get errServerProblem => '服务器出现问题，请稍后再试。';

  @override
  String get errServiceUnavailable => '此功能当前不可用。请稍后再试或联系管理员。';

  @override
  String get errNoAccess => '您没有访问此数据的权限。';

  @override
  String get errDuplicateData => '该数据已注册。请使用其他数据。';

  @override
  String get dashcamServiceUnavailable => '摄像头服务当前不可用。请联系管理员。';

  @override
  String get relativeJustNow => '刚刚';

  @override
  String get relativeYesterday => '昨天';

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
      other: '$count分钟前',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时前',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count天前',
    );
    return '$_temp0';
  }

  @override
  String relativeWeeks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count周前',
    );
    return '$_temp0';
  }

  @override
  String relativeMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个月前',
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
