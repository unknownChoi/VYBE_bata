import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class NearbyGnb extends StatelessWidget {
  final VoidCallback? onSearchTap;

  /// 검색 중인 키워드. null이면 일반(geo) 모드 → 플레이스홀더 표시.
  final String? searchKeyword;

  /// 검색 모드 해제(X) 콜백. null이면 X 미표시.
  final VoidCallback? onClearSearch;

  const NearbyGnb({
    super.key,
    this.onSearchTap,
    this.searchKeyword,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
      child: _SearchBar(
        onTap: onSearchTap,
        keyword: searchKeyword,
        onClear: onClearSearch,
      ),
    );
  }
}

// 최근 검색어 페이지의 SearchInputBar와 동일한 디자인 (gray800 단색, 아이콘 우측).
class _SearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? keyword;
  final VoidCallback? onClear;

  const _SearchBar({this.onTap, this.keyword, this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasKeyword = keyword != null && keyword!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: VybeColors.gray800,
          borderRadius: BorderRadius.circular(999.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasKeyword ? keyword! : '클럽, 지역, 장르 검색',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.body4.copyWith(
                  color: hasKeyword ? Colors.white : VybeColors.gray600,
                ),
              ),
            ),
            if (hasKeyword)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.close_rounded,
                    size: 18.r, color: VybeColors.gray400),
              )
            else
              SvgPicture.asset(
                'assets/icons/common/search.svg',
                width: 18.r,
                height: 18.r,
              ),
          ],
        ),
      ),
    );
  }
}

