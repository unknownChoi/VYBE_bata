import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/location_flip_mixin.dart';
import 'package:vybe/presentation/common/widgets/vybe_pin_flip.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';

class HomeLocationGreeting extends ConsumerStatefulWidget {
  const HomeLocationGreeting({super.key});

  @override
  ConsumerState<HomeLocationGreeting> createState() =>
      _HomeLocationGreetingState();
}

class _HomeLocationGreetingState extends ConsumerState<HomeLocationGreeting>
    with SingleTickerProviderStateMixin, LocationFlipMixin {
  // 위치 칩 라벨. 탭 전 '내 주변', 탭하면 홍대 좌표 인식 → '홍대'.
  String _locationLabel = '내 주변';

  void _onLocationTap() {
    // 홍대 좌표로 인식 → 검색 로딩 시작. (주변 페이지 최초 로딩 좌표와 동일)
    debugPrint(
        '위치 선택: ${AppGeo.hongdaeLabel} (${AppGeo.hongdaeLat}, ${AppGeo.hongdaeLng})');
    runLocationFlip(onResolved: () => _locationLabel = AppGeo.hongdaeLabel);
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    final fullName = uid == null
        ? '게스트'
        : (ref.watch(currentUserProvider(uid)).asData?.value?.name ?? '게스트');
    // 성을 떼고 이름만 표시 (예: 최윤성 → 윤성). 한 글자 성 가정.
    final name = fullName.length > 1 ? fullName.substring(1) : fullName;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationChip(),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 26.sp,
                height: 32 / 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 26 * -0.025,
              ),
              children: [
                TextSpan(text: '오늘 밤, $name님은\n어디서 '),
                const TextSpan(
                  text: '놀까요?',
                  style: TextStyle(color: VybeColors.mainLime500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 위치 칩 — 평상시 [핀+텍스트], 로딩 시 텍스트 사라지며 원형으로 축소 + 핀 3D 플립.
  Widget _buildLocationChip() {
    return GestureDetector(
      onTap: _onLocationTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: kLocationChipShrinkDuration,
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 12.h),
        // 로딩 중엔 사방 동일 패딩 → 핀을 감싸는 원형.
        padding: locLoading
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
              if (!locLoading) ...[
                SizedBox(width: 5.w),
                Text(
                  _locationLabel,
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
