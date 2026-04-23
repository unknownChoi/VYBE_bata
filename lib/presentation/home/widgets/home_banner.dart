import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/banner_model.dart';
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
  late final Timer _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_index + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 228.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Image.network(
              widget.banners[i].imageUrl,
              fit: BoxFit.cover,
              // precacheImage로 사전 로딩됐으므로 즉시 표시
              frameBuilder: (_, child, frame, __) => child,
            ),
          ),
          Positioned(
            right: 14.w,
            bottom: 14.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '${_index + 1}/${widget.banners.length}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 12 * -0.025,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 228.h,
      child: Container(color: const Color(0xFF1A1A1A)),
    );
  }
}
