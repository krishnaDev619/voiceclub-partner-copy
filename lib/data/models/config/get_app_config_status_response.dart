class GetAppConfigStatusResponseModel {
  final bool? forceUpdate;
  final bool? isAppUnderMaintenance;
  final String? message;
  final String? appVersion;
  final String? apkUrl;
  final String? title;

  GetAppConfigStatusResponseModel({
    this.forceUpdate,
    this.isAppUnderMaintenance,
    this.message,
    this.title,
    this.appVersion,
    this.apkUrl,
  });

  GetAppConfigStatusResponseModel.fromJson(Map<String, dynamic> json)
    : forceUpdate = json['force_update'] as bool?,
      isAppUnderMaintenance = json['is_app_under_maintenance'] as bool?,
      message = json['message'] as String?,
      appVersion = json['app_version'] as String?,
      apkUrl = json['apk_url'] as String?,
      title = json['title'] as String?;

  Map<String, dynamic> toJson() => {
    'force_update': forceUpdate,
    'is_app_under_maintenance': isAppUnderMaintenance,
    'message': message,
    'apk_url': apkUrl,
    'app_version': appVersion,
    'title': title,
  };
}
