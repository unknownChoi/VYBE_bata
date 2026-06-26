import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:vybe/presentation/search/widgets/club_list_item.dart';
import 'package:vybe/presentation/search/widgets/filter_chip_bar.dart';
import 'package:vybe/presentation/search/widgets/result_gnb.dart';

class SearchResultScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultScreen({super.key, required this.query});

  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  @override
  void initState() {
    super.initState();
    // 진입 즉시 검색 실행 (+ 검색 기록 저장).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUidProvider);
      ref
          .read(searchViewModelProvider.notifier)
          .search(widget.query, userId: uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchViewModelProvider);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResultGnb(query: widget.query),
            _buildLocationRow(),
            const FilterChipBar(),
            Expanded(
              child: resultsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: VybeColors.mainPurple500,
                  ),
                ),
                error: (_, __) => _buildMessage('검색 중 오류가 발생했어요'),
                data: (results) => results.isEmpty
                    ? _buildMessage("'${widget.query}' 검색 결과가 없어요")
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: results.length,
                        itemBuilder: (_, i) => ClubListItem(club: results[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: Text(
          text,
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
