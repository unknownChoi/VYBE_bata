import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 리뉴얼 디자인 스트로크 아이콘 (디자인 `VRPATH` · `VRIcon`).
///
/// Material 아이콘은 채움(fill) 기반이라 획 두께·모서리 곡률이 디자인과 다르다.
/// 디자인의 24 viewBox 패스를 그대로 옮겨 두께 1.85 · 둥근 끝으로 그린다.
///
/// 색은 패스에 넣지 않고 [ColorFilter]로 입힌다 — 알파까지 그대로 반영되고
/// 패스 문자열은 상수로 남아 색마다 다시 파싱하지 않는다.
class RenewIcons {
  const RenewIcons._();

  /// 주소 — 지도 핀.
  static const String pin =
      '<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>'
      '<circle cx="12" cy="10" r="3"/>';

  /// 영업시간 — 시계.
  static const String clock =
      '<circle cx="12" cy="12" r="10"/>'
      '<polyline points="12 6 12 12 16 14"/>';

  /// 입장료 — 티켓.
  static const String ticket =
      '<path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2z"/>'
      '<path d="M13 5v2"/><path d="M13 17v2"/><path d="M13 11v2"/>';

  /// 인스타그램 등 외부 링크 — 체인.
  static const String link =
      '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/>'
      '<path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>';

  /// 전화 — 수화기.
  static const String phone =
      '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.37 1.9.72 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.35 1.85.59 2.81.72A2 2 0 0 1 22 16.92z"/>';

  /// 복사.
  static const String copy =
      '<rect x="9" y="9" width="12" height="12" rx="2"/>'
      '<path d="M5 15V5a2 2 0 0 1 2-2h8"/>';

  // ── 마이 리뉴얼 (디자인 MRPATH) ──

  /// 찜 — 하트.
  static const String heart =
      '<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78'
      'l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>';

  /// 리뷰 — 말풍선.
  static const String review =
      '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>';

  /// 알림 — 종.
  static const String bell =
      '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>'
      '<path d="M13.7 21a2 2 0 0 1-3.4 0"/>';

  /// 공지사항 — 확성기.
  static const String mega =
      '<path d="M3 11v2a1 1 0 0 0 1 1h2l5 4V6L6 10H4a1 1 0 0 0-1 1z"/>'
      '<path d="M16 8.5a4 4 0 0 1 0 7"/>';

  /// 설정 — 톱니.
  static const String gear =
      '<circle cx="12" cy="12" r="3"/>'
      '<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06'
      'a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09'
      'A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06'
      'a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09'
      'A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06'
      'a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09'
      'a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06'
      'a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09'
      'a1.65 1.65 0 0 0-1.51 1z"/>';

  /// 로그아웃 — 문 밖 화살표.
  static const String logout =
      '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>'
      '<polyline points="16 17 21 12 16 7"/>'
      '<line x1="21" y1="12" x2="9" y2="12"/>';

  /// 프로필 사진 변경 — 카메라.
  static const String camera =
      '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>'
      '<circle cx="12" cy="13" r="3.6"/>';

  /// 회원 탈퇴 — 사용자에서 빼기.
  static const String userMinus =
      '<circle cx="9" cy="8" r="4"/>'
      '<path d="M1 21c0-4.4 3.6-8 8-8 1.6 0 3.1.5 4.4 1.3"/>'
      '<line x1="16" y1="17" x2="23" y2="17"/>';

  /// 수정 — 연필.
  static const String pencil =
      '<path d="M17 3a2.83 2.83 0 0 1 4 4L7.5 20.5 2 22l1.5-5.5z"/>';

  /// 삭제 — 휴지통.
  static const String trash =
      '<polyline points="3 6 5 6 21 6"/>'
      '<path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>'
      '<path d="M10 11v6M14 11v6"/>';

  /// 테마 — 초승달.
  static const String moon =
      '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>';

  /// 언어 — 지구본.
  static const String globe =
      '<circle cx="12" cy="12" r="9"/>'
      '<path d="M3.6 9h16.8M3.6 15h16.8"/>'
      '<path d="M12 3a15 15 0 0 1 0 18 15 15 0 0 1 0-18z"/>';

  /// 자동 로그인 유지 — 자물쇠. (디자인엔 없는 항목 — 기기에 저장되는 설정이라
  /// '보안' 계열 아이콘을 붙였다)
  static const String lock =
      '<rect x="3" y="11" width="18" height="11" rx="2"/>'
      '<path d="M7 11V7a5 5 0 0 1 10 0v4"/>';

  /// 사용자 — 로그인 안내·빈 상태.
  static const String user =
      '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8"/>';
}

/// 디자인 `VRIcon` — 24 viewBox · 스트로크 · 둥근 끝.
class RenewIcon extends StatelessWidget {
  /// [RenewIcons]의 패스 문자열.
  final String path;

  /// CSS px 기준 한 변 길이 (디자인 기본 18).
  final double size;

  final Color color;

  /// 디자인 `w` — 스트로크 두께.
  final double strokeWidth;

  /// 기본색은 `RenewGlass.t2`와 같은 값 — renew_glass가 이 파일을 쓰므로
  /// 반대 방향 import를 만들지 않으려고 리터럴로 둔다.
  const RenewIcon({
    super.key,
    required this.path,
    this.size = 18,
    this.color = const Color(0xD1FFFFFF),
    this.strokeWidth = 1.85,
  });

  @override
  Widget build(BuildContext context) {
    final side = size.r;
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="#FFFFFF" stroke-width="$strokeWidth" '
      'stroke-linecap="round" stroke-linejoin="round">$path</svg>',
      width: side,
      height: side,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// 디자인 `VRChev` — 펼침/이동 꺾쇠. 두께가 아이콘보다 두껍다(2.2).
class RenewChevron extends StatelessWidget {
  final RenewChevronDir dir;
  final double size;
  final Color color;
  final double strokeWidth;

  const RenewChevron({
    super.key,
    this.dir = RenewChevronDir.down,
    this.size = 16,
    this.color = const Color(0x80FFFFFF),
    this.strokeWidth = 2.2,
  });

  static const Map<RenewChevronDir, String> _points = {
    RenewChevronDir.down: '6 9 12 15 18 9',
    RenewChevronDir.right: '9 6 15 12 9 18',
    RenewChevronDir.left: '15 18 9 12 15 6',
  };

  @override
  Widget build(BuildContext context) {
    return RenewIcon(
      path: '<polyline points="${_points[dir]}"/>',
      size: size,
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

enum RenewChevronDir { down, right, left }
