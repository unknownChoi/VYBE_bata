import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/presentation/common/splash_destination.dart';
import 'package:vybe/presentation/common/splash_logo_landing.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';
import 'package:vybe/presentation/home/widgets/home_gnb.dart';

/// 스플래시 최소 노출 시간. [kSplashIntroDuration] 보다 길어야 인트로
/// 애니메이션이 중간에 잘리지 않는다.
const _kMinSplashDuration = Duration(milliseconds: 2600);

/// 버전·세션 검사를 기다려 주는 한계. 넘기면 결과 없이 넘어간다(fail-open) —
/// 이 뒤는 [VersionGate]·[AuthGate] 가 각자 스플래시를 그리며 이어받는다.
const _kMaxWait = Duration(milliseconds: 5500);

/// 스플래시 퇴장 길이. 디자인 `splash.jsx` 의 로고 이동(.82s)에 맞춘다.
const _kExitDuration = Duration(milliseconds: 820);

/// 로고 로고 비율(`vybe_white_logo.svg` viewBox 170x45).
const _kLogoAspect = 170 / 45;

/// 앱 최상단 스플래시 게이트 — 인트로를 끝까지 보여주고, 다음 화면이 준비되면
/// 조명이 빠지며 로고가 홈 상단 바 자리로 날아간 뒤 [child] 로 넘긴다.
///
/// [VersionGate] 보다 **위**에 둔다. 버전 체크/세션 복원은
/// [splashDestinationProvider] 를 통해 **앱 시작과 동시에** 병렬로 돌아가고,
/// 이 게이트는 그 결과가 나온 뒤에 한 번만 넘어간다 — 아래 게이트가 스플래시를
/// 다시 그리면 날아간 로고가 도로 가운데로 튀기 때문.
class SplashGate extends ConsumerStatefulWidget {
  final Widget child;

  /// 스플래시 최소 노출 시간. 테스트에서 줄여 쓸 수 있게 파라미터로 연다.
  final Duration minDuration;

  const SplashGate({
    super.key,
    required this.child,
    this.minDuration = _kMinSplashDuration,
  });

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exit;

  /// 최소 노출 시간이 지났는지 / 기다림 한계를 넘겼는지.
  bool _minElapsed = false;
  bool _waitedEnough = false;

  /// 퇴장이 시작됐는지 / 끝나 스플래시를 트리에서 뺐는지.
  bool _exiting = false;
  bool _gone = false;

  /// 퇴장 시작 시점에 확정한 목적지. 도중에 바뀌어도 연출은 흔들리지 않는다.
  SplashDestination _leaving = SplashDestination.pending;

  /// 로고가 착지할 자리. 퇴장 첫 프레임 뒤에 한 번만 정한다. null이면 로고도
  /// 조명과 함께 그냥 사라진다(착지할 자리가 없는 화면).
  Rect? _landing;

  /// 드러나는 앱의 뿌리. 착지 좌표를 **확대되기 전** 기준으로 재는 데 쓴다.
  final _appKey = GlobalKey(debugLabel: 'splashEnteringApp');

  Timer? _minTimer;
  Timer? _maxTimer;

