import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/core/utils/version_utils.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/viewmodels/session_viewmodel.dart';
import 'package:vybe/presentation/common/network_gate/viewmodels/network_status_viewmodel.dart';
import 'package:vybe/presentation/common/version_gate/viewmodels/version_check_viewmodel.dart';

/// 화면 확인용 강제 로그인 화면 진입.
///
/// true면 **이미 로그인돼 있어도** 스플래시가 [WelcomeScreen] 으로 넘어간다 —
/// 로고가 로그인 화면 로고 자리로 날아가 앉는 연출을 매번 볼 수 있다.
/// [AuthGate] 와 [splashDestinationProvider] 가 같이 본다(둘이 어긋나면
/// 스플래시가 넘긴 화면과 실제로 그려지는 화면이 달라진다).
///
/// `kDebugMode` 안에서만 읽으므로 켠 채 커밋해도 **릴리즈 빌드는 영향 없음**.
/// 확인이 끝나면 false로 되돌릴 것.
const kDebugStartAtWelcome = false;

/// 스플래시가 넘어갈 첫 화면.
enum SplashDestination {
  /// 아직 버전·세션 검사 중 — 넘어가면 아래 게이트가 스플래시를 다시 그린다.
  pending,

  /// 홈([MainScaffold]) — 상단 바에 로고가 있어 스플래시 로고를 이어 붙일 수 있다.
  home,

  /// 홈이 아닌 화면(로그인 · 강제 업데이트 · 점검). 로고를 날려 보낼 자리가 없다.
  other,
}

/// [SplashGate] 가 언제·어떻게 넘어갈지 정하는 단일 판단.
///
/// **이 provider가 필요한 이유** — 게이트는 `SplashGate → VersionGate → AuthGate`
/// 순서라 아래 게이트는 스플래시가 끝나야 비로소 마운트되고, 그때부터 검사를
/// 시작해 자기 스플래시를 또 그린다. 화면이 똑같을 땐 티가 안 났지만 퇴장에
/// 로고 이동이 붙으면 **로고가 구석으로 날아갔다가 다시 가운데로 튄다.**
/// 여기서 미리 watch 해 두면 검사가 앱 시작과 동시에 돌고(= main.dart 주석대로
/// 진짜 병렬), 스플래시는 결과가 나온 뒤 **한 번만** 넘어간다.
///
/// 판정은 [VersionGate]·[AuthGate] 와 같은 규칙을 쓴다 — 여기서 다르게 보면
/// 스플래시가 넘긴 화면과 실제로 그려지는 화면이 어긋난다.
final splashDestinationProvider = Provider<SplashDestination>((ref) {
  // 네트워크가 먼저 — 연결이 없으면 버전 조회·세션 복원이 타임아웃까지 스플래시를
  // 붙잡기만 하고 결과도 못 준다. 여기서 끊어 [NetworkGate] 안내로 바로 보낸다.
  final network = ref.watch(networkStatusProvider);
  if (!network.hasValue && !network.hasError) return SplashDestination.pending;
  if (network.value == false) return SplashDestination.other;

  final version = ref.watch(versionCheckProvider);
  final versionResult = version.value;
  // 조회 실패는 통과(fail-open) — 에러면 기다리지 않고 아래 판정으로 넘어간다.
  if (versionResult == null && !version.hasError) {
    return SplashDestination.pending;
  }
  final action = versionResult?.action;
  if (action == VersionAction.force || action == VersionAction.maintenance) {
    return SplashDestination.other;
  }

  final session = ref.watch(sessionCheckProvider);
  if (!session.hasValue && !session.hasError) return SplashDestination.pending;

  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) return SplashDestination.pending;

  // 세션 검사까지 다 기다린 **뒤** 강제한다 — 여기서 먼저 끊으면 [AuthGate] 가
  // 아직 자기 스플래시를 그리는 중이라 로고가 착지할 자리가 없다.
  if (kDebugMode && kDebugStartAtWelcome) return SplashDestination.other;

  return auth.value == null ? SplashDestination.other : SplashDestination.home;
});
