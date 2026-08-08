import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';

// 찜 목록이 비었을 때.

class SavedEmptyState extends StatelessWidget {
  final VoidCallback onExplore;

  const SavedEmptyState({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: GlassCard(
        padding: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.r,
              height: 76.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VybeColors.mainPurple500.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: VybeColors.mainPurple500.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 30.r,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              '아직 찜한 클럽이 없어요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20.sp,
                height: 22 / 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 20 * -0.025,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              '마음에 드는 클럽의 하트를 눌러서\n나만의 리스트를 만들어보세요',
              textAlign: TextAlign.center,
              style: ClubGlass.body(color: ClubGlass.t3),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onExplore,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 13.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      VybeColors.mainLime500,
                      VybeColors.mainLime700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: VybeColors.mainLime500.withValues(alpha: 0.2),
                      blurRadius: 26.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Text(
                  '클럽 둘러보기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    height: 18 / 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 16 * -0.025,
                    color: ClubGlass.ink,
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
