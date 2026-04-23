import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _banners = [
  'assets/images/home_screen/banner_ad_1.png',
  'assets/images/home_screen/banner_ad_2.png',
  'assets/images/home_screen/banner_ad_3.png',
  'assets/images/home_screen/banner_ad_4.png',
];

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late final PageController _controller;
  late final Timer _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_index + 1) % _banners.length;
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
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Image.asset(
              _banners[i],
              fit: BoxFit.cover,
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
                '${_index + 1}/${_banners.length}',
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
