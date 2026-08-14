import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/my_page/settings_screen.dart';

/// 알림 화면 헤더 (디자인 NGHeader).
///
/// 원형 글래스 버튼(뒤로 · 설정) + 큰 타이틀 + 안 읽은 수 + '모두 읽음' pill.
class NotificationHeader extends StatelessWidget {
  final int unread;

  /// null이면(= 안 읽은 알림 없음) 버튼이 흐려지고 반응하지 않는다.
  final VoidCallback? onReadAll;

  const NotificationHeader({super.key, required this.unread, this.onReadAll});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, top + 8.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VybeGlassButton(
                iconSize: 16,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              // 뒤로가기와 나란히 있어 같은 글래스 버튼으로 맞춘다.
              VybeGlassButton(
                icon: Icons.settings_outlined,
                iconSize: 18,
                iconColor: ClubGlass.t2,
                onTap: () => Navigator.of(context).push(
                  SwipeBackPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알림',
                      style: VybeTypography.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    _Subtitle(unread: unread),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              _ReadAllButton(enabled: unread > 0, onTap: onReadAll),
            ],
          ),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final int unread;

  const _Subtitle({required this.unread});

  @override
  Widget build(BuildContext context) {
    final base = VybeTypography.body4.copyWith(color: ClubGlass.t3);
    if (unread == 0) return Text('모두 확인했어요', style: base);

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: '읽지 않은 소식 '),
          TextSpan(
            text: '$unread개',
            style: const TextStyle(
              color: VybeColors.mainLime500,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


/// '모두 읽음' 글래스 pill.
class _ReadAllButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _ReadAllButton({required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(999.r);
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: r,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: ClubGlass.tileFill,
                borderRadius: r,
                border: Border.all(color: ClubGlass.tileBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 13.r,
                    color: enabled ? VybeColors.mainLime500 : ClubGlass.t4,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '모두 읽음',
                    style: VybeTypography.button2.copyWith(color: Colors.white),
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
