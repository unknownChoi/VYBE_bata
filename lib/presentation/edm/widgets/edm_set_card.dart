import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/night_clock.dart';
import 'package:vybe/presentation/edm/edm_models.dart';
import 'package:vybe/presentation/edm/widgets/edm_equalizer.dart';

/// 타임테이블 셋 카드 1장 — 클럽 · DJ · 세부 장르 · 지역/거리 · 진행 상태.
///
/// 디자인(edm_renew.jsx `SetCard`)의 좌측 액센트 바 색은 BPM(에너지)에서 나오는데
/// performances 에 BPM 이 없다. **진행 상태**로 대신 칠한다 — 없는 값을 지어내느니
/// 이미 아는 것을 색으로 말한다.
class EdmSetCard extends StatelessWidget {
  final EdmSet set;
  final NightSlotStatus status;

  /// 지금 시각(분). '몇 분 후 시작' 계산용 — 카드마다 시계를 다시 읽으면
  /// 같은 목록 안에서 기준이 어긋난다.
  final int nowMin;

  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  const EdmSetCard({
    super.key,
    required this.set,
    required this.status,
    required this.nowMin,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  /// 상태별 강조색 — 진행 중은 라임, 예정은 보라, 종료는 회색.
  Color get _tone => switch (status) {
    NightSlotStatus.live => kEdmHot,
    NightSlotStatus.upcoming => kEdmAccentText,
    NightSlotStatus.past => VybeColors.gray500,
  };

  String get _statusText => switch (status) {
    NightSlotStatus.live => '진행 중',
    NightSlotStatus.upcoming => '${nightMinutes(set.time) - nowMin}분 후 시작',
    NightSlotStatus.past => '공연 종료',
  };

  @override
  Widget build(BuildContext context) {
    final live = status == NightSlotStatus.live;
    final radius = BorderRadius.circular(14.r);

    return Opacity(
      opacity: status == NightSlotStatus.past ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: live ? null : VybeColors.gray900,
            // 진행 중 카드만 보라 그라데이션 — 목록에서 눈이 먼저 닿는 자리.
            gradient: live
                ? const LinearGradient(
                    begin: Alignment(-0.87, -0.5),
                    end: Alignment(0.87, 0.5),
                    colors: [Color(0x4D7731FE), Color(0x8C231A3A)],
                  )
                : null,
            borderRadius: radius,
            boxShadow: live
                ? [
                    BoxShadow(
                      color: kEdmAccent.withValues(alpha: 0.26),
                      blurRadius: 24.r,
                      offset: Offset(0, 6.h),
                    ),
                  ]
                : null,
          ),
          // ⚠ 테두리는 자식 위(foregroundDecoration)에 — decoration 에 두면 좌측
          // 액센트 바가 코너 호에서 선을 덮는다. (CLAUDE.md '라운드 카드에 테두리')
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: live
                  ? kEdmAccent.withValues(alpha: 0.55)
                  : VybeColors.gray800,
            ),
            borderRadius: radius,
          ),
          child: Stack(
            children: [
              // 좌측 액센트 바.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3.w,
                child: ColoredBox(color: _tone),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15.w, 13.h, 12.w, 13.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _Info(set: set, live: live, tone: _tone,
                        statusText: _statusText)),
                    SizedBox(width: 10.w),
                    _SaveButton(saved: saved, onTap: onSave),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final EdmSet set;
  final bool live;
  final Color tone;
  final String statusText;

  const _Info({
    required this.set,
    required this.live,
    required this.tone,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 클럽 이름 + (진행 중이면) 이퀄라이저.
        Row(
          children: [
            Flexible(
              child: Text(
                set.club,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 17.sp,
                  height: 19 / 17,
                  letterSpacing: 17 * -0.025,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            if (live) ...[
              SizedBox(width: 7.w),
              const EdmEqualizer(color: kEdmHot, size: 12, bars: 3),
            ],
          ],
        ),
        SizedBox(height: 7.h),
        // DJ.
        Row(
          children: [
            Icon(Icons.bolt_rounded, size: 13.r, color: tone),
            SizedBox(width: 3.w),
            Text(
              set.dj,
              style: VybeTypography.caption.copyWith(
                fontSize: 12.5.sp,
                height: 14 / 12.5,
                fontWeight: FontWeight.w700,
                color: tone,
              ),
            ),
          ],
        ),
        SizedBox(height: 9.h),
        // 지역 · 거리 · 진행 상태.
        Row(
          children: [
            Flexible(
              child: Text(
                set.dist == null
                    ? set.area
                    : '${set.area} · ${set.dist!.toStringAsFixed(1)}km',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.caption.copyWith(
                  fontSize: 11.sp,
                  height: 12 / 11,
                  color: VybeColors.gray500,
                ),
              ),
            ),
            const _Dot(),
            Text(
              statusText,
              style: VybeTypography.caption.copyWith(
                fontSize: 11.sp,
                height: 12 / 11,
                fontWeight: FontWeight.w600,
                color: VybeColors.gray500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 메타 항목 사이 점 구분자.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Container(
        width: 2.r,
        height: 2.r,
        decoration: const BoxDecoration(
          color: VybeColors.gray600,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onTap;
  const _SaveButton({required this.saved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30.r,
        height: 30.r,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 15.r,
          color: saved ? kEdmAccent : Colors.white,
        ),
      ),
    );
  }
}
