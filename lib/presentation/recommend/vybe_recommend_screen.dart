import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

// ── 추천 기준 칩 ──
class _Criterion {
  final String label;
  final IconData icon;
  final Color color;
  const _Criterion(this.label, this.icon, this.color);
}

const _criteria = [
  _Criterion('플로어 분위기', Icons.auto_awesome, Color(0xFF7731FE)),
  _Criterion('사운드 퀄리티', Icons.graphic_eq, Color(0xFF2B6BFF)),
  _Criterion('최근 리뷰', Icons.star_rounded, Color(0xFFB5FF60)),
  _Criterion('혼잡도', Icons.groups_rounded, Color(0xFFFF8A3D)),
  _Criterion('재방문율', Icons.repeat_rounded, Color(0xFFFF4D8D)),
];

// ── 추천 클럽 (백엔드 연동 전 프레젠테이션 모델) ──
class _RecClub {
  final int id;
  final int? rank; // null = featured(1위)
  final String name;
  final String area;
  final String genre;
  final double rating;
  final int reviews;
  final int match;
  final bool open;
  final String? hours;
  final List<Color> bg;
  final List<String> tags;
  final String reason;

  const _RecClub({
    required this.id,
    this.rank,
    required this.name,
    required this.area,
    required this.genre,
    required this.rating,
    this.reviews = 0,
    required this.match,
    required this.open,
    this.hours,
    required this.bg,
    required this.tags,
    required this.reason,
  });
}

const _featured = _RecClub(
  id: 1, name: '어썸레드', area: '홍대', genre: '힙합 클럽',
  rating: 4.76, reviews: 1284, match: 98, open: true,
  hours: '오늘 22:00 오픈 · 05:00 종료',
  bg: [Color(0xFF2B1655), Color(0xFF7731FE), Color(0xFFFF4D8D)],
  tags: ['#사운드맛집', '#힙합성지', '#첫방문추천'],
  reason: '탄탄한 힙합 라인업과 압도적인 사운드 시스템. 처음 클럽을 찾는다면 가장 먼저 추천하는 곳이에요.',
);

const _ranked = <_RecClub>[
  _RecClub(
    id: 2, rank: 2, name: '버뮤다', area: '홍대', genre: '힙합 클럽',
    rating: 4.62, match: 95, open: true,
    bg: [Color(0xFF06FFA5), Color(0xFF3A86FF)],
    tags: ['#무드맛집', '#새벽감성'],
    reason: '감각적인 조명과 여유로운 플로어. 늦은 밤 무드가 일품이에요.',
  ),
  _RecClub(
    id: 3, rank: 3, name: 'OCTAGON', area: '강남', genre: 'EDM 클럽',
    rating: 4.80, match: 93, open: false,
    bg: [Color(0xFF2B6BFF), Color(0xFF7731FE)],
    tags: ['#EDM성지', '#게스트DJ'],
    reason: '세계적 규모의 EDM 스테이지. 화려한 게스트 라인업이 강점.',
  ),
  _RecClub(
    id: 4, rank: 4, name: '인클', area: '홍대', genre: '힙합 클럽',
    rating: 4.70, match: 91, open: true,
    bg: [Color(0xFFFB5607), Color(0xFFFFBE0B)],
    tags: ['#새벽까지', '#단골만족'],
    reason: '새벽까지 이어지는 에너지. 단골 만족도가 가장 높은 곳.',
  ),
  _RecClub(
    id: 5, rank: 5, name: '벨로주', area: '홍대', genre: '재즈 클럽',
    rating: 4.51, match: 88, open: true,
    bg: [Color(0xFF2A2D34), Color(0xFF6C757D)],
    tags: ['#라이브재즈', '#대화하기좋은'],
    reason: '라이브 재즈와 차분한 무드. 대화하며 즐기기 좋아요.',
  ),
];

class VybeRecommendScreen extends StatefulWidget {
  const VybeRecommendScreen({super.key});

  @override
  State<VybeRecommendScreen> createState() => _VybeRecommendScreenState();
}

