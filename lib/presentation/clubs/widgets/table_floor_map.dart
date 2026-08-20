import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_data.dart';

// 플로어 배치도 — 테이블 위치를 상대 좌표로 그린다.

// ── 플로어맵 ──
class ClubFloorMap extends StatelessWidget {
  final String selId;
  final ValueChanged<String> onSelect;
  const ClubFloorMap({super.key, required this.selId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Container(
          height: 384.h,
          clipBehavior: Clip.hardEdge,
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
              for (final t in kClubFloorTables)
                Positioned(
                  top: t.top.h,
                  left: t.left != null ? w * t.left! : null,
                  right: t.right != null ? w * t.right! : null,
                  child: _ClubFloorTableSpot(
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
class _ClubFloorTableSpot extends StatelessWidget {
  final ClubTable table;
  final bool selected;
  final VoidCallback onTap;
  const _ClubFloorTableSpot({
    required this.table,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tier = kTableTiers[table.tierKey]!;
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
