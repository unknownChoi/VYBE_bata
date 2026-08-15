import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';

/// 앱 진입을 막는 전체화면 안내 — 강제 업데이트 · 서버 점검 공용.
///
/// 뒤로가기로 빠져나갈 수 없다(`PopScope canPop: false`) — 우회 가능하면
/// 강제 업데이트가 의미가 없다.
class VersionBlockScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  /// 주 버튼 문구 (예: '업데이트하기', '다시 시도').
  final String actionLabel;
  final VoidCallback onAction;

  /// 하단 버전 표기 (예: "1.0.0 (1)"). 비면 표시 안 함.
  final String versionLabel;

  const VersionBlockScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.versionLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: VybeColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: VybeAurora()),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 32.r,
                        color: VybeColors.mainPurple500,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: VybeTypography.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: VybeTypography.body3.copyWith(
                        color: VybeColors.gray500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    VybeButton(label: actionLabel, onTap: onAction),
                    if (versionLabel.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text(
                        '현재 버전 $versionLabel',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12.sp,
                          color: VybeColors.gray600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
