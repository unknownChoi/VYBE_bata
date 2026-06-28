import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
// 배너·주변 클럽 임시 제거 — 복구하려면 주석 해제.
// import 'package:vybe/presentation/home/widgets/home_banner.dart';
import 'package:vybe/presentation/home/widgets/home_category_grid.dart';
import 'package:vybe/presentation/home/widgets/home_gnb.dart';
import 'package:vybe/presentation/home/widgets/home_location_greeting.dart';
// import 'package:vybe/presentation/home/widgets/home_nearby_clubs.dart';

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
            child: IgnorePointer(child: AmbientBackdrop()),
          ),
          // 스크롤 컨텐츠 — 상단 바 높이만큼 패딩.
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
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
                children: const [
                  HomeLocationGreeting(),
                  // 배너·주변 클럽 임시 제거 — 복구하려면 주석 해제.
                  // HomeBanner(),
                  HomeCategoryGrid(),
                  // HomeNearbyClubs(),
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
