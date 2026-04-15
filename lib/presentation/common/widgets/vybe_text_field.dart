import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// 입력 필드 상태
enum VybeInputState { defaultState, focused, active, filled, error, disabled }

/// Vybe 공통 텍스트 필드
///
/// Figma "input / variant=Default" 컴포넌트 기반
/// 하단 라인(bottom border)만 있는 스타일
///
/// - [hint]: 플레이스홀더 텍스트
/// - [controller]: TextEditingController
/// - [errorText]: 에러 메시지 (null이면 에러 없음)
/// - [label]: 비활성(disabled) 상태에서 표시할 레이블 텍스트
/// - [obscureText]: 비밀번호 필드 여부
/// - [keyboardType]: 키보드 타입
/// - [inputFormatters]: 입력 포맷터
/// - [onChanged]: 텍스트 변경 콜백
/// - [enabled]: 활성화 여부
class VybeTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onClear;

  const VybeTextField({
    super.key,
    this.hint,
    this.controller,
    this.errorText,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.onClear,
  });

  @override
  State<VybeTextField> createState() => _VybeTextFieldState();
}

class _VybeTextFieldState extends State<VybeTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChange);
    _hasText = (widget.controller?.text ?? '').isNotEmpty;
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChange() {
    final hasText = (widget.controller?.text ?? '').isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  Color get _lineColor {
    if (!widget.enabled) return VybeColors.gray700;
    if (widget.errorText != null) return VybeColors.accentRed500;
    if (_isFocused || _hasText) return VybeColors.mainPurple500;
    return VybeColors.gray700;
  }

  Color get _textColor {
    if (widget.errorText != null) return VybeColors.accentRed700;
    return VybeColors.gray200;
  }

  bool get _showClear => widget.enabled && _hasText && widget.onClear != null;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return _DisabledField(
        label: widget.label,
        value: widget.controller?.text ?? '',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _lineColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  // iOS 16+의 SystemContextMenu는 활성 텍스트 입력 연결이 없으면
                  // assertion 오류 발생 → AdaptiveTextSelectionToolbar 직접 사용
                  contextMenuBuilder: (context, editableTextState) =>
                      AdaptiveTextSelectionToolbar(
                        anchors: editableTextState.contextMenuAnchors,
                        children:
                            AdaptiveTextSelectionToolbar.getAdaptiveButtons(
                          context,
                          editableTextState.contextMenuButtonItems,
                        ).toList(),
                      ),
                  onChanged: (val) {
                    setState(() => _hasText = val.isNotEmpty);
                    widget.onChanged?.call(val);
                  },
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 24.sp,
                    height: 26 / 24,
                    letterSpacing: 24 * -0.025,
                    color: _textColor,
                  ),
                  cursorColor: VybeColors.mainPurple500,
                  cursorHeight: 26.h,
                  cursorWidth: 2.w,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      height: 26 / 24,
                      letterSpacing: 24 * -0.025,
                      color: VybeColors.gray600,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  ),
                ),
              ),
              if (_showClear)
                GestureDetector(
                  onTap: () {
                    widget.controller?.clear();
                    setState(() => _hasText = false);
                    widget.onClear?.call();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Icon(
                      Icons.cancel,
                      size: 20.r,
                      color: VybeColors.gray500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: 8.h),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 14 / 12,
              letterSpacing: 12 * -0.025,
              color: VybeColors.accentRed500,
            ),
          ),
        ],
      ],
    );
  }
}

/// disabled 상태 전용 레이아웃 (레이블 + 값 + 회색 하단 라인)
class _DisabledField extends StatelessWidget {
  final String? label;
  final String value;

  const _DisabledField({this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 12 / 12,
              color: VybeColors.gray600,
            ),
          ),
        if (label != null) SizedBox(height: 8.h),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: VybeColors.gray700, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 24.sp,
              height: 26 / 24,
              letterSpacing: 24 * -0.025,
              color: VybeColors.gray600,
            ),
          ),
        ),
      ],
    );
  }
}
