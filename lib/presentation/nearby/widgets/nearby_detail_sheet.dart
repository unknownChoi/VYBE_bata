import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/geohash_utils.dart';
import 'package:vybe/core/utils/map_launcher.dart';
import 'package:vybe/core/utils/phone_launcher.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';

/// 주변 페이지 지도 위에 띄우는 클럽 상세 시트 (리퀴드 글래스).
///
/// 디자인 nearby_glass.jsx `NGDetailSheet`:
/// - 핀 탭 → 절반(0.56) 높이로 슬라이드 인, 요약(사진·퀵액션·기본정보) 표시
/// - 위로 끌어올리거나 '상세 정보 전체 보기' → full, 클럽 상세 페이지 전체 표시
/// - 충분히 내리면 닫힘
/// - 시트가 올라오면 하단 nav 바가 축소됨
class NearbyDetailSheet extends ConsumerStatefulWidget {
  final String clubId;

  /// 패널이 완전히 닫힌(슬라이드 아웃) 뒤 호출 — 핀 복원/상태 정리용.
  final VoidCallback? onClosed;

  const NearbyDetailSheet({super.key, required this.clubId, this.onClosed});

  @override
  ConsumerState<NearbyDetailSheet> createState() => _NearbyDetailSheetState();
}

class _NearbyDetailSheetState extends ConsumerState<NearbyDetailSheet> {
  // 디자인 SNAPS — 요약 0.56 / 전체 1.0.
  static const double _half = 0.56;
  static const double _full = 1.0;

  /// 이 비율 아래로 내리면 닫기.
  static const double _dismissBelow = 0.34;
  static const double _eps = 0.01;
  static const Duration _snapDur = Duration(milliseconds: 260);

  /// 화면 높이 대비 패널 높이 비율.
  double _frac = 0;
  bool _dragging = false;
  double _maxH = 0;

  bool get _isFull => _frac >= _full - _eps;

