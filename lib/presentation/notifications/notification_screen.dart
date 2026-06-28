import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

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
  // 우측 썸네일 그라데이션 (없으면 미표시).
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
        thumb: thumb,
      );
}

// ── 종류별 색/아이콘 매핑 ──
class _TypeStyle {
  final IconData icon;
  final Color bg;
  final Color tint;
  const _TypeStyle(this.icon, this.bg, this.tint);
}

_TypeStyle _styleOf(NotiType type) {
  switch (type) {
    case NotiType.reservation:
      return _TypeStyle(Icons.confirmation_number_outlined,
          VybeColors.mainPurple700, VybeColors.mainPurple500.withValues(alpha: 0.10));
    case NotiType.club:
      return _TypeStyle(Icons.music_note_rounded, const Color(0xFF1F7A4D),
          VybeColors.mainLime500.withValues(alpha: 0.08));
    case NotiType.promo:
      return _TypeStyle(Icons.sell_outlined, const Color(0xFFCF3A5E),
          VybeColors.accentRed500.withValues(alpha: 0.08));
    case NotiType.activity:
      return _TypeStyle(Icons.favorite_rounded, VybeColors.accentBlue700,
          VybeColors.accentBlue500.withValues(alpha: 0.08));
    case NotiType.review:
      return _TypeStyle(Icons.star_rounded, const Color(0xFFA87A1E),
          const Color(0xFFFFC850).withValues(alpha: 0.07));
    case NotiType.friend:
      return _TypeStyle(Icons.person_outline_rounded, VybeColors.gray700,
          Colors.white.withValues(alpha: 0.04));
    case NotiType.notice:
      return _TypeStyle(Icons.campaign_outlined, VybeColors.gray700,
          Colors.white.withValues(alpha: 0.04));
  }
}

// ── 필터 ──
class _Filter {
  final String key;
  final String label;
  const _Filter(this.key, this.label);
}

const _filters = [
  _Filter('all', '전체'),
  _Filter('reservation', '예약·입장'),
  _Filter('club', '클럽 소식'),
  _Filter('promo', '프로모션'),
  _Filter('activity', '활동'),
];

// activity 필터는 activity/review/friend 를 함께 묶는다.
bool _matchesFilter(NotificationItem n, String key) {
  if (key == 'all') return true;
  if (key == 'activity') {
    return n.type == NotiType.activity ||
        n.type == NotiType.review ||
        n.type == NotiType.friend;
  }
  return n.type.name == key;
}

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
    thumb: [Color(0xFF7731FE), Color(0xFFFF4D8D)],
    cta: '예약 코드 보기',
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
    thumb: [Color(0xFF2B6BFF), Color(0xFF7731FE)],
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
  String _filter = 'all';
  List<NotificationItem> _notis = List.of(_dummyNotis);
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();
    // 디자인과 동일하게 잠깐 스켈레톤 노출.
    _loadTimer = Timer(const Duration(milliseconds: 1300), () {
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

  // 필터별 안읽음 카운트 (칩 배지).
  Map<String, int> get _counts {
    final m = <String, int>{};
    for (final f in _filters) {
      m[f.key] = _notis.where((n) => !n.read && _matchesFilter(n, f.key)).length;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final visible = _notis.where((n) => _matchesFilter(n, _filter)).toList();

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(unread: _unread, onReadAll: _unread > 0 ? _readAll : null),
            Expanded(
              child: _loading
                  ? const _Skeleton()
                  : _buildList(visible),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<NotificationItem> visible) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _FilterChips(
            active: _filter,
            counts: _counts,
            onChange: (k) => setState(() => _filter = k),
          ),
        ),
        if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _Empty(
              label: _filter == 'all' ? '알림이 없어요' : '해당하는 알림이 없어요',
            ),
          )
        else ...[
          for (final (sec, label) in _sections)
            if (visible.any((n) => n.section == sec)) ...[
              SliverToBoxAdapter(child: _SectionLabel(label: label)),
              SliverList.list(
                children: [
                  for (final n in visible.where((n) => n.section == sec))
                    _NotiRow(noti: n, onRead: () => _readOne(n.id)),
                ],
              ),
            ],
          SliverToBoxAdapter(child: SizedBox(height: 28.h)),
        ],
      ],
    );
  }
}

