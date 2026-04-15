import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_checkbox.dart';

/// 약관 항목 모델
class VybeTermsItem {
  final String id;
  final String label;
  final bool isRequired;
  final VoidCallback? onDetail;

  const VybeTermsItem({
    required this.id,
    required this.label,
    this.isRequired = true,
    this.onDetail,
  });
}

/// Vybe 약관 동의 리스트
///
/// Figma "Frame103" 컴포넌트 기반
///
/// - [title]: 상단 제목 (기본: '서비스 이용을 위해 동의가 필요해요.')
/// - [items]: 약관 항목 목록
/// - [checkedIds]: 현재 체크된 항목 id 집합
/// - [onChanged]: 체크 상태 변경 콜백 (id, isChecked)
class VybeTermsList extends StatelessWidget {
  final String title;
  final List<VybeTermsItem> items;
  final Set<String> checkedIds;
  final void Function(String id, bool isChecked) onChanged;

  const VybeTermsList({
    super.key,
    this.title = '서비스 이용을 위해 동의가 필요해요.',
    required this.items,
    required this.checkedIds,
    required this.onChanged,
  });

  bool get _isAllChecked => items.every((item) => checkedIds.contains(item.id));

  void _onAllChanged(bool value) {
    for (final item in items) {
      onChanged(item.id, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            height: 22 / 20,
            letterSpacing: 20 * -0.025,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 36.h),

        // 전체 동의하기
        VybeCheckbox(
          value: _isAllChecked,
          onChanged: _onAllChanged,
          label: '전체 동의하기',
        ),
        SizedBox(height: 36.h),

        // 개별 항목 목록
        Column(
          children: items.map((item) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: item != items.last ? 16.h : 0,
              ),
              child: _TermsRow(
                item: item,
                isChecked: checkedIds.contains(item.id),
                onChanged: (val) => onChanged(item.id, val),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  final VybeTermsItem item;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _TermsRow({
    required this.item,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 체크마크 아이콘 (IcRoundCheck 스타일)
        GestureDetector(
          onTap: () => onChanged(!isChecked),
          child: Icon(
            Icons.check_rounded,
            size: 16.r,
            color: isChecked ? VybeColors.mainLime500 : VybeColors.gray600,
          ),
        ),
        SizedBox(width: 12.w),

        // 약관명 + 필수/선택 뱃지
        Expanded(
          child: Row(
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 18.sp,
                  height: 20 / 18,
                  letterSpacing: 18 * -0.025,
                  color: const Color(0xFFE4E4E5),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                item.isRequired ? '(필수)' : '(선택)',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 18 / 16,
                  letterSpacing: 16 * -0.05,
                  color: const Color(0xFF8F8F8F),
                ),
              ),
            ],
          ),
        ),

        // 상세 보기 버튼
        if (item.onDetail != null)
          GestureDetector(
            onTap: item.onDetail,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 24.r,
              color: VybeColors.gray500,
            ),
          ),
      ],
    );
  }
}