class _VybeRecommendScreenState extends State<VybeRecommendScreen> {
  bool _loading = true;
  bool _scrolled = false;
  final Set<int> _saved = {1};
  final ScrollController _scroll = ScrollController();
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();
    _loadTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _loading = false);
    });
    _scroll.addListener(() {
      final s = _scroll.offset > 40;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _toggleSave(int id) => setState(() {
        _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      // SizedBox.expand로 Stack을 화면 전체로 강제 → Positioned.fill 본문이
      // 꽉 차도록. (Stack은 non-positioned 자식 크기만 따라가므로 명시 필요)
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: _loading
                  ? const _Skeleton()
                  : ListView(
                      controller: _scroll,
                      padding: EdgeInsets.zero,
                      children: [
                        _Intro(),
                        _Featured(
                          club: _featured,
                          saved: _saved.contains(_featured.id),
                          onSave: () => _toggleSave(_featured.id),
                        ),
                        _RankedSection(
                          clubs: _ranked,
                          savedIds: _saved,
                          onSave: _toggleSave,
                        ),
                        _FooterNote(),
                        SizedBox(height: 28.h),
                      ],
                    ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Header(scrolled: _scrolled),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 헤더 (스크롤 시 타이틀+배경 등장) ──
class _Header extends StatelessWidget {
  final bool scrolled;
  const _Header({required this.scrolled});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      height: top + 52.h,
      padding: EdgeInsets.only(top: top, left: 8.w, right: 8.w),
      decoration: BoxDecoration(
        color: scrolled
            ? VybeColors.background.withValues(alpha: 0.9)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: scrolled ? VybeColors.gray900 : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconBtn(
            Icons.arrow_back_ios_new_rounded,
            () => Navigator.of(context).maybePop(),
          ),
          AnimatedOpacity(
            opacity: scrolled ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Text('VYBE 추천',
                style: VybeTypography.button1
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          _iconBtn(Icons.share_outlined, () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44.w,
        height: 44.h,
        child: Icon(icon, size: 21.r, color: Colors.white),
      ),
    );
  }
}

// ── 인트로 밴드 ──
class _Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, top + 60.h, 24.w, 26.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x4D7731FE), Color(0x00101013), Color(0x14B5FF60)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
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
          Text('오늘 밤, 실패 없는\n클럽만 골랐어요',
              style: VybeTypography.heading2.copyWith(
                fontSize: 30.sp,
                height: 36 / 30,
                color: Colors.white,
              )),
          SizedBox(height: 10.h),
          Text('최근 방문자 리뷰와 분위기 데이터를 분석해\nvybe가 직접 큐레이션한 추천 리스트예요.',
              style: VybeTypography.body3
                  .copyWith(color: VybeColors.gray400, height: 22 / 16)),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: _criteria.map(_criterionChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _criterionChip(_Criterion c) {
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

// ── Featured 히어로 (1위) ──
class _Featured extends StatelessWidget {
  final _RecClub club;
  final bool saved;
  final VoidCallback onSave;
  const _Featured(
      {required this.club, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: VybeColors.gray900,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: Column(
          children: [
            _heroImage(),
            _curatorNote(),
          ],
        ),
      ),
    );
  }

  Widget _heroImage() {
    return SizedBox(
      height: 230.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: club.bg,
              ),
            ),
          ),
          // 하단 어둡게 (텍스트 가독성).
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xEB101013), Color(0x1A101013), Color(0x00101013)],
                stops: [0.06, 0.5, 0.8],
              ),
            ),
          ),
          // NO.1 PICK 배지.
          Positioned(
            top: 14.h,
            left: 14.w,
            child: _glassBadge(
              child: Text('NO.1 PICK',
                  style: VybeTypography.caption.copyWith(
                    height: 14 / 12,
                    fontWeight: FontWeight.w800,
                    color: VybeColors.mainLime500,
                  )),
            ),
          ),
          // VYBE 매치 배지.
          Positioned(
            top: 14.h,
            right: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: VybeColors.mainPurple500.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: VybeColors.mainPurple500),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 11.r, color: VybeColors.mainLime500),
                  SizedBox(width: 5.w),
                  Text('VYBE 매치 ${club.match}%',
                      style: VybeTypography.caption.copyWith(
                        height: 14 / 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          // 이름 + 메타.
          Positioned(
            left: 18.w,
            right: 18.w,
            bottom: 16.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7.w,
                  children: club.tags
                      .map((t) => Text(t,
                          style: VybeTypography.caption.copyWith(
                            height: 14 / 12,
                            fontWeight: FontWeight.w600,
                            color: VybeColors.mainLime500,
                          )))
                      .toList(),
                ),
                SizedBox(height: 8.h),
                Text(club.name,
                    style: VybeTypography.heading2
                        .copyWith(fontSize: 27.sp, color: Colors.white)),
                SizedBox(height: 8.h),
                _metaRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 13.r, color: VybeColors.mainLime500),
        SizedBox(width: 7.w),
        Text(club.rating.toStringAsFixed(2),
            style: VybeTypography.body4
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        SizedBox(width: 7.w),
        Text('리뷰 ${club.reviews}',
            style: VybeTypography.caption
                .copyWith(height: 14 / 12, color: VybeColors.gray400)),
        _dot(),
        Text(club.area,
            style: VybeTypography.caption
                .copyWith(height: 14 / 12, color: VybeColors.gray300)),
        _dot(),
        Text(club.genre,
            style: VybeTypography.caption
                .copyWith(height: 14 / 12, color: VybeColors.gray300)),
      ],
    );
  }

  Widget _curatorNote() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded,
                  size: 18.r, color: VybeColors.mainPurple500),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(club.reason,
                    style: VybeTypography.body4.copyWith(
                      fontSize: 15.sp,
                      height: 23 / 15,
                      color: VybeColors.gray200,
                    )),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: VybeColors.mainPurple500,
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('상세보기',
                          style: VybeTypography.button1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          )),
                      Icon(Icons.chevron_right_rounded,
                          size: 16.r,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: onSave,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 46.r,
                  height: 46.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: saved
                        ? VybeColors.mainPurple500.withValues(alpha: 0.16)
                        : VybeColors.gray800,
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(
                      color: saved
                          ? VybeColors.mainPurple700
                          : VybeColors.gray800,
                    ),
                  ),
                  child: Icon(
                    saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 20.r,
                    color: saved ? VybeColors.mainPurple500 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassBadge({required Widget child}) {
    return Container(
      padding: EdgeInsets.fromLTRB(9.w, 7.h, 12.w, 7.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: child,
    );
  }

  Widget _dot() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Container(
          width: 2.r,
          height: 2.r,
          decoration: const BoxDecoration(
              color: VybeColors.gray600, shape: BoxShape.circle),
        ),
      );
}

