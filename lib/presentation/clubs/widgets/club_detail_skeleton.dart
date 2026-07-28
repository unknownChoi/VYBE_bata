import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';

/// 클럽 상세(리퀴드 글래스) 스켈레톤.
///
/// 실제 카드와 같은 [GlassCard] 안에 뼈대([GlassBone])만 세우고,
/// [GlassSkeletonSheen]이 카드 콘텐츠 위로 빛 띠를 훑는다.
/// 로딩이 끝나면 같은 자리에 실제 콘텐츠가 들어와 레이아웃이 튀지 않는다.
///
/// ⚠ sheen 안에는 뼈대와 레이아웃(Padding/Row/Column)만 둔다 —
/// srcIn 마스크가 색을 통째로 갈아끼우기 때문에 구분선(hairline)은 사라지고
/// 타일 배경은 뼈대처럼 보인다.

// ============================================================================
// 스윕 애니메이션
// ============================================================================

/// 뼈대 기본 톤 — rgba(255,255,255,0.08)
const Color _kBoneBase = Color(0x14FFFFFF);

/// 빛 띠가 지나갈 때 밝기 — rgba(255,255,255,0.18)
const Color _kBonePeak = Color(0x2EFFFFFF);

/// 자식(뼈대) 위를 좌 → 우로 지나가는 빛 띠.
///
/// 뼈대마다 컨트롤러를 두지 않고 카드 한 장당 하나만 돌린다.
/// 마스크는 자식이 그린 픽셀에만 적용되므로 여백은 그대로 비어 있다.
class GlassSkeletonSheen extends StatefulWidget {
  final Widget child;

  /// 넓은 면(히어로)은 기본 톤이 너무 옅어 보여 색을 올려 쓴다.
  final Color base;
  final Color peak;

  const GlassSkeletonSheen({
    super.key,
    required this.child,
    this.base = _kBoneBase,
    this.peak = _kBonePeak,
  });

  @override
  State<GlassSkeletonSheen> createState() => _GlassSkeletonSheenState();
}

class _GlassSkeletonSheenState extends State<GlassSkeletonSheen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    // easeInOut이라 양 끝에서 잠깐 머무는 호흡이 생긴다.
    _sweep = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheenScope(
      child: AnimatedBuilder(
        animation: _sweep,
        // 뼈대 트리는 한 번만 만들고 마스크만 매 프레임 다시 그린다.
        child: widget.child,
        builder: (_, child) => ShaderMask(
          // srcIn — 자식이 칠한 자리에만 그라디언트 색을 입힌다.
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(_sweep.value - 1, -0.3),
            end: Alignment(_sweep.value + 1, 0.3),
            colors: [widget.base, widget.peak, widget.base],
            stops: const [0.32, 0.5, 0.68],
          ).createShader(bounds),
          child: child,
        ),
      ),
    );
  }
}

/// 뼈대가 sheen 안에 있는지 알려주는 표식.
class _SheenScope extends InheritedWidget {
  const _SheenScope({required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SheenScope>() != null;

  @override
  bool updateShouldNotify(_SheenScope oldWidget) => false;
}

/// 스켈레톤 뼈대 한 조각.
///
/// [GlassSkeletonSheen] 안에서는 불투명 흰색으로 그려 마스크가 색을 입히고,
/// 밖에서는 스스로 글래스 타일 톤으로 그린다(애니메이션 없음).
class GlassBone extends StatelessWidget {
  final double? width;
  final double? height;

  /// CSS px 기준 모서리 반경 (`.r` 적용).
  final double radius;

  const GlassBone({super.key, this.width, this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _SheenScope.of(context) ? Colors.white : ClubGlass.tileFill,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// 섹션 헤더(제목 · 보조설명 · 우측 액션) 뼈대. [GlassSectionHead]와 같은 리듬.
class _HeadBones extends StatelessWidget {
  final double titleWidth;
  final double? subWidth;
  final double? actionWidth;

  const _HeadBones({required this.titleWidth, this.subWidth, this.actionWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassBone(width: titleWidth.w, height: 17.h),
              if (subWidth != null) ...[
                SizedBox(height: 5.h),
                GlassBone(width: subWidth!.w, height: 12.h),
              ],
            ],
          ),
          const Spacer(),
          if (actionWidth != null)
            GlassBone(width: actionWidth!.w, height: 12.h),
        ],
      ),
    );
  }
}

// ============================================================================
// 헤더 (히어로 · 아이덴티티 카드)
// ============================================================================

/// 히어로 이미지 자리. `_Hero` Stack 안에서 PageView 대신 깔린다 —
/// 위에 얹히는 스크림·하이라이트·뒤로가기 버튼은 그대로 살아 있다.
class DetailHeroSkeleton extends StatelessWidget {
  const DetailHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // 320 높이를 덮는 넓은 면이라 카드 뼈대보다 진하게 — 12% → 24%.
    return const GlassSkeletonSheen(
      base: Color(0x1FFFFFFF),
      peak: Color(0x3DFFFFFF),
      child: GlassBone(radius: 0),
    );
  }
}

