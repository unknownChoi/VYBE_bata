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
import 'package:vybe/presentation/common/widgets/vybe_recommend_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';

/// 주변 페이지 리스트 시트가 핀 선택 중일 때 보여주는 클럽 상세 콘텐츠.
///
/// 새 시트를 띄우지 않고 [NearbyBottomSheet]와 **같은**
/// DraggableScrollableSheet 안에서 내용만 교체된다 — 핀을 탭해도 시트 높이가
/// 그대로 유지된다. 드래그가 시트에 전달되려면 시트가 준 [scrollController]에
/// 붙은 스크롤뷰가 하나뿐이어야 해서 헤더까지 한 CustomScrollView로 묶는다.
///
/// 디자인 nearby_glass.jsx `NGDetailSheet` 요약 상태 —
/// 핸들 · 이름/메타 · 사진 · 퀵액션 · 기본정보 · '상세 정보 전체 보기'.
/// 전체 보기는 시트를 화면 전체로 키우는 대신(시트 높이 유지가 우선)
/// 리스트 카드 탭과 동일하게 클럽 상세 페이지로 이동한다.
class NearbyDetailSheetContent extends ConsumerStatefulWidget {
  final String clubId;

  /// 시트(DraggableScrollableSheet)가 builder로 넘겨준 컨트롤러.
  final ScrollController scrollController;

  /// 닫기(X) — 리스트 내용으로 복귀 + 핀 선택 해제.
  final VoidCallback onClose;

  const NearbyDetailSheetContent({
    super.key,
    required this.clubId,
    required this.scrollController,
    required this.onClose,
  });

  @override
  ConsumerState<NearbyDetailSheetContent> createState() =>
      _NearbyDetailSheetContentState();
}

class _NearbyDetailSheetContentState
    extends ConsumerState<NearbyDetailSheetContent> {
  @override
  void initState() {
    super.initState();
    // 리스트를 스크롤한 상태에서 핀을 탭하면 시트 컨트롤러의 오프셋이 남아
    // 상세가 중간부터 보일 수 있다 → 맨 위로 되돌린다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = widget.scrollController;
      if (mounted && c.hasClients && c.offset > 0) c.jumpTo(0);
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
    final onSave = uid == null
        ? null
        : () => ref
              .read(favoriteViewModelProvider.notifier)
              .toggleFavorite(uid, widget.clubId, isFavorited);

    return NearbySheetSurface(
      child: CustomScrollView(
        controller: widget.scrollController,
        // 내용이 짧아도 드래그가 시트로 전달되도록 항상 스크롤 가능.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              club: club,
              isFavorited: isFavorited,
              onSave: onSave,
              onClose: widget.onClose,
            ),
          ),
          SliverToBoxAdapter(
            child: _Preview(
              club: club,
              isFavorited: isFavorited,
              onSave: onSave,
              onExpand: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClubDetailScreen(clubId: widget.clubId),
                ),
              ),
            ),
          ),
          // 마지막 요소가 하단 nav 바에 가리지 않도록.
          SliverToBoxAdapter(
            child: SizedBox(height: navBarTotalHeight(context) + 12.h),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 헤더 (핸들 · 이름 · 저장/닫기 · 메타)
// ============================================================================

class _Header extends ConsumerWidget {
  final ClubModel? club;
  final bool isFavorited;
  final VoidCallback? onSave;
  final VoidCallback onClose;

  const _Header({
    required this.club,
    required this.isFavorited,
    required this.onSave,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myLocation = ref.watch(userLocationProvider);

    // 드래그는 시트의 스크롤뷰가 처리한다 (리스트 시트 헤더와 동일).
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 0),
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
                            const VybeRecommendBadge(),
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
// 요약 콘텐츠
// ============================================================================

/// 시트의 CustomScrollView 안에 들어가는 요약 블록.
/// 자체 스크롤을 만들면 시트 드래그가 끊기므로 [ListView]가 아닌 [Column]이다.
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

    if (c == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            VybeSkel(width: double.infinity, height: 126.h, radius: 16),
            SizedBox(height: 14.h),
            VybeSkel(width: double.infinity, height: 64.h, radius: 16),
            SizedBox(height: 14.h),
            VybeSkel(width: double.infinity, height: 120.h, radius: 18),
          ],
        ),
      );
    }

    // 히어로 → 갤러리 → 썸네일 순, 중복 URL 제거 후 최대 6장.
    final photos = <String>{
      ...c.heroImageUrls,
      ...c.imageUrls,
      if (c.thumbnailUrl.isNotEmpty) c.thumbnailUrl,
    }.take(6).toList();

    return Column(
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
