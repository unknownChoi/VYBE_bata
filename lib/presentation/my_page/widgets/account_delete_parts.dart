import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 회원 탈퇴 화면 전용 조각 (디자인 account_delete.jsx / account_delete_parts.jsx)
//
// 화면(account_delete_screen.dart)은 조립 + 상태만 갖고, 그리는 건 전부 여기.
//
// ⚠ 디자인 원문과 **일부러 다르게** 쓴 문구가 있다 — 디자인 시안은
//   '30일 안에는 재가입할 수 있어요'라고 안내하지만 서버 동작은 다르다 —
//   보관 기간엔 **새 가입은 막히고**(checkPhoneDuplicate → pendingDeletion),
//   대신 같은 계정으로 다시 로그인하면 서버가 계정을 되살린다(복구).
//   새로 가입할 수 있는 건 파기일부터.
//   시안대로 쓰면 사용자가 다시 가입하려는 순간 거짓말이 드러난다.
// ============================================================

/// 보관 기간 — 서버 `RETENTION_DAYS`와 같은 값. **문구 계산용**이고,
/// 실제 파기 시각은 탈퇴 응답의 `purgeAt`을 그대로 쓴다.
const int kLeaveRetentionDays = 30;

/// `2026.09.19`
String leaveDateLabel(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.'
    '${d.day.toString().padLeft(2, '0')}';

/// `09.19` — 타임라인처럼 연도가 자명한 자리.
String leaveShortDate(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

// ============================================================
// 아이콘
// ============================================================

/// 이 화면에서만 쓰는 스트로크 패스 (디자인 `ADI`).
///
/// 공용 [RenewIcons]에 넣지 않는다 — 다른 화면이 쓰지 않는 6개를 공용 세트에
/// 섞으면 그쪽이 '어디서 쓰는 아이콘인지' 알 수 없는 목록이 된다.
class LeaveIcons {
  const LeaveIcons._();

  /// 리뷰 사진 — 사진.
  static const String photo =
      '<rect x="3" y="5" width="18" height="14" rx="2.4"/>'
      '<circle cx="8.5" cy="10" r="1.6"/>'
      '<path d="M21 16l-4.5-4.5L7 21"/>';

  /// 내가 쓴 리뷰 — 별.
  static const String star =
      '<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 '
      '12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>';

  /// 서비스 음료 — 칵테일 잔.
  static const String glass =
      '<path d="M5 4h14l-1.6 6.2A4 4 0 0 1 13.5 13H12v6"/>'
      '<line x1="8" y1="19" x2="16" y2="19"/>';

  /// 오늘의 라인업 — 음표.
  static const String music =
      '<path d="M9 18V5l12-2v13"/>'
      '<circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/>';

  /// VYBE PICK — 반짝임.
  static const String sparkle =
      '<path d="M12 3l2.1 5.4L19.5 10l-5.4 1.6L12 17l-2.1-5.4L4.5 10l5.4-1.6z"/>'
      '<path d="M18.5 16.5l.9 2.1 2.1.9-2.1.9-.9 2.1-.9-2.1-2.1-.9 2.1-.9z"/>';

  /// 완료 · 체크박스 — 체크.
  static const String check = '<polyline points="20 6 9 17 4 12"/>';

  /// 클럽 정보 — 돋보기.
  static const String search =
      '<circle cx="11" cy="11" r="7"/>'
      '<line x1="20" y1="20" x2="16.5" y2="16.5"/>';

  /// 개인정보 — 방패.
  static const String shield =
      '<path d="M12 3l8 3v6c0 4.6-3.3 8.2-8 9-4.7-.8-8-4.4-8-9V6z"/>'
      '<polyline points="9 12 11 14 15.5 9.5"/>';

  /// 의견 — 말풍선.
  static const String msg =
      '<path d="M21 12a8 8 0 0 1-11.6 7.1L3 21l1.9-6.4A8 8 0 1 1 21 12z"/>';
}

// ============================================================
// 섹션 헤더 (ADSection)
// ============================================================

/// 제목 + **줄바꿈된** 보조 문구 + 본문.
///
/// 공용 [RenewSectionHead]는 보조 문구를 제목 옆에 한 줄로 붙여 한 줄을 넘기면
/// 잘린다. 이 화면의 보조 문구는 전부 문장이라 아래 줄에 둔다.
class LeaveSection extends StatelessWidget {
  final String title;
  final String sub;
  final Widget child;

  const LeaveSection({
    super.key,
    required this.title,
    required this.sub,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: RenewGlass.title()),
        SizedBox(height: 6.h),
        Text(
          sub,
          style: RenewGlass.body(color: RenewGlass.t4, lineHeight: 20),
        ),
        SizedBox(height: 13.h),
        child,
      ],
    );
  }
}

