import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_data.dart';

// 선택한 테이블 상세 — 등급·수용 인원·가격.

// ── 선택 자리 상세 카드 ──
class ClubTableDetail extends StatelessWidget {
  final ClubTable table;
  const ClubTableDetail({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final tier = kTableTiers[table.tierKey]!;
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

// ============================================================================
// 티어 요약 (클럽 상세 홈 탭)
// ============================================================================
