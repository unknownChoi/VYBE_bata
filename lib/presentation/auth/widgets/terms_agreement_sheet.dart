import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/auth/terms/terms_detail_screen.dart';
import 'package:vybe/presentation/auth/widgets/signup_glass.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';

class _TermsItem {
  final String title;
  final bool required;

  /// 이 항목이 가리키는 문서. null 이면 읽을 문서가 없는 확인 항목이라
  /// 꺽쇠(전문 보기)를 그리지 않는다.
  final LegalDoc? doc;

  bool checked = false;

  _TermsItem({required this.title, required this.required, this.doc});
}

/// 약관 동의 바텀시트 (디자인 `SVTermsSheet`)
///
/// 필수 3개 항목이 모두 체크되어야 '확인' 버튼 활성화
/// '>' 버튼 탭 시 [TermsDetailScreen] 으로 이동
/// [onConfirmed]: 확인 버튼 탭 후 시트가 닫힌 뒤 호출되는 콜백
///
/// Figma node: 2151:7534 / 2151:7542 (전체 동의 완료 상태)
class TermsAgreementSheet extends StatefulWidget {
  final Future<void> Function()? onConfirmed;

  const TermsAgreementSheet({super.key, this.onConfirmed});

  @override
  State<TermsAgreementSheet> createState() => _TermsAgreementSheetState();
}

class _TermsAgreementSheetState extends State<TermsAgreementSheet> {
  // 위치기반서비스 동의가 필수인 이유 — 앱이 단말기 GPS 로 주변 클럽을 찾는데,
  // 위치정보법 제18조가 이용약관과 **별도의** 약관·동의를 요구한다.
  final List<_TermsItem> _items = [
    _TermsItem(title: '개인정보 수집·이용 동의', required: true, doc: LegalDoc.privacy),
    _TermsItem(title: '만 19세 이상입니다', required: true),
    _TermsItem(title: '서비스 이용약관 동의', required: true, doc: LegalDoc.terms),
    _TermsItem(title: '위치기반서비스 이용 동의', required: true, doc: LegalDoc.location),
    _TermsItem(title: '마케팅 정보 수신 동의', required: false, doc: LegalDoc.marketing),
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

  void _openDetail(LegalDoc doc) {
    Navigator.push(
      context,
      SwipeBackPageRoute(builder: (_) => TermsDetailScreen(doc: doc)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const lime = VybeColors.mainLime500;

    return SignupSheet(
      padH: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 24.h),
            child: Text(
              '서비스 이용을 위해\n동의가 필요해요.',
              style: VybeTypography.heading4.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),

          // ── 전체 동의하기 (박스 없는 큰 체크) ──
          GestureDetector(
            onTap: _toggleAll,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              decoration: BoxDecoration(
                color: _allChecked
                    ? lime.withValues(alpha: 0.09)
                    : RenewGlass.tileFill,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _allChecked
                      ? lime.withValues(alpha: 0.30)
                      : RenewGlass.tileBorder,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    _allChecked
                        ? 'assets/icons/common/conditions/check_checked.svg'
                        : 'assets/icons/common/conditions/check_unchecked.svg',
                    width: 20.r,
                    height: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '전체 동의하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      letterSpacing: 18 * -0.025,
                      color: _allChecked ? Colors.white : RenewGlass.t2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 개별 항목 ──
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Column(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 11.h,
                  ),
                  child: Row(
                    children: [
                      // 체크 + 텍스트 (같이 토글)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _toggleItem(index),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                item.checked
                                    ? 'assets/icons/common/conditions/box_checked.svg'
                                    : 'assets/icons/common/conditions/box_unchecked.svg',
                                width: 16.r,
                                height: 16.r,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14.sp,
                                      letterSpacing: 14 * -0.025,
                                      color: item.checked
                                          ? RenewGlass.t1
                                          : RenewGlass.t3,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: item.required ? '[필수] ' : '[선택] ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: item.required
                                              ? lime
                                              : VybeColors.gray600,
                                        ),
                                      ),
                                      TextSpan(text: item.title),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 꺽쇠 — 약관 상세 보기.
                      // 읽을 문서가 없는 항목('만 19세 이상입니다')은 자리만 비워
                      // 다른 줄의 텍스트 폭이 어긋나지 않게 한다.
                      if (item.doc case final doc?)
                        GestureDetector(
                          onTap: () => _openDetail(doc),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.all(4.r),
                            child: SvgPicture.asset(
                              'assets/icons/common/conditions/show_more_conditions.svg',
                              width: 16.r,
                              height: 16.r,
                            ),
                          ),
                        )
                      else
                        SizedBox(width: 24.r),
                    ],
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 22.h),
          VybeButton(
            label: '확인',
            glow: true,
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
