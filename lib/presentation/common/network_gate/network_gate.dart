import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/presentation/common/network_gate/viewmodels/network_status_viewmodel.dart';
import 'package:vybe/presentation/common/network_gate/widgets/network_error_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';

/// 앱 진입 전 기기 네트워크 연결을 확인하는 게이트.
///
/// [VersionGate] 보다 **위**에 둔다 — 버전 정책·세션 복원·클럽 조회가 전부
/// 통신이라, 연결이 없으면 그 아래는 무엇을 그려도 빈 화면이 된다.
/// (연결 확인 자체는 [SplashGate] 가 도는 동안 이미 시작된다 —
///  `splashDestinationProvider` 가 [networkStatusProvider] 를 본다)
///
/// 확인 실패는 통과(fail-open) — 판단은 `DeviceNetworkDataSource` 에 있다.
class NetworkGate extends ConsumerStatefulWidget {
  final Widget child;

  const NetworkGate({super.key, required this.child});

  @override
  ConsumerState<NetworkGate> createState() => _NetworkGateState();
}

class _NetworkGateState extends ConsumerState<NetworkGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 핫리로드마다 재검사(디버그에서만 불린다).
  ///
  /// [DeviceNetworkDataSource.debugForceOffline] 을 켜고 저장하면 앱을 다시
  /// 켜지 않아도 바로 안내 화면이 뜬다 — 끄면 같은 방식으로 돌아온다.
  @override
  void reassemble() {
    super.reassemble();
    ref.read(networkStatusProvider.notifier).recheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 설정에서 와이파이를 켜고 돌아온 경우 — 버튼을 다시 누르지 않아도 넘어간다.
    if (state == AppLifecycleState.resumed) {
      ref.read(networkStatusProvider.notifier).recheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(networkStatusProvider);
    final connected = async.value;

    // 첫 확인 전. 인트로는 SplashGate가 이미 재생했으므로 완성 프레임만 이어 그린다.
    if (connected == null) {
      return async.hasError ? widget.child : const VybeSplash(playIntro: false);
    }

    return connected ? widget.child : const NetworkErrorScreen();
  }
}
