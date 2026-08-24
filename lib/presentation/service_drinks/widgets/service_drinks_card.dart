import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_club_card_parts.dart';
import 'package:vybe/presentation/common/widgets/vybe_open_now_pill.dart';
import 'package:vybe/presentation/common/widgets/vybe_save_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_models.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_style.dart';

/// 서비스 음료 클럽 카드 (디자인 service_drinks.jsx).
///
/// 사진 위에 `perk 리본 + 영업 pill`(상단) / `찜`(우상단) /
/// `이름·평점·지역·장르`(하단 글래스 바)를 얹는다.
class ServiceDrinksCard extends StatelessWidget {
  final ServiceDrinkClub club;
  final bool saved;

  /// 비로그인이면 null — 찜 버튼이 비활성으로 그려진다.
  final VoidCallback? onSave;
  final VoidCallback onTap;

  const ServiceDrinksCard({
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
      child: Container(
        height: kDrinkCardHeight.h,
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
            // 클럽 썸네일 (없으면 gradient만 노출).
            // SkeletonImage: 디코드 완료 후에도 1초간 shimmer 유지 후 reveal.
            if (club.thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: SkeletonImage(
                  url: club.thumbnailUrl,
                  fit: BoxFit.cover,
                  minSkeleton: const Duration(seconds: 1),
                ),
              ),
            const VybeCardScrim(),
            // perk 리본(좌) + 영업 pill(우) — 한 Row로 묶어 겹침 방지.
            // 찜 버튼 영역(우측 12~44w) 피하려 right: 52.w.
            Positioned(
              top: 14.h,
              left: 14.w,
              right: 52.w,
              child: Row(
                children: [
                  Flexible(child: _PerkRibbon(text: club.perk)),
                  SizedBox(width: 8.w),
                  VybeOpenNowPill(open: club.open, height: 32.h),
                ],
              ),
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: VybeSaveButton(saved: saved, onTap: onSave),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _InfoBar(club: club),
            ),
          ],
        ),
      ),
    );
  }
}

/// 제공 코멘트 리본. 길면 ellipsis로 줄어든다.
class _PerkRibbon extends StatelessWidget {
  final String text;
  const _PerkRibbon({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: kDrinkAccent,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: kDrinkAccent.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.liquor_rounded, size: 14.r, color: kDrinkInk),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VybeTypography.button2.copyWith(
                fontWeight: FontWeight.w800,
                color: kDrinkInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 하단 정보 — 유체 글래스 바 (full bleed, 사진 위 블러로 가독성 확보).
/// 디자인(service_drinks.jsx): blur(18px) + 어두운 그라데이션.
///
/// 상단 경계선 대신 dstIn 마스크로 윗부분을 페이드시켜 사진과 이어붙인다.
class _InfoBar extends StatelessWidget {
  final ServiceDrinkClub club;
  const _InfoBar({required this.club});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        // 위 35%까지 투명 → 불투명 (블러·스크림 경계 feather).
        colors: [Colors.transparent, Colors.white],
        stops: [0.0, 0.35],
      ).createShader(rect),
      child: ClipRect(
        child: BackdropFilter(
          // CSS blur(18px) ≈ sigma 9.
          filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 34.h, 16.w, 22.h),
            decoration: const BoxDecoration(
              // rgba(16,16,21,0.82) → rgba(28,28,38,0) (아래 → 위로 투명).
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
                ),
                SizedBox(height: 7.h),
                VybeClubMetaRow(
                  area: club.area,
                  dist: club.dist,
                  genre: club.genre,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
