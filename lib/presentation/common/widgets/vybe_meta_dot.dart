import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 메타 정보 사이 구분점 (`홍대 · 0.4km · 힙합`의 가운데 점).
///
/// 좌우 여백을 [gap] 만큼 두고 원을 그린다. [gap] 이 0이면 여백 없이 점만 렌더.
class VybeMetaDot extends StatelessWidget {
  /// 점 색상.
  final Color color;

  /// 점 지름 (.r 적용).
  final double size;

  /// 좌우 여백 (.w 적용). 0이면 여백 없음.
  final double gap;

  const VybeMetaDot({
    super.key,
    this.color = VybeColors.gray500,
    this.size = 2,
    this.gap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (gap == 0) return dot;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gap.w),
      child: dot,
    );
  }
}
