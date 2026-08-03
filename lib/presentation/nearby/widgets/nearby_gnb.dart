import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';

/// 주변 페이지 상단 검색 GNB (리퀴드 글래스).
///
/// 디자인 nearby_glass.jsx `NGGnb` — 글래스 pill 검색바 + (지역 선택 시)
/// 그 아래 '{지역} 지역' 해제 칩. 배경 스크림은 화면(NearbyScreen)이 그린다.
class NearbyGnb extends StatelessWidget {
  final VoidCallback? onSearchTap;

  /// 검색 중인 키워드. null이면 일반(geo) 모드 → 플레이스홀더 표시.
  final String? searchKeyword;

  /// 검색 모드 해제(X) 콜백. null이면 X 미표시.
  final VoidCallback? onClearSearch;

  /// 지역 클러스터로 선택된 area. null이면 칩 미표시.
  final String? area;

  /// 지역 선택 해제 콜백.
  final VoidCallback? onClearArea;

  const NearbyGnb({
    super.key,
    this.onSearchTap,
    this.searchKeyword,
    this.onClearSearch,
    this.area,
    this.onClearArea,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(
            onTap: onSearchTap,
            keyword: searchKeyword,
            onClear: onClearSearch,
          ),
          if (area != null) ...[
            SizedBox(height: 10.h),
            _AreaChip(area: area!, onClear: onClearArea),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? keyword;
  final VoidCallback? onClear;

  const _SearchBar({this.onTap, this.keyword, this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasKeyword = keyword != null && keyword!.isNotEmpty;
    final r = BorderRadius.circular(999.r);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              color: const Color(0x5C000000),
              blurRadius: 30.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: r,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: ClubGlass.blurSigma,
              sigmaY: ClubGlass.blurSigma,
            ),
            child: Container(
              // 검색 입력창 공통 높이 — 뒤로가기 글래스 버튼(size: 34)과 동일.
              height: 34.h,
              padding: EdgeInsets.fromLTRB(14.w, 0, 4.w, 0),
              decoration: BoxDecoration(
                color: ClubGlass.cardFill,
                borderRadius: r,
                border: Border.all(color: ClubGlass.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasKeyword ? keyword! : '클럽, 지역, 장르 검색',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VybeTypography.body4.copyWith(
                        color: hasKeyword ? Colors.white : ClubGlass.t3,
                        fontWeight: hasKeyword
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // pill 높이가 34로 줄어 기본 34 타일은 테두리에 붙는다 → 26으로 축소.
                  if (hasKeyword)
                    GestureDetector(
                      onTap: onClear,
                      behavior: HitTestBehavior.opaque,
                      child: GlassCircleTile(
                        size: 26,
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.r,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    GlassCircleTile(
                      size: 26,
                      child: SvgPicture.asset(
                        'assets/icons/common/search.svg',
                        width: 15.r,
                        height: 15.r,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// '{지역} 지역' 해제 칩 — 보라 반투명 + 라임 테두리.
class _AreaChip extends StatelessWidget {
  final String area;
  final VoidCallback? onClear;

  const _AreaChip({required this.area, this.onClear});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(999.r);
    return GestureDetector(
      onTap: onClear,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            padding: EdgeInsets.fromLTRB(13.w, 7.h, 10.w, 7.h),
            decoration: BoxDecoration(
              // rgba(119,49,254,0.34) / border rgba(181,255,96,0.35)
              color: const Color(0x577731FE),
              borderRadius: r,
              border: Border.all(color: const Color(0x59B5FF60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$area 지역',
                  style: ClubGlass.caption(
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.close_rounded,
                  size: 13.r,
                  color: const Color(0xCCFFFFFF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
