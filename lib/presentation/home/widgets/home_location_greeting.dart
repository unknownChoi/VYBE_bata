import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';

class HomeLocationGreeting extends ConsumerWidget {
  const HomeLocationGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final name = uid == null
        ? '게스트'
        : (ref.watch(currentUserProvider(uid)).asData?.value?.name ?? '게스트');

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 6.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 위치 칩 (역지오코딩 백엔드 없음 — 정적 라벨)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.fromLTRB(9.w, 6.h, 12.w, 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: VybeColors.gray800),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/home_screen/loaction_pin.svg',
                  width: 14.r,
                  height: 14.r,
                  colorFilter: const ColorFilter.mode(
                    VybeColors.mainLime500,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  '내 주변',
                  style: VybeTypography.button2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.r,
                  color: VybeColors.gray400,
                ),
              ],
            ),
          ),
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
                TextSpan(
                  text: '놀까요?',
                  style: const TextStyle(color: VybeColors.mainLime500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
