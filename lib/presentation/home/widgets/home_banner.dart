import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/banner_link_handler.dart';
import 'package:vybe/data/models/banner_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/home/viewmodels/banner_viewmodel.dart';

class HomeBanner extends ConsumerWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannerListProvider);
    return bannersAsync.when(
      loading: () => _BannerSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        return _BannerCarousel(banners: banners);
      },
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;

  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        final next = (_index + 1) % widget.banners.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: _BannerCard(
                banner: widget.banners[i],
                index: i,
                total: widget.banners.length,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // 인디케이터 dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: active ? 18.w : 5.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: active ? VybeColors.mainLime500 : VybeColors.gray700,
                borderRadius: BorderRadius.circular(99.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// 바텀 nav를 내린 채 열어야 해서 ref가 필요 → ConsumerWidget.
class _BannerCard extends ConsumerWidget {
  final BannerModel banner;
  final int index;
  final int total;

  const _BannerCard({
    required this.banner,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 링크 없는 배너는 탭 자체를 막는다 (눌리는데 아무 일 없는 상태 방지).
    return GestureDetector(
      onTap: banner.isTappable
          ? () => openBannerLink(context, ref, banner)
          : null,
      behavior: HitTestBehavior.opaque,
      child: _card(),
    );
  }

  Widget _card() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: VybeColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: VybeColors.gray800),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: VybeColors.surface),
            ),
            // 하단 가독성 그라데이션
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xC708080C)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // 카운터
            Positioned(
              right: 14.w,
              bottom: 14.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${index + 1} / $total',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 12 * -0.025,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: VybeColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
