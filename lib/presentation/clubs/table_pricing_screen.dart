import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_section.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';

/// 테이블 가격표 전체 화면.
///
/// 디자인: table_pricing.html — 클럽 상세 홈 탭의 '테이블 · 가격표' 링크 대상.
/// 플로어맵·티어 상세는 기존 [TablePricingSection]을 그대로 재사용한다.
class TablePricingScreen extends StatelessWidget {
  final String clubName;

  const TablePricingScreen({super.key, required this.clubName});

  static Future<void> push(BuildContext context, {required String clubName}) {
    return Navigator.of(context).push(
      SwipeBackPageRoute(
        builder: (_) => TablePricingScreen(clubName: clubName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: VybeAurora()),
          SafeArea(
            child: Column(
              children: [
                const GlassTopBar(title: '테이블 가격표'),
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 28.h),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                        child: Text(
                          clubName,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const TablePricingSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