/// 아이덴티티 카드 — 지역·장르 + 영업 pill / 이름 / 평점 / 소개 / 태그.
class DetailIdentityCardSkeleton extends StatelessWidget {
  const DetailIdentityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 20,
      radius: 24,
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 지역 · 장르 + 영업 상태
            Row(
              children: [
                GlassBone(width: 30.w, height: 12.h),
                SizedBox(width: 15.w),
                GlassBone(width: 56.w, height: 12.h),
                const Spacer(),
                GlassBone(width: 62.w, height: 22.h, radius: 999),
              ],
            ),
            SizedBox(height: 9.h),
            // 클럽 이름
            GlassBone(width: 176.w, height: 28.h, radius: 8),
            SizedBox(height: 10.h),
            // 평점 · 리뷰 수
            Row(
              children: [
                GlassBone(width: 15.r, height: 15.r, radius: 4),
                SizedBox(width: 8.w),
                GlassBone(width: 38.w, height: 16.h),
                SizedBox(width: 10.w),
                GlassBone(width: 52.w, height: 14.h),
              ],
            ),
            SizedBox(height: 12.h),
            // 소개글 두 줄
            GlassBone(width: double.infinity, height: 14.h),
            SizedBox(height: 6.h),
            GlassBone(width: 208.w, height: 14.h),
            SizedBox(height: 14.h),
            // 태그 칩
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                for (final w in const [56.0, 68.0, 48.0])
                  GlassBone(width: w.w, height: 24.h, radius: 99),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 홈 탭 섹션별 스켈레톤
// ============================================================================

/// 매장 정보 — 아이콘 + 한 줄짜리 행 4개(주소 · 영업시간 · 입장료 · 링크).
class DetailInfoCardSkeleton extends StatelessWidget {
  const DetailInfoCardSkeleton({super.key});

