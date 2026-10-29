import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  Future<AppInfo> getAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return AppInfo.fromPackageInfo(packageInfo);
    } catch (e) {
      return AppInfo();
    }
  }
}

class AppInfo {
  final String? version;
  final int? buildNumber;

  AppInfo({this.version, this.buildNumber});

  factory AppInfo.fromPackageInfo(PackageInfo packageInfo) {
    return AppInfo(
      version: packageInfo.version,
      buildNumber: int.tryParse(packageInfo.buildNumber),
    );
  }
}
