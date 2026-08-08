import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

// ── Base shimmer block ──────────────────────────────────────────

class VybeSkel extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const VybeSkel({super.key, this.width, this.height, this.radius = 6});

  @override
  State<VybeSkel> createState() => _VybeSkelState();
}

class _VybeSkelState extends State<VybeSkel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius.r),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              VybeColors.gray900,
              VybeColors.gray700,
              VybeColors.gray900,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton 이미지 ─────────────────────────────────────────────
//
// Image.network 로딩 중 + 디코드 완료 후에도 최소 [minSkeleton] 동안
// 스켈레톤(shimmer)을 유지한 뒤 페이드로 이미지를 노출한다.
// URL 로딩 지연 시 깜빡임을 막기 위한 위젯.

class SkeletonImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Duration minSkeleton;

  const SkeletonImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.minSkeleton = const Duration(seconds: 1),
  });

  @override
  State<SkeletonImage> createState() => _SkeletonImageState();
}

class _SkeletonImageState extends State<SkeletonImage> {
  bool _revealed = false;
  bool _loaded = false;
  late final DateTime _start;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();

    // 이미 ImageCache에 있으면(재방문) skeleton 없이 즉시 노출.
    // 최초 로드(캐시 없음)일 때만 minSkeleton 동안 shimmer 표시.
    final status = PaintingBinding.instance.imageCache.statusForKey(
      NetworkImage(widget.url),
    );
    if (status.keepAlive || status.live) {
      _loaded = true;
      _revealed = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 이미지 디코드(또는 에러) 완료 시 호출 — 최소 표시 시간 보장 후 reveal.
  void _onSettled() {
    if (_loaded) return;
    _loaded = true;
    final remain = widget.minSkeleton - DateTime.now().difference(_start);
    if (remain > Duration.zero) {
      _timer = Timer(remain, () {
        if (mounted) setState(() => _revealed = true);
      });
    } else {
      if (mounted) setState(() => _revealed = true);
    }
  }

  void _scheduleSettle() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onSettled());
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (_, child, frame, wasSync) {
        if ((frame != null || wasSync) && !_loaded) _scheduleSettle();
        return child;
      },
      errorBuilder: (_, __, ___) {
        if (!_loaded) _scheduleSettle();
        return Container(
          width: widget.width,
          height: widget.height,
          color: VybeColors.gray900,
        );
      },
    );

    final content = Stack(
      fit: StackFit.passthrough,
      children: [
        image,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _revealed,
            child: AnimatedOpacity(
              opacity: _revealed ? 0 : 1,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: VybeSkel(
                width: widget.width,
                height: widget.height,
                radius: 0,
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.borderRadius == null) return content;
    return ClipRRect(borderRadius: widget.borderRadius!, child: content);
  }
}

// ── Hero skeleton ───────────────────────────────────────────────
