import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_card_parts.dart';
import 'package:vybe/presentation/common/widgets/vybe_open_now_pill.dart';
import 'package:vybe/presentation/common/widgets/vybe_save_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/free_entry/free_entry_models.dart';
import 'package:vybe/presentation/free_entry/free_entry_style.dart';
import 'package:vybe/presentation/free_entry/widgets/free_entry_ribbon.dart';

/// 입장비 무료 목록의 클럽 카드 1장.
class FreeEntryCard extends StatelessWidget {
  final FreeEntryClub club;
  final bool saved;

  /// null이면 비로그인 — 찜 버튼이 눌리지 않는다.
  final VoidCallback? onSave;
  final VoidCallback onTap;

  const FreeEntryCard({
    super.key,
    required this.club,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: kEntryCardHeight.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: club.gradient,
          ),
          borderRadius: radius,
        ),
        // ⚠ 테두리는 자식 위(foregroundDecoration)에. decoration 에 두면 자식이
        // 바깥 라운드렉트로 클립되면서 코너 호에서 선을 덮어, 직선부만 남고
        // 모서리가 끊긴 것처럼 보인다. (CLAUDE.md '라운드 카드에 테두리' 참고)
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: VybeColors.gray800),
          borderRadius: radius,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 클럽 썸네일 (없으면 gradient만).
            if (club.thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: SkeletonImage(
                  url: club.thumbnailUrl,
                  fit: BoxFit.cover,
                  minSkeleton: const Duration(seconds: 1),
                ),
              ),
            const VybeCardScrim(),
            Positioned(
              top: 12.h,
              left: 12.w,
              child: FreeEntryRibbon(club: club),
            ),
            Positioned(
              top: 12.h,
              right: 52.w,
              child: VybeOpenNowPill(open: club.open),
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: VybeSaveButton(saved: saved, onTap: onSave),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 14.h,
              child: _CardFooter(club: club),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카드 하단 정보 블록 — 이름·평점 / 지역·거리·장르 / 입장 조건·요금.
class _CardFooter extends StatelessWidget {
  final FreeEntryClub club;

  const _CardFooter({required this.club});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VybeClubTitleRow(
          name: club.name,
          rating: club.rating,
          recommended: club.isVybeRecommended,
          titleHeight: 1.0,
        ),
        SizedBox(height: 6.h),
        VybeClubMetaRow(
          area: club.area,
          dist: club.dist,
          genre: club.genre,
          lineHeight: 1.0,
        ),
        SizedBox(height: 9.h),
        Row(
          children: [
            Flexible(child: _ConditionChip(cond: club.cond)),
            SizedBox(width: 8.w),
            ..._feeTail(club),
          ],
        ),
      ],
    );
  }
}

/// 입장 조건 칩 (`freeEntry.condition`).
class _ConditionChip extends StatelessWidget {
  final String cond;

  const _ConditionChip({required this.cond});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: kEntryAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: kEntryAccent.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 11.r,
            color: kEntryAccent,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              cond,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VybeTypography.caption.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: kEntryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 카드 하단 요금 표기.
///
/// 무료가 **지금 유효할 때만** 취소선을 긋는다 — 무료 시간이 아닌 클럽에 취소선을
/// 그으면 지금 공짜로 들어갈 수 있다는 거짓말이 된다. 그때는 평상시 요금을
/// 그대로 보여 주고 언제부터 무료인지를 덧붙인다.
List<Widget> _feeTail(FreeEntryClub club) {
  // 상시 무료는 영업 여부와 무관하게 정책 자체가 무료 → 취소선 유지.
  final struck = !club.timed || club.freeNow;
  final fee = club.cover > 0 ? '${formatThousands(club.cover)}원' : '';

  return [
    if (fee.isNotEmpty) ...[
      Text(
        fee,
        style: VybeTypography.caption.copyWith(
          fontSize: 11.sp,
          color: VybeColors.gray500,
          decoration: struck ? TextDecoration.lineThrough : null,
        ),
      ),
      SizedBox(width: 5.w),
    ],
    Text(
      struck
          ? '무료'
          : (club.startsLabel == null ? '무료 시간 종료' : '${club.startsLabel} 무료'),
      style: VybeTypography.caption.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: struck ? Colors.white : VybeColors.gray300,
      ),
    ),
  ];
}
