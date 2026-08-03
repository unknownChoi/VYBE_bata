import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';

/// 공지사항 리퀴드 글래스 조각들 (디자인 notice_glass.jsx).
///
/// 카테고리 색, 배지 pill(중요·카테고리·NEW·운영팀), 하단 잠금 안내가
/// 목록·상세 화면 공용이라 여기 모아 둔다.

/// 카드 라운드 · 내부 여백 (CSS px, `.r` 적용).
const double kNoticeCardRadius = 19;
const double kNoticeCardPad = 15;

/// 카테고리별 색 (디자인 NC_CATS).
class NoticeCatStyle {
  final String label;

  /// 라벨 색.
  final Color hue;

  /// 배지 채움 · 고정 공지 카드 틴트.
  final Color tint;

  /// 배지 테두리 · 고정 공지 카드 링.
  final Color ring;

  const NoticeCatStyle(this.label, this.hue, this.tint, this.ring);
}

const _kCatStyles = <String, NoticeCatStyle>{
  'notice': NoticeCatStyle(
    '공지',
    Color(0xEBFFFFFF), // rgba(255,255,255,0.92)
    Color(0x1AFFFFFF), // rgba(255,255,255,0.10)
    Color(0x38FFFFFF), // rgba(255,255,255,0.22)
  ),
  'update': NoticeCatStyle(
    '업데이트',
    Color(0xFFC7A6FF),
    Color(0x387731FE), // rgba(119,49,254,0.22)
    Color(0x737731FE), // rgba(119,49,254,0.45)
  ),
  'event': NoticeCatStyle(
    '이벤트',
    VybeColors.mainLime500,
    Color(0x29B5FF60), // rgba(181,255,96,0.16)
    Color(0x61B5FF60), // rgba(181,255,96,0.38)
  ),
  'maint': NoticeCatStyle(
    '점검',
    Color(0xFFFFC94D),
    Color(0x29FFC94D), // rgba(255,201,77,0.16)
    Color(0x5CFFC94D), // rgba(255,201,77,0.36)
  ),
};

/// 알 수 없는 category는 '공지' 스타일로 폴백 (모델 [NoticeModel.categoryLabel]과 동일 규칙).
NoticeCatStyle noticeCatStyleOf(String category) =>
    _kCatStyles[category] ?? _kCatStyles['notice']!;

/// 운영팀 배지 색 (보라 pill).
const Color _kTeamHue = Color(0xFFC7A6FF);
const Color _kTeamFill = Color(0x387731FE); // rgba(119,49,254,0.22)
const Color _kTeamBorder = Color(0x6B7731FE); // rgba(119,49,254,0.42)

/// 카테고리 pill — 공지 / 업데이트 / 이벤트 / 점검.
class NoticeCategoryPill extends StatelessWidget {
  final NoticeCatStyle style;

  /// 글자 크기 (목록 10.5 · 상세 11).
  final double fontSize;

  const NoticeCategoryPill({
    super.key,
    required this.style,
    this.fontSize = 10.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: style.tint,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: style.ring),
      ),
      child: Text(
        style.label,
        style: ClubGlass.caption(
          color: style.hue,
          size: fontSize,
          lineHeight: 13,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 고정 공지 '중요' pill (라임).
class NoticeImportantPill extends StatelessWidget {
  /// 글자 크기 (목록 10 · 상세 10.5).
  final double fontSize;

  const NoticeImportantPill({super.key, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 3.h, 8.w, 3.h),
      decoration: BoxDecoration(
        color: const Color(0x29B5FF60), // rgba(181,255,96,0.16)
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0x61B5FF60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.push_pin_rounded,
            size: (fontSize + 1).r,
            color: VybeColors.mainLime500,
          ),
          SizedBox(width: 4.w),
          Text(
            '중요',
            style: ClubGlass.caption(
              color: VybeColors.mainLime500,
              size: fontSize,
              lineHeight: 13,
              weight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 최근 게시(7일 이내) NEW 배지 — 라임 채움 + 잉크 글자.
class NoticeNewBadge extends StatelessWidget {
  final double fontSize;

  const NoticeNewBadge({super.key, this.fontSize = 9.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: VybeColors.mainLime500,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        'NEW',
        style: ClubGlass.caption(
          color: ClubGlass.ink,
          size: fontSize,
          lineHeight: 12,
          weight: FontWeight.w800,
        ).copyWith(letterSpacing: fontSize * 0.04),
      ),
    );
  }
}

/// 'vybe 운영팀' 보라 pill — 헤더·상세 메타 공용.
class NoticeTeamPill extends StatelessWidget {
  const NoticeTeamPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(7.w, 4.h, 9.w, 4.h),
      decoration: BoxDecoration(
        color: _kTeamFill,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: _kTeamBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 12.r, color: _kTeamHue),
          SizedBox(width: 5.w),
          Text(
            'vybe 운영팀',
            style: ClubGlass.caption(
              color: _kTeamHue,
              size: 11,
              lineHeight: 13,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// '공지사항은 vybe 운영팀만 등록할 수 있어요' 안내 (자물쇠 + 문구).
///
/// 앱에서 공지를 쓸 수 없는 이유를 알려주는 줄 — 목록 하단·상세 본문 끝에 붙는다.
class NoticeLockNote extends StatelessWidget {
  const NoticeLockNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 12.r,
          color: const Color(0x80FFFFFF),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            '공지사항은 vybe 운영팀만 등록할 수 있어요',
            textAlign: TextAlign.center,
            style: ClubGlass.caption(
              color: ClubGlass.t4,
              size: 11.5,
              lineHeight: 16,
            ),
          ),
        ),
      ],
    );
  }
}
