import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_glass.dart';

/// 지도를 옮긴 뒤 뜨는 '현재 지역에서 재검색' 플로팅 버튼.
///
/// 시트 위에 떠 있으므로 [sheetTop]만큼 띄운다. 시트가 중간 이상 올라오면
/// 버튼이 시트에 파묻히므로 호출측이 아예 그리지 않는다.
class NearbyReSearchButton extends StatelessWidget {
  /// 화면 아래에서 시트 상단까지의 높이 (= stackHeight × sheetSize).
  final double sheetTop;
  final VoidCallback onTap;

  const NearbyReSearchButton({
    super.key,
    required this.sheetTop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: sheetTop + 8.h,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: NearbyFloatSurface(
            radius: 999,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 15.r,
                    color: VybeColors.mainLime500,
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    '현재 지역에서 재검색',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 16 / 14,
                      letterSpacing: 14 * -0.025,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
