import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/utils/version_utils.dart';
import 'package:vybe/data/models/app_version_config_model.dart';
import 'package:vybe/data/repositories/app_config_repository_impl.dart';

part 'version_check_viewmodel.g.dart';

/// 조회 제한 시간. 앱 첫 화면을 붙잡는 구간이라 짧게 — 넘기면 통과시킨다.
const _timeout = Duration(seconds: 3);

/// 버전 게이트 판정 결과. 화면은 이 값만 보고 그린다.
class VersionCheckResult {
  final VersionAction action;

  /// 서버 정책. 조회 실패·문서 없음이면 null (이때 action은 항상 ok).
  final AppVersionConfigModel? config;

  /// 설치된 앱 버전명 (예: "1.0.0"). 못 읽었으면 빈 문자열.
  final String currentVersion;

  /// 설치된 앱 빌드번호 (예: "1"). 못 읽었으면 빈 문자열.
  final String buildNumber;

  /// 패키지명(Android). storeUrl이 비었을 때 스토어 폴백에 쓴다.
  final String packageName;

  const VersionCheckResult({
    required this.action,
    required this.config,
    required this.currentVersion,
    required this.buildNumber,
    this.packageName = '',
  });

  /// 통과 결과 — fail-open 경로에서 쓴다.
  const VersionCheckResult.pass({
    this.currentVersion = '',
    this.buildNumber = '',
    this.packageName = '',
  })  : action = VersionAction.ok,
        config = null;

  bool get isBlocked =>
      action == VersionAction.force || action == VersionAction.maintenance;

  /// 서버 문구가 있으면 그것, 비었으면 화면이 준 기본 문구.
  /// (config가 null인 fail-open 경로도 같은 분기로 처리된다)
  String updateTitleOr(String fallback) => _or(config?.updateTitle, fallback);

  String updateMessageOr(String fallback) =>
      _or(config?.updateMessage, fallback);

  String maintenanceMessageOr(String fallback) =>
      _or(config?.maintenanceMessage, fallback);

  static String _or(String? value, String fallback) =>
      (value == null || value.isEmpty) ? fallback : value;

  /// 설정 화면 표시용 (예: "1.0.0 (1)").
  String get versionLabel {
    if (currentVersion.isEmpty) return '';
    return buildNumber.isEmpty
        ? currentVersion
        : '$currentVersion ($buildNumber)';
  }
}

/// 앱 실행·복귀 시 버전 정책을 확인한다.
///
/// **fail-open** — 네트워크 실패·타임아웃·문서 없음·파싱 실패는 전부 통과.
/// 서버 사고로 전 유저가 앱에 못 들어가는 쪽이 훨씬 큰 사고다.
/// keepAlive — 게이트가 트리 최상단이라 재생성될 일이 없고, 화면 전환마다
/// 재조회되면 안 된다.
@Riverpod(keepAlive: true)
class VersionCheck extends _$VersionCheck {
  @override
  Future<VersionCheckResult> build() => _check();

  /// 앱 복귀(resumed) 시 재검사. 앱을 며칠 켜둔 기기가 강제 업데이트를
  /// 영원히 피하는 구멍을 막는다.
  ///
  /// 재조회 중에도 직전 결과를 유지한다(`AsyncValue.guard` 대신 수동 처리) —
  /// 복귀할 때마다 스플래시가 번쩍이지 않게.
  Future<void> recheck() async {
    final result = await _check();
    state = AsyncData(result);
  }

  Future<VersionCheckResult> _check() async {
    final info = await _packageInfo();
    final current = info?.version ?? '';
    final build = info?.buildNumber ?? '';
    final package = info?.packageName ?? '';

    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final config = await ref
          .read(appConfigRepositoryProvider)
          .getVersionConfig(platform)
          .timeout(_timeout);

      if (config == null) {
        return VersionCheckResult.pass(
          currentVersion: current,
          buildNumber: build,
          packageName: package,
        );
      }
      return VersionCheckResult(
        action: config.actionFor(current),
        config: config,
        currentVersion: current,
        buildNumber: build,
        packageName: package,
      );
    } catch (_) {
      // 조회 실패는 통과. 여기서만 삼킨다(datasource는 그대로 던진다).
      return VersionCheckResult.pass(
        currentVersion: current,
        buildNumber: build,
        packageName: package,
      );
    }
  }

  Future<PackageInfo?> _packageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      // 플러그인 미등록(테스트 환경 등) — 버전 미상으로 두면 판정이 통과된다.
      return null;
    }
  }
}
