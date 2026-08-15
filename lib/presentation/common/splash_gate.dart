import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';

/// 스플래시 최소 노출 시간. [kSplashIntroDuration] 보다 길어야 로고 등장
/// 애니메이션이 중간에 잘리지 않는다(버전 체크는 보통 그 전에 끝난다).
const _kMinSplashDuration = Duration(milliseconds: 1500);

/// 앱 최상단 스플래시 게이트 — 인트로 애니메이션을 끝까지 보여준 뒤 [child]로 넘긴다.
///
/// [VersionGate] 보다 **위**에 둔다. 버전 체크/세션 복원은 이 시간 동안
/// 백그라운드에서 병렬로 진행되므로 체감 지연은 거의 없다.
/// (게이트가 아직 로딩이면 [VybeSplash] 를 그대로 다시 그리므로 화면이 이어진다)
class SplashGate extends StatefulWidget {
  final Widget child;

  /// 스플래시 최소 노출 시간. 테스트에서 줄여 쓸 수 있게 파라미터로 연다.
  final Duration minDuration;

  const SplashGate({
    super.key,
    required this.child,
    this.minDuration = _kMinSplashDuration,
  });

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _done = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.minDuration, () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      child: _done
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : const VybeSplash(key: ValueKey('splash')),
    );
  }
}
