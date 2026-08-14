import 'package:vybe/data/models/app_version_config_model.dart';

abstract interface class AppConfigRepository {
  /// 플랫폼별 버전 정책. 문서가 없으면 null.
  /// [platform] 은 "android" | "ios".
  Future<AppVersionConfigModel?> getVersionConfig(String platform);
}
