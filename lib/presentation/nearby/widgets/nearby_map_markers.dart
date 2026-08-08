import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';

// 지도 마커로 그려지는 위젯 — NOverlayImage.fromWidget으로 이미지화한다.
// 화면에 직접 붙지 않으므로 레이아웃 제약이 없다(캔버스 크기는 호출부가 지정).

// 내 위치 점 (파란 점 + 흰 테두리). fromWidget으로 마커 이미지화.
// 지도 마커: 이름 라벨 pill + 핀. 선택 시 라임, 평소 보라.
// fromWidget으로 이미지화 → 핀 바닥이 캔버스 하단(=좌표)에 오도록 하단 정렬.
//
// 디자인 nearby_glass_shell.jsx `NGMap` 핀 라벨 — 선택되면 이름표가
// 보라 그라데이션 → 라임 그라데이션으로 바뀌고, 글자색이 배경색(어두운)으로
// 반전되며, 테두리가 밝아지고 라임 글로우 + 1.06배 확대가 걸린다.
//
// 디자인의 라벨은 이름 한 줄뿐이지만, 선택된 핀은 지도만 보고도 고를 수 있도록
// 별점·영업여부 줄을 덧붙인다 (디자인에 없는 추가 사양).
class NearbyPin extends StatelessWidget {
  final String label;
  final bool selected;
  final double rating;
  final int reviewCount;
  final bool isOpen;

  const NearbyPin({super.key, 
    required this.label,
    required this.selected,
    required this.rating,
    required this.reviewCount,
    required this.isOpen,
  });

  /// 마커 이미지 캔버스 크기.
  /// 선택 라벨(2줄) + 간격 + 핀 + 1.06배 확대분까지 담기는 높이로 잡는다.
  static const double canvasWidth = 200;
  static const double canvasHeight = 84;

  static const _purple = VybeColors.mainPurple700;
  static const _lime = VybeColors.mainLime500;
  static const _bg = VybeColors.background;

  /// 선택 라벨 — linear-gradient(135deg, LIME500, LIME700)
  static const _selectedFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [VybeColors.mainLime500, VybeColors.mainLime700],
  );

  /// 기본 라벨 — linear-gradient(135deg, purple500 96%, purple700 86%)
  static const _defaultFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xF57731FE), Color(0xDB622ACF)],
  );

  @override
  Widget build(BuildContext context) {
    final pinColor = selected ? _lime : _purple;
    return SizedBox(
      width: canvasWidth.r,
      height: canvasHeight.r,
      // 선택된 핀만 살짝 커진다 (디자인 transform: scale(1.06)).
      // 좌표는 캔버스 하단이므로 아래를 기준으로 키워야 핀 끝이 안 밀린다.
      child: Transform.scale(
        scale: selected ? 1.06 : 1.0,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: selected ? _selectedFill : _defaultFill,
                borderRadius: BorderRadius.circular(9.r),
                // 선택 시 테두리가 밝아져 지도 위에서 한 번 더 떠 보인다.
                border: Border.all(
                  color: selected
                      ? const Color(0x8CFFFFFF)
                      : const Color(0x3DFFFFFF),
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? const Color(0x6BB5FF60)
                        : const Color(0x80622ACF),
                    blurRadius: selected ? 22.r : 16.r,
                    offset: Offset(0, selected ? 8.h : 6.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      height: 14 / 12,
                      letterSpacing: 12 * -0.025,
                      color: selected ? _bg : Colors.white,
                    ),
                  ),
                  // 선택된 핀만 별점·영업여부를 펼친다.
                  if (selected) ...[SizedBox(height: 3.h), _buildMetaRow()],
                ],
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: 24.r,
              height: 27.r,
              child: CustomPaint(painter: VybeMapPinPainter(color: pinColor)),
            ),
          ],
        ),
      ),
    );
  }

  // 선택 라벨 둘째 줄 — `★ 4.76 · 영업중`.
  // 라임 배경 위라 라임 별/라임 '영업중'은 안 보인다 → 전부 배경색(어두운)으로,
  // 영업종료만 투명도를 낮춰 구분한다.
  Widget _buildMetaRow() {
    final hasRating = reviewCount > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasRating) ...[
          Icon(Icons.star_rounded, size: 11.r, color: _bg),
          SizedBox(width: 2.w),
          Text(rating.toStringAsFixed(2), style: _metaStyle(_bg)),
          SizedBox(width: 4.w),
          Text('·', style: _metaStyle(const Color(0x8C101013))),
          SizedBox(width: 4.w),
        ],
        Text(
          isOpen ? '영업중' : '영업종료',
          style: _metaStyle(isOpen ? _bg : const Color(0x99101013)),
        ),
      ],
    );
  }

  TextStyle _metaStyle(Color color) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    height: 12 / 10,
    letterSpacing: 10 * -0.025,
    color: color,
  );
}

// 지역 클러스터 동그라미. 보라 원 + 지역명(작게) + 클럽 수(크게) + glow.
class NearbyRegionCluster extends StatelessWidget {
  final String area;
  final int count;
  const NearbyRegionCluster({super.key, required this.area, required this.count});

  static const _purple = VybeColors.mainPurple700;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88.r,
      height: 88.r,
      child: Center(
        child: Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(
            color: _purple,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB388FF), width: 2),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.5),
                blurRadius: 20.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                area,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  height: 13 / 11,
                  letterSpacing: 11 * -0.025,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  height: 22 / 20,
                  letterSpacing: 20 * -0.025,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
