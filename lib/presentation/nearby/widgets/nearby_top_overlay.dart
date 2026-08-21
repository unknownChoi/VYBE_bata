import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_gnb.dart';

/// 지도 위 상단 레이어 — 스크림 + 검색 GNB (디자인 NGGnb).
///
/// 시트보다 위에 얹는다 — 시트가 최대로 올라와도 검색바는 남아야 한다.
class NearbyTopOverlay extends StatelessWidget {
  /// 검색 모드일 때의 검색어. null이면 기본(플레이스홀더) 상태.
  final String? searchKeyword;

  /// 지역 클러스터로 고른 area. null이면 지역 칩 미표시.
  final String? area;

  final VoidCallback onSearchTap;
  final VoidCallback onClearSearch;
  final VoidCallback onClearArea;

  const NearbyTopOverlay({
    super.key,
    required this.searchKeyword,
    required this.area,
    required this.onSearchTap,
    required this.onClearSearch,
    required this.onClearArea,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Stack(
        children: [
          const _Scrim(),
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 6.h),
                NearbyGnb(
                  searchKeyword: searchKeyword,
                  onClearSearch: searchKeyword == null ? null : onClearSearch,
                  onSearchTap: onSearchTap,
                  area: area,
                  onClearArea: area == null ? null : onClearArea,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 검색바 가독성용 스크림 + 상단 오로라(보라·라임).
///
/// 오로라는 스크림 범위 안에서만 얹는다 — 지도 전체에 깔면 실제 지도 색이
/// 왜곡돼 길·건물 구분이 어려워진다.
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 150.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xD10A090E), Color(0x570A090E), Color(0x000A090E)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.96, -1),
              radius: 1.3,
              colors: [Color(0x3D7731FE), Color(0x007731FE)],
              stops: [0.0, 0.64],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1, -0.8),
                radius: 1.1,
                colors: [Color(0x14B5FF60), Color(0x00B5FF60)],
                stops: [0.0, 0.66],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
