import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

/// 로딩 스켈레톤용 shimmer 블록.
///
/// 좌→우로 흐르는 밝은 띠를 ShaderMask로 그린다.
/// 수치는 **호출부에서 미리 스케일**해서 넘긴다 (`height: 34.h`, `radius: 8.r`).
///
/// 여러 줄을 쌓아 카드 형태를 만드는 스켈레톤 화면에서 사용.
/// 상세 페이지처럼 화면 전용 스켈레톤이 이미 있는 경우엔 `vybe_skeleton.dart` 쪽을 쓴다.
class VybeShimmerBox extends StatefulWidget {
  /// 고정 너비. null이면 부모 제약을 그대로 따른다.
  final double? width;

  final double height;
  final double radius;

  /// 부모 폭 대비 비율(0~1). [width] 와 같이 쓰지 않는다.
  final double? widthFactor;

  const VybeShimmerBox({
    super.key,
    this.width,
    required this.height,
    required this.radius,
    this.widthFactor,
  });

  @override
  State<VybeShimmerBox> createState() => _VybeShimmerBoxState();
}

class _VybeShimmerBoxState extends State<VybeShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) {
                final dx = (_c.value * 2 - 1) * rect.width * 1.5;
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    VybeColors.gray900,
                    VybeColors.gray800,
                    VybeColors.gray900,
                  ],
                ).createShader(
                  Rect.fromLTWH(dx, 0, rect.width, rect.height),
                );
              },
              child: const ColoredBox(color: VybeColors.gray900),
            );
          },
        ),
      ),
    );

    if (widget.widthFactor == null) return box;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widget.widthFactor,
      child: box,
    );
  }
}
