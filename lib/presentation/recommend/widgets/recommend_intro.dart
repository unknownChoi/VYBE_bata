import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/recommend/recommend_models.dart';

// VYBE 추천 인트로 — 이번 주 큐레이션 기준 안내.

// ── 인트로 밴드 ──
class RecommendIntro extends StatelessWidget {
  const RecommendIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    // 그라데이션은 화면 전체 배경 레이어가 담당 (build의 Stack 참조).
    // 인트로는 패딩만 — 자체 그라데이션 제거해 클럽 섹션과 자연스럽게 이어짐.
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, top + 60.h, 24.w, 26.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이번 주 vybe PICK 배지.
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: VybeColors.mainPurple500.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: VybeColors.mainPurple700),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 13.r, color: VybeColors.mainLime500),
                SizedBox(width: 6.w),
                Text('이번 주 vybe PICK',
                    style: VybeTypography.caption.copyWith(
                      height: 14 / 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text.rich(
            TextSpan(
              style: VybeTypography.heading2.copyWith(
                fontSize: 30.sp,
                height: 36 / 30,
                color: Colors.white,
              ),
              children: const [
                TextSpan(text: '오늘 밤, '),
                // 브랜드 라임 (녹색).
                TextSpan(
                    text: '실패 없는',
                    style: TextStyle(color: VybeColors.mainLime500)),
                TextSpan(text: '\n'),
                // 브랜드 퍼플.
                TextSpan(
                    text: '클럽',
                    style: TextStyle(color: VybeColors.mainPurple500)),
                TextSpan(text: '만 골랐어요'),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text('최근 방문자 리뷰와 분위기 데이터를 분석해\nvybe가 직접 큐레이션한 추천 리스트예요.',
              style: VybeTypography.body3
                  .copyWith(color: VybeColors.gray400, height: 22 / 16)),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: kRecommendCriteria.map(_criterionChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _criterionChip(RecommendCriterion c) {
    return Container(
      padding: EdgeInsets.fromLTRB(9.w, 7.h, 12.w, 7.h),
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: c.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18.r,
            height: 18.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.17),
              shape: BoxShape.circle,
            ),
            child: Icon(c.icon, size: 11.r, color: c.color),
          ),
          SizedBox(width: 6.w),
          Text(c.label,
              style: VybeTypography.caption.copyWith(
                height: 14 / 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}
