import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/search/data/club_search.dart';
import 'package:vybe/presentation/search/data/dummy_clubs.dart';
import 'package:vybe/presentation/search/widgets/club_list_item.dart';
import 'package:vybe/presentation/search/widgets/filter_chip_bar.dart';
import 'package:vybe/presentation/search/widgets/result_gnb.dart';

class SearchResultScreen extends StatelessWidget {
  final String query;

  const SearchResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // 테스트용: 가상 데이터(dummyClubs)에 검색 알고리즘 적용.
    final results = searchDummyClubs(dummyClubs, query);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResultGnb(query: query),
            _buildLocationRow(),
            const FilterChipBar(),
            Expanded(
              child: results.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: results.length,
                      itemBuilder: (_, i) => ClubListItem(club: results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: Text(
          "'$query' 검색 결과가 없어요",
          style: VybeTypography.body3.copyWith(color: VybeColors.gray500),
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/common/club_card/location_pin_sm.svg',
            width: 16.r,
            height: 16.r,
          ),
          SizedBox(width: 4.w),
          Text(
            '내 주변 검색',
            style: VybeTypography.body3.copyWith(color: VybeColors.gray200),
          ),
        ],
      ),
    );
  }
}
