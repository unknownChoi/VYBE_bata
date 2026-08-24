import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';

/// 지도 우측 플로팅 컨트롤 — 내 위치 (디자인 NGControls).
///
/// 시트 위에 얹히지 않도록 시트 상단을 기준으로 위치를 잡는다.
class NearbyMyLocationButton extends StatelessWidget {
  /// 시트 상단 y좌표 (= 스택 높이 × 시트 비율).
  final double sheetTop;

  final VoidCallback onTap;

  const NearbyMyLocationButton({
    super.key,
    required this.sheetTop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16.w,
      bottom: sheetTop + 8.h,
      child: NearbyRoundButton(
        onTap: onTap,
        child: Icon(Icons.my_location_rounded, size: 19.r, color: Colors.white),
      ),
    );
  }
}
