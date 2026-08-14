import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vybe/core/utils/version_utils.dart';

part 'app_version_config_model.freezed.dart';

/// 플랫폼별 버전 정책 (`appConfig/android` · `appConfig/ios`).
/// 쓰기는 어드민 페이지 전용 — 앱은 실행 시 1건만 읽는다.
///
/// Android/iOS는 스토어 심사·배포 시점이 달라 문서를 플랫폼별로 나눈다
/// (한쪽만 minVersion을 올릴 수 있어야 한다).
@freezed
abstract class AppVersionConfigModel with _$AppVersionConfigModel {
  const AppVersionConfigModel._();

  const factory AppVersionConfigModel({
    /// "android" | "ios" (= 문서 ID)
    required String platform,

    /// 이 버전 미만이면 강제 업데이트. 비면 강제 없음.
    @Default('') String minVersion,

    /// 이 버전 미만이면 업데이트 권유(닫을 수 있음). 비면 권유 없음.
    @Default('') String latestVersion,

    /// 스토어 링크. 앱 배포 없이 바꿀 수 있게 서버에 둔다.
    @Default('') String storeUrl,

    /// 업데이트 안내 제목·본문. 비면 화면의 기본 문구를 쓴다.
    @Default('') String updateTitle,
    @Default('') String updateMessage,

    /// 점검 모드 — 버전과 무관하게 앱 진입을 막는다.
    @Default(false) bool isMaintenance,
    @Default('') String maintenanceMessage,
    required DateTime updatedAt,
  }) = _AppVersionConfigModel;

  /// 현재 설치 버전에 대한 게이트 동작.
  /// 판정 규칙 자체는 [decideVersionAction] 한 곳에만 있다.
  VersionAction actionFor(String currentVersion) => decideVersionAction(
        currentVersion: currentVersion,
        minVersion: minVersion,
        latestVersion: latestVersion,
        isMaintenance: isMaintenance,
      );

  factory AppVersionConfigModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    return AppVersionConfigModel(
      platform: data['platform'] as String? ?? doc.id,
      minVersion: data['minVersion'] as String? ?? '',
      latestVersion: data['latestVersion'] as String? ?? '',
      storeUrl: data['storeUrl'] as String? ?? '',
      updateTitle: data['updateTitle'] as String? ?? '',
      updateMessage: data['updateMessage'] as String? ?? '',
      isMaintenance: data['isMaintenance'] as bool? ?? false,
      maintenanceMessage: data['maintenanceMessage'] as String? ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
