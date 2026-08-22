import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_map_pin.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_rec_pin.dart';

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
//
// 이름표는 세 모습이다 — 기본(보라) / VYBE 추천(핑크→퍼플, 더 굵게) /
// 선택(라임 + 2줄). **선택이 추천보다 우선**한다: 라임은 '지금 고른 핀'
// 전용 신호라, 추천 클럽을 골라도 다른 핀과 똑같이 라임으로 바뀌어야
// 지도에서 어느 것을 골랐는지 알 수 있다.
class NearbyPin extends StatelessWidget {
  final String label;
  final bool selected;
  final double rating;
  final int reviewCount;
  final bool isOpen;

  /// VYBE 추천 클럽 — 이름표가 핑크→퍼플로 바뀌고 핀에 왕관이 얹힌다.
  final bool isRecommended;

  const NearbyPin({super.key,
    required this.label,
    required this.selected,
    required this.rating,
    required this.reviewCount,
    required this.isOpen,
    this.isRecommended = false,
  });

  /// 마커 이미지 캔버스 크기.
  /// 선택 라벨(2줄) + 간격 + 왕관 얹은 핀 + 1.06배 확대분까지 담기는 높이.
  /// 모자라면 잘리므로 가장 큰 조합(선택 + 추천)을 기준으로 잡는다.
  static const double canvasWidth = 200;
  static const double canvasHeight = 92;

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

  /// 추천 라벨 — 핀 그라데이션과 같은 색이어야 이름표·핀이 한 쌍으로 읽힌다.
  static const _recFill = NearbyRecPin.gradient;

  @override
  Widget build(BuildContext context) {
    final pinColor = selected ? _lime : _purple;
    // 추천 표시는 이름표에도 남긴다 — 선택되면 라벨이 라임이라 추천 색이
    // 사라지는데, 왕관까지 없으면 고르는 순간 추천 클럽이 아닌 것처럼 보인다.
    final showCrown = isRecommended;
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
              padding: selected
                  ? EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.5.h)
                  : EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: selected
                    ? _selectedFill
                    : (isRecommended ? _recFill : _defaultFill),
                borderRadius: BorderRadius.circular(selected ? 13.r : 9.r),
                // 선택·추천 순으로 테두리가 밝아져 지도 위에서 한 번 더 떠 보인다.
                border: Border.all(
                  color: selected
                      ? const Color(0x8CFFFFFF)
                      : (isRecommended
                            ? const Color(0x73FFFFFF)
                            : const Color(0x3DFFFFFF)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? const Color(0x73B5FF60)
                        : (isRecommended
                              ? const Color(0x73BB67ED)
                              : const Color(0x80622ACF)),
                    blurRadius: selected
                        ? 26.r
                        : (isRecommended ? 20.r : 16.r),
                    offset: Offset(
                      0,
                      selected ? 10.h : (isRecommended ? 8.h : 6.h),
                    ),
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
                      fontSize: selected ? 12.5.sp : 12.sp,
                      fontWeight: selected || isRecommended
                          ? FontWeight.w800
                          : FontWeight.w700,
                      height: selected ? 15 / 12.5 : 14 / 12,
                      letterSpacing: 12 * -0.03,
                      color: selected ? _bg : Colors.white,
                    ),
                  ),
                  // 선택된 핀만 별점·영업여부를 펼친다.
                  if (selected) ...[SizedBox(height: 1.h), _buildMetaRow()],
                ],
              ),
            ),
            SizedBox(height: 3.h),
            if (showCrown)
              NearbyRecPin(selected: selected)
            else
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
