import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

class SearchInputBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// true이면 등장 시 자동 포커스 → 키보드 즉시 노출
  final bool autofocus;

  /// null이 아니면 검색창 왼쪽에 뒤로가기 화살표 노출 (push로 띄운 경우).
  final VoidCallback? onBack;

  const SearchInputBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.onBack,
  });

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  bool _focused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChange);
    _hasText = (widget.controller?.text ?? '').isNotEmpty;
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    final f = widget.focusNode?.hasFocus ?? false;
    if (f != _focused) setState(() => _focused = f);
  }

  void _onTextChange() {
    final h = (widget.controller?.text ?? '').isNotEmpty;
    if (h != _hasText) setState(() => _hasText = h);
  }

  void _clear() {
    widget.controller?.clear();
    widget.onChanged?.call('');
    widget.focusNode?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
      child: Row(
        children: [
          if (widget.onBack != null) ...[
            VybeGlassButton(
              onTap: widget.onBack!,
              size: 34,
              iconSize: 18,
              hitSize: 38,
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(child: _buildField()),
        ],
      ),
    );
  }

  Widget _buildField() {
    final accent = _focused ? VybeColors.mainLime500 : VybeColors.gray400;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: VybeColors.gray800,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: _focused ? VybeColors.mainLime500 : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: VybeColors.mainLime500.withValues(alpha: 0.12),
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/common/search.svg',
            width: 18.r,
            height: 18.r,
            colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              cursorColor: VybeColors.mainLime500,
              style: VybeTypography.body3.copyWith(color: Colors.white),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: '지역 / 클럽 이름 검색',
                hintStyle:
                    VybeTypography.body3.copyWith(color: VybeColors.gray500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_hasText) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _clear,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 18.r,
                height: 18.r,
                decoration: const BoxDecoration(
                  color: VybeColors.gray700,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 12.r,
                  color: VybeColors.gray300,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
