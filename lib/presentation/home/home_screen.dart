import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/home/viewmodels/home_skeleton_provider.dart';
import 'package:vybe/presentation/home/widgets/home_category_grid.dart';
import 'package:vybe/presentation/home/widgets/home_gnb.dart';
import 'package:vybe/presentation/home/widgets/home_screen_skeleton.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeScreen({super.key, this.onSearchTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// 홈 진입 직후 스켈레톤 노출 시간. 회원가입 완료 → 홈 전환이 비어 보이는 구간을 덮는다.
const _kSkeletonDuration = Duration(milliseconds: 1400);

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _scrolled = false;
  bool _showSkeleton = false;
  Timer? _skeletonTimer;

  @override
  void initState() {
    super.initState();
    // 세션당 1회(로그인 직후 / 자동 로그인 앱 실행)만 스켈레톤 표시.
    // 탭 전환 복귀 등 이후 진입에서는 게이트가 닫혀 있어 바로 실제 화면.
    _showSkeleton = ref.read(homeSkeletonGateProvider);
    if (_showSkeleton) {
      _skeletonTimer = Timer(_kSkeletonDuration, () {
        if (!mounted) return;
        // 게이트는 스켈레톤을 끝까지 보여준 뒤에만 닫는다.
        // 앱 콜드 스타트 때 auth 스트림이 여러 번 emit하면 HomeScreen이 만들어졌다
        // 곧바로 dispose될 수 있는데, mount 시점에 닫으면 정작 최종 홈에서는
        // 스켈레톤이 안 뜬다. 완주했을 때만 닫아 그 경우를 방지.
        ref.read(homeSkeletonGateProvider.notifier).close();
        setState(() => _showSkeleton = false);
      });
    }
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        children: [
          // 앰비언트 클럽 조명 백드롭 (스크롤 컨텐츠 뒤).
          const Positioned.fill(child: IgnorePointer(child: AmbientBackdrop())),
          // 스크롤 컨텐츠 — 상단 바 높이만큼 패딩.
          // 진입 직후엔 스켈레톤, 이후 실제 컨텐츠로 페이드 전환.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _showSkeleton
                  ? const HomeScreenSkeleton()
                  : NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        // depth 0 = 바깥 세로 ListView만. 배너 등 내부 가로 스크롤 무시.
                        if (n.depth != 0) return false;
                        final s = n.metrics.pixels > 12;
                        if (s != _scrolled) setState(() => _scrolled = s);
                        return false;
                      },
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: top + 52.h,
                          bottom: MediaQuery.of(context).padding.bottom + 100.h,
                        ),
                        // HomeLocationGreeting / HomeBanner / HomeNearbyClubs는
                        // 현재 노출 보류 상태 — 위젯 파일은 그대로 남아 있으므로
                        // 재노출 시 이 리스트에 다시 추가하면 된다.
                        children: const [
                          HomeCategoryGrid(),
                        ],
                      ),
                    ),
            ),
          ),
          // 상단 바 오버레이 (스크롤 시 blur 등장).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeGnb(
              scrolled: _scrolled,
              onSearchTap: widget.onSearchTap,
            ),
          ),
        ],
      ),
    );
  }
}
