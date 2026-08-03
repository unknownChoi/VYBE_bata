import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 목록 항목 진입 애니메이션 — 6px 아래에서 올라오며 페이드인.
///
/// 디자인 `@keyframes fadeIn` + `animationDelay: index * 45ms` 대응.
/// 카드마다 [delay]를 조금씩 늘려 순차 등장 효과를 만든다.
class VybeFadeInUp extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const VybeFadeInUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<VybeFadeInUp> createState() => _VybeFadeInUpState();
}

class _VybeFadeInUpState extends State<VybeFadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _curved;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _curved = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _startTimer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: AnimatedBuilder(
        animation: _curved,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 6.h * (1 - _curved.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
