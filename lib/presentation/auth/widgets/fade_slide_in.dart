import 'package:flutter/material.dart';

/// 마운트 시 한 번만 fade + 가로 슬라이드 인 애니메이션을 재생하는 래퍼
///
/// 동일 [key]로 재사용될 때는 Flutter가 위젯 인스턴스를 유지하므로
/// 애니메이션이 반복 재생되지 않는다.
///
/// 사용 예:
/// ```dart
/// FadeSlideIn(
///   key: ValueKey('below_${step.name}'),
///   child: someWidget,
/// )
/// ```
class FadeSlideIn extends StatefulWidget {
  final Widget child;

  const FadeSlideIn({super.key, required this.child});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(curved);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}
