import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_surface.dart';
import 'package:vybe/presentation/notifications/notification_item.dart';
import 'package:vybe/presentation/notifications/widgets/noti_glass.dart';

/// 알림 한 건 카드 (디자인 NGRow).
///
/// 안 읽음 = 유리 채움 + 종류 색 링·틴트·그림자, 읽음 = 옅은 유리.
/// 목록에 들어올 때 [appearDelay] 만큼 늦게 페이드인해 순차 등장 효과를 만든다.
class NotificationCard extends StatelessWidget {
  final NotificationItem noti;
  final VoidCallback onRead;
  final Duration appearDelay;

  const NotificationCard({
    super.key,
    required this.noti,
    required this.onRead,
    this.appearDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final s = notiStyleOf(noti.type);
    final unread = !noti.read;

    return VybeFadeInUp(
      delay: appearDelay,
      child: GestureDetector(
        onTap: onRead,
        behavior: HitTestBehavior.opaque,
        child: VybeGlassSurface(
          radius: NotiGlass.cardRadius,
          fill: unread ? ClubGlass.cardFill : VybeGlassSurface.quietFill,
          // 안 읽은 카드는 종류 색 링을 둘러 목록에서 먼저 눈에 띄게.
          border: unread ? s.ring : VybeGlassSurface.quietBorder,
          blurSigma: unread ? ClubGlass.blurSigma : VybeGlassSurface.quietBlur,
          elevated: unread,
          // 틴트·하이라이트는 여백 바깥(카드 전체)에 깔려야 해서 Stack이 padding을 감싼다.
          child: Stack(
            children: [
              if (unread) Positioned.fill(child: GlassTintOverlay(tint: s.tint)),
              GlassTopHighlight(strong: unread),
              Padding(
                padding: EdgeInsets.all(NotiGlass.cardPad.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    noti.thumb != null
                        ? _Thumb(colors: noti.thumb!, style: s)
                        : _IconTile(style: s),
                    SizedBox(width: 12.w),
                    Expanded(child: _content(unread, s)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(bool unread, NotiTypeStyle s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                noti.title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.5.sp,
                  height: 20 / 14.5,
                  letterSpacing: 14.5 * -0.025,
                  fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                  color: unread ? Colors.white : ClubGlass.t2,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              noti.time,
              style: ClubGlass.caption(
                color: ClubGlass.t4,
                size: 10.5,
                lineHeight: 16,
              ),
            ),
            if (unread) ...[
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: _UnreadDot(color: s.hue),
              ),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          noti.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ClubGlass.caption(
            color: unread ? ClubGlass.t3 : ClubGlass.t4,
            size: 12.5,
            lineHeight: 18,
          ),
        ),
        if (noti.cta != null) ...[
          SizedBox(height: 7.h),
          _CtaPill(label: noti.cta!, primary: unread && noti.primary),
        ],
      ],
    );
  }
}

/// 안 읽음 표시 점 — 종류 색으로 은은하게 발광.
class _UnreadDot extends StatelessWidget {
  final Color color;

  const _UnreadDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7.r,
      height: 7.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 8.r)],
      ),
    );
  }
}

/// 좌측 썸네일 (52) + 우하단 종류 아이콘 배지.
class _Thumb extends StatelessWidget {
  final List<Color> colors;
  final NotiTypeStyle style;

  const _Thumb({required this.colors, required this.style});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(15.r);
    return SizedBox(
      width: 57.r, // 52 + 배지가 -5 삐져나오는 만큼
      height: 57.r,
      child: Stack(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: r,
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            // 좌상단 광택.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                gradient: const RadialGradient(
                  center: Alignment(-0.4, -0.48),
                  radius: 0.9,
                  colors: [Color(0x47FFFFFF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ClipOval(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: 23.r,
                  height: 23.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xB80E0D12), // rgba(14,13,18,0.72)
                    shape: BoxShape.circle,
                    border: Border.all(color: style.ring),
                  ),
                  child: Icon(style.icon, size: 12.r, color: style.hue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 썸네일이 없는 알림의 종류 아이콘 타일 (44).
class _IconTile extends StatelessWidget {
  final NotiTypeStyle style;

  const _IconTile({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.tint,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: style.ring),
      ),
      child: Icon(style.icon, size: 19.r, color: style.hue),
    );
  }
}

/// 카드 하단 CTA pill. 안 읽은 주요 알림만 라임 채움, 나머지는 글래스 타일.
class _CtaPill extends StatelessWidget {
  final String label;
  final bool primary;

  const _CtaPill({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: primary ? null : ClubGlass.tileFill,
        gradient: primary
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [VybeColors.mainLime500, VybeColors.mainLime700],
              )
            : null,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: primary ? const Color(0x4DFFFFFF) : ClubGlass.tileBorder,
        ),
        boxShadow: primary
            ? [
                BoxShadow(
                  color: VybeColors.mainLime500.withValues(alpha: 0.18),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ClubGlass.caption(
              color: primary ? ClubGlass.ink : Colors.white,
              lineHeight: 14,
              weight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 5.w),
          Icon(
            Icons.chevron_right_rounded,
            size: 13.r,
            color: primary ? const Color(0x990E0D12) : const Color(0x99FFFFFF),
          ),
        ],
      ),
    );
  }
}
