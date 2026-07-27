import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

// 테이블 가격 섹션 — 클럽 상세 홈 탭.
// claude.ai/design club_detail.html (tables.jsx) 디자인 기반. 프론트 전용(하드코딩).
// 자리 선택 → 플로어맵 하이라이트 + 상세 카드 갱신.

// ── 티어 메타 ──
class _Tier {
  final String name; // 상세 배지 라벨
  final String short; // 플로어맵 표시 라벨
  final Color color; // 텍스트 accent
  final Color dot; // 범례 dot / 선택 border
  final Color selBg; // 선택 배경
  final Color soft; // 미선택 배경
  final Color ring; // 미선택 border
  const _Tier({
    required this.name,
    required this.short,
    required this.color,
    required this.dot,
    required this.selBg,
    required this.soft,
    required this.ring,
  });
}

const _tiers = <String, _Tier>{
  'VVIP': _Tier(
    name: 'VVIP',
    short: 'VVIP',
    color: Color(0xFFC8A8FF),
    dot: VybeColors.mainPurple500,
    selBg: VybeColors.mainPurple500,
    soft: Color(0x297731FE), // rgba(119,49,254,0.16)
    ring: Color(0x807731FE), // rgba(119,49,254,0.5)
  ),
  'VIP': _Tier(
    name: 'VIP',
    short: 'VIP',
    color: Color(0xFF8FB5FF),
    dot: VybeColors.accentBlue500,
    selBg: VybeColors.accentBlue500,
    soft: Color(0x242B6BFF), // rgba(43,107,255,0.14)
    ring: Color(0x802B6BFF), // rgba(43,107,255,0.5)
  ),
  'STD': _Tier(
    name: 'STANDARD',
    short: 'STD',
    color: VybeColors.gray300,
    dot: VybeColors.gray500,
    selBg: VybeColors.gray700,
    soft: Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
    ring: Color(0x33FFFFFF), // rgba(255,255,255,0.2)
  ),
};

// ── 자리 데이터 ──
class _Table {
  final String id;
  final String tierKey;
  final String name;
  final String desc;
  final String price; // 플로어맵 표시 (예 '100만')
  final int minPeople;
  final int minBottles;
  final String minSpend; // 상세 (예 '1,000,000원')
  // 위치: left/right 는 컨테이너 너비 대비 비율, top 은 px(393 기준).
  final double? left;
  final double? right;
  final double top;
  const _Table({
    required this.id,
    required this.tierKey,
    required this.name,
    required this.desc,
    required this.price,
    required this.minPeople,
    required this.minBottles,
    required this.minSpend,
    this.left,
    this.right,
    required this.top,
  });
}

const _floor = <_Table>[
  _Table(
    id: 'S1',
    tierKey: 'VVIP',
    name: '스테이지 프론트 A',
    desc: '무대 바로 앞 · 최고의 시야',
    price: '100만',
    minPeople: 8,
    minBottles: 3,
    minSpend: '1,000,000원',
    left: 0.05,
    top: 62,
  ),
  _Table(
    id: 'S2',
    tierKey: 'VVIP',
    name: '스테이지 프론트 B',
    desc: '무대 바로 앞 · 최고의 시야',
    price: '100만',
    minPeople: 8,
    minBottles: 3,
    minSpend: '1,000,000원',
    right: 0.05,
    top: 62,
  ),
  _Table(
    id: 'V1',
    tierKey: 'VIP',
    name: '센터 사이드 1',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    left: 0.03,
    top: 126,
  ),
  _Table(
    id: 'V2',
    tierKey: 'VIP',
    name: '센터 사이드 2',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    right: 0.03,
    top: 126,
  ),
  _Table(
    id: 'V3',
    tierKey: 'VIP',
    name: '센터 사이드 3',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    left: 0.03,
    top: 188,
  ),
  _Table(
    id: 'V4',
    tierKey: 'VIP',
    name: '센터 사이드 4',
    desc: '플로어 옆 · 활기찬 자리',
    price: '50만',
    minPeople: 6,
    minBottles: 2,
    minSpend: '500,000원',
    right: 0.03,
    top: 188,
  ),
  _Table(
    id: 'T1',
    tierKey: 'STD',
    name: '바 라운지 1',
    desc: '바 근처 · 편안한 자리',
    price: '20만',
    minPeople: 4,
    minBottles: 1,
    minSpend: '200,000원',
    left: 0.04,
    top: 288,
  ),
  _Table(
    id: 'T2',
    tierKey: 'STD',
    name: '바 라운지 2',
    desc: '바 근처 · 편안한 자리',
    price: '20만',
    minPeople: 4,
    minBottles: 1,
    minSpend: '200,000원',
    left: 0.37,
    top: 288,
  ),
  _Table(
    id: 'T3',
    tierKey: 'STD',
    name: '바 라운지 3',
    desc: '바 근처 · 편안한 자리',
    price: '20만',
    minPeople: 4,
    minBottles: 1,
    minSpend: '200,000원',
    right: 0.04,
    top: 288,
  ),
];

class TablePricingSection extends StatefulWidget {
  const TablePricingSection({super.key});

