import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/common/widgets/vybe_save_button.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_gradients.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_style.dart';
import 'package:vybe/presentation/hip_hop/hip_hop_view_models.dart';

// 힙합 히어로 — 오늘 밤 헤드라인 공연 캐러셀.

// ── 배너 빈 상태 (오늘 공연 없음) ──
class HipHopHeroEmpty extends StatelessWidget {
  const HipHopHeroEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: 320.h,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1216), Color(0xFF0D0A0C)],
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: top + 52.h, left: 24.w, right: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: kHipAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: kHipAccent.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.mic_external_off_rounded,
              size: 26.r,
              color: kHipAccent,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '오늘 예정된 공연이 없어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18.sp,
              height: 22 / 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '새로운 공연 일정이 등록되면 여기에 표시돼요.',
            textAlign: TextAlign.center,
            style: VybeTypography.body4.copyWith(
              height: 18 / 13,
              color: VybeColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 히어로 캐러셀 (배너 광고 — 좌우 스크롤 + 자동 넘김) ──
class HipHopHeroCarousel extends StatefulWidget {
  final List<HipHopHero> heroes;
  final Set<Object> saved;
  final ValueChanged<Object> onSave;
  const HipHopHeroCarousel({super.key, 
    required this.heroes,
    required this.saved,
    required this.onSave,
  });

  @override
  State<HipHopHeroCarousel> createState() => _HipHopHeroCarouselState();
}

class _HipHopHeroCarouselState extends State<HipHopHeroCarousel> {
  final PageController _page = PageController();
  int _active = 0;
  Timer? _auto;

  // 배너 자동 넘김 주기.
  static const _kRotate = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    _auto?.cancel();
    if (widget.heroes.length <= 1) return;
    _auto = Timer.periodic(_kRotate, (_) {
      if (!mounted || !_page.hasClients) return;
      final next = (_active + 1) % widget.heroes.length;
      _page.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant HipHopHeroCarousel old) {
    super.didUpdateWidget(old);
    if (old.heroes.length != widget.heroes.length) {
      if (_active >= widget.heroes.length) _active = 0;
      _startAuto();
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroes = widget.heroes;
    return SizedBox(
      height: 440.h,
      child: Stack(
        children: [
          // 사용자가 직접 스와이프하면 자동 넘김 타이머 리셋(바로 안 넘어가게).
          NotificationListener<UserScrollNotification>(
            onNotification: (n) {
              if (n.direction != ScrollDirection.idle) _startAuto();
              return false;
            },
            child: PageView.builder(
              controller: _page,
              onPageChanged: (i) => setState(() => _active = i),
              itemCount: heroes.length,
              itemBuilder: (_, i) => HipHopHeroSlide(
                h: heroes[i],
                saved: widget.saved.contains('hero-${heroes[i].name}'),
                onSave: () => widget.onSave('hero-${heroes[i].name}'),
              ),
            ),
          ),
          // 페이지 인디케이터.
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < heroes.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    height: 6.h,
                    width: i == _active ? 20.w : 6.w,
                    decoration: BoxDecoration(
                      color: i == _active
                          ? kHipAccent
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(99.r),
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

class HipHopHeroSlide extends StatelessWidget {
  final HipHopHero h;
  final bool saved;
  final VoidCallback onSave;
  const HipHopHeroSlide({super.key, 
    required this.h,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: hipHopSlideGradient(h.bg))),
        // 우상단 화이트 하이라이트.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, -0.76),
                radius: 0.9,
                colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
                stops: [0.0, 0.55],
              ),
            ),
          ),
        ),
        // 하단 어둡게.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF0D0A0C),
                  Color(0x8C0D0A0C),
                  Color(0x260D0A0C),
                  Color(0x660D0A0C),
                ],
                stops: [0.06, 0.42, 0.70, 1.0],
              ),
            ),
          ),
        ),
        // 찜.
        Positioned(
          top: 60.h,
          right: 16.w,
          child: VybeSaveButton(
            saved: saved,
            onTap: onSave,
            size: 38,
            iconSize: 20,
            backgroundOpacity: 0.4,
          ),
        ),
        // 본문.
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 42.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // eyebrow.
              Container(
                margin: EdgeInsets.only(bottom: 13.h),
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: kHipAccent,
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: [
                    BoxShadow(
                      color: kHipAccent.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_none_rounded, size: 13.r, color: kHipOnAccent),
                    SizedBox(width: 6.w),
                    Text(
                      h.tag,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11.sp,
                        height: 12 / 11,
                        fontWeight: FontWeight.w800,
                        color: kHipOnAccent,
                        letterSpacing: 11 * 0.02,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                h.name,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 40.sp,
                  height: 42 / 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0x800D0A0C),
                      blurRadius: 24,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              // 라인업 · 장르.
              Row(
                children: [
                  Icon(Icons.mic_none_rounded, size: 14.r, color: kHipAccent),
                  SizedBox(width: 4.w),
                  Text(
                    '${h.lineup} LIVE',
                    style: VybeTypography.body4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: kHipAccent,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const VybeMetaDot(size: 3, gap: 0),
                  SizedBox(width: 8.w),
                  Text(
                    h.genre,
                    style: VybeTypography.body4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: VybeColors.gray200,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // CTA.
              Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kHipAccent,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: kHipAccent.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 16.r, color: kHipOnAccent),
                    SizedBox(width: 7.w),
                    Text(
                      '지금 입장 정보 보기',
                      style: VybeTypography.button1.copyWith(
                        fontWeight: FontWeight.w800,
                        color: kHipOnAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 13.h),
              // 평점 · 위치 · 시간.
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 13.r,
                    color: VybeColors.mainLime500,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    h.rating.toStringAsFixed(2),
                    style: VybeTypography.body4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  const VybeMetaDot(size: 3, gap: 0),
                  SizedBox(width: 7.w),
                  Icon(
                    Icons.place_rounded,
                    size: 12.r,
                    color: VybeColors.gray300,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      '${h.area} · ${h.dist}km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VybeTypography.body4.copyWith(
                        color: VybeColors.gray300,
                      ),
                    ),
                  ),
                  SizedBox(width: 7.w),
                  const VybeMetaDot(size: 3, gap: 0),
                  SizedBox(width: 7.w),
                  Text(
                    h.time,
                    style: VybeTypography.body4.copyWith(
                      color: VybeColors.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
