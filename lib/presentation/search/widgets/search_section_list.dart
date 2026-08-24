import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 섹션 사이 간격. 숨은 섹션의 간격까지 같이 빠져야 해서 사이에만 넣는다.
const double kSearchSectionGap = 30;

/// 검색어 입력 전 기본 화면 — 최근 검색어 / 인기 해시태그 / 실시간 인기 검색어.
///
/// 데이터가 없는 섹션은 통째로 숨는다 → 사이 여백도 같이 빠지도록
/// **보이는 섹션만** 받아서 그 사이에만 간격을 넣는다.
class SearchSectionList extends StatelessWidget {
  /// 이미 걸러진 '보이는' 섹션 위젯 목록.
  final List<Widget> sections;

  const SearchSectionList({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) SizedBox(height: kSearchSectionGap.h),
              sections[i],
            ],
          ],
        ),
      ),
    );
  }
}
