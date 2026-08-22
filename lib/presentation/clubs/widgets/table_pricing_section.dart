import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/club_table_layout.dart';
import 'package:vybe/data/models/table_layout_palette.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/table_detail_sheet.dart';
import 'package:vybe/presentation/clubs/widgets/table_floor_map.dart';
import 'package:vybe/presentation/common/table_price_format.dart';

// 테이블 가격 섹션 — 배치도 + 범례 + 선택 자리 상세.
//
// 데이터는 `clubs/{clubId}/tableLayout/{clubId}` 문서 하나(업주 웹이 편집).
// 배치도가 없는 클럽은 호출부가 섹션 자체를 그리지 않는다.

class TablePricingSection extends StatefulWidget {
  final ClubTableLayout layout;

  const TablePricingSection({super.key, required this.layout});

  @override
  State<TablePricingSection> createState() => _TablePricingSectionState();
}

class _TablePricingSectionState extends State<TablePricingSection> {
  int _floorIndex = 0;
  String _selId = '';

  ClubTableLayout get _layout => widget.layout;

  TableFloor get _floor => _layout.floors[_floorIndex];

  @override
  void initState() {
    super.initState();
    _selId = _floor.tables.first.id;
  }

  void _selectFloor(int i) {
    if (i == _floorIndex) return;
    setState(() {
      _floorIndex = i;
      // 층을 바꾸면 선택도 그 층으로 옮긴다 — 다른 층 테이블의 상세가 남아 있으면
      // 배치도에는 하이라이트가 없는데 아래 카드만 채워져 있어 어긋나 보인다.
      _selId = _layout.floors[i].tables.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tables = _floor.tables;
    final sel = tables.firstWhere(
      (t) => t.id == _selId,
      orElse: () => tables.first,
    );
    final tiers = _layout.usedTiers();

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
          if (_layout.isMultiFloor) ...[
            FloorTabs(
              floors: _layout.floors,
              selectedIndex: _floorIndex,
              onSelect: _selectFloor,
            ),
            SizedBox(height: 12.h),
          ],
          ClubFloorMap(
            layout: _layout,
            floor: _floor,
            selId: sel.id,
            onSelect: (id) => setState(() => _selId = id),
          ),
          SizedBox(height: 12.h),
          _legend(tiers),
          ClubTableDetail(table: sel, tier: _layout.tierOf(sel.tierKey)),
          if (_layout.notice.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              _layout.notice,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11.sp,
                height: 16 / 11,
                color: VybeColors.gray600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 범례 — 등급별 최저가. 전 층 기준으로 센다(층을 옮겨도 기준이 흔들리지 않게).
  Widget _legend(List<TableTierDef> tiers) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 8.h,
        children: [
          for (final tier in tiers)
            Builder(
              builder: (_) {
                final style = tierStyleOf(tier.colorKey);
                final prices = _layout
                    .tablesOfTier(tier.key)
                    .map((t) => t.price)
                    .toList();
                final min = prices.isEmpty
                    ? 0
                    : prices.reduce((a, b) => a < b ? a : b);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9.r,
                      height: 9.r,
                      decoration: BoxDecoration(
                        color: style.dot,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      tier.name,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: VybeColors.gray400,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      min > 0 ? '${formatTablePriceShort(min)}~' : '문의',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
