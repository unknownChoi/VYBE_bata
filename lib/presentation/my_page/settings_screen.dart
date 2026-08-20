import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/storage/local_prefs.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/auth/terms/terms_detail_screen.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_dialog.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';
import 'package:vybe/presentation/my_page/account_delete_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/settings_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 설정 — 리뉴얼 (my_renew.html · MRSettingsScreen)
//
// 알림 / 일반 / 데이터 / 계정 4개 그룹 + 안내 문구 + 탈퇴하기 + 버전.
// 행은 카드로 감싸지 않고 헤어라인으로만 나눈다(디자인 MRSetRow).
//
// 디자인과 다른 점
// - **알림·위치·사운드 토글은 로컬 상태만** — 베타 범위에 설정 서버 저장도,
//   푸시 연동도 없다. 저장해 두면 동작하지 않는 설정이 켜져 있는 것처럼 보인다.
// - **자동 로그인 유지**는 디자인에 없지만 실제 동작이 걸린 설정이라 남겼다.
//   유일하게 기기에 저장된다([LocalPrefs]).
// - **테마·언어**는 값 + 꺾쇠까지 디자인대로 그리되 고를 것이 하나뿐이라
//   탭하면 안내 토스트만 띄운다(빈 화면으로 보내지 않는다).
// - 디자인 '계정 삭제는 고객센터' 문구는 앱에 실제 탈퇴 기능이 있어 교체.
// ============================================================

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

