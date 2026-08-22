import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/my_page/widgets/setting_row.dart';

/// 설정 화면의 그룹 블록들. 화면은 상태만 들고 여기에 값·콜백을 넘긴다.

/// 마케팅 알림 토글 키. 이 토글만 값이 로컬이 아니라 서버
/// (`users.agreements.marketing`)에 있어서 **동의 기록과 같은 키**를 쓴다 —
/// 가입 때 받은 마케팅 수신 동의가 그대로 토글 기본값이 된다.
final String kMarketingToggleKey = LegalDoc.marketing.name;

/// 알림 그룹 — '푸시 알림'이 마스터.
///
/// 마스터를 끄면 하위 4개를 흐리게 하고 잠근다(디자인 opacity .4 +
/// pointer-events none). **값은 그대로 둔다** — 다시 켰을 때 이전 선택이
/// 살아 있어야 한다.
class SettingsNotificationGroup extends StatelessWidget {
  /// 토글 키 → 켬/끔. 키는 `push`·`showtime`·`saved`·`review`·`marketing`.
  final Map<String, bool> toggles;

  /// 토글 키를 넘겨 뒤집는다.
  final ValueChanged<String> onToggle;

  const SettingsNotificationGroup({
    super.key,
    required this.toggles,
    required this.onToggle,
  });

  bool get _pushOn => toggles['push'] ?? false;

  Widget _row({
    required String label,
    required String sub,
    required String key,
    String? icon,
    bool last = false,
  }) => SettingToggleRow(
    label: label,
    sub: sub,
    on: toggles[key] ?? false,
    onToggle: () => onToggle(key),
    icon: icon,
    last: last,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RenewSectionHead(title: '알림', sub: _pushOn ? null : '전체 꺼짐'),
        _row(
          label: '푸시 알림',
          sub: '전체 알림 받기',
          key: 'push',
          icon: RenewIcons.bell,
          // 하위가 잠기면 마스터가 곧 마지막 행이라 헤어라인을 지운다.
          last: !_pushOn,
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _pushOn ? 1 : 0.4,
          child: IgnorePointer(
            ignoring: !_pushOn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _row(
                  label: '공연 시작 알림',
                  sub: '찜한 클럽의 오늘 라인업 시작 전',
                  key: 'showtime',
                ),
                _row(label: '찜한 클럽 소식', sub: '이벤트 · 입장 혜택 업데이트', key: 'saved'),
                _row(
                  label: '리뷰 반응 알림',
                  sub: '내 리뷰에 좋아요·댓글이 달릴 때',
                  key: 'review',
                ),
                _row(
                  label: '마케팅 · 홍보 알림',
                  sub: '혜택·이벤트 정보 수신',
                  key: kMarketingToggleKey,
                  last: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 계정 그룹 — 고객센터 · 이용약관 · 로그아웃.
class SettingsAccountGroup extends StatelessWidget {
  final VoidCallback onSupport;

  /// 법적 고지 문서 목록 화면(`LegalScreen`)을 연다.
  final VoidCallback onLegal;

  final VoidCallback onLogout;

  const SettingsAccountGroup({
    super.key,
    required this.onSupport,
    required this.onLegal,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RenewSectionHead(title: '계정'),
        SettingRow(
          icon: RenewIcons.review,
          label: '고객센터 · 문의',
          control: const SettingValueChevron(),
          onTap: onSupport,
        ),
        // 법적 고지는 문서가 4종이라 설정 목록에 한 줄씩 늘어놓으면 계정 그룹이
        // 약관으로 가득 찬다 → '이용약관' 한 줄로 묶고 목록은 그 안에서 본다.
        // (문서 자체를 합치지는 않는다 — 개정일이 문서마다 다르다)
        SettingRow(
          icon: RenewIcons.doc,
          label: '이용약관',
          sub: '서비스 이용약관 · 개인정보처리방침 등',
          control: const SettingValueChevron(),
          onTap: onLegal,
        ),
        SettingRow(
          icon: RenewIcons.logout,
          label: '로그아웃',
          control: const SettingValueChevron(),
          onTap: onLogout,
          last: true,
        ),
      ],
    );
  }
}

/// 하단 밑줄 링크 (디자인 '탈퇴하기').
///
/// 메뉴 행으로 만들지 않는 이유는 되돌릴 수 없는 동작이라
/// 목록 안에 섞이면 안 되기 때문.
class SettingsLeaveLink extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsLeaveLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Text(
            '탈퇴하기',
            style: RenewGlass.caption(lineHeight: 14).copyWith(
              decoration: TextDecoration.underline,
              decorationColor: RenewGlass.t4,
            ),
          ),
        ),
      ),
    );
  }
}
