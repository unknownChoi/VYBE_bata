import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';

/// 지도 핀을 탭하면 하단에 뜨는 클럽 요약 카드 (리퀴드 글래스).
///
/// 디자인 `pin_card.jsx` `NGPinCard` — 구 `nearby_glass.jsx` 판을 다듬은 버전.
/// 사진 가로 스크롤(+도보 pill · 닫기) · 이름/추천/찜 줄 · 평점 줄 ·
/// 영업 상태 칩 + 영업시간 + 입장료 한 줄 · '자세히 보기' 바.
///
/// 카드의 빈 곳을 누르면 [onTap](클럽 상세)으로 이동하고, 안의 버튼들은
/// 각자 제스처를 먼저 받아 상세 이동을 가로챈다.
///
/// 디자인과 다른 점(의도적)
/// - **길찾기**: 디자인엔 없지만 원형 타일 버튼으로 남겼다. 지도에서 핀을 눌러
///   바로 길을 찾는 건 이 화면의 핵심 동선이라 뺄 수 없다. 모양은 디자인의
///   원형 타일 버튼(닫기·찜)과 같은 규격이라 화면 언어는 어긋나지 않는다.
/// - **CTA 문구**: 디자인은 '사진, 리뷰, 예약까지'지만 예약 기능이 없어 '메뉴'로 둔다.
/// - **추천 뱃지**: 앱 전역 단일 디자인 규칙에 따라 [VybeRecommendBadge] 사용
///   (색·테두리·아이콘이 디자인 칩과 같고 라벨만 'VYBE 추천 클럽').
class ClubPinCard extends StatelessWidget {
  final ClubModel club;
  final bool isFavorited;

  /// 내 위치에서의 거리(m). null이면 도보 pill 숨김.
  final double? distanceMeters;

  /// 카드 탭 — 클럽 상세로 이동.
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDirectionsTap;

  const ClubPinCard({
    super.key,
    required this.club,
    required this.isFavorited,
    this.distanceMeters,
    this.onTap,
    this.onClose,
    this.onFavoriteTap,
    this.onDirectionsTap,
  });

  /// 디자인 토큰 — 라임/레드 틴트 칩 (배경 14% · 테두리 28%).
  static const _limeTint = Color(0x24B5FF60);
  static const _limeTintBorder = Color(0x47B5FF60);
  static const _redTint = Color(0x21FF5C5F);
  static const _redTintBorder = Color(0x47FF5C5F);

  /// 원형 타일 버튼 지름 (닫기 · 길찾기 · 찜 공통).
  static const double _roundSize = 38;

