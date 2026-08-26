import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/location_flip_mixin.dart';
import 'package:vybe/presentation/common/widgets/vybe_accent_dropdown.dart';
import 'package:vybe/presentation/common/widgets/vybe_location_chip.dart';

/// 목록 상단 「내 위치 칩 + 정렬 드롭다운」 한 줄.
///
/// 위치 칩을 탭하면 [onLocTap] 이 호출되고, 화면이 [locLoading] 을 켜면
/// 칩이 원형으로 줄어들며 [flip] 애니메이션을 도는 핀만 남는다.
/// 위치 인식 로직 자체는 화면(ViewModel) 소유 — 이 위젯은 표시만 한다.
class VybeLocationSortBar extends StatelessWidget {
  /// 칩 원형 축소 전환 시간. 화면의 위치 인식 시퀀스와 맞춰 쓴다.
  static const shrinkDuration = kLocationChipShrinkDuration;

  /// 현재 위치 라벨 (예: '홍대').
  final String loc;

  /// 현재 정렬 값.
  final String sort;

  /// 정렬 선택지.
  final List<String> sorts;

  /// true면 칩이 원형으로 축소되고 핀만 회전.
  final bool locLoading;

  /// 핀 플립 애니메이션 (0→1 한 바퀴 = 360도).
  final Animation<double> flip;

  final VoidCallback onLocTap;
  final ValueChanged<String> onSort;

  /// 화면별 액센트 색 (정렬 드롭다운의 선택 항목 표시).
  ///
  /// 위치 칩은 여기 쓰지 않는다 — 홈 위치 칩과 같은 중립 글래스 톤으로 통일했다
  /// (화면마다 칩이 다른 색으로 물들면 같은 동작이 다른 신호로 읽힌다).
  final Color accent;

  const VybeLocationSortBar({
    super.key,
    required this.loc,
    required this.sort,
    required this.sorts,
    required this.locLoading,
    required this.flip,
    required this.onLocTap,
    required this.onSort,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 내 위치 — 홈 상단과 **같은 위젯**(VybeLocationChip).
          VybeLocationChip(
            label: loc,
            loading: locLoading,
            flip: flip,
            onTap: onLocTap,
          ),
          // 정렬.
          VybeAccentDropdown<String>(
            value: sort,
            items: sorts,
            onSelected: onSort,
            accent: accent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: VybeColors.gray900,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: VybeColors.gray800),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sort,
                    style: VybeTypography.caption.copyWith(
                      height: 14 / 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14.r, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
