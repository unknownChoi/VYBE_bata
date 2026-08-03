import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_shimmer.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart'
    show navBarTotalHeight;
import 'package:vybe/presentation/my_page/settings_screen.dart';

/// 알림 — 리퀴드 글래스 리뉴얼.
///
/// 디자인: notifications_glass.html (notifications_glass_shell.jsx · notifications_glass.jsx).
/// 오로라 배경 + 큰 타이틀 헤더(뒤로/설정 원형 글래스 · '모두 읽음' pill) +
/// 시간 섹션 라벨 + 종류별 색 링을 두른 글래스 카드 목록.
///
/// 글래스 토큰(채움·테두리·타일·텍스트 계조)은 클럽 상세와 값이 같아 [ClubGlass]를
/// 그대로 쓰고, 알림 전용(읽음 카드의 옅은 글래스·종류별 색)만 여기 둔다.
///
/// ⚠ 디자인의 종류 필터 칩(전체/예약·입장/…)은 글래스 개편에서 빠졌다
/// (shell에 NG_FILTERS는 남아 있으나 페이지가 렌더하지 않음) → 여기서도 제외.

// ── 알림 종류 ──
enum NotiType { reservation, club, promo, activity, review, friend, notice }

// ── 섹션(시간 그룹) ──
enum NotiSection { today, week, earlier }

// ── 알림 아이템 (백엔드 연동 전 프레젠테이션 모델) ──
class NotificationItem {
  final int id;
  final NotiType type;
  final NotiSection section;
  final bool read;
  final String time;
  final String title;
  final String body;
  final String? cta;

  /// CTA를 강조(라임 채움)할지. 안 읽은 알림에서만 적용된다.
  final bool primary;

  // 좌측 썸네일 그라데이션 (없으면 종류 아이콘 타일로 대체).
  final List<Color>? thumb;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.section,
    required this.read,
    required this.time,
    required this.title,
    required this.body,
    this.cta,
    this.primary = false,
    this.thumb,
  });

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        type: type,
        section: section,
        read: read ?? this.read,
        time: time,
        title: title,
        body: body,
        cta: cta,
        primary: primary,
        thumb: thumb,
      );
}

// ── 종류별 색/아이콘 매핑 (NG_TYPES) ──
// hue = 아이콘 색, tint = 타일·카드 틴트, ring = 카드 외곽 링.
class _TypeStyle {
  final IconData icon;
  final Color hue;
  final Color tint;
  final Color ring;
  const _TypeStyle(this.icon, this.hue, this.tint, this.ring);
}

_TypeStyle _styleOf(NotiType type) {
  switch (type) {
    case NotiType.reservation:
      return const _TypeStyle(
        Icons.confirmation_number_outlined,
        VybeColors.mainPurple500,
        Color(0x387731FE), // rgba(119,49,254,0.22)
        Color(0x737731FE), // rgba(119,49,254,0.45)
      );
    case NotiType.club:
      return const _TypeStyle(
        Icons.music_note_rounded,
        VybeColors.mainLime500,
        Color(0x29B5FF60), // rgba(181,255,96,0.16)
        Color(0x61B5FF60), // rgba(181,255,96,0.38)
      );
    case NotiType.promo:
      return const _TypeStyle(
        Icons.sell_outlined,
        Color(0xFFFF5C7A),
        Color(0x2EFF5C7A), // rgba(255,92,122,0.18)
        Color(0x66FF5C7A), // rgba(255,92,122,0.40)
      );
    case NotiType.activity:
      return const _TypeStyle(
        Icons.favorite_rounded,
        Color(0xFF5B8CFF),
        Color(0x2E5B8CFF),
        Color(0x665B8CFF),
      );
    case NotiType.review:
      return const _TypeStyle(
        Icons.star_rounded,
        Color(0xFFFFC94D),
        Color(0x29FFC94D),
        Color(0x5CFFC94D),
      );
    case NotiType.friend:
      return const _TypeStyle(
        Icons.person_outline_rounded,
        Color(0xE6FFFFFF),
        Color(0x1AFFFFFF),
        Color(0x33FFFFFF),
      );
    case NotiType.notice:
      return const _TypeStyle(
        Icons.campaign_outlined,
        Color(0xE6FFFFFF),
        Color(0x1AFFFFFF),
        Color(0x33FFFFFF),
      );
  }
}

