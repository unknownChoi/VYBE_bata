import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/club_table_layout.dart';
import 'package:vybe/data/models/table_layout_palette.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/table_price_format.dart';

// 플로어 배치도 — 격자 셀 좌표를 픽셀로 펼쳐 그린다.
//
// 셀 크기는 **폭에서만** 구한다(`maxWidth / cols`). 높이로 따로 구하면 두 값이
// 미세하게 달라져 아래로 갈수록 도형이 어긋난다. 셀이 정사각이므로 캔버스 높이는
// `cell * rows` 로 따라온다 — 업주 웹도 같은 식을 써야 같은 그림이 나온다.

/// 배치도 캔버스. 층 하나를 그린다.
class ClubFloorMap extends StatelessWidget {
  final ClubTableLayout layout;
  final TableFloor floor;

  /// 선택된 테이블 [ClubTable.id].
  final String selId;
  final ValueChanged<String> onSelect;

  const ClubFloorMap({
    super.key,
    required this.layout,
    required this.floor,
    required this.selId,
    required this.onSelect,
  });

  /// 캔버스 안쪽 여백 — 테두리에 도형이 닿아 붙어 보이지 않게.
  ///
  /// ⚠ 이 값이 격자 폭을 깎아 셀 크기를 줄인다 — `kMaxGridCols` 의 탭 타겟 계산에
  ///   같이 들어가 있다. 키우려면 열 상한을 다시 계산할 것.
  static const double _pad = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(_pad.w),
      // 테두리는 자식 위에 — decoration 에 두면 코너 호에서 선이 덮인다.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const RadialGradient(
          center: Alignment(0, -1),
          radius: 1.1,
          colors: [Color(0xFF1B1B22), Color(0xFF101014)],
          stops: [0.0, 0.72],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = constraints.maxWidth / floor.cols;
          return SizedBox(
            width: constraints.maxWidth,
            height: cell * floor.rows,
            child: Stack(
              children: [
                // 구조물이 먼저 — 테이블이 항상 위에 온다.
                for (final f in floor.fixtures)
                  _place(f.rect, cell, child: _FixtureBox(fixture: f)),
                for (final t in floor.tables)
                  _place(
                    t.rect,
                    cell,
                    child: _TableSpot(
                      table: t,
                      tier: layout.tierOf(t.tierKey),
                      selected: selId == t.id,
                      onTap: () => onSelect(t.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _place(GridRect r, double cell, {required Widget child}) => Positioned(
    left: r.col * cell,
    top: r.row * cell,
    width: r.colSpan * cell,
    height: r.rowSpan * cell,
    child: child,
  );
}

// ── 구조물 ──

class _FixtureBox extends StatelessWidget {
  final FloorFixture fixture;

  const _FixtureBox({required this.fixture});

  @override
  Widget build(BuildContext context) {
    final style = fixtureStyleOf(fixture.type.key);
    final label = fixture.displayLabel;

    return Padding(
      padding: EdgeInsets.all(1.5.w),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: style.fill,
          border: Border.all(color: style.border),
        ),
        child: label.isEmpty
            ? null
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (style.icon != null) ...[
                      Icon(style.icon, size: 14.r, color: style.text),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: style.text,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── 테이블 ──

class _TableSpot extends StatelessWidget {
  final ClubTable table;
  final TableTierDef tier;
  final bool selected;
  final VoidCallback onTap;

  const _TableSpot({
    required this.table,
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = tierStyleOf(tier.colorKey);
    final radius = table.shape == TableShape.circle
        ? BorderRadius.circular(999.r)
        : BorderRadius.circular(9.r);

    return GestureDetector(
      onTap: onTap,
      // 도형 사이 여백(2px)까지 탭을 받는다 — 격자 규칙상 도형 자체가 44px 이상이라
      // 여기서 크기를 더 키우면 옆 테이블의 탭을 가로챈다.
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: selected ? style.selectedFill : style.fill,
            borderRadius: radius,
            border: Border.all(
              color: selected ? style.dot : style.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: style.border,
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tier.short,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 9.sp,
                    height: 10 / 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.27,
                    color: selected ? const Color(0xE0FFFFFF) : style.text,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  formatTablePriceShort(table.price),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13.sp,
                    height: 14 / 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 층 전환 탭 ──

/// 층이 2개 이상일 때만 배치도 위에 붙는다.
class FloorTabs extends StatelessWidget {
  final List<TableFloor> floors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const FloorTabs({
    super.key,
    required this.floors,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Row(
        children: [
          for (var i = 0; i < floors.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 34.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? VybeColors.mainPurple500
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Text(
                    floors[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: i == selectedIndex
                          ? Colors.white
                          : VybeColors.gray400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
