import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/location_flip_mixin.dart';
import 'package:vybe/presentation/common/widgets/vybe_pin_flip.dart';

/// 「지도 핀 + 지역 라벨」 위치 칩.
///
/// 평상시엔 [핀 + 텍스트], [loading] 이 켜지면 텍스트가 사라지며 원형으로 축소되고
/// 핀만 3D 플립을 돈다.
///
/// 홈 상단(`HomeLocationGreeting`)에만 있던 것을 승격했다 —
/// 입장비 무료·서비스 음료 목록 상단도 같은 칩을 쓴다. 화면마다 복붙하면
/// 핀 크기·색·여백이 조금씩 갈라져 같은 칩이 화면마다 다르게 보인다.
///
/// 위치 인식 로직(GPS 재조회·플립 애니메이션 제어)은 화면 소유 —
/// 이 위젯은 그리기만 한다.
class VybeLocationChip extends StatelessWidget {
  /// 표시 라벨 (예: '강남'). 등록된 지역 밖이면 화면이 '내 주변'을 넘긴다.
  final String label;

  /// true면 원형 축소 + 핀 회전.
  final bool loading;

  /// 핀 플립 애니메이션 (0→1 한 바퀴 = 360도).
  final Animation<double> flip;

  final VoidCallback onTap;

  /// 칩 바깥 여백. 홈은 아래 12를 준다.
  final EdgeInsetsGeometry? margin;

  const VybeLocationChip({
    super.key,
    required this.label,
    required this.loading,
    required this.flip,
    required this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: kLocationChipShrinkDuration,
        curve: Curves.easeInOut,
        margin: margin,
        // 로딩 중엔 사방 동일 패딩 → 핀을 감싸는 원형.
        padding: loading
            ? EdgeInsets.all(8.r)
            : EdgeInsets.fromLTRB(9.w, 6.h, 12.w, 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: AnimatedSize(
          duration: kLocationChipShrinkDuration,
          curve: Curves.easeInOut,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VybePinFlip(
                animation: flip,
                frontColor: VybeColors.mainLime500,
                size: 14,
              ),
              // 로딩 중엔 텍스트 제거 → 너비 축소.
              if (!loading) ...[
                SizedBox(width: 5.w),
                Text(
                  label,
                  style: VybeTypography.button2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
