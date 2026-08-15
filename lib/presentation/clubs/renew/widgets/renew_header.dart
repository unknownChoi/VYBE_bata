import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 히어로 높이 (디자인 VRHero 356).
const double kRenewHeroHeight = 356;

/// 타이틀 블록이 히어로를 덮는 깊이 (디자인 marginTop -24).
const double kRenewTitleOverlap = 24;

// ============================================================================
// 히어로 (VRHero)
// ============================================================================

/// 상단 이미지 캐러셀. 4.2초마다 자동으로 크로스페이드하고,
/// 아래쪽은 마스크로 서서히 사라져 오로라 배경과 이어진다.
///
/// 스크롤과 함께 위로 밀려야 해서 스크롤 뷰 **바깥**(루트 Stack)에 놓고
/// 화면이 스크롤한 만큼 위로 옮긴다 — 스크롤 뷰는 상단바 아래에서 시작하는데
/// 히어로는 상단바 뒤까지 올라와야 하기 때문.
class RenewHero extends StatefulWidget {
  final List<String> imageUrls;

  /// 클럽 로딩 중 — 이미지 자리에 스켈레톤.
  final bool loading;

  const RenewHero({super.key, required this.imageUrls, this.loading = false});

  @override
  State<RenewHero> createState() => _RenewHeroState();
}

class _RenewHeroState extends State<RenewHero> {
  int _index = 0;
  Timer? _timer;

  static const _autoPlay = Duration(milliseconds: 4200);
  static const _fade = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_autoPlay, (_) {
      if (!mounted || widget.imageUrls.length < 2) return;
      setState(() => _index = (_index + 1) % widget.imageUrls.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _go(int i) {
    final total = widget.imageUrls.length;
    if (total == 0) return;
    setState(() => _index = (i + total) % total);
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls;
    final total = images.length;

    return SizedBox(
      height: kRenewHeroHeight.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 마스크 안쪽 — 이미지 + 하이라이트 + 스크림
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black,
                Color(0x8C000000),
                Color(0x00000000),
              ],
              stops: [0.0, 0.58, 0.82, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.loading)
                  const VybeSkel(radius: 0)
                else
                  for (var i = 0; i < total; i++)
                    AnimatedOpacity(
                      opacity: i == _index ? 1 : 0,
                      duration: _fade,
                      curve: Curves.easeInOut,
                      child: SkeletonImage(url: images[i], fit: BoxFit.cover),
                    ),
                // radial(70% 60% at 26% 20%, rgba(255,255,255,0.22), transparent 62%)
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.48, -0.6),
                        radius: 0.9,
                        colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
                        stops: [0.0, 0.62],
                      ),
                    ),
                  ),
                ),
                // linear(180deg, rgba(8,7,12,.62), transparent 32%,
                //        rgba(14,13,18,.42) 76%, rgba(14,13,18,.72) 100%)
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x9E08070C),
                          Color(0x00000000),
                          Color(0x6B0E0D12),
                          Color(0xB80E0D12),
                        ],
                        stops: [0.0, 0.32, 0.76, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 좌우로 밀어 사진 넘기기 (디자인엔 없지만 캐러셀 기본 동작).
          if (total > 1)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v == 0) return;
                  _go(v < 0 ? _index + 1 : _index - 1);
                },
              ),
            ),
          if (total > 1) ...[
            // 카운터
            Positioned(
              right: RenewGlass.pagePad.w,
              bottom: 58.h,
              child: IgnorePointer(child: _counter(total)),
            ),
            // 도트 인디케이터
            Positioned(
              left: RenewGlass.pagePad.w,
              bottom: 60.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(total, (i) {
                  final on = i == _index;
                  return GestureDetector(
                    onTap: () => _go(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: EdgeInsets.only(right: i == total - 1 ? 0 : 5.w),
                      width: on ? 18.w : 5.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: on ? Colors.white : const Color(0x61FFFFFF),
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _counter(int total) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: RenewGlass.barFill,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0x24FFFFFF)),
      ),
      child: Text(
        '${_index + 1} / $total',
        style: RenewGlass.caption(
          color: Colors.white,
          lineHeight: 15,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
// 타이틀 블록 (VRTitle)
// ============================================================================

/// 히어로 아래 카드 없이 배경 위에 바로 얹히는 클럽 아이덴티티 블록.
class RenewTitleBlock extends StatelessWidget {
  final ClubModel club;

  /// `0.4km` — 내 위치 기준 거리. 좌표가 없으면 null.
  final String? distanceLabel;

  const RenewTitleBlock({super.key, required this.club, this.distanceLabel});

  @override
  Widget build(BuildContext context) {
    final today = club.operatingHours.today;
    final isOpen = today.isCurrentlyOpen;
    final statusLabel = isOpen && today.close != null
        ? '영업중 · ${today.close} 종료'
        : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        RenewGlass.pagePad.w,
        0,
        RenewGlass.pagePad.w,
        2.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (club.isVybeRecommended) ...[
                const VybeRecommendBadge(),
                SizedBox(width: 8.w),
              ],
              RenewStatusPill(isOpen: isOpen, label: statusLabel),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            club.name,
            style: VybeTypography.heading2.copyWith(color: RenewGlass.t1),
          ),
          SizedBox(height: 12.h),
          RenewMetaRow(
            items: [
              club.area,
              club.genre,
              if (distanceLabel != null) distanceLabel!,
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/club_card/star.svg',
                width: 15.r,
                height: 15.r,
              ),
              SizedBox(width: 7.w),
              Text(
                club.rating.toStringAsFixed(2),
                style: VybeTypography.body3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: RenewGlass.t1,
                ),
              ),
              SizedBox(width: 7.w),
              const RenewDot(),
              SizedBox(width: 7.w),
              Text(
                '리뷰 ${club.reviewCount}',
                style: RenewGlass.body(color: RenewGlass.t3),
              ),
            ],
          ),
          if (club.description.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(club.description, style: RenewGlass.body(lineHeight: 20)),
          ],
          if (club.tags.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                for (final tag in club.tags)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 11.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: RenewGlass.tileFill,
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(color: RenewGlass.tileBorder),
                    ),
                    child: Text(
                      '#$tag',
                      style: RenewGlass.caption(
                        color: RenewGlass.lavender,
                        lineHeight: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
