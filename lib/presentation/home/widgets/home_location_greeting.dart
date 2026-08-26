import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/location_flip_mixin.dart';
import 'package:vybe/presentation/common/widgets/vybe_location_chip.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';

class HomeLocationGreeting extends ConsumerStatefulWidget {
  const HomeLocationGreeting({super.key});

  @override
  ConsumerState<HomeLocationGreeting> createState() =>
      _HomeLocationGreetingState();
}

class _HomeLocationGreetingState extends ConsumerState<HomeLocationGreeting>
    with SingleTickerProviderStateMixin, LocationFlipMixin {
  // 위치 칩 탭 → 핀 플립 연출을 돌리는 동안 기기 GPS를 다시 읽는다.
  // 라벨은 userLocationProvider가 그리므로 여기서 대입할 상태가 없다.
  void _onLocationTap() {
    unawaited(ref.read(userLocationProvider.notifier).resolveFromDevice());
    runLocationFlip(onResolved: () {});
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

  // 위치 칩 — 공통 위젯 (VybeLocationChip). 라벨만 여기서 정한다.
  Widget _buildLocationChip() {
    // 라벨 = 지금 내 좌표가 속한 지역(예: '강남'). 등록된 지역 밖이면 '내 주변'.
    final locationLabel = ref.watch(userLocationProvider).areaLabel;

    return VybeLocationChip(
      label: locationLabel,
      loading: locLoading,
      flip: flip,
      onTap: _onLocationTap,
      margin: EdgeInsets.only(bottom: 12.h),
    );
  }
}
