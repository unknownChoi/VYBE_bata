import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/table_detail_sheet.dart';
import 'package:vybe/presentation/clubs/widgets/table_floor_map.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_data.dart';

// 테이블 가격 섹션 — 클럽 상세 홈 탭.
// claude.ai/design club_detail.html (tables.jsx) 디자인 기반. 프론트 전용(하드코딩).
// 자리 선택 → 플로어맵 하이라이트 + 상세 카드 갱신.

class TablePricingSection extends StatefulWidget {
  const TablePricingSection({super.key});

  @override
  State<TablePricingSection> createState() => _TablePricingSectionState();
}

class _TablePricingSectionState extends State<TablePricingSection> {
  String _selId = 'S1';

  @override
  Widget build(BuildContext context) {
    final sel = kClubFloorTables.firstWhere(
      (t) => t.id == _selId,
      orElse: () => kClubFloorTables.first,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '테이블 가격',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '자리를 선택하면 위치별 가격과 예약 조건을 볼 수 있어요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              height: 16 / 12,
              color: VybeColors.gray500,
            ),
          ),
          SizedBox(height: 14.h),
          ClubFloorMap(
            selId: _selId,
            onSelect: (id) => setState(() => _selId = id),
          ),
          SizedBox(height: 12.h),
          _legend(),
          ClubTableDetail(table: sel),
          SizedBox(height: 12.h),
          Text(
            '가격 및 예약 조건은 요일·이벤트에 따라 변동될 수 있습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11.sp,
              height: 16 / 11,
              color: VybeColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  // ── 범례 ──
  Widget _legend() {
    const items = [('VVIP', '100만'), ('VIP', '50만'), ('STD', '20만')];
    return Padding(
      padding: EdgeInsets.only(left: 2.w, right: 2.w),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 8.h,
        children: [
          for (final (tierKey, price) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9.r,
                  height: 9.r,
                  decoration: BoxDecoration(
                    color: kTableTiers[tierKey]!.dot,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  kTableTiers[tierKey]!.name,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: VybeColors.gray400,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '$price~',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 홈 탭 '테이블' 글래스 카드에 들어가는 티어 3줄 요약.
///
/// 디자인 club_glass_tabs.jsx(CGTables) — 플로어맵 없이 티어별
/// `{n}석 · 최소 {m}인` + 대표 가격만 보여주고, 전체는 가격표 화면으로 넘긴다.
/// 데이터(kTableTiers·kClubFloorTables)가 이 파일에 있어 여기에 함께 둔다.
class TableTierSummary extends StatelessWidget {
  const TableTierSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final keys = kTableTiers.keys.where(
      (k) => kClubFloorTables.any((t) => t.tierKey == k),
    );

    return Column(
      children: [
        for (final key in keys) ...[
          Builder(
            builder: (_) {
              final tier = kTableTiers[key]!;
              final rows = kClubFloorTables
                  .where((t) => t.tierKey == key)
                  .toList();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: tier.soft,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: tier.ring),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: tier.dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 46.w,
                      child: Text(
                        tier.short,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: tier.color,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${rows.length}석 · 최소 ${rows.first.minPeople}인',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12.sp,
                          height: 14 / 12,
                          color: const Color(0xADFFFFFF),
                        ),
                      ),
                    ),
                    Text(
                      rows.first.price,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }
}
