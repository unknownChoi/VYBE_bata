import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/storage/local_prefs.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/viewmodels/settings_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 설정 — 리뉴얼 (my_renew.html · MRSettingsScreen)
//
// 디자인과 다른 점: 알림·일반 토글 값은 로컬 상태만 사용 — 베타 범위에
// 설정 서버 저장이 없어 Firestore 연동 없이 화면 상태로만 동작.
// (실제 푸시 연동이 없는 값을 저장하면 동작하지 않는 설정이 동작하는 것처럼
//  보인다 — 그래서 저장하지 않는다)
//
// 예외로 **자동 로그인만** 기기에 저장한다([LocalPrefs]) — 앱 시작 시
// 세션을 유지할지 판단하는 실제 동작이 걸려 있다.
// 캐시 삭제는 실동작 (임시 디렉토리 + 메모리 이미지 캐시).
// ============================================================

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MyPushHeader(title: '설정'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                kMyPagePad.w,
                kMySectionGap.h,
                kMyPagePad.w,
                40.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RenewSectionHead(title: '알림'),
                  _toggleRow('푸시 알림', '전체 알림 받기', 'push'),
                  _toggleRow('공연 시작 알림', '찜한 클럽의 오늘 라인업 시작 전', 'showtime'),
                  _toggleRow('찜한 클럽 소식', '이벤트 · 입장 혜택 업데이트', 'saved'),
                  _toggleRow('리뷰 반응 알림', '내 리뷰에 좋아요·댓글이 달릴 때', 'review'),
                  _toggleRow(
                    '마케팅 · 홍보 알림',
                    '혜택·이벤트 정보 수신',
                    'marketing',
                    last: true,
                  ),

                  SizedBox(height: kMySectionGap.h),
                  const RenewSectionHead(title: '일반'),
                  _row(
                    '자동 로그인 유지',
                    '앱을 껐다 켜도 로그인 상태 유지',
                    MyToggle(on: _autoLogin, onTap: _toggleAutoLogin),
                  ),
                  _toggleRow('위치 서비스', '내 주변 클럽 추천에 사용', 'location'),
                  _toggleRow('사운드 및 진동', '앱 효과음', 'sound'),
                  _row('테마', null, _valueText('다크 · 기본값')),
                  _row('언어', null, _valueText('한국어'), last: true),

                  SizedBox(height: kMySectionGap.h),
                  const RenewSectionHead(title: '데이터'),
                  _cacheRow(),

                  SizedBox(height: kMySectionGap.h),
                  const RenewFooterNote(
                    text: '회원 탈퇴는 마이페이지 계정 메뉴에서 할 수 있어요. '
                        '데이터 이관은 고객센터를 통해 처리돼요.',
                  ),
                  SizedBox(height: 20.h),
                  const AppVersionLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 설정 행 (MRSetRow) — 라벨 + 보조설명 / 우측 컨트롤.
  Widget _row(String label, String? sub, Widget control, {bool last = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: RenewGlass.hair)),
      ),
      child: Row(
        children: [
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
  }

  Widget _toggleRow(
    String label,
    String sub,
    String key, {
    bool last = false,
  }) => _row(
    label,
    sub,
    MyToggle(on: _toggles[key] ?? false, onTap: () => _toggle(key)),
    last: last,
  );

  Widget _valueText(String value) =>
      Text(value, style: RenewGlass.body(color: RenewGlass.t4));

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

  Widget _cacheRow() {
    final sizeLabel = ref
        .watch(cacheManagerProvider)
        .when(
          data: formatCacheSize,
          loading: () => '계산 중…',
          error: (_, __) => '-',
        );

    return _row(
      '캐시 삭제',
      sizeLabel,
      GestureDetector(
        onTap: _clearCache,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RenewGlass.tileFill,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: RenewGlass.tileBorder),
          ),
          child: Text(
            _clearing ? '삭제 중…' : '삭제',
            style: VybeTypography.button2.copyWith(
              color: _clearing ? RenewGlass.t4 : RenewGlass.t1,
            ),
          ),
        ),
      ),
      last: true,
    );
  }
}
