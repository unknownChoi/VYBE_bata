import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';

/// 홈 섹션 머리 — 제목(+ 보조 문구) 왼쪽, `전체보기 ›` 오른쪽.
///
/// '전체보기' 표기는 `home_nearby_clubs.dart` 의 것과 맞춰 둔다
/// (caption · gray400). 한쪽만 바꾸면 홈에서 같은 버튼이 두 모양이 된다.
///
/// 디자인 `home.jsx > SecHead`. 보조 문구가 제목 **아래** 줄에 오는 형태라
/// 제목 옆에 붙는 [RenewSectionHead]와는 배치가 다르다 — 그래서 홈 전용으로 둔다.
/// (세 번째 화면이 같은 배치를 쓰게 되면 common/widgets로 승격)
class HomeSectionHead extends StatelessWidget {
  final String title;

  /// 제목 아래 한 줄 설명. 비면 제목만.
  final String? sub;

  /// null이면 '전체보기'를 그리지 않는다.
  final VoidCallback? onAction;

  const HomeSectionHead({
    super.key,
    required this.title,
    this.sub,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VybeTypography.heading4.copyWith(color: Colors.white),
                ),
                if (sub != null && sub!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RenewGlass.caption(lineHeight: 16),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // '주변 클럽' 섹션(home_nearby_clubs.dart)과 같은 표기 —
                  // 홈 안에서 같은 동작의 버튼이 섹션마다 다른 색·크기로
                  // 보이면 안 된다.
                  Text(
                    '전체보기',
                    style: VybeTypography.caption.copyWith(
                      color: VybeColors.gray400,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  SvgPicture.asset(
                    'assets/icons/home_screen/add_content.svg',
                    width: 4.w,
                    height: 8.h,
                    colorFilter: const ColorFilter.mode(
                      VybeColors.gray400,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 섹션 로딩·오류 자리를 같은 높이로 채우는 회색 안내.
class HomeSectionMessage extends StatelessWidget {
  final String text;

  /// **설계 단위**(393x852 기준) 높이 — 내부에서 `.h`로 환산한다.
  /// 호출부가 `.h`를 붙여 넘기면 두 번 환산되니 붙이지 말 것.
  final double height;

  const HomeSectionMessage({
    super.key,
    required this.text,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      child: Center(
        child: Text(
          text,
          style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
        ),
      ),
    );
  }
}
