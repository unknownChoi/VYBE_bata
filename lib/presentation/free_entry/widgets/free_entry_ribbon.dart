import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/free_entry/free_entry_models.dart';
import 'package:vybe/presentation/free_entry/free_entry_style.dart';

/// 카드 좌상단 무료입장 리본.
///
/// 상태 셋 — ① 지금 무료(영업 중 + 무료 창 안) ② 시간대 무료인데 지금은 아님
/// ③ 상시 무료. ②만 톤을 낮춘다(채운 라임은 "지금 들어가면 공짜"라는 뜻으로 읽혀서).
class FreeEntryRibbon extends StatelessWidget {
  final FreeEntryClub club;

  const FreeEntryRibbon({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    final pending = club.timed && !club.freeNow;
    final fg = pending ? kEntryAccent : kEntryInk;

    return Container(
      height: 32.r,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 11.w),
      decoration: BoxDecoration(
        color: pending ? const Color(0xCC141018) : kEntryAccent,
        borderRadius: BorderRadius.circular(12.r),
        border: pending
            ? Border.all(color: kEntryAccent.withValues(alpha: 0.5))
            : null,
        boxShadow: pending
            ? null
            : [
                BoxShadow(
                  color: kEntryAccent.withValues(alpha: 0.34),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pending
                ? Icons.schedule_rounded
                : Icons.confirmation_number_rounded,
            size: 15.r,
            color: fg,
          ),
          SizedBox(width: 6.w),
          Text(
            _ribbonLabel(club),
            style: VybeTypography.button2.copyWith(
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// 리본 문구.
///
/// 상시 무료도 '지금 무료'이긴 하나 그렇게 쓰면 시간 제한이 있는 것처럼 읽힌다
/// → 종류(timed)를 먼저 보고 문구를 고른다.
String _ribbonLabel(FreeEntryClub club) => switch ((club.timed, club.freeNow)) {
  (false, _) => '입장비 무료',
  (true, true) =>
    club.remainingLabel == null ? '지금 무료' : '지금 무료 · ${club.remainingLabel}',
  // 창을 못 읽은 데이터(빈 windows)는 시각 대신 종류만 말한다.
  (true, false) =>
    club.windowLabel.isEmpty ? '시간대 무료' : '${club.windowLabel} 무료',
};
