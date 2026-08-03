import 'package:flutter/material.dart';
import 'package:vybe/design_system/colors.dart';

/// 알림 프레젠테이션 모델 · 종류별 스타일 · 더미 데이터.
///
/// 백엔드(`notifications` 컬렉션) 연동 전이라 data 레이어 모델이 아니라
/// 화면 전용 모델로 둔다. 실연동 시 이 파일의 [kDummyNotifications]만 걷어내고
/// 모델을 `data/models/`의 Freezed 모델로 교체하면 된다.

// ── 알림 종류 ──
enum NotiType { reservation, club, promo, activity, review, friend, notice }

// ── 섹션(시간 그룹) ──
enum NotiSection { today, week, earlier }

/// 섹션 노출 순서 + 라벨.
const kNotiSections = [
  (NotiSection.today, '오늘'),
  (NotiSection.week, '이번 주'),
  (NotiSection.earlier, '이전'),
];

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

// ── 종류별 색/아이콘 매핑 (디자인 NG_TYPES) ──
// hue = 아이콘 색, tint = 타일·카드 틴트, ring = 카드 외곽 링.
class NotiTypeStyle {
  final IconData icon;
  final Color hue;
  final Color tint;
  final Color ring;

  const NotiTypeStyle(this.icon, this.hue, this.tint, this.ring);
}

const _kTypeStyles = <NotiType, NotiTypeStyle>{
  NotiType.reservation: NotiTypeStyle(
    Icons.confirmation_number_outlined,
    VybeColors.mainPurple500,
    Color(0x387731FE), // rgba(119,49,254,0.22)
    Color(0x737731FE), // rgba(119,49,254,0.45)
  ),
  NotiType.club: NotiTypeStyle(
    Icons.music_note_rounded,
    VybeColors.mainLime500,
    Color(0x29B5FF60), // rgba(181,255,96,0.16)
    Color(0x61B5FF60), // rgba(181,255,96,0.38)
  ),
  NotiType.promo: NotiTypeStyle(
    Icons.sell_outlined,
    Color(0xFFFF5C7A),
    Color(0x2EFF5C7A), // rgba(255,92,122,0.18)
    Color(0x66FF5C7A), // rgba(255,92,122,0.40)
  ),
  NotiType.activity: NotiTypeStyle(
    Icons.favorite_rounded,
    Color(0xFF5B8CFF),
    Color(0x2E5B8CFF),
    Color(0x665B8CFF),
  ),
  NotiType.review: NotiTypeStyle(
    Icons.star_rounded,
    Color(0xFFFFC94D),
    Color(0x29FFC94D),
    Color(0x5CFFC94D),
  ),
  NotiType.friend: NotiTypeStyle(
    Icons.person_outline_rounded,
    Color(0xE6FFFFFF),
    Color(0x1AFFFFFF),
    Color(0x33FFFFFF),
  ),
  NotiType.notice: NotiTypeStyle(
    Icons.campaign_outlined,
    Color(0xE6FFFFFF),
    Color(0x1AFFFFFF),
    Color(0x33FFFFFF),
  ),
};

NotiTypeStyle notiStyleOf(NotiType type) => _kTypeStyles[type]!;

// ── 더미 데이터 (백엔드 연동 전) ──
const kDummyNotifications = <NotificationItem>[
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
