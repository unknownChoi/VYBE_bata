import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';

class HomeLocationBar extends StatefulWidget {
  const HomeLocationBar({super.key});

  @override
  State<HomeLocationBar> createState() => _HomeLocationBarState();
}

class _HomeLocationBarState extends State<HomeLocationBar> {
  bool _isLoading = false;
  String? _area;

  Future<void> _onTap() async {
    if (_isLoading || _area != null) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _area = '홍대';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/home_screen/loaction_pin.svg',
              width: 16.r,
              height: 16.r,
              colorFilter: const ColorFilter.mode(
                VybeColors.gray200,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 4.w),
            if (_isLoading)
              SizedBox(
                width: 14.r,
                height: 14.r,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: VybeColors.gray200,
                ),
              )
            else
              Text(
                _area ?? '내 주변 검색',
                style: VybeTypography.body3.copyWith(color: VybeColors.gray200),
              ),
          ],
        ),
      ),
    );
  }
}