  @override
  void initState() {
    super.initState();
    // 슬라이드 인 (0 → 절반).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _frac = _half);
    });
  }

  // 시트가 절반보다 커지면 nav 축소, 아니면 원래대로.
  void _syncNav() {
    final n = ref.read(navBarVisibilityProvider.notifier);
    if (_frac > _half + _eps) {
      n.collapse();
    } else {
      n.expand();
    }
  }

  void _setFrac(double f) {
    if ((f - _frac).abs() < 0.0001) return;
    setState(() => _frac = f);
    _syncNav();
  }

  void _onHandleDragUpdate(DragUpdateDetails d) {
    if (_maxH == 0) return;
    _dragging = true;
    _setFrac((_frac - d.delta.dy / _maxH).clamp(0.0, 1.0));
  }

  void _onHandleDragEnd(DragEndDetails d) {
    _dragging = false;
    if (_frac < _dismissBelow) {
      _close();
      return;
    }
    _setFrac((_full - _frac).abs() < (_frac - _half).abs() ? _full : _half);
  }

  // 본문 스크롤 → 시트 크기 연동.
  //
  // 요약 상태에선 스크롤로 시트를 키우지 않는다. 요약 내용이 절반 높이보다
  // 길어서(사진·퀵액션·기본정보·CTA), 스크롤이 곧바로 전체 보기로 바뀌면
  // '상세 정보 전체 보기' 버튼에 영영 닿을 수 없다. 확장은 핸들 드래그 또는
  // 그 버튼으로만 — 디자인 NGDetailSheet와 같은 동작.
  bool _onScroll(ScrollNotification n) {
    // 시트 full + 최상단에서 더 위로 당김(overscroll top) → 절반으로 내림.
    if (_isFull && n is OverscrollNotification && n.overscroll < 0) {
      _setFrac(_half);
    }
    return false;
  }

  // 슬라이드 아웃 후 onClosed 호출.
  void _close() {
    _setFrac(0);
    Future.delayed(_snapDur, () {
      if (mounted) widget.onClosed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;
    final uid = ref.watch(currentUidProvider);
    final streamFavIds = uid != null
        ? ref.watch(favoritedClubIdsProvider(uid)).asData?.value ?? <String>{}
        : <String>{};
    final optimistic = ref.watch(favoriteViewModelProvider);
    final isFavorited =
        optimistic[widget.clubId] ?? streamFavIds.contains(widget.clubId);

    return LayoutBuilder(
      builder: (context, constraints) {
        _maxH = constraints.maxHeight;
        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: _dragging ? Duration.zero : _snapDur,
            curve: Curves.easeOut,
            height: _maxH * _frac,
            child: NearbySheetSurface(
              // 전체 보기에선 상단 라운드를 편다 (디자인 full 상태).
              topRadius: _isFull ? 0 : 28,
              // 슬라이드 인/아웃 중(frac < 0.56)에도 내용은 절반 높이 기준으로
              // 배치하고 아래를 잘라낸다. 그냥 두면 시트가 헤더보다 낮은
              // 프레임에서 RenderFlex overflow가 난다.
              child: _ClippedContent(
                height: _maxH * (_frac < _half ? _half : _frac),
                child: Column(
                  children: [
                    _Header(
                      club: club,
                      isFull: _isFull,
                      isFavorited: isFavorited,
                      onSave: uid == null
                          ? null
                          : () => ref
                                .read(favoriteViewModelProvider.notifier)
                                .toggleFavorite(
                                  uid,
                                  widget.clubId,
                                  isFavorited,
                                ),
                      onClose: _close,
                      onDragUpdate: _onHandleDragUpdate,
                      onDragEnd: _onHandleDragEnd,
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onScroll,
                        child: _isFull
                            ? ClubDetailScreen(
                                clubId: widget.clubId,
                                onClose: _close,
                              )
                            : _Preview(
                                club: club,
                                isFavorited: isFavorited,
                                onSave: uid == null
                                    ? null
                                    : () => ref
                                          .read(
                                            favoriteViewModelProvider.notifier,
                                          )
                                          .toggleFavorite(
                                            uid,
                                            widget.clubId,
                                            isFavorited,
                                          ),
                                onExpand: () => _setFrac(_full),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 시트 안 내용을 [height]로 고정 배치하고 넘치는 부분을 잘라낸다.
/// 시트가 그보다 낮은 프레임(슬라이드 인/아웃)에서 overflow가 나지 않게 한다.
class _ClippedContent extends StatelessWidget {
  final double height;
  final Widget child;

  const _ClippedContent({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: height,
        maxHeight: height,
        child: child,
      ),
    );
  }
}

// ============================================================================
// 헤더 (드래그 영역)
// ============================================================================

class _Header extends ConsumerWidget {
  final ClubModel? club;
  final bool isFull;
  final bool isFavorited;
  final VoidCallback? onSave;
  final VoidCallback onClose;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final ValueChanged<DragEndDetails> onDragEnd;

  const _Header({
    required this.club,
    required this.isFull,
    required this.isFavorited,
    required this.onSave,
    required this.onClose,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myLocation = ref.watch(userLocationProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 260),
        // full일 땐 상태바를 피해 위쪽 여백을 키운다.
        padding: EdgeInsets.fromLTRB(
          16.w,
          isFull ? MediaQuery.of(context).padding.top + 10.h : 11.h,
          16.w,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NearbySheetHandle(),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: club == null
                      ? VybeSkel(width: 140.w, height: 20.h)
                      : Row(
                          children: [
                            Flexible(
                              child: Text(
                                club!.name,
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
                            if (club!.isVybeRecommended) ...[
                              SizedBox(width: 8.w),
                              _RecommendBadge(),
                            ],
                          ],
                        ),
                ),
                SizedBox(width: 10.w),
                GlassRoundButton(
                  size: 34,
                  onTap: onSave,
                  child: SvgPicture.asset(
                    'assets/icons/common/club_card/favorite.svg',
                    width: 16.r,
                    height: 16.r,
                    colorFilter: ColorFilter.mode(
                      isFavorited ? ClubGlass.saved : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                GlassRoundButton(
                  size: 34,
                  onTap: onClose,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.r,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 9.h),
            _MetaRow(club: club, myLat: myLocation.lat, myLng: myLocation.lng),
            SizedBox(height: 13.h),
          ],
        ),
      ),
    );
  }
}

class _RecommendBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: NearbyGlass.activeChip,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0x80B5FF60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/common/club_card/vybe_recommend.svg',
            width: 10.r,
            height: 10.r,
          ),
          SizedBox(width: 4.w),
          Text(
            'VYBE 추천',
            style: ClubGlass.caption(
              color: Colors.white,
              size: 10,
              lineHeight: 11,
              weight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 평점 · 리뷰 수 · 장르 · 영업 상태 · 도보 시간 한 줄.
class _MetaRow extends StatelessWidget {
  final ClubModel? club;
  final double myLat;
  final double myLng;

  const _MetaRow({
    required this.club,
    required this.myLat,
    required this.myLng,
  });

  @override
  Widget build(BuildContext context) {
    if (club == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: VybeSkel(width: 200.w, height: 14.h),
      );
    }
    final c = club!;
    final isOpen = c.operatingHours.today.isCurrentlyOpen;
    final hasLocation = c.lat != 0 || c.lng != 0;
    final walk = hasLocation
        ? walkMinutes(
            GeohashUtils.haversineKm(myLat, myLng, c.lat, c.lng) * 1000,
          )
        : null;

    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/common/club_card/star.svg',
          width: 13.r,
          height: 13.r,
        ),
        SizedBox(width: 6.w),
        Text(
          c.rating.toStringAsFixed(2),
          style: ClubGlass.body(
            color: Colors.white,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(width: 7.w),
        Text('리뷰 ${c.reviewCount}', style: ClubGlass.body(color: ClubGlass.t4)),
        SizedBox(width: 7.w),
        const GlassDot(),
        SizedBox(width: 7.w),
        Flexible(
          child: Text(
            c.genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClubGlass.body(color: ClubGlass.t3),
          ),
        ),
        SizedBox(width: 7.w),
        const GlassDot(),
        SizedBox(width: 7.w),
        Text(
          isOpen ? '영업중' : '영업종료',
          style: ClubGlass.body(
            color: isOpen ? VybeColors.mainLime500 : ClubGlass.t4,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        if (walk != null) ...[
          SizedBox(width: 7.w),
          const GlassDot(),
          SizedBox(width: 7.w),
          Text('도보 $walk분', style: ClubGlass.body(color: ClubGlass.t3)),
        ],
      ],
    );
  }
}

// ============================================================================
// 요약(절반 높이) 콘텐츠
// ============================================================================

class _Preview extends StatelessWidget {
  final ClubModel? club;
  final bool isFavorited;
  final VoidCallback? onSave;
  final VoidCallback onExpand;

  const _Preview({
    required this.club,
    required this.isFavorited,
    required this.onSave,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final c = club;
    final padBottom = navBarTotalHeight(context) + 12.h;

    if (c == null) {
      return ListView(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, padBottom),
        children: [
          VybeSkel(width: double.infinity, height: 126.h, radius: 16),
          SizedBox(height: 14.h),
          VybeSkel(width: double.infinity, height: 64.h, radius: 16),
          SizedBox(height: 14.h),
          VybeSkel(width: double.infinity, height: 120.h, radius: 18),
        ],
      );
    }

    // 히어로 → 갤러리 → 썸네일 순, 중복 URL 제거 후 최대 6장.
    final photos = <String>{
      ...c.heroImageUrls,
      ...c.imageUrls,
      if (c.thumbnailUrl.isNotEmpty) c.thumbnailUrl,
    }.take(6).toList();

    return ListView(
      padding: EdgeInsets.only(bottom: padBottom),
      children: [
        if (photos.isNotEmpty) _Photos(photos: photos),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: _Actions(club: c, isFavorited: isFavorited, onSave: onSave),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: _InfoCard(club: c),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GestureDetector(
            onTap: onExpand,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0x24FFFFFF)),
              ),
              child: Text(
                '상세 정보 전체 보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16.sp,
                  height: 18 / 16,
                  letterSpacing: 16 * -0.025,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 가로 스크롤 사진 — 첫 장은 넓게(66%), 나머지는 좁게(44%).
class _Photos extends StatelessWidget {
  final List<String> photos;

  const _Photos({required this.photos});

  @override
  Widget build(BuildContext context) {
    final content = MediaQuery.of(context).size.width - 32.w;
    return SizedBox(
      height: 126.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
        itemCount: photos.length,
        separatorBuilder: (_, __) => SizedBox(width: 9.w),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SkeletonImage(
            url: photos[i],
            width: content * (i == 0 ? 0.66 : 0.44),
            height: 126.h,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// 퀵 액션 4칸.
///
/// 디자인의 '예약'은 베타 범위에서 제외된 기능(웨이팅·테이블 예약)이라
/// 클럽 상세 페이지와 동일하게 '전화'로 대체했다.
class _Actions extends StatelessWidget {
  final ClubModel club;
  final bool isFavorited;
  final VoidCallback? onSave;

  const _Actions({
    required this.club,
    required this.isFavorited,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionTile(
          icon: Icons.near_me_outlined,
          label: '길찾기',
          accent: true,
          onTap: () => launchDirections(
            context,
            lat: club.lat,
            lng: club.lng,
            // 목적지 라벨은 주소 — 주소가 비면 클럽 이름으로 폴백
            destination: club.address.isNotEmpty ? club.address : club.name,
          ),
        ),
        SizedBox(width: 8.w),
        _ActionTile(
          icon: Icons.phone_rounded,
          label: '전화',
          onTap: () => launchPhoneCall(context, club.phone),
        ),
        SizedBox(width: 8.w),
        _ActionTile(
          icon: Icons.ios_share_rounded,
          label: '공유',
          onTap: () => VybeToast.show(context, message: '공유 기능은 준비 중이에요'),
        ),
        SizedBox(width: 8.w),
        _ActionTile(
          icon: isFavorited ? Icons.favorite_rounded : Icons.favorite_border,
          label: isFavorited ? '저장됨' : '저장',
          on: isFavorited,
          onTap: onSave,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool accent;
  final bool on;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.accent = false,
    this.on = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: accent ? null : ClubGlass.tileFill,
            gradient: accent ? NearbyGlass.activeChip : null,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: accent ? NearbyGlass.activeBorder : ClubGlass.tileBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.r,
                color: on ? ClubGlass.saved : Colors.white,
              ),
              SizedBox(height: 7.h),
              Text(
                label,
                style: ClubGlass.caption(
                  color: on ? ClubGlass.accentLavender : ClubGlass.t2,
                  lineHeight: 12,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 주소 · 영업시간 · 입장료 요약 카드.
class _InfoCard extends StatelessWidget {
  final ClubModel club;

  const _InfoCard({required this.club});

  @override
  Widget build(BuildContext context) {
    final today = club.operatingHours.today;
    final isOpen = today.isCurrentlyOpen;
    final String hours;
    if (!today.isOpen) {
      hours = '오늘 휴무';
    } else if (today.open != null && today.close != null) {
      hours = '${today.open} - ${today.close}';
    } else {
      hours = '영업 시간 미등록';
    }

    return GlassCard(
      padding: 15,
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
            Icons.place_outlined,
            club.address.isEmpty ? '주소 미등록' : club.address,
          ),
          SizedBox(height: 11.h),
          _row(
            Icons.access_time_rounded,
            '${isOpen ? '영업중' : '영업종료'} · $hours',
          ),
          SizedBox(height: 11.h),
          _row(
            Icons.confirmation_number_outlined,
            '입장료 ${formatEntryFee(min: club.entryFeeMin, max: club.entryFeeMax)}',
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h, right: 9.w),
          child: Icon(icon, size: 15.r, color: ClubGlass.t3),
        ),
        Expanded(child: Text(text, style: ClubGlass.body())),
      ],
    );
  }
}
