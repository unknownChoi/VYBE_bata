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
/// 디자인 nearby_glass.jsx `NGPinCard` — 사진 가로 스크롤(+도보 거리 pill · 닫기) ·
/// 이름/길찾기/추천 뱃지/찜 줄 · 평점 · 영업 · 입장료 · '자세히 보기' 행.
/// 카드의 빈 곳을 누르면 [onTap](클럽 상세)으로 이동하고, 안의 버튼들은
/// 각자 제스처를 먼저 받아 상세 이동을 가로챈다.
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
    final radius = BorderRadius.circular(26.r);

    // 등장·퇴장 애니메이션은 카드를 띄우는 쪽(ClubPinCardTransition)이 담당한다 —
    // 카드가 사라질 때는 이 위젯이 이미 트리에서 빠진 뒤라 여기선 못 그린다.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0x9E000000),
              blurRadius: 48.r,
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
                // 시트와 같은 불투명 채움으로 가독성 확보 (NearbyGlass 주석 참고).
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
      // 사진 126 + 상단 여백 10.
      height: 136.h,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 디자인 flex-basis — 첫 장 64%, 나머지 40%.
                final first = constraints.maxWidth * 0.64;
                final rest = constraints.maxWidth * 0.40;
                if (photos.isEmpty) {
                  return _PhotoTile(url: null, width: constraints.maxWidth);
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: photos.length,
                  separatorBuilder: (_, __) => SizedBox(width: 6.w),
                  itemBuilder: (_, i) => _PhotoTile(
                    url: photos[i],
                    width: i == 0 ? first : rest,
                    // 첫 장 위에 도보 pill이 올라가 하단만 어둡게.
                    darkenBottom: i == 0 && walk != null,
                  ),
                );
              },
            ),
          ),
          if (walk != null)
            Positioned(
              left: 19.w,
              bottom: 9.h,
              child: _GlassPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 12.r,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      walk,
                      style: ClubGlass.caption(
                        color: Colors.white,
                        size: 11,
                        lineHeight: 13,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 20.h,
            right: 20.w,
            child: GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x990E0D12),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
          SizedBox(height: 9.h),
          _buildRatingRow(),
          SizedBox(height: 9.h),
          _buildHoursRow(),
          SizedBox(height: 9.h),
          _buildFeeRow(),
          SizedBox(height: 12.h),
          _buildDetailCta(),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
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
              SizedBox(width: 9.w),
              GestureDetector(
                onTap: onDirectionsTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '길찾기',
                      style: ClubGlass.caption(
                        color: VybeColors.mainLime500,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14.r,
                      color: VybeColors.mainLime500,
                    ),
                  ],
                ),
              ),
              // 디자인은 여기서 금색 왕관 'VYBE 추천' 뱃지를 쓰지만, 추천 뱃지는
              // 앱 전역 단일 디자인(VybeRecommendBadge) 규칙이 있어 라임 뱃지로 통일.
              if (club.isVybeRecommended) ...[
                SizedBox(width: 8.w),
                const VybeRecommendBadge(size: 10),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onFavoriteTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 34.r,
            height: 34.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ClubGlass.tileFill,
              shape: BoxShape.circle,
              border: Border.all(color: ClubGlass.tileBorder),
            ),
            child: Icon(
              isFavorited
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 17.r,
              color: isFavorited ? ClubGlass.saved : Colors.white,
            ),
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
          style: ClubGlass.caption(
            color: Colors.white,
            weight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '(${club.reviewCount})',
          style: ClubGlass.caption(color: ClubGlass.t4),
        ),
        SizedBox(width: 6.w),
        const GlassDot(),
        SizedBox(width: 6.w),
        Text(club.area, style: ClubGlass.caption(color: ClubGlass.t3)),
        SizedBox(width: 6.w),
        const GlassDot(),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            club.genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClubGlass.caption(color: ClubGlass.t3),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursRow() {
    final today = club.operatingHours.today;
    final isOpen = today.isCurrentlyOpen;

    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/time.svg',
          width: 13.r,
          height: 13.r,
        ),
        SizedBox(width: 7.w),
        NearbyLiveDot(live: isOpen),
        SizedBox(width: 7.w),
        Text(
          isOpen ? '영업중' : '영업종료',
          style: ClubGlass.caption(
            color: isOpen ? VybeColors.mainLime500 : ClubGlass.t4,
            weight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            '· ${todayHoursLabel(today)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClubGlass.caption(color: ClubGlass.t3),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow() {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/won.svg',
          width: 14.r,
          height: 14.r,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            '입장료 ${formatEntryFee(min: club.entryFeeMin, max: club.entryFeeMax)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClubGlass.caption(color: ClubGlass.t3),
          ),
        ),
      ],
    );
  }

  /// 카드 하단 '자세히 보기' 행 — 카드 전체가 상세로 가는 걸 알리는 어포던스.
  Widget _buildDetailCta() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: ClubGlass.tileFill,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '사진, 리뷰, 메뉴까지 자세히 보기',
              style: ClubGlass.caption(
                color: ClubGlass.t2,
                lineHeight: 15,
                weight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 16.r, color: ClubGlass.t2),
        ],
      ),
    );
  }
}

// ============================================================================
// 조각
// ============================================================================

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
class _PhotoTile extends StatelessWidget {
  final String? url;
  final double width;
  final bool darkenBottom;

  const _PhotoTile({
    required this.url,
    required this.width,
    this.darkenBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(17.r);
    return Container(
      width: width,
      height: 126.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: radius,
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null && url!.isNotEmpty)
            SkeletonImage(url: url!, fit: BoxFit.cover),
          if (darkenBottom)
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
        ],
      ),
    );
  }
}

/// 사진 위 작은 글래스 pill (도보 거리).
class _GlassPill extends StatelessWidget {
  final Widget child;

  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999.r);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0x850E0D12),
            borderRadius: radius,
            border: Border.all(color: const Color(0x29FFFFFF)),
          ),
          child: child,
        ),
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
