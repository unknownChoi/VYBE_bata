import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/my_page/widgets/notice_glass.dart';

/// 헤더 — 원형 글래스 뒤로가기 + '공지사항' + `vybe 운영팀`이 전하는 소식.
class NoticesHeader extends StatelessWidget {
  const NoticesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, top + 8.h, 16.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앱 공통 리퀴드 글래스 버튼 (누르면 줄어들며 라임 글로우).
          VybeGlassButton(
            onTap: () => Navigator.of(context).maybePop(),
            size: 38,
            iconSize: 17,
            hitSize: 42,
          ),
          SizedBox(height: 18.h),
          Text(
            '공지사항',
            style: VybeTypography.heading1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              const NoticeTeamPill(),
              SizedBox(width: 7.w),
              Text(
                '이 전하는 소식',
                style: VybeTypography.body4.copyWith(color: ClubGlass.t3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
