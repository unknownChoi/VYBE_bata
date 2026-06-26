import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

/// Vybe 인증번호 입력 (OTP 스타일)
///
/// Figma "certificate input" 컴포넌트 기반
/// 6자리 개별 박스 스타일
///
/// - [length]: 입력 자리 수 (기본: 6)
/// - [controller]: TextEditingController
/// - [onCompleted]: 입력 완료 콜백 (length만큼 입력 시)
/// - [errorText]: 에러 메시지
/// - [enabled]: 활성화 여부
class VybeCertificateInput extends StatefulWidget {
  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onCompleted;
  final String? errorText;
  final bool enabled;

  /// true이면 등장 시 자동 포커스 → 키보드 즉시 노출
  final bool autofocus;

  const VybeCertificateInput({
    super.key,
    this.length = 6,
    this.controller,
    this.onCompleted,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<VybeCertificateInput> createState() => _VybeCertificateInputState();
}

class _VybeCertificateInputState extends State<VybeCertificateInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _code => _controller.text;

  Color _boxBorderColor(int index) {
    if (widget.errorText != null) return VybeColors.accentRed500;
    if (_isFocused) return VybeColors.mainPurple500;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Stack(
            children: [
              // Hidden text field (실제 입력 처리)
              SizedBox(
                width: 0,
                height: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  enabled: widget.enabled,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) {
                    setState(() {});
                    if (val.length == widget.length) {
                      widget.onCompleted?.call(val);
                    }
                  },
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
              // 박스 UI
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.length, (index) {
                  final char = index < _code.length ? _code[index] : '';
                  final isCurrentBox = _isFocused && index == _code.length;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < widget.length - 1 ? 11.w : 0,
                    ),
                    child: _CodeBox(
                      char: char,
                      borderColor: _boxBorderColor(index),
                      isCurrent: isCurrentBox,
                    ),
                  );
                }),
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

class _CodeBox extends StatelessWidget {
  final String char;
  final Color borderColor;
  final bool isCurrent;

  const _CodeBox({
    required this.char,
    required this.borderColor,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 43.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: VybeColors.gray800,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: char.isNotEmpty
          ? Text(
              char,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 24.sp,
                height: 26 / 24,
                letterSpacing: 24 * -0.025,
                color: VybeColors.gray200,
              ),
            )
          : isCurrent
              ? Container(
                  width: 2.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    color: VybeColors.mainPurple500,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                )
              : null,
    );
  }
}
