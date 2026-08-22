import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/club_table_layout.dart';
import 'package:vybe/data/models/table_layout_palette.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/table_price_format.dart';

// 선택한 테이블 상세 — 등급·가격·수용 인원·최소 주문.

/// 배치도에서 고른 자리의 상세 카드.
class ClubTableDetail extends StatelessWidget {
  final ClubTable table;
  final TableTierDef tier;

  const ClubTableDetail({super.key, required this.table, required this.tier});

  @override
  Widget build(BuildContext context) {
    final style = tierStyleOf(tier.colorKey);
    return GlassCard(
      margin: EdgeInsets.only(top: 14.h),
      padding: 16,
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: style.fill,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  tier.name,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.33,
                    color: style.text,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  table.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                formatWon(table.price),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: style.text,
                ),
              ),
            ],
          ),
          if (table.desc.isNotEmpty) ...[
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
          ],
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _reqStat(
                  Icons.people_outline_rounded,
                  '최소 인원',
                  '${table.minPeople}인',
                  style.text,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _reqStat(
                  Icons.local_bar_outlined,
                  '최소 보틀',
                  '${table.minBottles}병',
                  style.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _minSpendPanel(style),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: style.fill,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: style.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 15.r,
                    color: style.text,
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
                            color: style.text,
                          ),
                        ),
                        const TextSpan(text: '부터, 보틀 '),
                        TextSpan(
                          text: '${table.minBottles}병',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: style.text,
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
          // 업주가 남긴 자유 문구 — 있을 때만.
          if (table.note.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              table.note,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.sp,
                height: 17 / 12,
                color: VybeColors.gray400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 최소 주문 금액 — 리퀴드 글래스 패널.
  ///
  /// 부모 [GlassCard]가 이미 BackdropFilter를 걸어 뒤를 흐려 놨으므로 여기선
  /// 블러를 겹치지 않는다(중첩 BackdropFilter는 비용만 늘고 그림은 같다).
  /// 대신 채움 + 좌상단 하이라이트 + 상단 1px 광택으로 같은 유리 톤을 만든다.
  Widget _minSpendPanel(TableTierStyle style) {
    final r = BorderRadius.circular(14.r);
    return Container(
      decoration: BoxDecoration(borderRadius: r),
      // 테두리는 하이라이트 위에 그려야 선이 죽지 않는다 (GlassCard와 같은 규칙).
      foregroundDecoration: BoxDecoration(
        borderRadius: r,
        border: Border.all(color: ClubGlass.tileBorder),
      ),
      child: ClipRRect(
        borderRadius: r,
        child: ColoredBox(
          color: ClubGlass.tileFill,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // 등급 색이 우측 금액 쪽에서 옅게 번진다.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [style.fill, style.fill.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.8, -1),
                      radius: 1.1,
                      colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
                      stops: [0.0, 0.6],
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: ColoredBox(color: Color(0x29FFFFFF)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '최소 주문 금액',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        height: 15 / 12,
                        color: ClubGlass.t3,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // 금액은 업주가 넣는 값이라 자릿수를 앱이 정할 수 없다 —
                    // 1,000,000원이 24sp 로는 좁은 기기에서 넘친다. 남는 폭에 맞춰 줄인다.
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatWon(table.minSpend),
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 24.sp,
                                height: 26 / 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (table.minSpend > 0)
                              Text(
                                '~',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12.sp,
                                  color: ClubGlass.t4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reqStat(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ClubGlass.tileFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ClubGlass.tileBorder),
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
