import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/clubs/widgets/table_pricing_section.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';

/// 테이블 가격표 전체 화면.
///
/// 디자인: table_pricing.html — 클럽 상세 홈 탭의 '테이블 · 가격표' 링크 대상.
/// 배치도·티어 상세는 [TablePricingSection]을 그대로 재사용한다.
///
/// 데이터는 `clubTableLayoutProvider` 하나 — 클럽 상세 홈 탭이 이미 읽어 둬서
/// 여기서 다시 watch 해도 Firestore read 가 추가로 들지 않는다(같은 provider 캐시).
class TablePricingScreen extends ConsumerWidget {
  final String clubId;
  final String clubName;

  const TablePricingScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  static Future<void> push(
    BuildContext context, {
    required String clubId,
    required String clubName,
  }) {
    return Navigator.of(context).push(
      SwipeBackPageRoute(
        builder: (_) =>
            TablePricingScreen(clubId: clubId, clubName: clubName),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutAsync = ref.watch(clubTableLayoutProvider(clubId));
    final layout = layoutAsync.value;

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
                  child: layout == null
                      ? Center(
                          child: layoutAsync.isLoading
                              ? const VybeSpinner(size: 40)
                              : Text(
                                  '등록된 테이블 정보가 없어요',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 13.sp,
                                    color: VybeColors.gray500,
                                  ),
                                ),
                        )
                      : ListView(
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
                            TablePricingSection(layout: layout),
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
