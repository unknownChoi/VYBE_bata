import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';

// 리뷰 별점 입력 — 0.5 단위 반쪽 별.

const kReviewStarAsset = 'assets/icons/common/club_card/star.svg';

/// 별 하나를 반쪽 단위까지 채우는 별점 입력.
///
/// 별의 왼쪽 절반을 누르면 x.5, 오른쪽 절반을 누르면 x.0.
/// 가로로 드래그하면 값이 이어서 바뀐다. 최소 0.5, 최대 5.0.
class ReviewHalfStarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const ReviewHalfStarRating({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  static const _count = 5;

  @override
  Widget build(BuildContext context) {
    final star = 40.r;
    final gap = 10.w;
    final width = star * _count + gap * (_count - 1);

    void update(double dx) {
      final unit = star + gap;
      final index = (dx / unit).floor().clamp(0, _count - 1);
      final inStar = dx - index * unit;
      // 별 안쪽 왼쪽 절반이면 반 개, 그 외(오른쪽 절반·별 사이 간격)면 한 개.
      final fill = inStar <= star / 2 ? 0.5 : 1.0;
      final next = index + fill;
      if (next != rating) onChanged(next);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => update(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => update(d.localPosition.dx),
      child: SizedBox(
        width: width,
        height: star,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _count; i++) ...[
              _ReviewStarIcon(size: star, fill: (rating - i).clamp(0.0, 1.0)),
              if (i != _count - 1) SizedBox(width: gap),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewStarIcon extends StatelessWidget {
  final double size;

  /// 0.0(빈 별) ~ 1.0(꽉 찬 별). 0.5면 왼쪽 절반만 채워진다.
  final double fill;

  const _ReviewStarIcon({required this.size, required this.fill});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: fill > 0 ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            SvgPicture.asset(
              kReviewStarAsset,
              width: size,
              height: size,
              colorFilter: const ColorFilter.mode(
                Color(0x24FFFFFF), // rgba(255,255,255,0.14)
                BlendMode.srcIn,
              ),
            ),
            if (fill > 0)
              ClipRect(
                clipper: _ReviewStarFillClipper(fill),
                child: SvgPicture.asset(
                  kReviewStarAsset,
                  width: size,
                  height: size,
                  colorFilter: const ColorFilter.mode(
                    VybeColors.mainLime500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStarFillClipper extends CustomClipper<Rect> {
  final double fraction;

  const _ReviewStarFillClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_ReviewStarFillClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

// =============================================================================
// 공통 조각
// =============================================================================
