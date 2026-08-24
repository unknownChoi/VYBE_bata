import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/hangul_search.dart';
import 'package:vybe/design_system/colors.dart';

class SearchSuggestionItem extends StatelessWidget {
  final String keyword;
  final String query;
  final VoidCallback? onTap;

  const SearchSuggestionItem({
    super.key,
    required this.keyword,
    required this.query,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 17.sp,
      height: 22 / 17,
      letterSpacing: 17 * -0.025,
    );

    // 강조 구간은 조합 중 자모까지 감안해 찾는다 — '홍대 ㅇ'으로 뜬 '어썸레드'가
    // 왜 떴는지 보이지 않으면 목록이 엉뚱해 보인다. (앞부분 일치가 아니어도 강조)
    // 구간이 여럿인 이유 — '홍대 ㅋ'이면 '홍대'와 '클'이 떨어져 있다.
    final ranges = query.trim().isEmpty
        ? const <HangulMatch>[]
        : HangulQuery.parse(query).highlightRangesIn(keyword);

    final plain = baseStyle.copyWith(color: VybeColors.gray200);
    final InlineSpan textSpan;
    if (ranges.isEmpty) {
      textSpan = TextSpan(text: keyword, style: plain);
    } else {
      final spans = <InlineSpan>[];
      var cursor = 0;
      for (final r in ranges) {
        if (r.start > cursor) {
          spans.add(
            TextSpan(text: keyword.substring(cursor, r.start), style: plain),
          );
        }
        spans.add(
          TextSpan(
            text: keyword.substring(r.start, r.end),
            style: baseStyle.copyWith(color: VybeColors.mainLime700),
          ),
        );
        cursor = r.end;
      }
      if (cursor < keyword.length) {
        spans.add(TextSpan(text: keyword.substring(cursor), style: plain));
      }
      textSpan = TextSpan(children: spans);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 50.h,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 9.h),
          child: RichText(text: textSpan),
        ),
      ),
    );
  }
}
