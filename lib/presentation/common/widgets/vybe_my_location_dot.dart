import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 지도 위 「내 위치」 파란 점 (흰 테두리 + 글로우).
///
/// 주변 페이지 지도와 클럽 상세 매장정보 탭 지도가 같은 마커를 쓴다.
/// 네이버 지도 `NOverlayImage.fromWidget`으로 이미지화해 올린다.
class VybeMyLocationDot extends StatelessWidget {
  const VybeMyLocationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 18.r,
        height: 18.r,
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
