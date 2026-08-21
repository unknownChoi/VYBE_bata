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
import 'package:vybe/presentation/my_page/widgets/setting_row.dart';
import 'package:vybe/presentation/my_page/widgets/settings_groups.dart';

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
                      SettingsNotificationGroup(
                        toggles: _toggles,
                        onToggle: _toggle,
                      ),
                      SizedBox(height: _kGroupGap.h),
                      _generalGroup(),
                      SizedBox(height: _kGroupGap.h),
                      _dataGroup(),
                      SizedBox(height: _kGroupGap.h),
                      SettingsAccountGroup(
                        onSupport: () =>
                            VybeToast.show(context, message: '고객센터는 준비 중이에요'),
                        onLegal: _openLegal,
                        onLogout: _confirmLogout,
                      ),
                      SizedBox(height: _kGroupGap.h),
                      const RenewFooterNote(
                        text:
                            '탈퇴하면 작성한 리뷰·사진은 바로 숨겨지고 30일 뒤 완전히 삭제돼요. '
                            '데이터 이관은 고객센터를 통해 처리돼요.',
                      ),
                      SizedBox(height: 18.h),
                      SettingsLeaveLink(
                        onTap: () => pushHidingNavBar<void>(
                          context,
                          const AccountDeleteScreen(),
                        ),
                      ),
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

  Widget _generalGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RenewSectionHead(title: '일반'),
        SettingRow(
          icon: RenewIcons.lock,
          label: '자동 로그인 유지',
          sub: '앱을 껐다 켜도 로그인 상태 유지',
          control: MyToggle(on: _autoLogin, onTap: _toggleAutoLogin),
        ),
        _toggleRow(
          label: '위치 서비스',
          sub: '내 주변 클럽 추천에 사용',
          key: 'location',
          icon: RenewIcons.pin,
        ),
        _toggleRow(
          label: '사운드 및 진동',
          sub: '앱 효과음',
          key: 'sound',
          icon: RenewIcons.mega,
        ),
        SettingRow(
          icon: RenewIcons.moon,
          label: '테마',
          control: const SettingValueChevron(value: '다크'),
          onTap: () => VybeToast.show(context, message: '지금은 다크 테마만 지원해요'),
        ),
        SettingRow(
          icon: RenewIcons.globe,
          label: '언어',
          control: const SettingValueChevron(value: '한국어'),
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
        SettingRow(
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

  /// 토글 상태를 [_toggles] 에서 읽어오는 설정 행.
  Widget _toggleRow({
    required String label,
    required String sub,
    required String key,
    String? icon,
    bool last = false,
  }) => SettingToggleRow(
    label: label,
    sub: sub,
    on: _toggles[key] ?? false,
    onToggle: () => _toggle(key),
    icon: icon,
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
