import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 리퀴드 글래스 버튼 공통 누름 반응 (디자인 `kakao_liquid_press.html`).
///
/// 누르면 세 가지가 동시에 일어난다 —
/// 1. 버튼 전체가 **1.045배로 커진다** (줄어드는 게 아니라 커진다).
///    `transform .42s cubic-bezier(.22,1.2,.3,1)` — 되돌아올 때 살짝 넘겼다 온다.
/// 2. 손가락 자리에 **렌즈**(흐린 흰 원)가 붙고, 손가락을 따라 스프링처럼 뒤따라온다.
///    프레임마다 목표 지점으로 22%씩 다가가 관성이 생긴다.
/// 3. 떼면 렌즈가 1.5배로 한 번 퍼지며 사라진다(`.26s`).
///
/// 이 위젯은 **움직임만** 맡는다 — 배경·테두리 색 전환은 각 버튼이 원래 하던
/// 대로 두고, [onPressChanged]로 눌림 여부만 알려준다.
///
/// 렌즈는 버튼 모양대로 잘린다 — [circle]이면 원, 아니면 [borderRadius].
class VybeLiquidPress extends StatefulWidget {
  final Widget child;

  /// null이면 눌러도 반응하지 않는다(비활성).
  final VoidCallback? onTap;

  /// 렌즈를 자를 모서리. [circle]이 true면 무시된다.
  final BorderRadius? borderRadius;

  /// 원형 버튼 여부.
  final bool circle;

  /// 눌렀을 때 배율 (디자인 1.045).
  final double pressScale;

  /// 렌즈 색 — 어두운 유리 위는 흰색, 라임·보라 채움 위도 흰색이 자연스럽다.
  final Color lensColor;

  /// 렌즈 지름 비율 (디자인 `data-lens`, 기본 .78).
  final double lensRatio;

  /// 눌림 상태 변화 알림 — 버튼의 색 전환을 그대로 쓰기 위한 통로.
  final ValueChanged<bool>? onPressChanged;

  const VybeLiquidPress({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
    this.circle = false,
    this.pressScale = 1.045,
    this.lensColor = Colors.white,
    this.lensRatio = 0.78,
    this.onPressChanged,
  });

  @override
  State<VybeLiquidPress> createState() => _VybeLiquidPressState();
}

enum _LensPhase { idle, pressed, releasing }

