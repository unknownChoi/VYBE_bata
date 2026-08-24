import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_card_parts.dart';
import 'package:vybe/presentation/free_entry/free_entry_style.dart';

/// 화면 상단 인트로 — 헤드라인 + '지금 무료 n곳' pill + `{지역} 근처 {n}곳`.
class FreeEntryIntro extends StatelessWidget {
  /// 필터·정렬을 거친 뒤의 클럽 수 (전체 수가 아니다).
  final int count;

  /// 이 중 지금 무료인 곳. 0이면 pill 문구를 '무료입장 정책'으로 낮춘다 —
  /// 한 곳도 무료가 아닌데 '지금 무료입장'이라 쓰면 거짓 정보다.
  final int freeNowCount;

  /// 헤드라인 접두사. '전체' → '내 주변', 그 외 → 지역명(예: '홍대').
  final String region;

  const FreeEntryIntro({
    super.key,
    required this.count,
    required this.freeNowCount,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = region == kFilterAll ? '내 주변' : region;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Headline(prefix: prefix, region: region),
          SizedBox(height: 9.h),
          Row(
            children: [
              _FreeNowPill(freeNowCount: freeNowCount),
              SizedBox(width: 7.w),
              VybeAreaCountLine(area: prefix, count: count),
            ],
          ),
        ],
      ),
    );
  }
}

/// 지역 변경 시 페이드+슬라이드로 갈아 끼우는 헤드라인 (핫플레이스와 동일 패턴).
class _Headline extends StatelessWidget {
  final String prefix;
  final String region;

  const _Headline({required this.prefix, required this.region});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 27.sp,
      height: 33 / 27,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 27 * -0.025,
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Text.rich(
        key: ValueKey(region),
        TextSpan(
          style: base,
          children: [
            TextSpan(text: '$prefix '),
            const TextSpan(
              text: '입장비 무료',
              style: TextStyle(color: kEntryAccent),
            ),
            const TextSpan(text: '\n클럽 모아보기'),
          ],
        ),
      ),
    );
  }
}

/// '지금 무료 n곳' pill. 0곳이면 점을 회색으로 낮추고 문구를 '무료입장 정책'으로 바꾼다.
class _FreeNowPill extends StatelessWidget {
  final int freeNowCount;

  const _FreeNowPill({required this.freeNowCount});

  @override
  Widget build(BuildContext context) {
    final hasFreeNow = freeNowCount > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: kEntryAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: kEntryAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: hasFreeNow ? kEntryAccent : VybeColors.gray500,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            hasFreeNow ? '지금 무료 $freeNowCount곳' : '무료입장 정책',
            style: VybeTypography.caption.copyWith(
              height: 14 / 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
