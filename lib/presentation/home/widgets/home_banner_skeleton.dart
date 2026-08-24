import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 홈 배너 로딩 자리.
///
/// 홈 화면 전체 스켈레톤과 배너 자체의 로딩 상태가 **같은 그림**을 써야 한다 —
/// 예전에는 두 곳이 각자 그려서 첫 진입은 shimmer + 인디케이터, 배너만 다시
/// 불러올 때는 평면 회색 박스가 떴다.
class HomeBannerSkeleton extends StatelessWidget {
  const HomeBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          // 배너 카드: viewportFraction 0.9 + 좌우 6.w → 실제와 유사한 좌우 여백.
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: VybeSkel(height: 200.h, radius: 20),
        ),
        SizedBox(height: 12.h),
        // 인디케이터 dots (활성 1 + 비활성 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VybeSkel(width: 18.w, height: 5.h, radius: 99),
            SizedBox(width: 4.w),
            VybeSkel(width: 5.w, height: 5.h, radius: 99),
            SizedBox(width: 4.w),
            VybeSkel(width: 5.w, height: 5.h, radius: 99),
          ],
        ),
      ],
    );
  }
}
