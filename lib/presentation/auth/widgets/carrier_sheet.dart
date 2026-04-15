import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_select_item.dart';

/// 통신사 선택 바텀시트
///
/// 국내 주요 통신사 6개 (SKT, KT, LGU+, 알뜰폰 3종) 목록을 표시한다.
/// [selected]와 일치하는 항목은 [VybeSelectItem]의 선택 스타일로 표시되며,
/// 항목 탭 시 [onSelected]를 통해 선택값을 전달한다.
class CarrierSheet extends StatelessWidget {
  /// 현재 선택된 통신사 이름. null이면 아무것도 선택되지 않은 상태.
  final String? selected;

  /// 통신사 선택 시 호출. 선택된 통신사 이름을 인자로 전달.
  final ValueChanged<String> onSelected;

  /// 선택 가능한 통신사 목록
  static const List<String> carriers = [
    'SKT',
    'KT',
    'LGU+',
    'SKT 알뜰폰',
    'KT 알뜰폰',
    'LGU+ 알뜰폰',
  ];

  const CarrierSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // VybeColors.gray800: 카드/바텀시트 배경보다 한 단계 어두운 레이어
        color: VybeColors.gray800,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 80.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '통신사를 선택해주세요.',
              // VybeTypography.heading4: SemiBold 20sp ✓
              style: VybeTypography.heading4.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(height: 24.h),
          // 통신사 목록 — 현재 선택된 항목은 highlighted 스타일로 표시
          ...carriers.map(
            (carrier) => VybeSelectItem(
              label: carrier,
              isSelected: selected == carrier,
              onTap: () => onSelected(carrier),
            ),
          ),
        ],
      ),
    );
  }
}