  @override
  State<TablePricingSection> createState() => _TablePricingSectionState();
}

class _TablePricingSectionState extends State<TablePricingSection> {
  String _selId = 'S1';

  @override
  Widget build(BuildContext context) {
    final sel = _floor.firstWhere(
      (t) => t.id == _selId,
      orElse: () => _floor.first,
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
          _FloorMap(
            selId: _selId,
            onSelect: (id) => setState(() => _selId = id),
          ),
          SizedBox(height: 12.h),
          _legend(),
          _TableDetail(table: sel),
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
                    color: _tiers[tierKey]!.dot,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  _tiers[tierKey]!.name,
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

// ── 플로어맵 ──
class _FloorMap extends StatelessWidget {
  final String selId;
  final ValueChanged<String> onSelect;
  const _FloorMap({required this.selId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Container(
          height: 384.h,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: VybeColors.gray800),
            gradient: const RadialGradient(
              center: Alignment(0, -1),
              radius: 1.1,
              colors: [Color(0xFF1B1B22), Color(0xFF101014)],
              stops: [0.0, 0.72],
            ),
          ),
          child: Stack(
            children: [
              // 스테이지
              Positioned(
                top: 12.h,
                left: w * 0.07,
                right: w * 0.07,
                child: Container(
                  height: 40.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0x807731FE)),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x597731FE), Color(0x0F7731FE)],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.album_outlined,
                        size: 15.r,
                        color: const Color(0xFFC8A8FF),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'DJ BOOTH · STAGE',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.96,
                          color: const Color(0xFFC8A8FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 댄스 플로어
              Positioned(
                top: 118.h,
                left: w * 0.27,
                width: w * 0.46,
                child: Container(
                  height: 150.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: const Color(0x04FFFFFF),
                    border: Border.all(color: VybeColors.gray700, width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _floorLabel('DANCE'),
                      SizedBox(height: 3.h),
                      _floorLabel('FLOOR'),
                      SizedBox(height: 4.h),
                      Text(
                        '스탠딩',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10.sp,
                          color: VybeColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 바
              Positioned(
                bottom: 12.h,
                left: w * 0.07,
                right: w * 0.07,
                child: Container(
                  height: 34.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: const Color(0x0AFFFFFF),
                    border: Border.all(color: VybeColors.gray800),
                  ),
                  child: Text(
                    'BAR',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.32,
                      color: VybeColors.gray400,
                    ),
                  ),
                ),
              ),
              // 테이블들
              for (final t in _floor)
                Positioned(
                  top: t.top.h,
                  left: t.left != null ? w * t.left! : null,
                  right: t.right != null ? w * t.right! : null,
                  child: _FloorTable(
                    table: t,
                    selected: selId == t.id,
                    onTap: () => onSelect(t.id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _floorLabel(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.76,
      color: VybeColors.gray500,
    ),
  );
}

// ── 플로어맵 개별 테이블 ──
class _FloorTable extends StatelessWidget {
  final _Table table;
  final bool selected;
  final VoidCallback onTap;
  const _FloorTable({
    required this.table,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tier = _tiers[table.tierKey]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.07 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 64.w,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected ? tier.selBg : tier.soft,
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(color: selected ? tier.dot : tier.ring),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: tier.ring,
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
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
                  color: selected ? const Color(0xE0FFFFFF) : tier.color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                table.price,
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
    );
  }
}

// ── 선택 자리 상세 카드 ──
class _TableDetail extends StatelessWidget {
  final _Table table;
  const _TableDetail({required this.table});

  @override
  Widget build(BuildContext context) {
    final tier = _tiers[table.tierKey]!;
    return Container(
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: VybeColors.gray900,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: tier.soft,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  tier.name,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.33,
                    color: tier.color,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  table.name,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          Text(
            table.desc,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              height: 15 / 12,
              color: VybeColors.gray500,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _reqStat(
                  Icons.people_outline_rounded,
                  '최소 인원',
                  '${table.minPeople}인',
                  tier.color,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _reqStat(
                  Icons.local_bar_outlined,
                  '최소 보틀',
                  '${table.minBottles}병',
                  tier.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최소 주문 금액',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  height: 15 / 12,
                  color: VybeColors.gray500,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    table.minSpend,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 24.sp,
                      height: 26 / 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '~',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.sp,
                      color: VybeColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: tier.soft,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: tier.ring),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 15.r,
                    color: tier.color,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        height: 18 / 12,
                        color: VybeColors.gray200,
                      ),
                      children: [
                        const TextSpan(text: '최소 '),
                        TextSpan(
                          text: '${table.minPeople}인',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: tier.color,
                          ),
                        ),
                        const TextSpan(text: '부터, 보틀 '),
                        TextSpan(
                          text: '${table.minBottles}병',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: tier.color,
                          ),
                        ),
                        const TextSpan(text: ' 이상 주문 시 예약 가능합니다.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reqStat(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: VybeColors.gray800),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17.r, color: iconColor),
          SizedBox(width: 9.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10.sp,
                  height: 11 / 10,
                  color: VybeColors.gray500,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
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