// ── 순위 섹션 ──
class _RankedSection extends StatelessWidget {
  final List<_RecClub> clubs;
  final Set<int> savedIds;
  final ValueChanged<int> onSave;
  const _RankedSection(
      {required this.clubs, required this.savedIds, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('추천 순위',
                  style: VybeTypography.heading4
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text('2위 — ${clubs.length + 1}위',
                    style: VybeTypography.caption
                        .copyWith(height: 16 / 12, color: VybeColors.gray500)),
              ),
            ],
          ),
        ),
        for (final c in clubs)
          _RankRow(
            club: c,
            saved: savedIds.contains(c.id),
            onSave: () => onSave(c.id),
          ),
      ],
    );
  }
}

// ── 순위 행 ──
class _RankRow extends StatelessWidget {
  final _RecClub club;
  final bool saved;
  final VoidCallback onSave;
  const _RankRow(
      {required this.club, required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 순위 숫자.
          SizedBox(
            width: 22.w,
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text('${club.rank}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                    height: 24 / 22,
                    color: VybeColors.gray700,
                    letterSpacing: 22 * -0.04,
                  )),
            ),
          ),
          SizedBox(width: 14.w),
          _thumb(),
          SizedBox(width: 14.w),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _thumb() {
    return SizedBox(
      width: 84.r,
      height: 84.r,
      child: Stack(
        children: [
          Container(
            width: 84.r,
            height: 84.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: club.bg,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: VybeColors.gray900),
            ),
          ),
          Positioned(
            left: 5.w,
            bottom: 5.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(99.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded,
                      size: 9.r, color: VybeColors.mainLime500),
                  SizedBox(width: 3.w),
                  Text(club.rating.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11.sp,
                        height: 12 / 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(club.name,
                  style: VybeTypography.body3
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            GestureDetector(
              onTap: onSave,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(2.r),
                child: Icon(
                  saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 19.r,
                  color: saved ? VybeColors.mainPurple500 : Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Text('매치 ${club.match}%',
                style: VybeTypography.caption.copyWith(
                  height: 14 / 12,
                  fontWeight: FontWeight.w700,
                  color: VybeColors.mainPurple500,
                )),
            _dot(),
            Text(club.area,
                style: VybeTypography.caption
                    .copyWith(height: 14 / 12, color: VybeColors.gray500)),
            _dot(),
            Text(club.genre,
                style: VybeTypography.caption
                    .copyWith(height: 14 / 12, color: VybeColors.gray500)),
            _dot(),
            Text(club.open ? '영업중' : '영업종료',
                style: VybeTypography.caption.copyWith(
                  height: 14 / 12,
                  fontWeight: FontWeight.w600,
                  color: club.open ? VybeColors.mainLime500 : VybeColors.gray600,
                )),
          ],
        ),
        SizedBox(height: 5.h),
        Text(club.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: VybeTypography.caption
                .copyWith(height: 18 / 12, color: VybeColors.gray400)),
      ],
    );
  }

  Widget _dot() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Container(
          width: 2.r,
          height: 2.r,
          decoration: const BoxDecoration(
              color: VybeColors.gray600, shape: BoxShape.circle),
        ),
      );
}

// ── 하단 안내 ──
class _FooterNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16.r, color: VybeColors.mainLime500),
          SizedBox(width: 10.w),
          Expanded(
            child: Text('추천 리스트는 매주 화요일, 최근 방문 데이터를 반영해 새롭게 업데이트돼요.',
                style: VybeTypography.caption
                    .copyWith(height: 17 / 12, color: VybeColors.gray400)),
          ),
        ],
      ),
    );
  }
}

