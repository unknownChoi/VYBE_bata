import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';

/// 리뷰·찜 개수 카드 2칸 (디자인 MRStats).
///
/// 개수가 null이면 `-` — 0과 구분해야 "아직 못 읽음"과 "정말 0개"가 헷갈리지 않는다.
class MyPageStats extends StatelessWidget {
  final int? reviewCount;
  final int? savedCount;
  final VoidCallback onReviews;
  final VoidCallback onSaved;

  const MyPageStats({
    super.key,
    required this.reviewCount,
    required this.savedCount,
    required this.onReviews,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return RenewGlassCard(
      quiet: true,
      padding: 0,
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Cell(label: '리뷰', value: reviewCount, onTap: onReviews),
            // 구분선은 위아래 12씩 띄워 카드 모서리까지 닿지 않게 한다.
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const VerticalDivider(
                width: 1,
                thickness: 1,
                color: RenewGlass.hair,
              ),
            ),
            _Cell(label: '찜', value: savedCount, onTap: onSaved),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final int? value;
  final VoidCallback onTap;

  const _Cell({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value?.toString() ?? '-',
                style: VybeTypography.heading4.copyWith(
                  fontSize: 22.sp,
                  color: RenewGlass.t1,
                ),
              ),
              SizedBox(height: 6.h),
              Text(label, style: RenewGlass.caption(lineHeight: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
