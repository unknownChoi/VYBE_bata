import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/utils/gradient_palette.dart';
import 'package:vybe/core/utils/number_format.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_card_parts.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/common/widgets/vybe_save_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

// 검색결과 카드 (search_results_v2 리뉴얼) — 이미지 중심 + 하단 유체 글래스 바.
class ClubListItem extends StatelessWidget {
  final ClubModel club;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  const ClubListItem({
    super.key,
    required this.club,
    this.isFavorited = false,
    this.onFavoriteTap,
  });

  bool get _isOpen => club.operatingHours.today.isCurrentlyOpen;

  // clubId 해시 기반 일관 그라데이션 fallback (썸네일 없을 때).
  static const _fallbackGradients = <List<Color>>[
    [VybeColors.accentBlue500, VybeColors.mainPurple500],
    [Color(0xFFFF006E), Color(0xFF8338EC)],
    [Color(0xFF06FFA5), Color(0xFF3A86FF)],
    [Color(0xFFFB5607), Color(0xFFFFBE0B)],
    [Color(0xFF6D4C91), Color(0xFF2A2D34)],
    [Color(0xFF3A0CA3), Color(0xFF4361EE)],
  ];

  void _openDetail(BuildContext context) {
    openClubDetail(context, club.clubId);
  }

  @override
  Widget build(BuildContext context) {
    final grad = gradientForKey(_fallbackGradients, club.clubId);
    return GestureDetector(
      onTap: () => _openDetail(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
        child: Container(
          height: 208.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: grad,
            ),
            borderRadius: BorderRadius.circular(18.r),
          ),
          // ⚠ 테두리는 자식 위(foregroundDecoration)에. decoration 에 두면 자식이
          // 바깥 라운드렉트로 클립되면서 코너 호에서 선을 덮어, 직선부만 남고
          // 모서리가 끊긴 것처럼 보인다. (CLAUDE.md '라운드 카드에 테두리' 참고)
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: VybeColors.gray800),
            borderRadius: BorderRadius.circular(18.r),
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
              // 상단 우측 화이트 하이라이트 (radial).
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.4, -0.85),
                      radius: 0.9,
                      colors: [Color(0x2EFFFFFF), Color(0x00000000)],
                      stops: [0.0, 0.55],
                    ),
                  ),
                ),
              ),
              _buildStatusPill(),
              _buildSaveButton(),
              _GlassBar(club: club),
            ],
          ),
        ),
      ),
    );
  }

  // 영업 상태 pill (우상단, 찜 버튼 왼쪽).
  Widget _buildStatusPill() {
    return Positioned(
      top: 12.h,
      right: 52.w,
      child: Container(
        height: 32.r,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 11.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(
            color: _isOpen
                ? VybeColors.mainLime500.withValues(alpha: 0.45)
                : VybeColors.gray700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                color: _isOpen ? VybeColors.mainLime500 : VybeColors.gray500,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              _isOpen ? '영업중' : '영업종료',
              style: VybeTypography.caption.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: _isOpen ? VybeColors.mainLime500 : VybeColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      top: 12.h,
      right: 12.w,
      child: VybeSaveButton(saved: isFavorited, onTap: onFavoriteTap),
    );
  }
}

/// 카드 하단 유체 글래스 바 — 블러 + 그라데이션, 상단 페이드로 사진과 자연 연결.
class _GlassBar extends StatelessWidget {
  final ClubModel club;

  const _GlassBar({required this.club});

  @override
  Widget build(BuildContext context) {
    // 무료입장 정책은 두 갈래 — 상시 무료(entryFeeMin=0)와 시간대 무료.
    // 시간대 무료는 '지금'이 창 안이고 **영업 중일 때만** 무료라고 말한다
    // (문 닫은 클럽의 '지금 무료'는 거짓 정보).
    final now = DateTime.now();
    final timedFreeNow =
        club.freeEntry.isTimed &&
        club.freeEntry.statusAt(now).isFreeNow &&
        club.operatingHours.dayAt(now).isOpenAt(now);
    final free = club.entryFeeMin == 0 || timedFreeNow;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white],
          stops: [0.0, 0.35],
        ).createShader(rect),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 34.h, 16.w, 15.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xD1101015), Color(0x001C1C26)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VybeClubTitleRow(
                    name: club.name,
                    rating: club.rating,
                    recommended: club.isVybeRecommended,
                    titleHeight: 1.0,
                    trailing: Text(
                      '리뷰 ${club.reviewCount}',
                      style: VybeTypography.caption.copyWith(
                        fontSize: 12.sp,
                        color: VybeColors.gray400,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _MetaRow(club: club),
                  SizedBox(height: 8.h),
                  _FeeChip(club: club, free: free, timedFreeNow: timedFreeNow),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 지역 · 장르 · 영업종료 시각.
///
/// 공용 [VybeClubMetaRow] 를 쓰지 않는 이유 — 검색 결과 카드는 거리 대신
/// 영업종료 시각을 붙인다(검색은 위치 기준 목록이 아니다).
class _MetaRow extends StatelessWidget {
  final ClubModel club;

  const _MetaRow({required this.club});

  bool get _isOpen => club.operatingHours.today.isCurrentlyOpen;
  String? get _closeTime => club.operatingHours.today.close;

  @override
  Widget build(BuildContext context) {
    final meta = VybeTypography.caption.copyWith(
      fontSize: 12.sp,
      height: 1.0,
      color: VybeColors.gray400,
    );
    return Row(
      children: [
        Icon(Icons.place_rounded, size: 11.r, color: VybeColors.gray300),
        SizedBox(width: 3.w),
        Text(
          club.area,
          style: meta.copyWith(
            fontWeight: FontWeight.w600,
            color: VybeColors.gray300,
          ),
        ),
        const VybeMetaDot(),
        Text(club.genre, style: meta),
        if (_isOpen && _closeTime != null) ...[
          const VybeMetaDot(),
          Icon(
            Icons.access_time_rounded,
            size: 11.r,
            color: VybeColors.gray400,
          ),
          SizedBox(width: 3.w),
          Text('$_closeTime 영업종료', style: meta),
        ],
      ],
    );
  }
}

/// 입장료 칩 (무료면 라임).
class _FeeChip extends StatelessWidget {
  final ClubModel club;

  /// 상시 무료이거나 시간대 무료가 지금 유효한지.
  final bool free;

  /// 시간대 무료가 **지금** 진행 중인지.
  final bool timedFreeNow;

  const _FeeChip({
    required this.club,
    required this.free,
    required this.timedFreeNow,
  });

  /// 시간대 무료가 진행 중이면 평상시 요금 대신 '지금 무료'를 앞세운다 —
  /// 무료 시간이 끝나면 다시 원래 요금 표기로 돌아간다.
  String get _label {
    if (timedFreeNow) return '지금 무료입장';
    if (free) {
      return club.entryFeeMax == 0
          ? '입장료 무료'
          : '입장료 0 ~ ${formatThousands(club.entryFeeMax)}원';
    }
    return '입장료 ${formatThousands(club.entryFeeMin)} ~ '
        '${formatThousands(club.entryFeeMax)}원';
  }

  @override
  Widget build(BuildContext context) {
    final tint = free ? VybeColors.mainLime500 : VybeColors.gray300;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: free
            ? VybeColors.mainLime500.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: free
              ? VybeColors.mainLime500.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/common/club_card/won.svg',
            width: 11.r,
            height: 11.r,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
          ),
          SizedBox(width: 5.w),
          Text(
            _label,
            style: VybeTypography.caption.copyWith(
              fontSize: 11.sp,
              height: 1.0,
              fontWeight: FontWeight.w700,
              color: free ? VybeColors.mainLime500 : VybeColors.gray200,
            ),
          ),
        ],
      ),
    );
  }
}