// ── 헤더 ──
class _Header extends StatelessWidget {
  final int unread;
  final VoidCallback? onReadAll;
  const _Header({required this.unread, this.onReadAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      padding: EdgeInsets.fromLTRB(4.w, 0, 8.w, 0),
      height: 52.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              VybeGlassButton(
                onTap: () => Navigator.of(context).maybePop(),
                size: 34,
                iconSize: 18,
                hitSize: 40,
              ),
              Text('알림',
                  style: VybeTypography.heading4
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              if (unread > 0) ...[
                SizedBox(width: 8.w),
                Container(
                  constraints: BoxConstraints(minWidth: 18.r),
                  height: 18.r,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: VybeColors.mainPurple500,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text('$unread',
                      style: VybeTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      )),
                ),
              ],
            ],
          ),
          GestureDetector(
            onTap: onReadAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded,
                      size: 15.r,
                      color: unread > 0
                          ? VybeColors.mainPurple500
                          : VybeColors.gray700),
                  SizedBox(width: 5.w),
                  Text('모두 읽음',
                      style: VybeTypography.button2.copyWith(
                        color: unread > 0 ? VybeColors.gray200 : VybeColors.gray700,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 필터 칩 ──
class _FilterChips extends StatelessWidget {
  final String active;
  final Map<String, int> counts;
  final ValueChanged<String> onChange;
  const _FilterChips(
      {required this.active, required this.counts, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      child: Row(
        children: [
          for (final f in _filters) ...[
            _chip(f, f.key == active, counts[f.key] ?? 0),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }

  Widget _chip(_Filter f, bool sel, int n) {
    return GestureDetector(
      onTap: () => onChange(f.key),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: sel ? VybeColors.mainPurple700 : VybeColors.gray900,
          borderRadius: BorderRadius.circular(999.r),
          border: sel ? null : Border.all(color: VybeColors.gray800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(f.label,
                style: VybeTypography.button2.copyWith(
                  color: sel ? Colors.white : VybeColors.gray300,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                )),
            if (n > 0) ...[
              SizedBox(width: 6.w),
              Text('$n',
                  style: VybeTypography.caption.copyWith(
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    color: sel
                        ? Colors.white.withValues(alpha: 0.75)
                        : VybeColors.mainPurple500,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 알림 행 ──
class _NotiRow extends StatelessWidget {
  final NotificationItem noti;
  final VoidCallback onRead;
  const _NotiRow({required this.noti, required this.onRead});

  @override
  Widget build(BuildContext context) {
    final s = _styleOf(noti.type);
    final unread = !noti.read;
    return GestureDetector(
      onTap: onRead,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: unread ? s.tint : Colors.transparent,
          border: Border(bottom: BorderSide(color: VybeColors.gray900)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Stack(
          children: [
            if (unread)
              Positioned(
                left: -20.w,
                top: 12.h,
                bottom: 12.h,
                child: Container(
                  width: 3.w,
                  decoration: BoxDecoration(
                    color: VybeColors.mainPurple500,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 종류 아이콘.
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: s.bg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(s.icon, size: 19.r, color: Colors.white),
                ),
                SizedBox(width: 13.w),
                Expanded(child: _content(unread)),
                _trailing(unread),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(bool unread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(noti.title,
                  style: VybeTypography.body4.copyWith(
                    fontSize: 15.sp,
                    height: 20 / 15,
                    color: unread ? Colors.white : VybeColors.gray200,
                    fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                  )),
            ),
            SizedBox(width: 8.w),
            Text(noti.time,
                style: VybeTypography.caption
                    .copyWith(color: VybeColors.gray600, height: 16 / 12)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(noti.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: VybeTypography.body4.copyWith(
              height: 19 / 14,
              color: unread ? VybeColors.gray400 : VybeColors.gray500,
            )),
        if (noti.cta != null) ...[
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: unread ? VybeColors.mainPurple500 : VybeColors.gray800,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(noti.cta!,
                    style: VybeTypography.button2.copyWith(
                      color: unread ? Colors.white : VybeColors.gray200,
                    )),
                Icon(Icons.chevron_right_rounded,
                    size: 13.r,
                    color: unread
                        ? Colors.white.withValues(alpha: 0.8)
                        : VybeColors.gray500),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _trailing(bool unread) {
    if (noti.thumb != null) {
      return Padding(
        padding: EdgeInsets.only(left: 13.w),
        child: SizedBox(
          width: 55.r,
          height: 55.r,
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
                    colors: noti.thumb!,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: VybeColors.gray900),
                ),
              ),
              if (unread)
                Positioned(
                  top: -3.r,
                  right: -3.r,
                  child: Container(
                    width: 9.r,
                    height: 9.r,
                    decoration: BoxDecoration(
                      color: VybeColors.mainPurple500,
                      shape: BoxShape.circle,
                      border: Border.all(color: VybeColors.background, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    if (unread) {
      return Padding(
        padding: EdgeInsets.only(left: 13.w, top: 6.h),
        child: Container(
          width: 8.r,
          height: 8.r,
          decoration: const BoxDecoration(
            color: VybeColors.mainPurple500,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ── 섹션 라벨 ──
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
      child: Text(label,
          style: VybeTypography.caption.copyWith(
            height: 14 / 12,
            fontWeight: FontWeight.w700,
            color: VybeColors.gray500,
          )),
    );
  }
}

// ── 빈 상태 ──
class _Empty extends StatelessWidget {
  final String label;
  const _Empty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 72.h, horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 72.r, color: VybeColors.gray700),
          SizedBox(height: 18.h),
          Text(label,
              style: VybeTypography.heading4
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('새로운 소식이 오면\n여기에서 가장 먼저 알려드릴게요',
              textAlign: TextAlign.center,
              style: VybeTypography.body4
                  .copyWith(color: VybeColors.gray500, height: 20 / 14)),
        ],
      ),
    );
  }
}

// ── 스켈레톤 ──
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            child: Row(
              children: [
                for (final w in [52, 72, 72, 66, 56]) ...[
                  _Shimmer(width: w.w, height: 34.h, radius: 999.r),
                  SizedBox(width: 8.w),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
            child: _Shimmer(width: 50.w, height: 12.h, radius: 6.r),
          ),
          for (var i = 0; i < 5; i++) const _SkeletonRow(),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Shimmer(width: 42.r, height: 42.r, radius: 12.r),
          SizedBox(width: 13.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 180.w, height: 14.h, radius: 6.r),
                  SizedBox(height: 9.h),
                  _Shimmer(width: 260.w, height: 11.h, radius: 6.r),
                  SizedBox(height: 9.h),
                  _Shimmer(width: 120.w, height: 11.h, radius: 6.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 좌→우 흐르는 shimmer.
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer(
      {required this.width, required this.height, required this.radius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) {
                final dx = (_c.value * 2 - 1) * rect.width * 1.5;
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    VybeColors.gray900,
                    VybeColors.gray800,
                    VybeColors.gray900,
                  ],
                ).createShader(
                    Rect.fromLTWH(dx, 0, rect.width, rect.height));
              },
              child: ColoredBox(color: VybeColors.gray900),
            );
          },
        ),
      ),
    );
  }
}
