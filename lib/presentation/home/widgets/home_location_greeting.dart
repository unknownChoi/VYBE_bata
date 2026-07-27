import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';

// 홍대 기본 좌표 — 주변 페이지 최초 로딩 좌표(nearby_viewmodel.dart)와 동일.
const _kHongdaeLat = 37.5572;
const _kHongdaeLng = 126.9239;

// 칩 축소(원형 변형) 애니메이션 시간. 이게 끝난 뒤 핀 플립 시작.
const _kShrinkDuration = Duration(milliseconds: 320);

// 위치 검색(로딩) 지속 시간 — 핀 플립 애니메이션 노출 구간.
const _kSearchDuration = Duration(milliseconds: 1600);

class HomeLocationGreeting extends ConsumerStatefulWidget {
  const HomeLocationGreeting({super.key});

  @override
  ConsumerState<HomeLocationGreeting> createState() =>
      _HomeLocationGreetingState();
}

class _HomeLocationGreetingState extends ConsumerState<HomeLocationGreeting>
    with SingleTickerProviderStateMixin {
  // 위치 칩 라벨. 탭 전 '내 주변', 탭하면 홍대 좌표 인식 → '홍대'.
  String _locationLabel = '내 주변';
  bool _loading = false;

  // 지도 핀 3D 플립 컨트롤러 (Y축 회전 반복).
  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  Future<void> _onLocationTap() async {
    if (_loading) return;
    // 홍대 좌표로 인식 → 검색 로딩 시작. (주변 페이지 최초 로딩 좌표와 동일)
    debugPrint('위치 선택: 홍대 ($_kHongdaeLat, $_kHongdaeLng)');
    setState(() => _loading = true);

    // 칩이 원형으로 줄어드는 애니메이션 완료 후 핀 플립 시작.
    await Future.delayed(_kShrinkDuration);
    if (!mounted) return;
    _flip.repeat();

    await Future.delayed(_kSearchDuration);
    if (!mounted) return;

    _flip.stop();
    _flip.reset();
    setState(() {
      _loading = false;
      _locationLabel = '홍대';
    });
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

  // 위치 칩 — 평상시 [핀+텍스트], 로딩 시 텍스트 사라지며 원형으로 축소 + 핀 3D 플립.
  Widget _buildLocationChip() {
    return GestureDetector(
      onTap: _onLocationTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _kShrinkDuration,
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 12.h),
        // 로딩 중엔 사방 동일 패딩 → 핀을 감싸는 원형.
        padding: _loading
            ? EdgeInsets.all(8.r)
            : EdgeInsets.fromLTRB(9.w, 6.h, 12.w, 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: AnimatedSize(
          duration: _kShrinkDuration,
          curve: Curves.easeInOut,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PinFlip(animation: _flip),
              // 로딩 중엔 텍스트 제거 → 너비 축소.
              if (!_loading) ...[
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

// 지도 핀 3D 플립 — Y축 회전. 앞면 녹색, 뒷면 보라.
class _PinFlip extends StatelessWidget {
  final Animation<double> animation;
  const _PinFlip({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final angle = animation.value * 2 * math.pi; // 0 → 360도 반복
        final isFront = math.cos(angle) >= 0;
        final color = isFront
            ? VybeColors.mainLime500
            : VybeColors.mainPurple500;

        return Transform(
          alignment: Alignment.center,
          // 원근감(3D) — setEntry(3,2,..)로 perspective 부여.
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: Transform(
            // 뒷면일 때 좌우 반전 보정(아이콘 거울상 방지).
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(isFront ? 0 : math.pi),
            child: SvgPicture.asset(
              'assets/icons/home_screen/loaction_pin.svg',
              width: 14.r,
              height: 14.r,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        );
      },
    );
  }
}
