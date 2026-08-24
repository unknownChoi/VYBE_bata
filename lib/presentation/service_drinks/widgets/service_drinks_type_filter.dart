import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';
import 'package:vybe/presentation/common/widgets/vybe_chip_filter_bar.dart';
import 'package:vybe/presentation/service_drinks/service_drinks_style.dart';

/// 음료 종류 가로 필터 칩 줄 (전체 · 양주 · 샴페인 …).
///
/// 칩 줄 자체는 입장비 무료 화면과 같은 모양이라 [VybeChipFilterBar] 로 승격했다 —
/// 여기 남는 건 이 화면의 값·색·아이콘 규칙뿐이다.
class ServiceDrinksTypeFilter extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;

  const ServiceDrinksTypeFilter({
    super.key,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return VybeChipFilterBar(
      options: kDrinkTypes,
      active: active,
      onChange: onChange,
      accent: kDrinkAccent,
      accentInk: kDrinkInk,
      // '전체'는 종류가 아니라 해제라 술잔 아이콘을 달지 않는다.
      iconOf: (type) => type == kFilterAll ? null : Icons.liquor_rounded,
    );
  }
}