  static const List<double> _rowWidths = [212, 156, 124, 140];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeadBones(titleWidth: 64),
            for (final w in _rowWidths)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                child: Row(
                  children: [
                    GlassBone(width: 17.r, height: 17.r, radius: 5),
                    SizedBox(width: 12.w),
                    GlassBone(width: w.w, height: 14.h),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 오늘의 라인업 — 썸네일 44 + 이름·시간 두 줄짜리 행 2개.
class DetailLineupCardSkeleton extends StatelessWidget {
  const DetailLineupCardSkeleton({super.key});

  static const int _rows = 2;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeadBones(titleWidth: 92, subWidth: 104, actionWidth: 48),
            for (var i = 0; i < _rows; i++)
              Padding(
                // 행 안쪽 여백 10 + 행 사이 간격 10.
                padding: EdgeInsets.fromLTRB(
                  10.w,
                  10.h,
                  10.w,
                  i == _rows - 1 ? 10.h : 20.h,
                ),
                child: Row(
                  children: [
                    GlassBone(width: 44.r, height: 44.r, radius: 12),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassBone(width: 96.w, height: 14.h),
                          SizedBox(height: 6.h),
                          GlassBone(width: 132.w, height: 12.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 메뉴 — 이름·설명·가격 + 78 썸네일 행 3개.
class DetailMenuCardSkeleton extends StatelessWidget {
  const DetailMenuCardSkeleton({super.key});

  static const int _rows = 3;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeadBones(titleWidth: 44, subWidth: 176, actionWidth: 40),
            for (var i = 0; i < _rows; i++)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassBone(width: 116.w, height: 14.h),
                          SizedBox(height: 6.h),
                          GlassBone(width: 152.w, height: 12.h),
                          SizedBox(height: 8.h),
                          GlassBone(width: 76.w, height: 16.h),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    GlassBone(width: 78.r, height: 78.r, radius: 14),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 사진 — 3열 정사각 6칸.
class DetailPhotoCardSkeleton extends StatelessWidget {
  const DetailPhotoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeadBones(titleWidth: 44, subWidth: 36, actionWidth: 52),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6.w,
                crossAxisSpacing: 6.w,
              ),
              itemBuilder: (_, __) => const GlassBone(radius: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// 주변 클럽 — 가로 스크롤 카드 3장. 실제 카드와 같은 높이를 잡아 둔다.
class DetailNearbyCardSkeleton extends StatelessWidget {
  const DetailNearbyCardSkeleton({super.key});

  static const int _cards = 3;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 0,
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
              child: const _HeadBones(titleWidth: 72, subWidth: 88),
            ),
            SizedBox(
              height: kNearbyThumbSize.w + 9.h + kNearbyTextBlock.h + 18.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
                itemCount: _cards,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (_, __) => SizedBox(
                  width: kNearbyThumbSize.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassBone(
                        width: kNearbyThumbSize.w,
                        height: kNearbyThumbSize.w,
                        radius: 16,
                      ),
                      SizedBox(height: 9.h),
                      GlassBone(width: 96.w, height: 14.h),
                      SizedBox(height: 7.h),
                      GlassBone(width: 72.w, height: 12.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 매장 정보 탭
// ============================================================================

/// 위치 카드 — 지도(200) + 주소 타일 + 주소 복사·길찾기 칩.
class DetailLocationCardSkeleton extends StatelessWidget {
  const DetailLocationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeadBones(titleWidth: 36, subWidth: 116),
            // 지도 — _NaverMapCard 자리(같은 200 높이라 로딩 후 안 튄다).
            GlassBone(width: double.infinity, height: 200.h, radius: 16),
            SizedBox(height: 14.h),
            // 주소 타일 (주소 한 줄 + 지하철 한 줄)
            GlassBone(width: double.infinity, height: 78.h, radius: 14),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(child: GlassBone(height: 42.h, radius: 12)),
                SizedBox(width: 8.w),
                Expanded(child: GlassBone(height: 42.h, radius: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 상세 정보 카드 — 영업시간(요일 7줄) + 입장료 · 전화 · 링크 행.
class DetailStoreInfoCardSkeleton extends StatelessWidget {
  const DetailStoreInfoCardSkeleton({super.key});

  /// 영업시간 아래 한 줄짜리 행(입장료 · 전화 · 링크) 본문 너비.
  static const List<double> _rowWidths = [128, 116, 96];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeadBones(titleWidth: 64),
            // 영업시간 — 오늘 한 줄 + 요일 표 7줄. GlassInfoRow와 같은 여백(13).
            Padding(
              padding: EdgeInsets.symmetric(vertical: 13.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 1.h, right: 12.w),
                    child: GlassBone(width: 17.r, height: 17.r, radius: 5),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassBone(width: 172.w, height: 14.h),
                        SizedBox(height: 12.h),
                        // WeekHoursTable(rowGap: 9)과 같은 리듬.
                        for (var i = 0; i < 7; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: i == 6 ? 0 : 9.h),
                            child: Row(
                              children: [
                                GlassBone(width: 16.w, height: 12.h),
                                SizedBox(width: 12.w),
                                GlassBone(width: 104.w, height: 12.h),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (final w in _rowWidths)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                child: Row(
                  children: [
                    GlassBone(width: 17.r, height: 17.r, radius: 5),
                    SizedBox(width: 12.w),
                    GlassBone(width: w.w, height: 14.h),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 메뉴 탭
// ============================================================================

/// 메뉴 탭 — 메뉴판 이미지 카드 + 카테고리 섹션 카드.
class DetailMenuTabSkeleton extends StatelessWidget {
  const DetailMenuTabSkeleton({super.key});

  static const int _boards = 3;
  static const int _rows = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 메뉴판 이미지 — 104 정사각 가로 스크롤.
        GlassCard(
          child: GlassSkeletonSheen(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeadBones(titleWidth: 72),
                SizedBox(
                  height: 104.r,
                  child: Row(
                    children: [
                      for (var i = 0; i < _boards; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            right: i == _boards - 1 ? 0 : 8.w,
                          ),
                          child: GlassBone(
                            width: 104.r,
                            height: 104.r,
                            radius: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        glassGap(),
        // 카테고리 섹션 — 실제 카드처럼 padding 0 + 안쪽 18 여백.
        GlassCard(
          padding: 0,
          child: GlassSkeletonSheen(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeadBones(titleWidth: 56),
                  for (var i = 0; i < _rows; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GlassBone(width: 116.w, height: 14.h),
                                SizedBox(height: 6.h),
                                GlassBone(width: 152.w, height: 12.h),
                                SizedBox(height: 8.h),
                                GlassBone(width: 76.w, height: 16.h),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),
                          GlassBone(width: 78.r, height: 78.r, radius: 14),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 사진 탭
// ============================================================================

/// 사진 탭 — 2열 매스너리. 실제 타일과 같은 높이 패턴을 쓴다.
class DetailPhotoTabSkeleton extends StatelessWidget {
  const DetailPhotoTabSkeleton({super.key});

  static const List<double> _leftHeights = [220, 180, 260, 200];
  static const List<double> _rightHeights = [180, 240, 190, 230];

  @override
  Widget build(BuildContext context) {
    return GlassSkeletonSheen(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _column(_leftHeights)),
          SizedBox(width: 8.w),
          Expanded(child: _column(_rightHeights)),
        ],
      ),
    );
  }

  Widget _column(List<double> heights) {
    return Column(
      children: [
        for (var i = 0; i < heights.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == heights.length - 1 ? 0 : 8.h),
            child: GlassBone(
              width: double.infinity,
              height: heights[i].h,
              radius: 14,
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// 리뷰 탭
// ============================================================================

/// 리뷰 탭 — 평점 요약 카드 + 작성 버튼 + 정렬 행 + 리뷰 카드 3장.
class DetailReviewTabSkeleton extends StatelessWidget {
  const DetailReviewTabSkeleton({super.key});

  static const int _cards = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryCard(),
        glassGap(),
        // 작성 버튼 + 정렬 행은 카드 밖이라 sheen을 따로 씌운다.
        GlassSkeletonSheen(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassBone(width: double.infinity, height: 48.h, radius: 16),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassBone(width: 48.w, height: 14.h),
                  Row(
                    children: [
                      for (final w in const [46.0, 46.0, 34.0])
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: GlassBone(
                            width: w.w,
                            height: 22.h,
                            radius: 999,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        for (var i = 0; i < _cards; i++) ...[
          _reviewCard(),
          SizedBox(height: 14.h),
        ],
      ],
    );
  }

  /// 평점 요약 — 좌측 평균(78) + 우측 분포 바 5줄.
  Widget _summaryCard() {
    return GlassCard(
      padding: 20,
      child: GlassSkeletonSheen(
        child: Row(
          children: [
            SizedBox(
              width: 78.w,
              child: Column(
                children: [
                  GlassBone(width: 62.w, height: 30.h, radius: 8),
                  SizedBox(height: 5.h),
                  GlassBone(width: 64.w, height: 12.h),
                  SizedBox(height: 5.h),
                  GlassBone(width: 52.w, height: 12.h),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == 4 ? 0 : 5.h),
                      child: Row(
                        children: [
                          GlassBone(width: 10.w, height: 12.h),
                          SizedBox(width: 8.w),
                          Expanded(child: GlassBone(height: 5.h, radius: 99)),
                          SizedBox(width: 8.w),
                          GlassBone(width: 14.w, height: 12.h),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 리뷰 카드 — 아바타 34 + 이름·별점 + 날짜 / 본문 두 줄.
  Widget _reviewCard() {
    return GlassCard(
      padding: 16,
      child: GlassSkeletonSheen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GlassBone(width: 34.r, height: 34.r, radius: 999),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GlassBone(width: 72.w, height: 14.h),
                      SizedBox(height: 5.h),
                      GlassBone(width: 58.w, height: 10.h),
                    ],
                  ),
                ),
                GlassBone(width: 62.w, height: 12.h),
              ],
            ),
            SizedBox(height: 12.h),
            GlassBone(width: double.infinity, height: 14.h),
            SizedBox(height: 6.h),
            GlassBone(width: 216.w, height: 14.h),
          ],
        ),
      ),
    );
  }
}
