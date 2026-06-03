import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/subway_line_badge.dart';

class DetailInfoTab extends ConsumerStatefulWidget {
  final String clubId;
  const DetailInfoTab({super.key, required this.clubId});

  @override
  ConsumerState<DetailInfoTab> createState() => _DetailInfoTabState();
}

class _DetailInfoTabState extends ConsumerState<DetailInfoTab> {
  bool _hoursExpanded = false;
  bool _noticeExpanded = true;

  static const List<List<String>> _hours = [
    ['월', '11:00 - 02:00'],
    ['화', '11:00 - 02:00'],
    ['수', '11:00 - 02:00'],
    ['목', '11:00 - 02:00'],
    ['금', '11:00 - 02:00'],
    ['토', '11:00 - 02:00'],
    ['일', '정기휴무'],
  ];

  static const _notices = [
    '성인만 입장 가능합니다.',
    '프로모션 기간에는 운영 시간과 가격이 변동될 수 있습니다.',
    '예약 변경 및 취소는 방문일 전 3일까지 앱을 통해 가능하며, 2일 ~ 하루 전 취소 시 50% 환불, 당일 취소 및 노쇼는 환불 불가입니다.',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _buildLocationSection(),
        _sectionDivider(),
        _buildDetailInfoSection(),
        SizedBox(height: 32.h),
      ],
    );
  }

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
                        '서울 마포구 잔다리로 12 지하 1층',
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
                      const SubwayLineBadge(line: 9),
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
              ),
              SizedBox(width: 8.w),
              _actionChip(
                icon: Icons.map_rounded,
                label: '지도',
                accent: false,
              ),
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

  Widget _actionChip({
    required IconData icon,
    required String label,
    required bool accent,
  }) {
    final color = accent ? VybeColors.mainLime500 : VybeColors.gray200;
    return Expanded(
      child: GestureDetector(
        onTap: () {},
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

  Widget _buildDetailInfoSection() {
    final today = DateTime.now().weekday - 1;
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
              onTap: () =>
                  setState(() => _hoursExpanded = !_hoursExpanded),
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
                              color: VybeColors.mainLime500
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(99.r),
                            ),
                            child: Text(
                              '영업중',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: VybeColors.mainLime500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '11:00 - 02:00',
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
                  if (_hoursExpanded) ...[
                    SizedBox(height: 12.h),
                    ...List.generate(_hours.length, (i) {
                      final isToday = i == today;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18.w,
                              child: Text(
                                _hours[i][0],
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
                              _hours[i][1],
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
                                  borderRadius:
                                      BorderRadius.circular(4.r),
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
                  ],
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
                  '02-1234-1234',
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
                  '@awesomered_omg',
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
                Expanded(
                  child: Text(
                    'open.kakao.com/o/gYnkW0yf',
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
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () =>
                setState(() => _noticeExpanded = !_noticeExpanded),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
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
          if (_noticeExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
              decoration: BoxDecoration(
                color: VybeColors.accentRed500.withValues(alpha: 0.04),
                border: Border(
                  left: BorderSide(
                    color:
                        VybeColors.accentRed500.withValues(alpha: 0.25),
                  ),
                  right: BorderSide(
                    color:
                        VybeColors.accentRed500.withValues(alpha: 0.25),
                  ),
                  bottom: BorderSide(
                    color:
                        VybeColors.accentRed500.withValues(alpha: 0.25),
                  ),
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _notices.map((notice) {
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
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(lat, lng),
              zoom: 16,
            ),
            mapType: NMapType.basic,
            activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
            nightModeEnable: true,
            scrollGesturesEnable: false,
            zoomGesturesEnable: false,
            rotationGesturesEnable: false,
            tiltGesturesEnable: false,
          ),
          onMapReady: (controller) async {
            _mapController = controller;
            final marker = NMarker(
              id: 'club_marker',
              position: NLatLng(lat, lng),
            );
            final infoWindow = NInfoWindow.onMarker(
              id: 'club_info',
              text: name,
            );
            await controller.addOverlay(marker);
            marker.openInfoWindow(infoWindow);
          },
        ),
      ),
    );
  }
}