  /// 사진 우선순위 — 히어로 > 갤러리 > 썸네일. 최대 5장.
  List<String> get _photos {
    final urls = club.heroImageUrls.isNotEmpty
        ? club.heroImageUrls
        : club.imageUrls.isNotEmpty
        ? club.imageUrls
        : (club.thumbnailUrl.isEmpty
              ? const <String>[]
              : <String>[club.thumbnailUrl]);
    return urls.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(19.r);

    // 등장·퇴장 애니메이션은 카드를 띄우는 쪽(ClubPinCardTransition)이 담당한다 —
    // 카드가 사라질 때는 이 위젯이 이미 트리에서 빠진 뒤라 여기선 못 그린다.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          // 디자인 2겹 그림자 — 가까운 대비 + 멀리 퍼지는 깊이.
          boxShadow: [
            BoxShadow(
              color: const Color(0x5C000000),
              blurRadius: 30.r,
              offset: Offset(0, 10.h),
            ),
            BoxShadow(
              color: const Color(0x47000000),
              blurRadius: 44.r,
              offset: Offset(0, 18.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: NearbyGlass.sheetBlur,
              sigmaY: NearbyGlass.sheetBlur,
            ),
            child: Container(
              decoration: BoxDecoration(
                // 지도(플랫폼 뷰) 위라 BackdropFilter가 안 먹는다 —
                // 디자인의 반투명 글래스 대신 시트와 같은 불투명 채움을 쓴다
                // (NearbyGlass 주석 참고). 이걸 되돌리면 지도 위에서 글씨가 안 읽힌다.
                color: NearbyGlass.sheetFill,
                borderRadius: radius,
                border: Border.all(color: NearbyGlass.floatBorder),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _CardAurora(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildPhotos(), _buildBody(context)],
                  ),
                  // 상단 하이라이트 헤어라인 (디자인 rgba(255,255,255,0.18)).
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 1,
                        color: const Color(0x2EFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- 사진 영역

  Widget _buildPhotos() {
    final photos = _photos;
    final walk = walkLabel(distanceMeters);

    return SizedBox(
      // 사진 122 + 상단 여백 12.
      height: 134.h,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 디자인 flex-basis — 첫 장 64%, 나머지 40%.
                final first = constraints.maxWidth * 0.64;
                final rest = constraints.maxWidth * 0.40;
                if (photos.isEmpty) {
                  return _PhotoTile(
                    url: null,
                    width: constraints.maxWidth,
                    walkLabel: walk,
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: photos.length,
                  separatorBuilder: (_, __) => SizedBox(width: 6.w),
                  itemBuilder: (_, i) => _PhotoTile(
                    url: photos[i],
                    width: i == 0 ? first : rest,
                    // 도보 pill은 첫 장 안에 얹는다 — 사진을 옆으로 넘기면
                    // pill도 같이 흘러가야 어느 사진의 정보인지 헷갈리지 않는다.
                    walkLabel: i == 0 ? walk : null,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 20.h,
            right: 20.w,
            child: _RoundTileButton(
              onTap: onClose,
              // 사진 위에 바로 얹혀 배경이 밝을 수 있다 → 어두운 유리로 깐다.
              dark: true,
              child: Icon(Icons.close_rounded, size: 15.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- 본문 영역

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameRow(),
          SizedBox(height: 10.h),
          _buildRatingRow(),
          SizedBox(height: 10.h),
          _buildStatusRow(),
          SizedBox(height: 12.h),
          _buildDetailCta(),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        // 이름 + 추천 뱃지를 한 덩어리로 묶어 Expanded 하나만 준다.
        // Flexible(이름)과 Spacer를 형제로 두면 남는 공간을 1:1로 나눠 가져
        // 긴 이름이 절반에서 잘린다 (디자인은 min-width:0 + marginLeft:auto).
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20.sp,
                    height: 22 / 20,
                    letterSpacing: 20 * -0.025,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (club.isVybeRecommended) ...[
                SizedBox(width: 8.w),
                const VybeRecommendBadge(size: 10),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _RoundTileButton(
          onTap: onDirectionsTap,
          child: Icon(Icons.near_me_rounded, size: 16.r, color: ClubGlass.t2),
        ),
        SizedBox(width: 8.w),
        _RoundTileButton(
          onTap: onFavoriteTap,
          child: Icon(
            isFavorited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            size: 16.r,
            color: isFavorited ? ClubGlass.saved : ClubGlass.t2,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/star.svg',
          width: 13.r,
          height: 13.r,
        ),
        SizedBox(width: 6.w),
        Text(
          club.rating.toStringAsFixed(2),
          style: _meta(color: Colors.white, weight: FontWeight.w600),
        ),
        SizedBox(width: 4.w),
        Text('(${club.reviewCount})', style: _meta(color: VybeColors.gray600)),
        SizedBox(width: 6.w),
        const _MetaDot(),
        SizedBox(width: 6.w),
        Text(club.area, style: _meta()),
        SizedBox(width: 6.w),
        const _MetaDot(),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            club.genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _meta(),
          ),
        ),
      ],
    );
  }

  /// 영업 상태 칩 + 영업시간 + 입장료를 한 줄로 (디자인 flexWrap).
  ///
  /// 구버전은 시계·원화 아이콘을 단 두 줄이었다. 칩 하나로 상태를 먼저 읽히게 하고
  /// 나머지는 곁텍스트로 낮춘다 — 핀 카드에서 제일 먼저 보고 싶은 건 "지금 여나"다.
  Widget _buildStatusRow() {
    final today = club.operatingHours.today;
    final isOpen = today.isCurrentlyOpen;

    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _StatusChip(isOpen: isOpen),
        Text(todayHoursLabel(today), style: _meta()),
        const _MetaDot(),
        Text(
          '입장료 ${formatEntryFee(min: club.entryFeeMin, max: club.entryFeeMax)}',
          style: _meta(),
        ),
      ],
    );
  }

  /// 카드 하단 '자세히 보기' 바 — 카드 전체가 상세로 가는 걸 알리는 어포던스.
  Widget _buildDetailCta() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: ClubGlass.barFill,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ClubGlass.hair),
      ),
      child: Row(
        children: [
          // 디자인 문구는 '사진, 리뷰, 예약까지' — 예약 기능이 없어 '메뉴'로 바꿨다.
          Expanded(child: Text('사진, 리뷰, 메뉴까지 자세히 보기', style: _meta())),
          Icon(
            Icons.chevron_right_rounded,
            size: 15.r,
            color: VybeColors.mainLime500,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 조각
// ============================================================================

/// 카드 본문 곁텍스트 (디자인 13px / 행간 15 / NG.t3).
TextStyle _meta({Color color = ClubGlass.t3, FontWeight? weight}) =>
    ClubGlass.caption(
      color: color,
      size: 13,
      lineHeight: 15,
      weight: weight ?? FontWeight.w400,
    );

/// 메타 항목 사이 구분점 (디자인 3px · GRAY600).
class _MetaDot extends StatelessWidget {
  const _MetaDot();

  @override
  Widget build(BuildContext context) =>
      const GlassDot(size: 3, color: VybeColors.gray600);
}

/// 영업중/영업종료 칩. 영업중이면 라임 틴트 + 맥박 점, 아니면 레드 틴트 + 정적 점.
class _StatusChip extends StatelessWidget {
  final bool isOpen;

  const _StatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? VybeColors.mainLime500 : VybeColors.accentRed500;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOpen ? ClubPinCard._limeTint : ClubPinCard._redTint,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: isOpen
              ? ClubPinCard._limeTintBorder
              : ClubPinCard._redTintBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 영업중일 때만 맥박 — 닫힌 가게에 살아있는 점을 찍지 않는다.
          if (isOpen)
            const NearbyLiveDot(live: true)
          else
            Container(
              width: 5.r,
              height: 5.r,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          SizedBox(width: 5.w),
          Text(
            isOpen ? '영업중' : '영업종료',
            style: ClubGlass.caption(
              color: color,
              size: 11,
              lineHeight: 13,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 카드 안 원형 타일 버튼 (닫기 · 길찾기 · 찜 공통 규격).
///
/// [dark]는 사진 위에 얹히는 닫기 버튼용 — 밝은 사진 위에서도 아이콘이 살도록
/// 어두운 유리로 깔고 블러를 준다.
class _RoundTileButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool dark;

  const _RoundTileButton({required this.child, this.onTap, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final size = ClubPinCard._roundSize.r;

    final button = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? const Color(0x990E0D12) : ClubGlass.tileFill,
        shape: BoxShape.circle,
        border: Border.all(
          color: dark ? const Color(0x33FFFFFF) : ClubGlass.tileBorder,
        ),
      ),
      child: child,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: dark
          ? ClipOval(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                child: button,
              ),
            )
          : button,
    );
  }
}

/// 카드 상단 오로라 글로우 (좌측 보라 · 우측 라임).
class _CardAurora extends StatelessWidget {
  const _CardAurora();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 150.h,
        width: double.infinity,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.72, -1),
              radius: 1.1,
              colors: [Color(0x3D7731FE), Color(0x007731FE)],
              stops: [0.0, 0.7],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.88, -1),
                radius: 1.0,
                colors: [Color(0x17B5FF60), Color(0x00B5FF60)],
                stops: [0.0, 0.7],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 사진 한 장. URL이 없으면 빈 플레이스홀더.
/// [walkLabel]이 있으면 좌하단에 도보 거리 pill을 얹는다.
class _PhotoTile extends StatelessWidget {
  final String? url;
  final double width;
  final String? walkLabel;

  const _PhotoTile({required this.url, required this.width, this.walkLabel});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    final pill = walkLabel;

    return Container(
      width: width,
      height: 122.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: radius,
        border: Border.all(color: ClubGlass.hair),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null && url!.isNotEmpty)
            SkeletonImage(url: url!, fit: BoxFit.cover),
          if (pill != null) ...[
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x8C000000)],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8.w,
              bottom: 8.h,
              child: NearbyGlassPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 11.r,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      pill,
                      style: ClubGlass.caption(
                        color: Colors.white,
                        size: 11,
                        lineHeight: 13,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 핀 카드 등장·퇴장 전환 (디자인 keyframes `ngRise` — 아래에서 떠오르며 페이드).
///
/// 카드를 `null`로 바꿔 그냥 지우면 툭 사라진다 → 퇴장 중에도 옛 카드를 살려두는
/// [AnimatedSwitcher]로 감싼다. [child]가 null이면 퇴장, 다른 핀으로 갈아타면
/// 새 카드가 떠오르며 옛 카드가 내려간다.
///
/// 카드를 감싸는 쪽(주변 화면 Stack)에서 써야 한다 — 카드 위젯 안에 두면
/// 퇴장 시점엔 이미 트리에서 빠진 뒤라 애니메이션이 안 보인다.
class ClubPinCardTransition extends StatelessWidget {
  final Widget? child;

  const ClubPinCardTransition({super.key, this.child});

  /// 나타날 때는 여유 있게, 사라질 때는 짧게 — 닫기 반응이 굼떠 보이지 않도록.
  static const Duration _inDuration = Duration(milliseconds: 320);
  static const Duration _outDuration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _inDuration,
      reverseDuration: _outDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // 기본 layoutBuilder는 자식을 가운데 정렬해, 높이가 다른 카드끼리 바뀌면
      // 옛 카드가 위아래로 튄다 → 카드가 붙어 있는 아래쪽 기준으로 쌓는다.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.bottomCenter,
        children: [...previous, if (current != null) current],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          // 카드 높이의 8% (≈30px) 아래에서 올라온다.
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ),
      ),
      child: child ?? const SizedBox.shrink(key: ValueKey('pin_card_empty')),
    );
  }
}