class _VybeLiquidPressState extends State<VybeLiquidPress>
    with SingleTickerProviderStateMixin {
  static const Duration _scaleDuration = Duration(milliseconds: 420);
  static const Cubic _scaleCurve = Cubic(0.22, 1.2, 0.3, 1);
  static const Cubic _lensCurve = Cubic(0.22, 1, 0.3, 1);

  /// 스프링 추종 계수 — 프레임마다 남은 거리의 22%를 따라간다.
  static const double _follow = 0.22;

  late final Ticker _ticker;

  /// 렌즈의 현재 좌표. 매 프레임 바뀌므로 setState 대신 알림값으로 흘린다 —
  /// setState로 돌리면 버튼 내용까지 매 프레임 다시 그린다.
  final ValueNotifier<Offset> _lens = ValueNotifier(Offset.zero);

  Offset _target = Offset.zero;
  Size _size = Size.zero;
  _LensPhase _phase = _LensPhase.idle;

  bool get _enabled => widget.onTap != null;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _lens.dispose();
    super.dispose();
  }

  void _onTick(Duration _) {
    final current = _lens.value;
    final next = Offset(
      current.dx + (_target.dx - current.dx) * _follow,
      current.dy + (_target.dy - current.dy) * _follow,
    );
    _lens.value = next;
    // 눌린 동안엔 계속 돌고, 뗀 뒤엔 목표에 닿으면 멈춘다.
    if (_phase != _LensPhase.pressed && (next - _target).distance <= 0.5) {
      _ticker.stop();
    }
  }

  void _press(Offset local) {
    final box = context.findRenderObject() as RenderBox?;
    _size = box?.hasSize == true ? box!.size : Size.zero;
    // 누른 순간엔 렌즈가 손가락 자리에서 바로 시작한다(따라오지 않는다).
    _target = local;
    _lens.value = local;
    _setPhase(_LensPhase.pressed);
  }

  void _release() {
    if (_phase != _LensPhase.pressed) return;
    _setPhase(_LensPhase.releasing);
    // 퍼지며 사라지는 시간이 지나면 다음 누름을 위해 초기 크기로 되돌린다.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _phase != _LensPhase.releasing) return;
      _setPhase(_LensPhase.idle);
    });
  }

  void _setPhase(_LensPhase phase) {
    if (_phase == phase) return;
    setState(() => _phase = phase);
    widget.onPressChanged?.call(phase == _LensPhase.pressed);
    if (phase == _LensPhase.pressed && !_ticker.isActive) _ticker.start();
  }

  void _moveTo(Offset local) {
    if (_phase != _LensPhase.pressed) return;
    _target = Offset(
      local.dx.clamp(0.0, _size.width),
      local.dy.clamp(0.0, _size.height),
    );
  }

  /// 디자인 `size()` — `max(26, min(h,w) * ratio + h * .18)`.
  double get _diameter {
    if (_size.isEmpty) return 26;
    final base =
        _size.shortestSide * widget.lensRatio + _size.height * 0.18;
    return base < 26 ? 26 : base;
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _phase == _LensPhase.pressed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (d) => _press(d.localPosition) : null,
      onTapUp: _enabled ? (_) => _release() : null,
      // 스크롤 등으로 탭이 취소되면 렌즈도 같이 걷는다.
      onTapCancel: _enabled ? _release : null,
      onTap: widget.onTap,
      child: Listener(
        onPointerMove: (e) => _moveTo(e.localPosition),
        child: AnimatedScale(
          scale: pressed ? widget.pressScale : 1,
          duration: _scaleDuration,
          curve: _scaleCurve,
          child: Stack(
            children: [
              widget.child,
              // 렌즈 층은 항상 트리에 둔다 — 누를 때 붙이면 0.4→1 확대가
              // 시작점 없이 곧바로 1로 그려져 커지는 게 안 보인다.
              // (opacity 0이면 그리기 자체를 건너뛴다)
              Positioned.fill(
                child: IgnorePointer(child: _clip(child: _lensLayer())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clip({required Widget child}) {
    if (widget.circle) return ClipOval(child: child);
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: child,
    );
  }

  Widget _lensLayer() {
    final pressed = _phase == _LensPhase.pressed;
    final d = _diameter;

    return ValueListenableBuilder<Offset>(
      valueListenable: _lens,
      builder: (_, at, child) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: at.dx - d / 2,
            top: at.dy - d / 2,
            width: d,
            height: d,
            child: child!,
          ),
        ],
      ),
      child: AnimatedScale(
        // 대기 0.4 → 누름 1 → 뗌 1.5(퍼지며 사라짐).
        scale: switch (_phase) {
          _LensPhase.idle => 0.4,
          _LensPhase.pressed => 1,
          _LensPhase.releasing => 1.5,
        },
        duration: Duration(
          milliseconds: switch (_phase) {
            _LensPhase.idle => 0,
            _LensPhase.pressed => 340,
            _LensPhase.releasing => 260,
          },
        ),
        curve: pressed ? _lensCurve : Curves.easeOut,
        child: AnimatedOpacity(
          opacity: pressed ? 1 : 0,
          duration: Duration(milliseconds: pressed ? 200 : 260),
          curve: Curves.ease,
          child: ImageFiltered(
            // CSS blur(7px) ≈ sigma 3.5
            imageFilter: ui.ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // radial-gradient(circle at 42% 38%, .62 → .30(58%) → .05)
                gradient: RadialGradient(
                  center: const Alignment(-0.16, -0.24),
                  colors: [
                    widget.lensColor.withValues(alpha: 0.62),
                    widget.lensColor.withValues(alpha: 0.30),
                    widget.lensColor.withValues(alpha: 0.05),
                  ],
                  stops: const [0, 0.58, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
