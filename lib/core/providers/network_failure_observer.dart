import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/presentation/common/network_gate/viewmodels/network_status_viewmodel.dart';

/// provider가 에러를 뱉을 때마다 기기 연결을 다시 확인하는 관찰자.
///
/// **왜 필요한가** — [NetworkStatus] 는 앱 실행 · 앱 복귀 · 기기 연결 변화
/// 세 시점에만 갱신된다. 와이파이는 붙어 있는데 실제로 못 나가는 상태
/// (공용 와이파이 로그인 페이지 · 회선 장애)는 기기 연결 변화가 아예 안 흘러서,
/// 화면은 로딩만 돌거나 빈 목록을 그린 채로 남는다. 데이터 요청이 실패한
/// 순간이 곧 '연결을 의심할 시점'이라 그때 한 번 더 확인한다.
///
/// 확인 결과 정말 연결이 없으면 [networkStatusProvider] 가 false가 되고
/// [NetworkGate] 가 연결 안내 화면으로 넘긴다. 연결이 멀쩡하면(권한 오류 ·
/// 서버 오류 등) 확인이 통과해 화면은 그대로다 — 즉 **에러 종류를 가리지 않고
/// 넘겨도 안전**하다. 실제 판정은 [NetworkStatus.reportRequestFailure] 한 곳.
///
/// [ProviderScope.observers] 에 등록한다 (`main.dart`).
final class NetworkFailureObserver extends ProviderObserver {
  const NetworkFailureObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    // 연결 확인 자체가 실패한 경우까지 되받으면 확인 → 실패 → 확인이 반복된다.
    if (identical(context.provider, networkStatusProvider)) return;

    if (kDebugMode) {
      debugPrint('[NetworkFailure] ${context.provider} 실패 → 연결 재확인: $error');
    }

    // 관찰자 콜백은 provider 갱신 도중에 불린다 — 그 안에서 다른 provider를
    // 건드리면 같은 프레임에서 상태가 두 번 바뀐다. 한 틱 미뤄서 읽는다.
    Future.microtask(() {
      context.container
          .read(networkStatusProvider.notifier)
          .reportRequestFailure();
    });
  }
}