/// 디자인 MRSettingsScreen 그룹 사이 간격.
const double _kGroupGap = 26;

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Map<String, bool> _toggles = {
    'push': true,
    'showtime': true,
    'saved': true,
    'review': false,
    'marketing': false,
    'location': true,
    'sound': true,
  };
  bool _clearing = false;

  /// 자동 로그인 유지 — 유일하게 기기에 저장되는 설정.
  /// 저장값을 읽어오기 전에는 기본값(켜짐)으로 그린다.
  bool _autoLogin = true;

  bool get _pushOn => _toggles['push'] ?? false;

  @override
  void initState() {
    super.initState();
    _loadAutoLogin();
  }

  Future<void> _loadAutoLogin() async {
    try {
      final prefs = await ref.read(localPrefsProvider.future);
      if (!mounted) return;
      setState(() => _autoLogin = prefs.autoLogin);
    } catch (_) {
      // 저장소를 못 열면 기본값(켜짐) 그대로 — 앱 시작 판정도 같은 기본값을 쓴다.
    }
  }

  Future<void> _toggleAutoLogin() async {
    final next = !_autoLogin;
    setState(() => _autoLogin = next);
    try {
      final prefs = await ref.read(localPrefsProvider.future);
      await prefs.setAutoLogin(next);
    } catch (_) {
      if (!mounted) return;
      setState(() => _autoLogin = !next); // 저장 실패 → 화면도 되돌린다
    }
  }

  void _toggle(String key) =>
      setState(() => _toggles[key] = !(_toggles[key] ?? false));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RenewGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MyPushHeader(title: '설정'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    kMyPagePad.w,
                    18.h,
                    kMyPagePad.w,
                    40.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _notificationGroup(),
                      SizedBox(height: _kGroupGap.h),
                      _generalGroup(),
                      SizedBox(height: _kGroupGap.h),
                      _dataGroup(),
                      SizedBox(height: _kGroupGap.h),
                      _accountGroup(),
                      SizedBox(height: _kGroupGap.h),
                      const RenewFooterNote(
                        text: '탈퇴하면 작성한 리뷰·사진은 바로 숨겨지고 30일 뒤 완전히 삭제돼요. '
                            '데이터 이관은 고객센터를 통해 처리돼요.',
                      ),
                      SizedBox(height: 18.h),
                      _leaveLink(),
                      SizedBox(height: 8.h),
                      const AppVersionLabel(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ 그룹 ============

  /// 알림 — '푸시 알림'이 마스터. 끄면 하위 4개를 흐리게 하고 잠근다
  /// (디자인 opacity .4 + pointer-events none). 값은 그대로 둔다 —
  /// 다시 켰을 때 이전 선택이 살아 있어야 한다.
  Widget _notificationGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RenewSectionHead(title: '알림', sub: _pushOn ? null : '전체 꺼짐'),
        _toggleRow(
          '푸시 알림',
          '전체 알림 받기',
          'push',
          icon: RenewIcons.bell,
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
                _toggleRow('공연 시작 알림', '찜한 클럽의 오늘 라인업 시작 전', 'showtime'),
                _toggleRow('찜한 클럽 소식', '이벤트 · 입장 혜택 업데이트', 'saved'),
                _toggleRow('리뷰 반응 알림', '내 리뷰에 좋아요·댓글이 달릴 때', 'review'),
                _toggleRow('마케팅 · 홍보 알림', '혜택·이벤트 정보 수신', 'marketing', last: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _generalGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RenewSectionHead(title: '일반'),
        _row(
          icon: RenewIcons.lock,
          label: '자동 로그인 유지',
          sub: '앱을 껐다 켜도 로그인 상태 유지',
          control: MyToggle(on: _autoLogin, onTap: _toggleAutoLogin),
        ),
        _toggleRow('위치 서비스', '내 주변 클럽 추천에 사용', 'location', icon: RenewIcons.pin),
        _toggleRow('사운드 및 진동', '앱 효과음', 'sound', icon: RenewIcons.mega),
        _row(
          icon: RenewIcons.moon,
          label: '테마',
          control: const _ValueChevron(value: '다크'),
          onTap: () => VybeToast.show(context, message: '지금은 다크 테마만 지원해요'),
        ),
        _row(
          icon: RenewIcons.globe,
          label: '언어',
          control: const _ValueChevron(value: '한국어'),
          onTap: () => VybeToast.show(context, message: '지금은 한국어만 지원해요'),
          last: true,
        ),
      ],
    );
  }

  Widget _dataGroup() {
    // 실제 임시 디렉토리 용량. 순회 중에는 숫자 대신 상태를 그대로 쓴다
    // ('계산 중… 사용 중'처럼 붙어 읽히지 않게 문장 전체를 갈아 끼운다).
    final sizeLabel = ref
        .watch(cacheManagerProvider)
        .when(
          data: (bytes) => '${formatCacheSize(bytes)} 사용 중',
          loading: () => '용량 계산 중…',
          error: (_, __) => '용량을 확인할 수 없어요',
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RenewSectionHead(title: '데이터'),
        _row(
          icon: RenewIcons.trash,
          label: '캐시 삭제',
          sub: sizeLabel,
          control: RenewChip(
            label: _clearing ? '삭제 중…' : '삭제',
            selected: false,
            onTap: _clearCache,
          ),
          last: true,
        ),
      ],
    );
  }

  void _openLegal(LegalDoc doc) =>
      pushHidingNavBar<void>(context, TermsDetailScreen(doc: doc));

  Widget _accountGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RenewSectionHead(title: '계정'),
        _row(
          icon: RenewIcons.review,
          label: '고객센터 · 문의',
          control: const _ValueChevron(),
          onTap: () => VybeToast.show(context, message: '고객센터는 준비 중이에요'),
        ),
        // 법적 고지는 문서마다 별개다 — 한 화면에 뭉치면 어느 문서에 동의했는지
        // 확인할 수 없다. 마케팅 동의(선택)는 알림 설정에서 다루므로 여기선 뺀다.
        _row(
          icon: RenewIcons.user,
          label: LegalDoc.terms.title,
          control: const _ValueChevron(),
          onTap: () => _openLegal(LegalDoc.terms),
        ),
        _row(
          icon: RenewIcons.user,
          label: LegalDoc.privacy.title,
          control: const _ValueChevron(),
          onTap: () => _openLegal(LegalDoc.privacy),
        ),
        _row(
          icon: RenewIcons.user,
          label: LegalDoc.location.title,
          control: const _ValueChevron(),
          onTap: () => _openLegal(LegalDoc.location),
        ),
        _row(
          icon: RenewIcons.logout,
          label: '로그아웃',
          control: const _ValueChevron(),
          onTap: _confirmLogout,
          last: true,
        ),
      ],
    );
  }

  /// 하단 밑줄 링크 (디자인 '탈퇴하기'). 메뉴 행으로 만들지 않는 이유는
  /// 되돌릴 수 없는 동작이라 목록 안에 섞이면 안 되기 때문.
  Widget _leaveLink() {
    return Center(
      child: GestureDetector(
        onTap: () =>
            pushHidingNavBar<void>(context, const AccountDeleteScreen()),
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

  // ============ 행 ============

  /// 설정 행 (MRSetRow) — `[아이콘] 라벨/보조설명 ... 컨트롤`.
  ///
  /// [onTap]을 주면 행 전체가 눌린다(값+꺾쇠 행). 토글 행은 토글만 눌린다 —
  /// 행 전체를 누르게 하면 스크롤하다 실수로 켜진다.
  Widget _row({
    String? icon,
    required String label,
    String? sub,
    required Widget control,
    VoidCallback? onTap,
    bool last = false,
  }) {
    final row = Container(
      constraints: BoxConstraints(minHeight: 46.h),
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: RenewGlass.hair)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 30.r,
              height: 30.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: RenewGlass.tileFill,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: RenewGlass.tileBorder),
              ),
              child: RenewIcon(
                path: icon,
                size: 15,
                color: RenewGlass.t2,
                strokeWidth: 1.9,
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: RenewGlass.body(color: RenewGlass.t1)),
                if (sub != null) ...[
                  SizedBox(height: 3.h),
                  Text(sub, style: RenewGlass.caption(lineHeight: 15)),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          control,
        ],
      ),
    );

    if (onTap == null) return row;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }

  Widget _toggleRow(
    String label,
    String sub,
    String key, {
    String? icon,
    bool last = false,
  }) => _row(
    icon: icon,
    label: label,
    sub: sub,
    control: MyToggle(on: _toggles[key] ?? false, onTap: () => _toggle(key)),
    last: last,
  );

  // ============ 동작 ============

  Future<void> _clearCache() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    try {
      await ref.read(cacheManagerProvider.notifier).clearCache();
      if (!mounted) return;
      VybeToast.show(context, message: '캐시를 삭제했어요');
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await VybeConfirmDialog.show(
      context,
      title: '로그아웃할까요?',
      message: '언제든 다시 로그인할 수 있어요.',
      confirmLabel: '로그아웃',
    );
    if (!confirmed) return;

    // 로그아웃하면 AuthGate가 루트를 WelcomeScreen으로 교체하고
    // 그 위에 쌓인 라우트(이 화면 포함)를 전부 정리한다.
    await ref.read(authViewModelProvider.notifier).signOut();
  }
}

/// 값 + 꺾쇠 (디자인 MRSetValue). 값이 없으면 꺾쇠만.
class _ValueChevron extends StatelessWidget {
  final String? value;

  const _ValueChevron({this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null) ...[
          Text(
            value!,
            style: RenewGlass.caption(color: RenewGlass.t3, lineHeight: 14),
          ),
          SizedBox(width: 4.w),
        ],
        const RenewChevron(
          dir: RenewChevronDir.right,
          size: 12,
          color: RenewGlass.t4,
          strokeWidth: 2,
        ),
      ],
    );
  }
}
