/// 앱 버전 비교 · 업데이트 판정.
///
/// Firestore·Flutter 의존이 없는 **순수 로직**이라 단위 테스트로 검증한다
/// (`test/version_utils_test.dart`). 판정 기준을 여기 한 곳에만 둬서
/// 게이트 화면·뷰모델이 각자 다른 규칙을 갖지 않게 한다.
library;

/// 버전 게이트가 내리는 결정.
///
/// 우선순위: [maintenance] > [force] > [optional] > [ok].
enum VersionAction {
  /// 그대로 앱 진입.
  ok,

  /// 업데이트 권유 — 닫을 수 있는 안내.
  optional,

  /// 강제 업데이트 — 앱 사용 차단.
  force,

  /// 서버 점검 — 버전과 무관하게 차단.
  maintenance,
}

/// 버전 문자열 비교. `a > b` 면 양수, 같으면 0, `a < b` 면 음수.
///
/// - 자릿수가 달라도 됨 (`"1.2"` == `"1.2.0"`).
/// - 빌드번호·프리릴리스 꼬리는 무시 (`"1.2.0+7"`, `"1.2.0-beta1"` → `1.2.0`).
///   스토어에 노출되는 건 버전명이므로 정책도 버전명만 본다.
/// - 숫자로 못 읽는 파트는 0 취급 — 정책 문서 오타로 예외를 던지지 않는다.
int compareVersion(String a, String b) {
  final left = _parts(a);
  final right = _parts(b);
  final length = left.length > right.length ? left.length : right.length;

  for (var i = 0; i < length; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) return l < r ? -1 : 1;
  }
  return 0;
}

List<int> _parts(String version) {
  // 빌드번호(+7)·프리릴리스(-beta1) 제거 후 점으로 분해.
  final core = version.trim().split(RegExp(r'[+\-]')).first;
  if (core.isEmpty) return const [0];
  return core.split('.').map((part) {
    final digits = RegExp(r'\d+').firstMatch(part)?.group(0);
    return digits == null ? 0 : (int.tryParse(digits) ?? 0);
  }).toList();
}

/// 현재 버전과 서버 정책으로 게이트 동작을 정한다.
///
/// **fail-open** — 현재 버전을 못 읽었거나(빈 문자열) 정책 값이 비어 있으면
/// 막지 않는다. 서버 사고로 전 유저 앱이 잠기는 쪽이 업데이트를 한 번
/// 놓치는 것보다 훨씬 나쁘다.
VersionAction decideVersionAction({
  required String currentVersion,
  required String minVersion,
  required String latestVersion,
  bool isMaintenance = false,
}) {
  // 점검은 버전보다 우선 — 최신 버전 유저도 들어가면 안 된다.
  if (isMaintenance) return VersionAction.maintenance;
  if (currentVersion.trim().isEmpty) return VersionAction.ok;

  if (minVersion.trim().isNotEmpty &&
      compareVersion(currentVersion, minVersion) < 0) {
    return VersionAction.force;
  }
  if (latestVersion.trim().isNotEmpty &&
      compareVersion(currentVersion, latestVersion) < 0) {
    return VersionAction.optional;
  }
  return VersionAction.ok;
}