// ============================================================
// 통계 카드 (ADStatCard)
// ============================================================

/// 찜·리뷰·사진 개수 3칸 + 붉은 경고 줄.
///
/// 숫자를 먼저 보여주는 이유 — "모든 데이터가 삭제됩니다" 같은 추상적인 문구는
/// 자기 리뷰 7개가 사라진다는 걸 알려주지 못한다.
class LeaveStatCard extends StatelessWidget {
  /// null이면 아직 로딩 중 — '-'로 그린다.
  final int? savedCount;
  final int? reviewCount;
  final int? photoCount;

  const LeaveStatCard({
    super.key,
    required this.savedCount,
    required this.reviewCount,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    return RenewGlassCard(
      padding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 18.h, bottom: 16.h),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _cell(RenewIcons.heart, savedCount, '곳', '찜한 클럽'),
                  _divider(),
                  _cell(LeaveIcons.star, reviewCount, '개', '내가 쓴 리뷰'),
                  _divider(),
                  _cell(LeaveIcons.photo, photoCount, '장', '리뷰 사진'),
                ],
              ),
            ),
          ),
          _warning(),
        ],
      ),
    );
  }

  Widget _divider() => const VerticalDivider(
    width: 1,
    thickness: 1,
    color: RenewGlass.hair,
  );

  Widget _cell(String icon, int? n, String unit, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RenewIcon(
            path: icon,
            size: 17,
            color: const Color(0x80FFFFFF), // rgba(255,255,255,0.5)
          ),
          SizedBox(height: 7.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                n?.toString() ?? '-',
                style: VybeTypography.heading2.copyWith(
                  fontSize: 27.sp,
                  height: 28 / 27,
                  color: RenewGlass.t1,
                ),
              ),
              SizedBox(width: 2.w),
              Text(unit, style: RenewGlass.body(color: RenewGlass.t3)),
            ],
          ),
          SizedBox(height: 7.h),
          Text(label, style: RenewGlass.caption(lineHeight: 14)),
        ],
      ),
    );
  }

  /// 카드 아래 붙는 붉은 경고 줄 — 숫자에 이어 "그래서 지금 어떻게 되는지".
  Widget _warning() {
    // 아직 세지 못했으면 숫자 없이 쓴다 — '리뷰 개와 사진 장이'처럼
    // 반쯤 빈 문장이 나오면 안 된다.
    final head = (reviewCount == null || photoCount == null)
        ? '탈퇴하는 순간 내가 쓴 리뷰와 사진이'
        : '탈퇴하는 순간 리뷰 $reviewCount개와 사진 $photoCount장이';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: kMyDanger.withValues(alpha: 0.07),
        border: const Border(top: BorderSide(color: RenewGlass.hair)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h, right: 8.w),
            child: const _BangBadge(size: 15, fontSize: 10),
          ),
          Expanded(
            child: Text(
              '$head 클럽 페이지에서 바로 내려가요. '
              '최근 검색 기록과 본인인증 상태도 함께 지워져요.',
              style: RenewGlass.caption(color: RenewGlass.t3, lineHeight: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// 붉은 원형 `!` 배지 — 경고 줄·확인 다이얼로그 공용.
class _BangBadge extends StatelessWidget {
  final double size;
  final double fontSize;

  const _BangBadge({required this.size, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kMyDanger.withValues(alpha: 0.18),
        border: Border.all(color: kMyDanger.withValues(alpha: 0.34)),
      ),
      child: Text(
        '!',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
          fontSize: fontSize.sp,
          height: 1,
          color: kMyDanger,
        ),
      ),
    );
  }
}

// ============================================================
// 놓치게 되는 것 (ADBenefitRow)
// ============================================================

/// 탈퇴하면 못 쓰게 되는 기능 한 줄.
class LeaveBenefit {
  final String icon;
  final Color hue;
  final String title;
  final String desc;

  const LeaveBenefit({
    required this.icon,
    required this.hue,
    required this.title,
    required this.desc,
  });
}

/// 돈·시간이 직접 걸린 기능부터 (디자인 AD_BENEFITS).
/// 여기 있는 6개는 전부 앱에 실제로 구현된 화면이다 — 없는 기능을 아쉬움으로
/// 내세우면 만류가 아니라 광고가 된다.
const List<LeaveBenefit> kLeaveBenefits = [
  LeaveBenefit(
    icon: RenewIcons.ticket,
    hue: VybeColors.mainLime500,
    title: '시간대별 무료입장',
    desc: '오늘 밤 무료로 들어갈 수 있는 클럽, 더는 안 보여요.',
  ),
  LeaveBenefit(
    icon: LeaveIcons.glass,
    hue: RenewGlass.link,
    title: '서비스 음료 정보',
    desc: '테이블당 맥주 6병 같은 조건을 미리 못 봐요.',
  ),
  LeaveBenefit(
    icon: RenewIcons.clock,
    hue: RenewGlass.lavender,
    title: '영업시간 · 메뉴판',
    desc: '오늘 여는지, 얼마인지 확인하던 게 사라져요.',
  ),
  LeaveBenefit(
    icon: LeaveIcons.music,
    hue: Color(0xFFFF9EDB),
    title: '오늘의 라인업',
    desc: '누가 트는지 보고 고르던 게 안 돼요.',
  ),
  LeaveBenefit(
    icon: RenewIcons.mega,
    hue: Color(0xFFFFC94D),
    title: '이벤트 공지',
    desc: 'VYBE에서만 여는 이벤트 소식을 못 받아요.',
  ),
  LeaveBenefit(
    icon: LeaveIcons.sparkle,
    hue: VybeColors.mainLime500,
    title: 'VYBE 추천',
    desc: '매주 새로 올라오는 큐레이션을 못 봐요.',
  ),
];

class LeaveBenefitRow extends StatelessWidget {
  final LeaveBenefit benefit;

  const LeaveBenefitRow({super.key, required this.benefit});

  @override
  Widget build(BuildContext context) {
    // 6줄이 한 화면에 겹쳐 있어 줄마다 BackdropFilter를 두지 않는다
    // (오로라 위에서는 블러 유무가 거의 안 보이는데 비용만 6배가 된다).
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: RenewGlass.quietFill,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: RenewGlass.quietBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: benefit.hue.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: benefit.hue.withValues(alpha: 0.34)),
            ),
            child: RenewIcon(path: benefit.icon, size: 17, color: benefit.hue),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit.title,
                    style: RenewGlass.body(
                      color: RenewGlass.t1,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    benefit.desc,
                    style: RenewGlass.caption(lineHeight: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 탈퇴 후 30일 (ADRejoinCard)
// ============================================================

/// 탈퇴 → 보관 → 파기 3단계 타임라인.
///
/// ⚠ 가운데 단계를 라임(= 괜찮음)으로 칠하지 않는다. 보관 기간에 되돌릴 수는
/// 있어도(재로그인 = 복구) 데이터가 내려가 있는 구간이라 '괜찮은 구간'처럼
/// 보이면 안 된다.
class LeaveTimelineCard extends StatelessWidget {
  /// 오늘(탈퇴 요청일).
  final DateTime leaveDate;

  /// 완전 파기 = 재가입 가능 시점.
  final DateTime purgeDate;

  const LeaveTimelineCard({
    super.key,
    required this.leaveDate,
    required this.purgeDate,
  });

  @override
  Widget build(BuildContext context) {
    final steps = <({String when, String title, String desc, Color color})>[
      (
        when: '오늘 ${leaveShortDate(leaveDate)}',
        title: '탈퇴 처리',
        desc: '찜·리뷰·사진이 즉시 내려가요. 앱에서 되돌리는 버튼은 없어요.',
        color: kMyDanger,
      ),
      (
        when: '~ ${leaveShortDate(purgeDate)}',
        title: '$kLeaveRetentionDays일 보관 기간',
        desc: '계정과 데이터가 보관돼요. 이 기간에 같은 계정으로 '
            '다시 로그인하면 계정이 복구돼요. 새로 가입하는 건 안 돼요.',
        color: RenewGlass.lavender,
      ),
      (
        when: '${leaveDateLabel(purgeDate)} 이후',
        title: '계정 정보 완전 삭제',
        desc: '보관된 데이터가 완전히 파기돼요. 복구 경로는 없고, '
            '이날부터 같은 번호로 새로 가입할 수 있어요.',
        color: VybeColors.gray600,
      ),
    ];

    return RenewGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _rail(steps[i].color, last: i == steps.length - 1),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: i == steps.length - 1 ? 0 : 18.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].when,
                            style: RenewGlass.caption(
                              color: steps[i].color,
                              lineHeight: 14,
                              weight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            steps[i].title,
                            style: RenewGlass.body(
                              color: RenewGlass.t1,
                              weight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            steps[i].desc,
                            style: RenewGlass.caption(lineHeight: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 점 + 아래로 이어지는 선.
  Widget _rail(Color color, {required bool last}) {
    return SizedBox(
      width: 10.r,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.h),
            width: 9.r,
            height: 9.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              // 디자인 box-shadow 0 0 0 3px {color}22
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.13),
                  spreadRadius: 3.r,
                ),
              ],
            ),
          ),
          if (!last)
            Expanded(
              child: Container(
                width: 1,
                margin: EdgeInsets.only(top: 4.h),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x38FFFFFF), Color(0x0FFFFFFF)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 탈퇴 이유 (ADReasons)
// ============================================================

/// 이유 칩을 고르면 펼쳐지는 대안 카드의 하단 버튼 동작.
enum LeaveReasonCta {
  /// 버튼 없음 — 보낼 곳이 없는 이유(클럽 제보·의견함이 아직 없다).
  none,
  settings,
  privacy,
}

class LeaveReason {
  /// 칩 라벨이자 서버로 보내는 `deletionReason` 값. **문구를 바꾸면 저장값도 바뀐다.**
  final String key;

  final String icon;
  final String title;
  final String desc;
  final LeaveReasonCta cta;
  final String ctaLabel;

  const LeaveReason({
    required this.key,
    required this.icon,
    required this.title,
    required this.desc,
    this.cta = LeaveReasonCta.none,
    this.ctaLabel = '',
  });
}

/// 이유 → 대안 (디자인 AD_REASONS).
///
/// ⚠ 디자인의 '클럽 제보하기'·'의견 보내기' 버튼은 뺐다 — 제보함·의견함이
/// 아직 없어서 버튼을 달면 눌러도 아무 데도 가지 않는다. 대신 이유는 실제로
/// 서버에 함께 저장되므로(`deletionReason`) 그 사실을 문구로 알린다.
const List<LeaveReason> kLeaveReasons = [
  LeaveReason(
    key: '이용 빈도가 낮아서',
    icon: RenewIcons.bell,
    title: '알림만 꺼도 괜찮아요',
    desc: '계정은 그대로 두고 알림만 끄면 앱이 조용해져요. '
        '필요할 때 찜·리뷰는 그대로 남아 있어요.',
    cta: LeaveReasonCta.settings,
    ctaLabel: '알림 설정 열기',
  ),
  LeaveReason(
    key: '원하는 클럽 정보가 없어서',
    icon: LeaveIcons.search,
    title: '클럽은 계속 늘어나고 있어요',
    desc: '지금 검색에 없는 곳도 순차로 올라와요. '
        '어떤 클럽을 찾으셨는지 아래 사유와 함께 남겨 주시면 확인해요.',
  ),
  LeaveReason(
    key: '앱 사용이 불편해서',
    icon: LeaveIcons.msg,
    title: '어떤 점이 불편했는지 알려 주세요',
    desc: '선택하신 이유는 탈퇴 요청과 함께 운영팀에 전달돼요. '
        '다음 업데이트에 반영할게요.',
  ),
  LeaveReason(
    key: '개인정보가 걱정돼서',
    icon: LeaveIcons.shield,
    title: '저장되는 정보는 이것뿐이에요',
    desc: '휴대폰 번호, 이름, 생년월일과 찜·리뷰 기록만 저장해요. '
        '위치는 앱을 쓰는 동안에만 쓰고 남기지 않아요.',
    cta: LeaveReasonCta.privacy,
    ctaLabel: '개인정보 처리방침',
  ),
  LeaveReason(
    key: '기타',
    icon: LeaveIcons.msg,
    title: '이유를 알려 주시면 도움이 돼요',
    desc: '남겨 주신 이유는 운영팀이 직접 확인해요.',
  ),
];

class LeaveReasonPicker extends StatelessWidget {
  /// 선택된 이유의 [LeaveReason.key]. null이면 미선택.
  final String? selected;
  final ValueChanged<String?> onSelect;
  final ValueChanged<LeaveReasonCta> onCta;

  const LeaveReasonPicker({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    LeaveReason? current;
    for (final reason in kLeaveReasons) {
      if (reason.key == selected) current = reason;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final reason in kLeaveReasons)
              _chip(reason, on: reason.key == selected),
          ],
        ),
        if (current != null) ...[
          SizedBox(height: 12.h),
          _alternative(current),
        ],
      ],
    );
  }

  Widget _chip(LeaveReason reason, {required bool on}) {
    return GestureDetector(
      onTap: () => onSelect(on ? null : reason.key),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: on
              ? VybeColors.mainPurple500.withValues(alpha: 0.28)
              : RenewGlass.tileFill,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: on
                ? VybeColors.mainPurple500.withValues(alpha: 0.60)
                : RenewGlass.tileBorder,
          ),
        ),
        child: Text(
          reason.key,
          style: RenewGlass.body(
            color: on ? RenewGlass.t1 : RenewGlass.t3,
            weight: on ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 고른 이유에 맞는 대안 카드. 보라 톤 — 만류가 아니라 '다른 방법' 제안.
  Widget _alternative(LeaveReason reason) {
    return MyFadeUp(
      // key로 이유가 바뀔 때마다 다시 떠오르게 한다.
      key: ValueKey(reason.key),
      child: RenewGlassCard(
        radius: 16,
        padding: 15,
        fill: VybeColors.mainPurple500.withValues(alpha: 0.16),
        border: VybeColors.mainPurple500.withValues(alpha: 0.38),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0x29FFFFFF)),
              ),
              child: RenewIcon(
                path: reason.icon,
                size: 16,
                color: RenewGlass.lavender,
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.title,
                    style: RenewGlass.body(
                      color: RenewGlass.t1,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    reason.desc,
                    style: RenewGlass.caption(
                      color: RenewGlass.t3,
                      lineHeight: 18,
                    ),
                  ),
                  if (reason.cta != LeaveReasonCta.none) ...[
                    SizedBox(height: 11.h),
                    _ctaButton(reason),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaButton(LeaveReason reason) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => onCta(reason.cta),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0x2EFFFFFF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reason.ctaLabel,
                style: VybeTypography.button2.copyWith(color: RenewGlass.t1),
              ),
              SizedBox(width: 5.w),
              const RenewChevron(
                dir: RenewChevronDir.right,
                size: 11,
                color: Color(0xB3FFFFFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 동의 체크 행
// ============================================================

/// 체크해야 '탈퇴하기'가 열린다. 오탭 한 번으로 계정이 사라지면 안 된다.
///
/// [nudge]가 true가 되는 동안 좌우로 흔들린다 — 미체크 상태로 탈퇴를 눌렀을 때
/// 어디를 봐야 하는지 알려주려고.
class LeaveAgreeRow extends StatefulWidget {
  final bool checked;
  final VoidCallback onTap;

  /// 값이 바뀔 때마다 한 번 흔든다(값 자체는 의미 없음 — 변화만 본다).
  final int nudgeTick;

  const LeaveAgreeRow({
    super.key,
    required this.checked,
    required this.onTap,
    required this.nudgeTick,
  });

  @override
  State<LeaveAgreeRow> createState() => _LeaveAgreeRowState();
}

class _LeaveAgreeRowState extends State<LeaveAgreeRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void didUpdateWidget(LeaveAgreeRow old) {
    super.didUpdateWidget(old);
    if (widget.nudgeTick != old.nudgeTick) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  /// 디자인 keyframes adNudge — -5 → +4 → -2 → 0 으로 잦아든다.
  double _offset(double t) {
    const stops = [0.0, 0.20, 0.45, 0.70, 1.0];
    const values = [0.0, -5.0, 4.0, -2.0, 0.0];
    for (var i = 0; i < stops.length - 1; i++) {
      if (t <= stops[i + 1]) {
        final p = (t - stops[i]) / (stops[i + 1] - stops[i]);
        return values[i] + (values[i + 1] - values[i]) * p;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.checked;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(_offset(_shake.value).w, 0),
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            color: on
                ? kMyDanger.withValues(alpha: 0.08)
                : RenewGlass.tileFill,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: on
                  ? kMyDanger.withValues(alpha: 0.30)
                  : RenewGlass.tileBorder,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 20.r,
                height: 20.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? kMyDanger : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: on ? kMyDanger : const Color(0xFF8F8F8F),
                    width: 1.4,
                  ),
                ),
                child: on
                    ? const RenewIcon(
                        path: LeaveIcons.check,
                        size: 11,
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : null,
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  '위 내용을 모두 확인했으며 동의합니다',
                  style: RenewGlass.body(
                    color: on ? RenewGlass.t1 : RenewGlass.t3,
                    lineHeight: 19,
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

// ============================================================
// 확인 다이얼로그 아이콘 · 완료 화면
// ============================================================

/// 확인 다이얼로그 상단의 붉은 `!` 타일 (디자인 ADDialog).
class LeaveDialogIcon extends StatelessWidget {
  const LeaveDialogIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.r,
      height: 46.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kMyDanger.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: kMyDanger.withValues(alpha: 0.30)),
      ),
      child: Text(
        '!',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
          fontSize: 22.sp,
          height: 1,
          color: kMyDanger,
        ),
      ),
    );
  }
}

/// 탈퇴 완료 안내 (디자인 ADDone).
///
/// ⚠ **라우트가 아니라 오버레이로 띄운다.** 탈퇴가 끝나면 세션이 끊겨
/// `AuthGate`가 루트 위 라우트를 전부 걷어내므로(popUntil), 화면으로 push하면
/// 뜨자마자 사라진다. 오버레이 엔트리는 라우트가 아니라 살아남는다.
class LeaveDoneOverlay {
  const LeaveDoneOverlay._();

  /// [purgeAt]은 서버가 돌려준 실제 파기 시각 — 이때부터 재가입할 수 있다.
  ///
  /// 오버레이는 `Navigator`와 무관하므로 호출 화면이 사라져도 남는다.
  /// [overlay]는 반드시 **await 전에** 잡아 둘 것.
  static void show(OverlayState overlay, DateTime purgeAt) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _LeaveDoneView(
        purgeAt: purgeAt,
        onClose: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _LeaveDoneView extends StatefulWidget {
  final DateTime purgeAt;
  final VoidCallback onClose;

  const _LeaveDoneView({required this.purgeAt, required this.onClose});

  @override
  State<_LeaveDoneView> createState() => _LeaveDoneViewState();
}

class _LeaveDoneViewState extends State<_LeaveDoneView> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: GestureDetector(
          // 뒤(웰컴 화면)로 탭이 새지 않게 막는다 — 확인 버튼으로만 닫는다.
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: RenewGlass.ink)),
              const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56.r,
                        height: 56.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: RenewGlass.tileFill,
                          border: Border.all(color: RenewGlass.tileBorder),
                        ),
                        child: const RenewIcon(
                          path: LeaveIcons.check,
                          size: 22,
                          color: VybeColors.mainLime500,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        '탈퇴가 완료됐어요',
                        style: VybeTypography.heading3.copyWith(
                          color: RenewGlass.t1,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '${leaveDateLabel(widget.purgeAt)}까지 데이터를 보관한 뒤\n'
                        '완전히 삭제해요. 그 전에 같은 계정으로\n'
                        '다시 로그인하면 계정이 복구돼요.',
                        textAlign: TextAlign.center,
                        style: RenewGlass.body(
                          color: RenewGlass.t3,
                          lineHeight: 22,
                        ),
                      ),
                      SizedBox(height: 26.h),
                      GestureDetector(
                        onTap: widget.onClose,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 200.w,
                          height: 52.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: VybeColors.mainPurple500,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '확인',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 17.sp,
                              height: 1,
                              letterSpacing: 17 * -0.025,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
