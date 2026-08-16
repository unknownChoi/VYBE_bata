import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_underline.dart';

/// 생년월일 입력 위젯 (주민등록번호 앞 7자리 형식)
///
/// [YYMMDD] — [●]●●●●●
/// - 앞 6자리: 생년월일 숫자 직접 표시 (YYMMDD), 자간 최대화
/// - 뒷 1자리: 성별 코드 + 나머지 6개 고정 점
/// - 두 영역이 하나의 bottom border를 공유
///
/// 자동 포커스 이동: 앞 6자리 입력 완료 시 → 뒷 자리로 자동 이동
class BirthInput extends StatefulWidget {
  /// 생년월일 6자리 컨트롤러 (YYMMDD)
  final TextEditingController frontCtrl;

  /// 성별 코드 1자리 컨트롤러
  final TextEditingController backCtrl;

  final FocusNode frontFocus;
  final FocusNode backFocus;

  /// true이면 입력 불가 (완료 단계 표시용)
  final bool readOnly;

  /// 미성년자 에러 상태 — border·텍스트·점 색상을 빨간색으로 변경
  final bool isError;

  /// readOnly 상태에서 필드 탭 시 호출되는 콜백
  ///
  /// readOnly TextField는 외부 GestureDetector로 이벤트가 전달되지 않으므로
  /// 이 콜백을 통해 앞·뒤 필드 탭을 모두 수신한다.
  final VoidCallback? onTap;

  const BirthInput({
    super.key,
    required this.frontCtrl,
    required this.backCtrl,
    required this.frontFocus,
    required this.backFocus,
    this.readOnly = false,
    this.isError = false,
    this.onTap,
  });

  @override
  State<BirthInput> createState() => _BirthInputState();
}

class _BirthInputState extends State<BirthInput> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // 앞·뒤 필드 중 하나라도 포커스되면 border를 purple로 변경
    widget.frontFocus.addListener(_onFocusChange);
    widget.backFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.frontFocus.hasFocus || widget.backFocus.hasFocus;
    });
  }

  @override
  void dispose() {
    widget.frontFocus.removeListener(_onFocusChange);
    widget.backFocus.removeListener(_onFocusChange);
    super.dispose();
  }

  /// 하단 border 색상
  /// - 에러: accentRed500
  /// - 포커스 중: mainPurple500
  /// - 그 외: gray700
  Color get _lineColor {
    if (widget.isError) return VybeColors.accentRed500;
    if (!widget.readOnly && _isFocused) return VybeColors.mainPurple500;
    return VybeColors.gray700;
  }

  /// 입력 텍스트 색상
  /// - 에러: accentRed700
  /// - 포커스 중: gray200
  /// - 포커스 아웃: gray600
  Color get _textColor {
    if (widget.isError) return VybeColors.accentRed700;
    return _isFocused ? VybeColors.gray200 : VybeColors.gray600;
  }

  /// 앞 6자리 텍스트 스타일
  ///
  /// Figma 기준 자간: tracking-[10.56px] → 각 자리가 최대한 벌어지도록
  /// VybeTypography에 24sp Medium이 없으므로 하드코딩
  TextStyle get _frontInputStyle => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        fontSize: 24.sp,
        height: 26 / 24,
        letterSpacing: 10.56.sp,
        color: _textColor,
      );

  /// 뒷 자리(성별 코드) 텍스트 스타일 — 일반 자간 유지
  TextStyle get _backInputStyle => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        fontSize: 24.sp,
        height: 26 / 24,
        letterSpacing: 24 * -0.025,
        color: _textColor,
      );

  /// hint 텍스트 스타일
  TextStyle get _hintStyle => TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        fontSize: 24.sp,
        height: 26 / 24,
        letterSpacing: 24 * -0.025,
        color: VybeColors.gray600,
      );

  /// 나머지 6자리 자리표시 점 — 에러일 때만 붉게 물든다(디자인 `SVBirth`).
  Color get _dotColor => widget.isError
      ? VybeColors.accentRed500.withValues(alpha: 0.55)
      : VybeColors.gray700;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
      Padding(
      padding: EdgeInsets.fromLTRB(0, 4.h, 0, 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 앞 6자리 (YYMMDD, 자간 최대화) ──
          Expanded(
            child: TextField(
              controller: widget.frontCtrl,
              focusNode: widget.frontFocus,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: _frontInputStyle,
              cursorColor: VybeColors.mainPurple500,
              cursorHeight: 26.h,
              cursorWidth: 2.w,
              showCursor: !widget.readOnly,
              contextMenuBuilder: (context, editableTextState) =>
                  AdaptiveTextSelectionToolbar(
                    anchors: editableTextState.contextMenuAnchors,
                    children:
                        AdaptiveTextSelectionToolbar.getAdaptiveButtons(
                      context,
                      editableTextState.contextMenuButtonItems,
                    ).toList(),
                  ),
              decoration: InputDecoration(
                hintText: '생년월일 6자리',
                hintStyle: _hintStyle,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // ── 구분선 ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text('—', style: _hintStyle),
          ),

          // ── 뒷 자리 (성별 코드 1자리 + 고정 점 6개) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 성별 코드: 실제 입력 영역
              SizedBox(
                width: 20.w,
                child: TextField(
                  controller: widget.backCtrl,
                  focusNode: widget.backFocus,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: _backInputStyle,
                  cursorColor: VybeColors.mainPurple500,
                  cursorHeight: 26.h,
                  cursorWidth: 2.w,
                  showCursor: !widget.readOnly,
                  contextMenuBuilder: (context, editableTextState) =>
                      AdaptiveTextSelectionToolbar(
                        anchors: editableTextState.contextMenuAnchors,
                        children:
                            AdaptiveTextSelectionToolbar.getAdaptiveButtons(
                          context,
                          editableTextState.contextMenuButtonItems,
                        ).toList(),
                      ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // 나머지 6자리를 나타내는 고정 점
              ...List.generate(
                6,
                (_) => Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: _dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 전체 삭제 버튼 (한 글자라도 입력 시 표시) ──
          if (!widget.readOnly &&
              (widget.frontCtrl.text.isNotEmpty ||
                  widget.backCtrl.text.isNotEmpty)) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                widget.frontCtrl.clear();
                widget.backCtrl.clear();
              },
              child: SizedBox(
                width: 20.r,
                height: 20.r,
                child: SvgPicture.asset(
                  'assets/icons/auth/delete_all_text.svg',
                  width: 18.r,
                  height: 18.r,
                ),
              ),
            ),
          ],
        ],
      ),
      ),
      VybeUnderline(
        color: _lineColor,
        glow: !widget.readOnly && _isFocused && !widget.isError,
      ),
      ],
    );
  }
}
