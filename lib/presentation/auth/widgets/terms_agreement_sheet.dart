import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/terms/terms_detail_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';

class _TermsItem {
  final String title;
  final bool required;
  bool checked = false;

  _TermsItem({required this.title, required this.required});
}

/// 약관 동의 바텀시트
///
/// 필수 3개 항목이 모두 체크되어야 '확인' 버튼 활성화
/// '>' 버튼 탭 시 [TermsDetailScreen] 으로 이동
/// [onConfirmed]: 확인 버튼 탭 후 시트가 닫힌 뒤 호출되는 콜백
///
/// Figma node: 2151:7534 / 2151:7542 (전체 동의 완료 상태)
class TermsAgreementSheet extends StatefulWidget {
  final VoidCallback? onConfirmed;

  const TermsAgreementSheet({super.key, this.onConfirmed});

  @override
  State<TermsAgreementSheet> createState() => _TermsAgreementSheetState();
}

class _TermsAgreementSheetState extends State<TermsAgreementSheet> {
  final List<_TermsItem> _items = [
    _TermsItem(title: '개인정보 수집∙이용 동의', required: true),
    _TermsItem(title: '만 19세 이상입니다', required: true),
    _TermsItem(title: '서비스 이용약관 동의', required: true),
    _TermsItem(title: '개인정보 마케팅 활용 동의', required: false),
  ];

  bool get _allChecked => _items.every((item) => item.checked);
  bool get _allRequiredChecked =>
      _items.where((item) => item.required).every((item) => item.checked);

  void _toggleAll() {
    final newValue = !_allChecked;
    setState(() {
      for (final item in _items) {
        item.checked = newValue;
      }
    });
  }

  void _toggleItem(int index) {
    setState(() => _items[index].checked = !_items[index].checked);
  }

  void _openDetail(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsDetailScreen(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: VybeColors.gray800,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        60.h,
        20.w,
        40.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 약관 항목 영역 ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀
                  Text(
                    '서비스 이용을 위해 동의가 필요해요.',
                    style: VybeTypography.heading4.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 36.h),
                  // 전체 동의하기
                  GestureDetector(
                    onTap: _toggleAll,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          _allChecked
                              ? 'assets/icons/common/conditions/box_checked.svg'
                              : 'assets/icons/common/conditions/box_unchecked.svg',
                          width: 16.r,
                          height: 16.r,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '전체 동의하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 20.sp,
                            color: VybeColors.gray200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 36.h),
                  // 개별 항목 목록
                  Column(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < _items.length - 1 ? 16.h : 0,
                        ),
                        child: Row(
                          children: [
                            // 체크 아이콘 (체크 토글)
                            GestureDetector(
                              onTap: () => _toggleItem(index),
                              child: SvgPicture.asset(
                                item.checked
                                    ? 'assets/icons/common/conditions/check_checked.svg'
                                    : 'assets/icons/common/conditions/check_unchecked.svg',
                                width: 16.r,
                                height: 16.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // 텍스트 (체크 토글)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _toggleItem(index),
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Text(
                                      item.title,
                                      style: VybeTypography.body2.copyWith(
                                        color: const Color(0xFFE4E4E5),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      item.required ? '(필수)' : '(선택)',
                                      style: VybeTypography.body3.copyWith(
                                        color: VybeColors.gray500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 꺽쇄 아이콘 (약관 상세 보기)
                            GestureDetector(
                              onTap: () => _openDetail(item.title),
                              child: SvgPicture.asset(
                                'assets/icons/common/conditions/show_more_conditions.svg',
                                width: 24.r,
                                height: 24.r,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // 확인 버튼
              VybeButton(
                label: '확인',
                onTap: _allRequiredChecked
                    ? () {
                        Navigator.pop(context);
                        widget.onConfirmed?.call();
                      }
                    : null,
              ),
            ],
          ),
    );
  }
}
