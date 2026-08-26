import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/filter_chip_style.dart';
import 'package:vybe/presentation/hot_places/hot_places_models.dart';
// ── 지역 필터 ──
class HotPlacesAreaFilter extends StatelessWidget {
  final String active;
  final bool scrolled;
  final ValueChanged<String> onChange;
  const HotPlacesAreaFilter({super.key, required this.active, required this.scrolled, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scrolled ? VybeColors.background.withValues(alpha: 0.92) : Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final a in kHotAreas) ...[
              // 칩 외형은 주변 페이지와 같은 글래스 칩 단일 소스.
              VybeGlassFilterChip(
                label: a,
                selected: a == active,
                // '내 주변'만 위치 아이콘 — 지역명 칩과 성격이 달라서다.
                icon: a == '내 주변' ? Icons.place : null,
                accent: kHotAccent,
                hPadding: a == '내 주변' ? 13 : 16,
                onTap: () => onChange(a),
              ),
              if (a != kHotAreas.last) SizedBox(width: 8.w),
            ],
          ],
        ),
      ),
    );
  }
}
