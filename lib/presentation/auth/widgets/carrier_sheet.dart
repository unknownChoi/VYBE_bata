import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/widgets/signup_glass.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';

// 디자인 `carrier_sheet.jsx` 수치
/// 항목 한 줄 높이 (디자인 height 54)
const double _rowHeight = 54;

/// 시트 좌우 여백(24) 안쪽 추가 들여쓰기 (디자인 padding '0 4px')
const double _rowInset = 4;

/// 선택 표시 체크 아이콘 크기
const double _checkSize = 18;

/// 눌림 색 전환 (디자인 `transition: color .14s`)
const Duration _pressFade = Duration(milliseconds: 140);

/// 통신사 선택 바텀시트 (디자인 `carrier_sheet.jsx`)
///
/// 국내 주요 통신사 6개 (SKT, KT, LGU+, 알뜰폰 3종) 목록을 표시한다.
/// [selected]와 일치하는 항목은 라임 톤으로 강조되며,
/// 항목 탭 시 [onSelected]를 통해 선택값을 전달한다.
///
/// ⚠ 다른 회원가입 시트와 달리 **리퀴드 글래스를 쓰지 않는다**([SignupSheet.glass]
/// = false) — 목록만 있는 시트에 블러를 겹치면 항목 텍스트 대비가 떨어진다.
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
    return SignupSheet(
      glass: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(_rowInset.w, 0, _rowInset.w, 20.h),
            child: Text(
              '통신사를 선택해주세요.',
              // VybeTypography.heading4: SemiBold 20sp ✓
              style: VybeTypography.heading4.copyWith(color: Colors.white),
            ),
          ),
          // 항목 사이 간격 0 — 구분선 없이 행 높이로만 나눈다 (디자인 gap 0)
          for (final carrier in carriers)
            _CarrierRow(
              label: carrier,
              selected: selected == carrier,
              onTap: () => onSelected(carrier),
            ),
        ],
      ),
    );
  }
}

/// 통신사 한 줄. 배경·테두리 없이 **텍스트 색만** 상태를 나타낸다.
/// 선택 = 라임 SemiBold, 누르는 중 = 흰색, 평시 = t2(0.82).
class _CarrierRow extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CarrierRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CarrierRow> createState() => _CarrierRowState();
}

class _CarrierRowState extends State<_CarrierRow> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    const lime = VybeColors.mainLime500;

    // 선택이 눌림보다 우선 — 선택된 행은 누르는 동안에도 라임 유지 (디자인과 동일)
    final Color labelColor = widget.selected
        ? lime
        : (_pressed ? Colors.white : RenewGlass.t2);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: _rowHeight.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _rowInset.w),
          child: Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: _pressFade,
                  // VybeTypography.body2: Regular 18sp ✓ (선택 시 SemiBold)
                  style: VybeTypography.body2.copyWith(
                    color: labelColor,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  child: Text(widget.label),
                ),
              ),
              if (widget.selected)
                Icon(Icons.check_rounded, size: _checkSize.r, color: lime),
            ],
          ),
        ),
      ),
    );
  }
}