// ── 스켈레톤 ──
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, top + 60.h, 24.w, 26.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(width: 120.w, height: 28.h, radius: 999.r),
                SizedBox(height: 14.h),
                _Shimmer(width: 280.w, height: 30.h, radius: 8.r),
                SizedBox(height: 14.h),
                _Shimmer(width: 200.w, height: 18.h, radius: 6.r),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Column(
              children: [
                _Shimmer(
                    width: double.infinity, height: 230.h, radius: 20.r),
                SizedBox(height: 16.h),
                _Shimmer(width: double.infinity, height: 14.h, radius: 6.r),
                SizedBox(height: 12.h),
                _Shimmer(width: double.infinity, height: 46.h, radius: 13.r),
              ],
            ),
          ),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 22.w, height: 24.h, radius: 6.r),
                  SizedBox(width: 14.w),
                  _Shimmer(width: 84.r, height: 84.r, radius: 12.r),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Shimmer(width: 120.w, height: 14.h, radius: 6.r),
                        SizedBox(height: 9.h),
                        _Shimmer(width: 180.w, height: 11.h, radius: 6.r),
                        SizedBox(height: 9.h),
                        _Shimmer(width: 240.w, height: 11.h, radius: 6.r),
                      ],
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

// 좌→우 흐르는 shimmer.
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer(
      {required this.width, required this.height, required this.radius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) {
                final dx = (_c.value * 2 - 1) * rect.width * 1.5;
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    VybeColors.gray900,
                    VybeColors.gray800,
                    VybeColors.gray900,
                  ],
                ).createShader(
                    Rect.fromLTWH(dx, 0, rect.width, rect.height));
              },
              child: const ColoredBox(color: VybeColors.gray900),
            );
          },
        ),
      ),
    );
  }
}