  @override
  void initState() {
    super.initState();

    // 앱 첫 로딩에 내 위치를 받아 둔다 — 위치 권한 팝업도 여기서 한 번 뜬다.
    // 결과를 기다리지 않는다: 스플래시(2.6초)가 도는 동안 병렬로 끝나고,
    // 실패해도 폴백 좌표(홍대)로 그대로 진행한다.
    unawaited(ref.read(userLocationProvider.notifier).resolveFromDevice());

    _exit = AnimationController(vsync: this, duration: _kExitDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _gone = true);
        }
      });

    _minTimer = Timer(widget.minDuration, () {
      if (!mounted) return;
      setState(() => _minElapsed = true);
    });
    _maxTimer = Timer(_kMaxWait, () {
      if (!mounted) return;
      setState(() => _waitedEnough = true);
    });
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _maxTimer?.cancel();
    _exit.dispose();
    super.dispose();
  }

  /// 로고가 앉을 자리. 퇴장 **첫 프레임이 그려진 뒤** 한 번만 부른다 —
  /// 목적지 위젯은 퇴장이 시작되는 프레임에 처음 만들어져 그 전엔 잴 것이 없다.
  Rect? _resolveLanding() {
    // 홈 상단 바는 계산으로. [HomeGnb] 와 같은 상수를 쓴다.
    if (_leaving == SplashDestination.home) {
      final top = MediaQuery.paddingOf(context).top;
      final height = kHomeGnbLogoHeight.h;
      return Rect.fromLTWH(
        kHomeGnbHPadding.w,
        top + kHomeGnbTopGap.h,
        height * _kLogoAspect,
        height,
      );
    }
    // 그 밖의 화면은 [splashLogoLandingKey] 를 단 로고가 있으면 그 자리로
    // (로그인 화면). 강제 업데이트·점검처럼 로고가 없는 화면이면 null.
    return _measuredLanding();
  }

  /// [splashLogoLandingKey] 가 가리키는 로고의 화면 좌표.
  ///
  /// 좌표는 **앱 뿌리([_appKey]) 기준**으로 뽑는다. 드러나는 앱은 지금
  /// 1.04배로 확대돼 있어 `localToGlobal` 로 재면 그 배율이 섞이는데, 로고가
  /// 착지하는 건 배율이 1로 돌아온 뒤라 확대 전 자리를 써야 한다.
  Rect? _measuredLanding() {
    final logo = splashLogoLandingKey.currentContext?.findRenderObject();
    final root = _appKey.currentContext?.findRenderObject();
    if (logo is! RenderBox || root is! RenderBox) return null;
    if (!logo.attached || !logo.hasSize) return null;
    return MatrixUtils.transformRect(
      logo.getTransformTo(root),
      Offset.zero & logo.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return widget.child;

    final destination = ref.watch(splashDestinationProvider);

    // 최소 노출을 채웠고 다음 화면이 정해졌으면(또는 너무 오래 기다렸으면) 퇴장.
    if (!_exiting &&
        _minElapsed &&
        (destination != SplashDestination.pending || _waitedEnough)) {
      _exiting = true;
      _leaving = destination;
      // 빌드 중에 컨트롤러를 굴리지 않는다 — 이 프레임은 아래 child를 처음
      // 만드는 프레임이라 그대로 시작하면 첫 구간을 건너뛴 채로 보인다.
      // 착지 자리도 여기서 정한다: 이제 목적지가 레이아웃을 마쳐 잴 수 있다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _landing = _resolveLanding());
        _exit.forward();
      });
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 퇴장이 시작되면 아래에서 앱을 먼저 그린다 — 로고가 착지할 상단 바가
        // 이미 그 자리에 있어야 이어 붙는다.
        if (_exiting) _buildEntering(widget.child),
        RepaintBoundary(
          child: VybeSplash(exit: _exit, logoLanding: _landing),
        ),
      ],
    );
  }

  /// 드러나는 앱 — 살짝 확대된 상태에서 제자리로 내려앉으며 나타난다.
  /// (디자인의 홈 진입: scale 1.04 → 1 · opacity 0 → 1)
  ///
  /// 원본의 blur 10 → 0 은 뺐다. 전체화면 블러는 앱이 첫 프레임을 그리는
  /// 바로 그 구간에 매 프레임 레이어를 하나 더 뜨게 한다.
  Widget _buildEntering(Widget child) {
    return AnimatedBuilder(
      animation: _exit,
      builder: (_, inner) {
        final p = _exit.value;
        final e = const Cubic(0.2, 0.8, 0.2, 1).transform(p);
        return Opacity(
          opacity: ((p - 0.08) / 0.52).clamp(0.0, 1.0),
          child: Transform.scale(scale: 1.04 - 0.04 * e, child: inner),
        );
      },
      // 착지 좌표를 재는 기준면. Stack이 이미 꽉 찬 제약을 주므로 크기는
      // 그대로고, 확대 Transform 바깥에 있어 확대 전 좌표계가 된다.
      child: SizedBox.expand(key: _appKey, child: child),
    );
  }
}
