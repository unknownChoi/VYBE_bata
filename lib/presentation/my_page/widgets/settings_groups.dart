import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/my_page/widgets/setting_row.dart';

/// 설정 화면의 그룹 블록들. 화면은 상태만 들고 여기에 값·콜백을 넘긴다.

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
                  key: 'marketing',
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

/// 계정 그룹 — 고객센터 · 법적 고지 3종 · 로그아웃.
class SettingsAccountGroup extends StatelessWidget {
  final VoidCallback onSupport;
  final ValueChanged<LegalDoc> onLegal;
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
        // 법적 고지는 문서마다 별개다 — 한 화면에 뭉치면 어느 문서에 동의했는지
        // 확인할 수 없다. 마케팅 동의(선택)는 알림 설정에서 다루므로 여기선 뺀다.
        for (final doc in const [
          LegalDoc.terms,
          LegalDoc.privacy,
          LegalDoc.location,
        ])
          SettingRow(
            icon: RenewIcons.user,
            label: doc.title,
            control: const SettingValueChevron(),
            onTap: () => onLegal(doc),
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
