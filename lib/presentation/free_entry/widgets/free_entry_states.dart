import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/free_entry/free_entry_style.dart';

/// 목록 자리에 들어가는 로딩 스켈레톤 (카드와 같은 높이라 전환에 튀지 않는다).
class FreeEntryListSkeleton extends StatelessWidget {
  /// 스켈레톤 카드 장수.
  final int count;

  const FreeEntryListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 14.h),
          child: VybeSkel(height: kEntryCardHeight.h, radius: 18),
        ),
      ),
    );
  }
}

/// 조회 실패 / 결과 없음 안내 문구.
class FreeEntryMessage extends StatelessWidget {
  final String text;

  const FreeEntryMessage(this.text, {super.key});

  /// 조회 자체가 실패했을 때.
  const FreeEntryMessage.error({super.key}) : text = '입장비 무료 클럽을 불러오지 못했어요';

  /// 결과가 0건일 때 — 지역 필터가 걸려 있으면 그 지역을 문구에 넣는다.
  factory FreeEntryMessage.empty(String region) => FreeEntryMessage(
    region == kFilterAll ? '입장비 무료 클럽이 아직 없어요' : '$region 지역에 입장비 무료 클럽이 없어요',
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
      ),
    );
  }
}
