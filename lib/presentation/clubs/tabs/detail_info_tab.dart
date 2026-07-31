import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/map_launcher.dart';
import 'package:vybe/core/utils/phone_launcher.dart';
import 'package:vybe/core/utils/url_utils.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_detail_skeleton.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 클럽 상세 · 매장 정보 탭 (리퀴드 글래스).
///
/// 디자인 club_glass.jsx '매장 정보' 탭 — 위치(지도·주소·액션칩) /
/// 상세 정보(영업시간 전체·입장료·전화·인스타) / 이용 안내.
///
/// 디자인의 '편의시설'(주차·화장실·흡연실 등) 카드는 Firestore에 해당 필드가
/// 없어 제외했다. 실제 없는 정보를 하드코딩하면 잘못된 안내가 된다.
class DetailInfoTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailInfoTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailInfoTab> createState() => _DetailInfoTabState();
}

class _DetailInfoTabState extends ConsumerState<DetailInfoTab> {
  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final clubInfoAsync = ref.watch(clubInfoProvider(widget.clubId));
    final club = clubAsync.value;
    final clubInfo = clubInfoAsync.value;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: glassTabPadding(context),
      children: [
        clubAsync.isLoading
            ? const DetailLocationCardSkeleton()
            : _buildLocationCard(club, clubInfo),
        glassGap(),
        clubAsync.isLoading
            ? const DetailStoreInfoCardSkeleton()
            : _buildDetailCard(club),
        if ((clubInfo?.cautions ?? const []).isNotEmpty) ...[
          glassGap(),
          _buildCautionCard(clubInfo!.cautions),
        ],
      ],
    );
  }

  // ==========================================================================
  // 위치
  // ==========================================================================

  Widget _buildLocationCard(ClubModel? club, ClubInfoModel? clubInfo) {
    final subways = clubInfo?.nearbySubways ?? const [];
    final nearest = subways.isEmpty ? null : subways.first;
    final address = club?.address ?? '';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSectionHead(title: '위치', sub: subwayLabel(nearest)),
          _NaverMapCard(clubId: widget.clubId),
          SizedBox(height: 14.h),
          // 주소 타일
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ClubGlass.tileFill,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: ClubGlass.tileBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h, right: 10.w),
                      child: Icon(
                        Icons.place_outlined,
                        size: 18.r,
                        color: const Color(0x99FFFFFF),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        address,
                        style: ClubGlass.body(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (nearest != null) ...[
                  SizedBox(height: 9.h),
                  Padding(
                    padding: EdgeInsets.only(left: 28.w),
                    child: SubwayStationLine(subway: nearest),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10.h),
          // 주소 복사 · 길찾기
          Row(
            children: [
              Expanded(
                child: _actionChip(
                  icon: Icons.copy_rounded,
                  label: '주소 복사',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: address));
                    if (!mounted) return;
                    VybeToast.show(context, message: '주소를 복사했어요');
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _actionChip(
                  icon: Icons.near_me_outlined,
                  label: '길찾기',
                  accent: true,
                  onTap: () => launchDirections(
                    context,
                    lat: club?.lat ?? 0,
                    lng: club?.lng ?? 0,
                    // 목적지 라벨은 주소 — 주소가 비면 클럽 이름으로 폴백
                    destination: address.isNotEmpty
                        ? address
                        : (club?.name ?? ''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    final color = accent ? VybeColors.mainLime500 : ClubGlass.t2;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: accent
              ? VybeColors.mainLime500.withValues(alpha: 0.13)
              : ClubGlass.tileFill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: accent
                ? VybeColors.mainLime500.withValues(alpha: 0.3)
                : ClubGlass.tileBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.r, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 상세 정보
  // ==========================================================================

  Widget _buildDetailCard(ClubModel? club) {
    final hours = club?.operatingHours ?? const OperatingHours();
    final today = hours.today;
    final phone = club?.phone ?? '';
    final igHandle = instagramHandle(club?.instagramUrl ?? '');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GlassSectionHead(title: '상세 정보'),
          Transform.translate(
            offset: Offset(0, -4.h),
            child: Column(
              children: [
                // 영업시간 — 상세 탭에서는 요일 전체를 항상 펼쳐 보여준다.
                GlassInfoRow(
                  icon: Icons.schedule_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OpenHoursLine(today: today),
                      SizedBox(height: 12.h),
                      WeekHoursTable(hours: hours, rowGap: 9),
                    ],
                  ),
                ),
                GlassInfoRow(
                  icon: Icons.confirmation_number_outlined,
                  child: Row(
                    children: [
                      Text('입장료 ', style: ClubGlass.body()),
                      Text(
                        formatEntryFee(
                          min: club?.entryFeeMin ?? 0,
                          max: club?.entryFeeMax ?? 0,
                        ),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          height: 20 / 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassInfoRow(
                  icon: Icons.phone_rounded,
                  child: GestureDetector(
                    onTap: phone.isEmpty
                        ? null
                        : () => launchPhoneCall(context, phone),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      phone.isEmpty ? '등록된 번호가 없어요' : phone,
                      style: ClubGlass.body(
                        color: phone.isEmpty ? ClubGlass.t4 : ClubGlass.link,
                      ),
                    ),
                  ),
                ),
                GlassInfoRow(
                  icon: Icons.link_rounded,
                  last: true,
                  child: Text(
                    igHandle.isEmpty ? '등록된 링크가 없어요' : '@$igHandle',
                    style: ClubGlass.body(
                      color: igHandle.isEmpty ? ClubGlass.t4 : ClubGlass.link,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 이용 안내
  // ==========================================================================

  Widget _buildCautionCard(List<String> cautions) {
    return GlassCard(
      fill: VybeColors.mainPurple500.withValues(alpha: 0.16),
      border: VybeColors.mainPurple500.withValues(alpha: 0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16.r,
                color: VybeColors.mainLime500,
              ),
              SizedBox(width: 7.w),
              Text('이용 안내', style: ClubGlass.title()),
            ],
          ),
          SizedBox(height: 14.h),
          for (var i = 0; i < cautions.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == cautions.length - 1 ? 0 : 10.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4.r,
                    height: 4.r,
                    margin: EdgeInsets.only(top: 7.h, right: 8.w),
                    decoration: const BoxDecoration(
                      color: VybeColors.mainLime500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      cautions[i],
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        height: 19 / 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xD9FFFFFF),
                      ),
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

// ============================================================================
// MAP CARD
// ============================================================================

class _NaverMapCard extends ConsumerStatefulWidget {
  final String clubId;
  const _NaverMapCard({required this.clubId});

  @override
  ConsumerState<_NaverMapCard> createState() => _NaverMapCardState();
}

class _NaverMapCardState extends ConsumerState<_NaverMapCard> {
  NaverMapController? _mapController; // ignore: unused_field
  // 마커 이미지 캐시 — fromWidget 재생성 시 플러그인 캐시 정리 로그 방지.
  NOverlayImage? _myLocationIcon;
  NOverlayImage? _clubPinIcon;

  @override
  Widget build(BuildContext context) {
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;
    if (club == null) {
      return Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: ClubGlass.tileBorder),
        ),
      );
    }

    final lat = club.lat;
    final lng = club.lng;
    final name = club.name;
    // 앱 진입 시 설정된 내 위치 — 내 위치 마커 기준.
    final myLocation = ref.watch(userLocationProvider);
    // 좌표가 없는 클럽(0,0)은 핀을 찍을 수 없어 내 위치를 중심으로 둔다.
    final hasClubLocation = lat != 0 || lng != 0;
    final center = hasClubLocation
        ? NLatLng(lat, lng)
        : NLatLng(myLocation.lat, myLocation.lng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: double.infinity,
        height: 200.h,
        child: NaverMap(
          // 탭뷰(가로 스와이프) 안에서도 지도가 제스처를 독점하도록.
          // 미지정 시 가로 드래그가 부모 PageView로 전달돼 탭이 넘어감.
          forceGesture: true,
          options: NaverMapViewOptions(
            // 초기 위치 = 클럽(화면 가운데). 매장 정보 탭의 지도라 클럽 핀이
            // 항상 보여야 한다. 내 위치는 GPS 미연동(고정 기본 좌표)이라
            // 중심으로 쓰면 클럽이 화면 밖으로 나간다.
            initialCameraPosition: NCameraPosition(target: center, zoom: 16),
            mapType: NMapType.basic,
            activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
            nightModeEnable: true,
            // 좌우 이동(scroll) + 축소/확대(zoom) 허용
            scrollGesturesEnable: true,
            zoomGesturesEnable: true,
            rotationGesturesEnable: false,
            tiltGesturesEnable: false,
          ),
          onMapReady: (controller) async {
            _mapController = controller;
            if (!mounted) return;

            // 1) 클럽 핀을 먼저 올린다 — 이 지도의 주인공.
            // 보라 라벨 + 핀을 하나의 마커 이미지로 생성해서,
            // 지도를 움직여도 클럽 좌표에 정확히 붙어 따라간다.
            await controller.updateCamera(
              NCameraUpdate.withParams(target: center, zoom: 16),
            );
            if (!mounted) return;
            if (hasClubLocation) {
              final overlayImage = _clubPinIcon ??=
                  await NOverlayImage.fromWidget(
                    widget: _PinWithLabel(label: name),
                    size: Size(240.r, 64.r),
                    context: context,
                  );
              if (!mounted) return;
              await controller.addOverlay(
                NMarker(
                  id: 'club_marker',
                  position: NLatLng(lat, lng),
                  icon: overlayImage,
                  // 핀 바닥(캔버스 하단 중앙)이 좌표를 가리키도록
                  anchor: const NPoint(0.5, 1.0),
                ),
              );
            }

            // 2) 내 위치 점. locationOverlay 기본 아이콘이 환경에 따라
            // 안 보여 커스텀 마커로 그린다. 클럽에서 멀면 화면 밖.
            if (!mounted) return;
            final myIcon = _myLocationIcon ??= await NOverlayImage.fromWidget(
              widget: const _MyLocationDot(),
              size: const Size(28, 28),
              context: context,
            );
            if (!mounted) return;
            await controller.addOverlay(
              NMarker(
                id: 'my_location_marker',
                position: NLatLng(myLocation.lat, myLocation.lng),
                icon: myIcon,
                anchor: const NPoint(0.5, 0.5),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 내 위치 점 (파란 점 + 흰 테두리). fromWidget으로 마커 이미지화.
class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFF0086FF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0086FF).withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// 지도 마커용 보라 라벨 + 핀 (디자인의 main pin).
// fromWidget으로 이미지화 → 핀 바닥이 캔버스 하단(=좌표)에 오도록 하단 정렬.
class _PinWithLabel extends StatelessWidget {
  final String label;
  const _PinWithLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240.r,
      height: 64.r,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: VybeColors.mainPurple500,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: VybeColors.mainPurple500.withValues(alpha: 0.4),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 24.r,
            height: 27.r,
            child: const CustomPaint(painter: VybeMapPinPainter()),
          ),
        ],
      ),
    );
  }
}
