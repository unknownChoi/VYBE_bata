import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/home/widgets/home_banner.dart';
import 'package:vybe/presentation/home/widgets/home_category_grid.dart';
import 'package:vybe/presentation/home/widgets/home_gnb.dart';
import 'package:vybe/presentation/home/widgets/home_location_greeting.dart';
import 'package:vybe/presentation/home/widgets/home_nearby_clubs.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeScreen({super.key, this.onSearchTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        children: [
          // 앰비언트 클럽 조명 백드롭 (스크롤 컨텐츠 뒤).
          const Positioned.fill(
            child: IgnorePointer(child: _AmbientBackdrop()),
          ),
          // 스크롤 컨텐츠 — 상단 바 높이만큼 패딩.
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                final s = n.metrics.pixels > 12;
                if (s != _scrolled) setState(() => _scrolled = s);
                return false;
              },
              child: ListView(
                padding: EdgeInsets.only(top: top + 52.h, bottom: 32.h),
                children: const [
                  HomeLocationGreeting(),
                  HomeBanner(),
                  HomeCategoryGrid(),
                  HomeNearbyClubs(),
                ],
              ),
            ),
          ),
          // 상단 바 오버레이 (스크롤 시 blur 등장).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeGnb(scrolled: _scrolled, onSearchTap: widget.onSearchTap),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120F1A), Color(0xFF101013), Color(0xFF0E0D12)],
          stops: [0.0, 0.34, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 좌상단 보라 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.9, -1),
                  radius: 1.0,
                  colors: [Color(0x4D7731FE), Color(0x00000000)],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
          // 우상단 라임 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.9),
                  radius: 1.0,
                  colors: [Color(0x1FB5FF60), Color(0x00000000)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
