import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/version_gate/viewmodels/version_check_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/viewmodels/settings_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 설정 화면 (my.html 디자인 기반)
//
// 디자인과 다른 점: 토글 값은 로컬 상태만 사용 — 베타 범위에
// 설정 서버 저장이 없어 Firestore 연동 없이 화면 상태로만 동작.
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
    'marketing': false,
    'location': true,
    'sound': true,
  };
  bool _clearing = false;

  void _toggle(String key) =>
      setState(() => _toggles[key] = !(_toggles[key] ?? false));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackdrop()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SubScreenHeader(title: '설정'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionTitle('알림'),
                        _group([
                          _toggleRow('푸시 알림', '전체 알림 받기', 'push'),
                          _toggleRow(
                              '공연 시작 알림', '찜한 클럽의 오늘 라인업 시작 전', 'showtime'),
                          _toggleRow('찜한 클럽 소식', '이벤트 · 입장 혜택 업데이트', 'saved'),
                          _toggleRow('마케팅 · 홍보 알림', '혜택·이벤트 정보 수신', 'marketing'),
                        ]),
                        const SectionTitle('일반'),
                        _group([
                          _toggleRow('위치 서비스', '내 주변 클럽 추천에 사용', 'location'),
                          _toggleRow('사운드 및 진동', '앱 효과음', 'sound'),
                        ]),
                        const SectionTitle('데이터'),
                        _group([_cacheRow()]),
                        SizedBox(height: 26.h),
                        const Center(child: _AppVersionLabel()),
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

  Widget _group(List<Widget> rows) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: glassDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: hairColor),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _rowBase(String label, String? sub, Widget trailing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: VybeTypography.body3.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (sub != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.sp,
                      color: VybeColors.gray500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          trailing,
        ],
      ),
    );
  }

  Widget _toggleRow(String label, String sub, String key) {
    return _rowBase(label, sub, _Toggle(
      on: _toggles[key] ?? false,
      onTap: () => _toggle(key),
    ));
  }

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
    final sizeAsync = ref.watch(cacheManagerProvider);
    final sizeLabel = sizeAsync.when(
      data: formatCacheSize,
      loading: () => '계산 중…',
      error: (_, __) => '-',
    );
    return _rowBase(
      '캐시 삭제',
      sizeLabel,
      GestureDetector(
        onTap: _clearCache,
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          alignment: Alignment.center,
          decoration: glassTileDecoration(radius: 8),
          child: Text(
            _clearing ? '삭제 중…' : '삭제',
            style: VybeTypography.button2.copyWith(
              color: _clearing ? VybeColors.gray500 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;

  const _Toggle({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46.w,
        height: 28.h,
        padding: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99.r),
          color: on
              ? VybeColors.mainPurple500
              : Colors.white.withValues(alpha: 0.16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22.r,
            height: 22.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 5.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 하단 앱 버전 표기. 값은 앱 실행 시 버전 게이트가 이미 읽어둔 것을
/// 그대로 쓴다 — 설정 화면에서 다시 조회하지 않는다.
/// (하드코딩하면 릴리스마다 잊고 안 고쳐서 실제 버전과 어긋난다)
class _AppVersionLabel extends ConsumerWidget {
  const _AppVersionLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 버전 문자열만 구독 — 복귀 재검사로 정책이 바뀌어도 버전이 그대로면
    // 이 라벨은 리빌드되지 않는다.
    final label = ref.watch(
      versionCheckProvider.select((s) => s.value?.versionLabel ?? ''),
    );
    return Text(
      label.isEmpty ? 'vybe' : 'vybe · 버전 $label',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 12.sp,
        color: VybeColors.gray600,
      ),
    );
  }
}
