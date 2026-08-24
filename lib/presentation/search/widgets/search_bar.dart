import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

/// 검색 화면 상단 입력창 (리퀴드 글래스).
///
/// 주변 페이지 GNB(`NearbyGnb._SearchBar`)와 같은 글래스 pill 형태 —
/// 블러 + 반투명 채움 + 우측 원형 타일(검색 아이콘 / 입력 중이면 X).
/// 주변 GNB는 탭 전용 표시 위젯이라 포커스 개념이 없지만, 여기는 실제 입력창이므로
/// 포커스 시 테두리를 라임으로 바꿔 입력 상태를 드러낸다.
class SearchInputBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// true이면 등장 시 자동 포커스 → 키보드 즉시 노출
  final bool autofocus;

  /// 검색엔진 조회 대기 중 — 우측 타일을 스피너로 바꾼다.
  /// 엔터를 눌렀는데 아무 일도 안 일어나는 것처럼 보이지 않게 하려는 표시.
  final bool busy;

  /// null이 아니면 검색창 왼쪽에 뒤로가기 화살표 노출 (push로 띄운 경우).
  final VoidCallback? onBack;

  const SearchInputBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.busy = false,
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
    final r = BorderRadius.circular(999.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: const Color(0x5C000000),
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: ClubGlass.blurSigma,
            sigmaY: ClubGlass.blurSigma,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            // 좌측 뒤로가기 글래스 버튼(VybeGlassButton size: 34)과 같은 높이.
            height: 34.h,
            padding: EdgeInsets.fromLTRB(14.w, 0, 4.w, 0),
            decoration: BoxDecoration(
              color: ClubGlass.cardFill,
              borderRadius: r,
              border: Border.all(
                color: _focused
                    ? VybeColors.mainLime500.withValues(alpha: 0.55)
                    : ClubGlass.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    autofocus: widget.autofocus,
                    cursorColor: VybeColors.mainLime500,
                    // 34 고정 높이 pill 안에서 세로 정렬이 어긋나지 않게
                    // 타이포 기본 line-height(16/14) 대신 여유 있는 값을 쓴다.
                    style: VybeTypography.body4.copyWith(
                      color: Colors.white,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    decoration: InputDecoration(
                      hintText: '클럽, 지역, 장르 검색',
                      hintStyle: VybeTypography.body4.copyWith(
                        color: ClubGlass.t3,
                        height: 1.25,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // pill 높이가 34로 줄어 기본 34 타일은 테두리에 붙는다 → 26으로 축소.
                if (widget.busy)
                  GlassCircleTile(
                    size: 26,
                    child: SizedBox(
                      width: 13.r,
                      height: 13.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: VybeColors.mainLime500,
                      ),
                    ),
                  )
                else if (_hasText)
                  GestureDetector(
                    onTap: _clear,
                    behavior: HitTestBehavior.opaque,
                    child: GlassCircleTile(
                      size: 26,
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.r,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  GlassCircleTile(
                    size: 26,
                    child: SvgPicture.asset(
                      'assets/icons/common/search.svg',
                      width: 15.r,
                      height: 15.r,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
