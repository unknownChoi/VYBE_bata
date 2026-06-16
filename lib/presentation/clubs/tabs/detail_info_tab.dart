import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/subway_line_badge.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

class DetailInfoTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailInfoTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailInfoTab> createState() => _DetailInfoTabState();
}

class _DetailInfoTabState extends ConsumerState<DetailInfoTab> {
  bool _hoursExpanded = false;
  bool _noticeExpanded = true;

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubDetailProvider(widget.clubId));
    final clubInfoAsync = ref.watch(clubInfoProvider(widget.clubId));
    final isLoading = clubAsync.isLoading;
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        isLoading ? const LocationSkeleton() : _buildLocationSection(),
        _sectionDivider(),
        isLoading
            ? const DetailInfoSkeleton()
            : _buildDetailInfoSection(clubAsync.value, clubInfoAsync.value),
        SizedBox(height: 32.h),
      ],
    );
  }

  /// "https://instagram.com/awesomered_omg" → "@awesomered_omg"
  String _instagramHandle(String url) {
    if (url.isEmpty) return '';
    final cleaned = url
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^(www\.)?instagram\.com/'), '')
        .replaceAll(RegExp(r'/+$'), '');
    return cleaned.isEmpty ? '' : '@$cleaned';
  }

  /// URL 표시용 — 스킴 제거
  String _stripScheme(String url) =>
      url.replaceFirst(RegExp(r'^https?://'), '');

  /// 하루 영업시간 문자열
  String _dayHoursText(DayHours d) =>
      (d.isOpen && d.open != null && d.close != null)
      ? '${d.open} - ${d.close}'
      : '정기휴무';

  Widget _sectionDivider() {
    return Container(
      height: 8.h,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF1F1F23)),
        ),
      ),
    );
  }

  // ── LOCATION ──

  Widget _buildLocationSection() {
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;
    final address = (club?.address.isNotEmpty ?? false)
        ? club!.address
        : '서울 마포구 잔다리로 12 지하 1층';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '위치',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          _NaverMapCard(clubId: widget.clubId),
          SizedBox(height: 16.h),
          // address card
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: VybeColors.gray900,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: VybeColors.gray800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 18.r,
                      color: VybeColors.gray400,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 28.w),
                  child: Row(
                    children: [
                      const SubwayLineBadge(line: '9호선'),
                      SizedBox(width: 6.w),
                      Text(
                        '상수역 1번 출구에서 422m',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13.sp,
                          color: VybeColors.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          // action chips
          Row(
            children: [
              _actionChip(
                icon: Icons.copy_rounded,
                label: '주소 복사',
                accent: false,
                onTap: () => _copyAddress(address),
              ),
              SizedBox(width: 8.w),
              _actionChip(icon: Icons.map_rounded, label: '지도', accent: false),
              SizedBox(width: 8.w),
              _actionChip(
                icon: Icons.near_me_rounded,
                label: '길찾기',
                accent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyAddress(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;
    VybeToast.show(context, message: '주소가 복사되었습니다');
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required bool accent,
    VoidCallback? onTap,
  }) {
    final color = accent ? VybeColors.mainLime500 : VybeColors.gray200;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: VybeColors.gray900,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: VybeColors.gray800),
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
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DETAIL INFO ──

  Widget _buildDetailInfoSection(ClubModel? club, ClubInfoModel? clubInfo) {
    final today = DateTime.now().weekday - 1;
    final hours = club?.operatingHours ?? const OperatingHours();
    final days = [
      hours.mon,
      hours.tue,
      hours.wed,
      hours.thu,
      hours.fri,
      hours.sat,
      hours.sun,
    ];
    final todayHours = hours.today;
    final isOpen = todayHours.isCurrentlyOpen;
    final phone = club?.phone ?? '';
    final instagram = _instagramHandle(club?.instagramUrl ?? '');
    final openChatUrl = clubInfo?.openChatUrl ?? '';
    final cautions = clubInfo?.cautions ?? const <String>[];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 정보',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),

          // hours row
          _infoRowFull(
            icon: Icons.access_time_rounded,
            label: '영업 시간',
            child: GestureDetector(
              onTap: () => setState(() => _hoursExpanded = !_hoursExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isOpen
                                          ? VybeColors.mainLime500
                                          : VybeColors.gray500)
                                      .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(99.r),
                            ),
                            child: Text(
                              isOpen ? '영업중' : '영업종료',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: isOpen
                                    ? VybeColors.mainLime500
                                    : VybeColors.gray500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _dayHoursText(todayHours),
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      AnimatedRotation(
                        turns: _hoursExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14.r,
                          color: VybeColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: _hoursExpanded ? 1 : 0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Column(
                            children: List.generate(days.length, (i) {
                      final isToday = i == today;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18.w,
                              child: Text(
                                _weekdayLabels[i],
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 13.sp,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isToday
                                      ? Colors.white
                                      : VybeColors.gray500,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              _dayHoursText(days[i]),
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13.sp,
                                fontWeight: isToday
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isToday
                                    ? Colors.white
                                    : VybeColors.gray500,
                              ),
                            ),
                            if (isToday) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x247731FE),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '오늘',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: VybeColors.mainPurple500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // phone row
          _infoRowFull(
            icon: Icons.phone_rounded,
            label: '전화번호',
            child: Row(
              children: [
                Text(
                  phone.isNotEmpty ? phone : '-',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '전화 걸기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.mainLime500,
                  ),
                ),
              ],
            ),
          ),

          // instagram row
          _infoRowFull(
            icon: Icons.camera_alt_rounded,
            label: '인스타그램',
            child: Row(
              children: [
                Text(
                  instagram.isNotEmpty ? instagram : '-',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14.sp,
                    color: VybeColors.accentBlue500,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 12.r,
                  color: VybeColors.accentBlue500,
                ),
              ],
            ),
          ),

          // openchat row
          _infoRowFull(
            icon: Icons.chat_bubble_rounded,
            label: '오픈 채팅',
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    openChatUrl.isNotEmpty ? _stripScheme(openChatUrl) : '-',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14.sp,
                      color: VybeColors.accentBlue500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 12.r,
                  color: VybeColors.accentBlue500,
                ),
              ],
            ),
          ),

          // notice section
          if (cautions.isNotEmpty) ...[
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => setState(() => _noticeExpanded = !_noticeExpanded),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: VybeColors.accentRed500.withValues(alpha: 0.08),
                  border: Border.all(
                    color: VybeColors.accentRed500.withValues(alpha: 0.25),
                  ),
                  borderRadius: _noticeExpanded
                      ? BorderRadius.vertical(top: Radius.circular(12.r))
                      : BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16.r,
                      color: VybeColors.accentRed500,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '안내 및 유의사항',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: VybeColors.accentRed500,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _noticeExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14.r,
                        color: VybeColors.accentRed500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _noticeExpanded ? 1 : 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
                decoration: BoxDecoration(
                  color: VybeColors.accentRed500.withValues(alpha: 0.04),
                  border: Border(
                    left: BorderSide(
                      color: VybeColors.accentRed500.withValues(alpha: 0.25),
                    ),
                    right: BorderSide(
                      color: VybeColors.accentRed500.withValues(alpha: 0.25),
                    ),
                    bottom: BorderSide(
                      color: VybeColors.accentRed500.withValues(alpha: 0.25),
                    ),
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cautions.map((notice) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14.sp,
                              color: VybeColors.gray500,
                              height: 1.43,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              notice,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14.sp,
                                color: VybeColors.gray200,
                                height: 1.43,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRowFull({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.r, color: VybeColors.gray400),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: VybeColors.gray400,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── MAP CARD ──

class _NaverMapCard extends ConsumerStatefulWidget {
  final String clubId;
  const _NaverMapCard({required this.clubId});

  @override
  ConsumerState<_NaverMapCard> createState() => _NaverMapCardState();
}

class _NaverMapCardState extends ConsumerState<_NaverMapCard> {
  NaverMapController? _mapController; // ignore: unused_field

  @override
  Widget build(BuildContext context) {
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;
    if (club == null) {
      return Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: VybeColors.gray800),
        ),
      );
    }

    final lat = club.lat;
    final lng = club.lng;
    final name = club.name;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: double.infinity,
        height: 200.h,
        child: NaverMap(
          // 탭뷰(가로 스와이프) 안에서도 지도가 제스처를 독점하도록.
          // 미지정 시 가로 드래그가 부모 PageView로 전달돼 탭이 넘어감.
          forceGesture: true,
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(lat, lng),
              zoom: 16,
            ),
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
            // 보라 라벨 + 핀을 하나의 마커 이미지로 생성.
            // 지도를 움직여도 클럽 좌표에 정확히 붙어 따라간다.
            final overlayImage = await NOverlayImage.fromWidget(
              widget: _PinWithLabel(label: name),
              size: Size(240.r, 64.r),
              context: context,
            );
            final marker = NMarker(
              id: 'club_marker',
              position: NLatLng(lat, lng),
              icon: overlayImage,
              // 핀 바닥(캔버스 하단 중앙)이 좌표를 가리키도록
              anchor: const NPoint(0.5, 1.0),
            );
            await controller.addOverlay(marker);
          },
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