// 읽은 알림 카드 (NG.glassQuiet) — 채움·테두리를 절반 이하로 낮춰 뒤로 물러나게.
const Color _quietFill = Color(0x14787880); // rgba(120,120,128,0.08)
const Color _quietBorder = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)

const _sections = [
  (NotiSection.today, '오늘'),
  (NotiSection.week, '이번 주'),
  (NotiSection.earlier, '이전'),
];

// ── 더미 데이터 (백엔드 연동 전) ──
const _dummyNotis = <NotificationItem>[
  NotificationItem(
    id: 1, type: NotiType.reservation, section: NotiSection.today,
    read: false, time: '12분 전',
    title: '어썸레드 입장이 확정되었어요',
    body: '오늘 23:00 · 2인 · 게스트 입장. 입장 시 예약 코드를 보여주세요.',
    thumb: [VybeColors.mainPurple500, Color(0xFFFF4D8D)],
    cta: '예약 코드 보기',
    primary: true,
  ),
  NotificationItem(
    id: 2, type: NotiType.club, section: NotiSection.today,
    read: false, time: '40분 전',
    title: '버뮤다 · 오늘 밤 게스트 DJ',
    body: '찜한 클럽에서 자정부터 DJ SOULSCAPE 단독 셋이 진행돼요.',
    thumb: [Color(0xFF06FFA5), Color(0xFF3A86FF)],
  ),
  NotificationItem(
    id: 3, type: NotiType.promo, section: NotiSection.today,
    read: false, time: '2시간 전',
    title: '주말 한정 입장권 30% 할인',
    body: '오늘 자정까지 강남 인기 클럽 6곳 입장권을 할인가로 예약하세요.',
    cta: '혜택 보기',
  ),
  NotificationItem(
    id: 4, type: NotiType.activity, section: NotiSection.today,
    read: true, time: '5시간 전',
    title: '회원님의 리뷰가 인기를 얻고 있어요',
    body: '어썸레드에 남긴 리뷰에 좋아요 12개와 댓글 3개가 달렸어요.',
  ),
  NotificationItem(
    id: 5, type: NotiType.reservation, section: NotiSection.week,
    read: true, time: '어제',
    title: '입장 24시간 전 안내',
    body: 'OCTAGON 예약이 내일 22:00로 예정되어 있어요. 드레스 코드를 확인하세요.',
    thumb: [VybeColors.accentBlue500, VybeColors.mainPurple500],
  ),
  NotificationItem(
    id: 6, type: NotiType.friend, section: NotiSection.week,
    read: true, time: '2일 전',
    title: '지민님이 회원님을 팔로우해요',
    body: '함께 아는 친구 4명 · 지민님도 홍대 클럽을 자주 찾아요.',
  ),
  NotificationItem(
    id: 7, type: NotiType.review, section: NotiSection.week,
    read: true, time: '3일 전',
    title: '다녀온 클럽은 어땠나요?',
    body: '인클에서의 밤, 별점과 한 줄 후기를 남기면 다른 사람들에게 도움이 돼요.',
    cta: '리뷰 남기기',
  ),
  NotificationItem(
    id: 8, type: NotiType.club, section: NotiSection.earlier,
    read: true, time: '1주 전',
    title: '벨로주에 새 사진 12장이 올라왔어요',
    body: '찜한 재즈 클럽의 최근 분위기를 확인해보세요.',
    thumb: [Color(0xFF2A2D34), Color(0xFF6C757D)],
  ),
  NotificationItem(
    id: 9, type: NotiType.notice, section: NotiSection.earlier,
    read: true, time: '1주 전',
    title: 'vybe 예약 정책이 업데이트되었어요',
    body: '노쇼 방지를 위한 입장 확정 절차가 추가되었습니다. 자세히 보기.',
  ),
];

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _loading = true;
  List<NotificationItem> _notis = List.of(_dummyNotis);
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();
    // 디자인과 동일하게 잠깐 스켈레톤 노출.
    _loadTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  int get _unread => _notis.where((n) => !n.read).length;

  void _readAll() =>
      setState(() => _notis = _notis.map((n) => n.copyWith(read: true)).toList());

  void _readOne(int id) => setState(() => _notis =
      _notis.map((n) => n.id == id ? n.copyWith(read: true) : n).toList());

  @override
  Widget build(BuildContext context) {
    // 홈 탭 Navigator 위에 push되므로 하단 floating nav가 그대로 떠 있다.
    final bottomPad = 28.h + navBarTotalHeight(context);

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: ClubAurora()),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  unread: _unread,
                  onReadAll: _unread > 0 ? _readAll : null,
                ),
              ),
              if (_loading)
                const SliverToBoxAdapter(child: _Skeleton())
              else if (_notis.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const _Empty(label: '알림이 없어요'),
                  ),
                )
              else
                ..._buildSections(),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    final slivers = <Widget>[];
    for (final (sec, label) in _sections) {
      final rows = _notis.where((n) => n.section == sec).toList();
      if (rows.isEmpty) continue;
      slivers.add(
        SliverToBoxAdapter(
          child: _SectionLabel(label: label, count: rows.length),
        ),
      );
      slivers.add(
        SliverList.list(
          children: [
            for (var i = 0; i < rows.length; i++)
              Padding(
                // 카드 사이 간격 10px.
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                child: _FadeInUp(
                  delay: Duration(milliseconds: i * 45),
                  child: _NotiCard(
                    noti: rows[i],
                    onRead: () => _readOne(rows[i].id),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return slivers;
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  final int unread;
  final VoidCallback? onReadAll;
  const _Header({required this.unread, this.onReadAll});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, top + 8.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassRound(
                icon: Icons.arrow_back_ios_new_rounded,
                iconSize: 16,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              _GlassRound(
                icon: Icons.settings_outlined,
                iconSize: 18,
                iconColor: ClubGlass.t2,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
                    _subtitle(),
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

  Widget _subtitle() {
    if (unread == 0) {
      return Text(
        '모두 확인했어요',
        style: VybeTypography.body4.copyWith(color: ClubGlass.t3),
      );
    }
    return Text.rich(
      TextSpan(
        style: VybeTypography.body4.copyWith(color: ClubGlass.t3),
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

/// 헤더 좌우 원형 글래스 버튼 (NGRound).
class _GlassRound extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassRound({
    required this.icon,
    required this.onTap,
    this.iconSize = 19,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 38.r,
            height: 38.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ClubGlass.tileFill,
              shape: BoxShape.circle,
              border: Border.all(color: ClubGlass.tileBorder),
            ),
            child: Icon(icon, size: iconSize.r, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// '모두 읽음' 글래스 pill. 안 읽은 알림이 없으면 흐려지고 반응하지 않는다.
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

// ============================================================================
// SECTION LABEL
// ============================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      child: Row(
        children: [
          Text(
            label,
            style: ClubGlass.caption(
              color: ClubGlass.t2,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 12 * 0.04),
          ),
          SizedBox(width: 10.w),
          Text(
            '$count',
            style: ClubGlass.caption(
              color: ClubGlass.t4,
              weight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10.w),
          // 오른쪽으로 사라지는 헤어라인.
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x21FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NOTIFICATION CARD
// ============================================================================

class _NotiCard extends StatelessWidget {
  final NotificationItem noti;
  final VoidCallback onRead;

  const _NotiCard({required this.noti, required this.onRead});

  @override
  Widget build(BuildContext context) {
    final s = _styleOf(noti.type);
    final unread = !noti.read;
    final r = BorderRadius.circular(19.r);

    return GestureDetector(
      onTap: onRead,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: unread
              ? [
                  BoxShadow(
                    color: const Color(0x5C000000),
                    blurRadius: 30.r,
                    offset: Offset(0, 10.h),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: r,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              // 읽은 카드는 blur(14px) ≈ sigma 7로 한 단계 낮춘다.
              sigmaX: unread ? ClubGlass.blurSigma : 7,
              sigmaY: unread ? ClubGlass.blurSigma : 7,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: unread ? ClubGlass.cardFill : _quietFill,
                borderRadius: r,
                // 안 읽은 카드는 종류 색 링을 둘러 목록에서 먼저 눈에 띄게.
                border: Border.all(color: unread ? s.ring : _quietBorder),
              ),
              // 틴트는 패딩 바깥(카드 전체)에 깔려야 해서 Stack이 padding을 감싼다.
              child: Stack(
                children: [
                  if (unread)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            // 115deg — 좌상단에서 우하단으로 옅게 흐르는 종류 틴트.
                            gradient: LinearGradient(
                              begin: const Alignment(-0.9, -0.6),
                              end: const Alignment(0.6, 0.5),
                              colors: [s.tint, s.tint.withValues(alpha: 0)],
                              stops: const [0.0, 0.58],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // inset 0 1px 0 rgba(255,255,255,0.18/0.08) — 상단 1px 하이라이트.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: ColoredBox(
                      color: unread ? const Color(0x2EFFFFFF) : const Color(0x14FFFFFF),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(13.r),
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
        ),
      ),
    );
  }

  Widget _content(bool unread, _TypeStyle s) {
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
                child: Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    color: s.hue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: s.hue, blurRadius: 8.r),
                    ],
                  ),
                ),
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

/// 좌측 썸네일 (52) + 우하단 종류 아이콘 배지.
class _Thumb extends StatelessWidget {
  final List<Color> colors;
  final _TypeStyle style;

  const _Thumb({required this.colors, required this.style});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 57.r, // 52 + 배지가 -5 삐져나오는 만큼
      height: 57.r,
      child: Stack(
        clipBehavior: Clip.none,
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
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            // 좌상단 광택.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
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
  final _TypeStyle style;

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

// ============================================================================
// EMPTY / SKELETON
// ============================================================================

class _Empty extends StatelessWidget {
  final String label;
  const _Empty({required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 34,
      margin: EdgeInsets.only(top: 14.h),
      child: Column(
        children: [
          Container(
            width: 74.r,
            height: 74.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VybeColors.mainPurple500.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: VybeColors.mainPurple500.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 30.r,
              color: const Color(0x80FFFFFF),
            ),
          ),
          SizedBox(height: 13.h),
          Text(
            label,
            style: VybeTypography.heading4
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 13.h),
          Text(
            '새로운 소식이 오면\n여기에서 가장 먼저 알려드릴게요',
            textAlign: TextAlign.center,
            style: VybeTypography.body4
                .copyWith(color: ClubGlass.t3, height: 20 / 14),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 20.h, 4.w, 10.h),
            child: VybeShimmerBox(width: 54.w, height: 12.h, radius: 6.r),
          ),
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            const _SkeletonCard(),
          ],
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(19.r);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          padding: EdgeInsets.all(13.r),
          decoration: BoxDecoration(
            color: _quietFill,
            borderRadius: r,
            border: Border.all(color: _quietBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VybeShimmerBox(width: 44.r, height: 44.r, radius: 14.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 3.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VybeShimmerBox(
                        widthFactor: 0.62,
                        height: 13.h,
                        radius: 6.r,
                      ),
                      SizedBox(height: 8.h),
                      VybeShimmerBox(
                        widthFactor: 0.92,
                        height: 10.h,
                        radius: 6.r,
                      ),
                      SizedBox(height: 8.h),
                      VybeShimmerBox(
                        widthFactor: 0.45,
                        height: 10.h,
                        radius: 6.r,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 진입 애니메이션 (fadeIn + 6px 상승, 카드마다 45ms 지연)
// ============================================================================

class _FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeInUp({required this.child, required this.delay});

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _startTimer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 6.h * (1 - curved.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
