import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/search_trend_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/search/widgets/search_section_head.dart';
import 'package:vybe/presentation/search/widgets/trend_row.dart';

/// 실시간 인기 검색어 섹션 — 좌우 2열 카드.
class TrendingSearchesSection extends StatelessWidget {
  final SearchTrendSnapshot snapshot;
  final ValueChanged<String> onKeyword;

  const TrendingSearchesSection({
    super.key,
    required this.snapshot,
    required this.onKeyword,
  });

  @override
  Widget build(BuildContext context) {
    final items = snapshot.items;
    // 좌우 2열. 홀수여도 왼쪽이 한 칸 더 많게 나눈다.
    final split = (items.length / 2).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchSectionHead(
          icon: Icon(
            Icons.local_fire_department_rounded,
            size: 16.r,
            color: VybeColors.mainLime500,
          ),
          // 실검색 데이터가 하나도 없으면 '실시간'이라고 하지 않는다.
          title: snapshot.isLive ? '실시간 인기 검색어' : '인기 검색어',
          right: snapshot.updatedAt == null
              ? null
              : Text(
                  '${formatTrendUpdatedAt(snapshot.updatedAt!)} 기준',
                  style: VybeTypography.caption.copyWith(
                    color: VybeColors.gray600,
                  ),
                ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.015),
              ],
            ),
            border: Border.all(color: VybeColors.gray800),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Column(items: items.sublist(0, split), onKeyword: onKeyword)),
              Container(
                width: 1,
                margin: EdgeInsets.symmetric(vertical: 6.h),
                color: VybeColors.gray800,
              ),
              Expanded(child: _Column(items: items.sublist(split), onKeyword: onKeyword)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  final List<SearchTrendItem> items;
  final ValueChanged<String> onKeyword;

  const _Column({required this.items, required this.onKeyword});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          TrendRow(item: item, onTap: () => onKeyword(item.keyword)),
      ],
    );
  }
}

/// 'MM.dd HH:mm' — 서버 갱신 시각을 그대로 보여준다.
String formatTrendUpdatedAt(DateTime dt) {
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.month)}.${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
