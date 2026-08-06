import 'dart:math' show min;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart' show CupertinoPageTransition;
import 'package:flutter/gestures.dart' show HorizontalDragGestureRecognizer;
import 'package:flutter/material.dart';

/// 화면 어디서든 오른쪽으로 끌면 이전 페이지로 돌아가는 라우트.
///
/// iOS 기본 back 제스처(`CupertinoPageRoute`)는 왼쪽 끝 20px에서만 먹고
/// 그 폭은 프레임워크 private 상수라 조정할 수 없다 → 같은 로직을 화면 전체
/// 폭으로 확장한 라우트를 직접 만든다. 전환 자체는 `CupertinoPageTransition`을
/// 그대로 쓰고, 드래그가 라우트 애니메이션을 직접 몰아 손가락을 따라온다.
///
/// 가로 스크롤 위젯(추천 rail, 칩 행, TabBarView, 히어로 PageView) 위에서는
/// 제스처 아레나에 안쪽 스크롤러가 먼저 등록돼 스크롤이 그대로 이긴다 —
/// 드래그 백은 그 밖의 영역에서만 동작한다.
class SwipeBackPageRoute<T> extends MaterialPageRoute<T> {
  SwipeBackPageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 아래에서 올라오는 풀스크린 다이얼로그는 기본 전환·기본 동작 유지.
    if (fullscreenDialog) {
      return super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      // 드래그 중에는 커브를 태우면 손가락과 페이지가 어긋난다 → 선형.
      linearTransition: navigator?.userGestureInProgress ?? false,
      child: _SwipeBackGestureDetector(
        enabledCallback: _popGestureEnabled,
        onStartPopGesture: _startPopGesture,
        child: child,
      ),
    );
  }

  /// 지금 드래그 백을 받아도 되는 상태인지. (Cupertino의 판정과 동일 기준)
  bool _popGestureEnabled() {
    // 스택 첫 라우트 = 돌아갈 페이지 없음 (각 탭의 루트 화면).
    if (isFirst) return false;
    if (willHandlePopInternally) return false;
    // PopScope 등으로 pop이 막힌 화면(가입 완료 등)은 제스처도 막는다.
    if (popDisposition == RoutePopDisposition.doNotPop) return false;
    // 전환 애니메이션 중이거나, 위에 다른 페이지가 덮여 있으면 무시.
    if (!(animation?.isCompleted ?? false)) return false;
    if (!(secondaryAnimation?.isDismissed ?? false)) return false;
    if (navigator?.userGestureInProgress ?? true) return false;
    return true;
  }

  _SwipeBackController _startPopGesture() {
    final nav = navigator!;
    nav.didStartUserGesture();
    // controller는 @protected — 라우트 서브클래스 안에서만 꺼내 넘긴다.
    return _SwipeBackController(navigator: nav, controller: controller!);
  }
}

/// 화면 폭의 몇 배/초로 던져야 플링으로 볼지.
const double _kMinFlingVelocity = 1.0;
const int _kMaxDroppedSwipePageForwardAnimationTime = 800;
const int _kMaxPageBackAnimationTime = 300;

/// 드래그 입력을 라우트 애니메이션 값으로 옮기는 컨트롤러.
/// 0.0 = 새 페이지 완전히 밀려남(pop), 1.0 = 제자리.
class _SwipeBackController {
  final NavigatorState navigator;
  final AnimationController controller;

  _SwipeBackController({required this.navigator, required this.controller});

  void dragUpdate(double delta) => controller.value -= delta;

  void dragEnd(double velocity) {
    const Curve curve = Curves.fastLinearToSlowEaseIn;
    // 플링이면 방향으로, 아니면 절반 넘겼는지로 판단.
    final bool animateForward = velocity.abs() >= _kMinFlingVelocity
        ? velocity <= 0
        : controller.value > 0.5;

    if (animateForward) {
      // 되돌리기 — 남은 거리에 비례한 시간.
      final int ms = min(
        lerpDouble(
          _kMaxDroppedSwipePageForwardAnimationTime,
          0,
          controller.value,
        )!.floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(
        1.0,
        duration: Duration(milliseconds: ms),
        curve: curve,
      );
    } else {
      navigator.pop();
      // pop이 애니메이션을 이미 되감고 있으면 남은 거리만큼만 이어서 재생.
      if (controller.isAnimating) {
        final int ms = lerpDouble(
          0,
          _kMaxDroppedSwipePageForwardAnimationTime,
          controller.value,
        )!.floor();
        controller.animateBack(
          0.0,
          duration: Duration(milliseconds: ms),
          curve: curve,
        );
      }
    }

    if (controller.isAnimating) {
      // 애니메이션이 끝나야 제스처 종료 — 중간에 풀면 라우트가 반쯤 밀린 채 굳는다.
      late AnimationStatusListener listener;
      listener = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(listener);
      };
      controller.addStatusListener(listener);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

/// 화면 전체에서 가로 드래그를 받아 [_SwipeBackController]에 넘기는 래퍼.
///
/// Cupertino처럼 Stack 위에 Listener를 얹지 않고 자식을 **감싼다** — 위에 얹으면
/// 히트테스트 순서상 이 인식기가 먼저 아레나에 들어가 안쪽 가로 스크롤을 뺏는다.
class _SwipeBackGestureDetector extends StatefulWidget {
  final Widget child;
  final ValueGetter<bool> enabledCallback;
  final ValueGetter<_SwipeBackController> onStartPopGesture;

  const _SwipeBackGestureDetector({
    required this.child,
    required this.enabledCallback,
    required this.onStartPopGesture,
  });

  @override
  State<_SwipeBackGestureDetector> createState() =>
      _SwipeBackGestureDetectorState();
}

class _SwipeBackGestureDetectorState extends State<_SwipeBackGestureDetector> {
  _SwipeBackController? _controller;
  late final HorizontalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    // 드래그 도중 화면이 사라지면 제스처 플래그가 남는다 → 다음 프레임에 해제.
    final controller = _controller;
    if (controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.navigator.mounted) {
          controller.navigator.didStopUserGesture();
        }
      });
      _controller = null;
    }
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) _recognizer.addPointer(event);
  }

  void _handleDragStart(DragStartDetails details) {
    _controller = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final width = context.size?.width ?? 0;
    if (width == 0) return;
    _controller?.dragUpdate(details.primaryDelta! / width);
  }

  void _handleDragEnd(DragEndDetails details) {
    final width = context.size?.width ?? 1;
    _controller?.dragEnd(details.velocity.pixelsPerSecond.dx / width);
    _controller = null;
  }

  void _handleDragCancel() {
    _controller?.dragEnd(0);
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(onPointerDown: _handlePointerDown, child: widget.child);
  }
}
