import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/hot_places/hot_places_models.dart';

// 핫플레이스 상단 — 백드롭 · 인트로 · 지역 필터.

// ── 백드롭 그라데이션 ──
class HotPlacesBackdrop extends StatelessWidget {
  const HotPlacesBackdrop({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-1, -1),
                radius: 1.2,
                colors: [kHotAccent.withValues(alpha: 0.30), Colors.transparent],
                stops: const [0, 0.72],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(1, -0.85),
                radius: 1.3,
                colors: [const Color(0xFFFF3B30).withValues(alpha: 0.17), Colors.transparent],
                stops: const [0, 0.72],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 인트로 (헤딩 + 실시간 배지) ──
class HotPlacesIntro extends StatelessWidget {
  final String area;
  const HotPlacesIntro({super.key, required this.area});

  @override
  Widget build(BuildContext context) {
    final base = VybeTypography.heading2.copyWith(
      fontSize: 27.sp,
      height: 33 / 27,
      color: Colors.white,
    );
    final spans = area == '전체'
        ? <InlineSpan>[
            const TextSpan(text: '지금 가장 '),
            const TextSpan(text: '뜨거운', style: TextStyle(color: kHotAccent)),
            const TextSpan(text: '\n클럽을 모아봤어요'),
          ]
        : <InlineSpan>[
            TextSpan(text: '지금 $area에서 가장 '),
            const TextSpan(text: '뜨거운', style: TextStyle(color: kHotAccent)),
            const TextSpan(text: '\n클럽을 모아봤어요'),
          ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: Text.rich(
              TextSpan(style: base, children: spans),
              key: ValueKey(area),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HotPlacesPulseDot(),
                    SizedBox(width: 5.w),
                    Text(
                      '실시간',
                      style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 7.w),
              Flexible(
                child: Text(
                  '오늘 23:40 기준 · 최근 2시간 방문자 순',
                  style: VybeTypography.caption.copyWith(height: 16 / 12, color: VybeColors.gray400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HotPlacesPulseDot extends StatefulWidget {
  const HotPlacesPulseDot({super.key});
  @override
  State<HotPlacesPulseDot> createState() => _HotPlacesPulseDotState();
}

class _HotPlacesPulseDotState extends State<HotPlacesPulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.18).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.7).animate(_c),
        child: Container(
          width: 7.r,
          height: 7.r,
          decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ── 지역 필터 ──
class HotPlacesAreaFilter extends StatelessWidget {
  final String active;
  final bool scrolled;
  final ValueChanged<String> onChange;
  const HotPlacesAreaFilter({super.key, required this.active, required this.scrolled, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scrolled ? VybeColors.background.withValues(alpha: 0.92) : Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final a in kHotAreas) ...[
              _HotPlacesChip(label: a, selected: a == active, onTap: () => onChange(a)),
              if (a != kHotAreas.last) SizedBox(width: 8.w),
            ],
          ],
        ),
      ),
    );
  }
}

class _HotPlacesChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _HotPlacesChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNear = label == '내 주변';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(
          left: isNear ? 11.w : 16.w,
          right: 16.w,
          top: 8.h,
          bottom: 8.h,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: selected ? null : Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNear) ...[
              Icon(Icons.place, size: 13.r, color: selected ? Colors.black : kHotAccent),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: VybeTypography.button2.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.black : VybeColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
