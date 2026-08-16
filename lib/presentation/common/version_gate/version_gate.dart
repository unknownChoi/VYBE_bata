import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/core/utils/store_launcher.dart';
import 'package:vybe/core/utils/version_utils.dart';
import 'package:vybe/presentation/common/version_gate/viewmodels/version_check_viewmodel.dart';
import 'package:vybe/presentation/common/version_gate/widgets/version_block_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_dialog.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';

/// 서버 문구가 비었을 때 쓰는 기본 안내. 문구는 presentation에 둔다 —
/// 모델(data 레이어)이 UI 카피를 들고 있을 이유가 없다.
const _kForceTitle = '업데이트가 필요합니다';
const _kForceMessage = '원활한 이용을 위해 최신 버전으로 업데이트해 주세요.';
const _kOptionalTitle = '새로운 버전이 나왔어요';
const _kOptionalMessage = '더 좋아진 vybe를 만나보세요.\n지금 업데이트할까요?';
const _kMaintenanceTitle = '서버 점검 중입니다';
const _kMaintenanceMessage = '더 나은 서비스를 위해 점검하고 있어요.\n잠시 후 다시 이용해 주세요.';

/// 선택 업데이트 안내를 띄우기까지 기다리는 시간.
/// 스플래시 퇴장(≈0.82s)이 끝난 뒤에 뜨도록 그보다 조금 길게 잡는다.
const _kOptionalPromptDelay = Duration(milliseconds: 1000);

/// 앱 진입 전 버전 정책을 확인하는 게이트.
///
/// [AuthGate]보다 **위**에 둔다 — 로그인 여부와 무관하게 먼저 걸러야 하고,
/// 차단 화면이 로그인 플로우 뒤로 밀리면 우회가 가능해진다.
///
/// 조회 실패·타임아웃은 전부 통과(fail-open) — 판단은 [VersionCheck]에 있다.
class VersionGate extends ConsumerStatefulWidget {
  final Widget child;

  const VersionGate({super.key, required this.child});

  @override
  ConsumerState<VersionGate> createState() => _VersionGateState();
}

class _VersionGateState extends ConsumerState<VersionGate>
    with WidgetsBindingObserver {
  /// 선택 업데이트 안내는 **앱 실행당 1회만**. 화면 복귀마다 뜨면 성가시다.
  /// (버전 단위 '건너뛰기' 영구 저장은 로컬 저장소가 없어 베타 범위 밖)
  bool _optionalShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱을 며칠 켜둔 기기가 강제 업데이트를 영영 피하지 못하게 복귀 시 재검사.
    if (state == AppLifecycleState.resumed) {
      ref.read(versionCheckProvider.notifier).recheck();
    }
  }

  Future<void> _openStore(VersionCheckResult result) => launchStore(
    context,
    storeUrl: result.config?.storeUrl ?? '',
    packageName: result.packageName,
  );

  /// 선택 업데이트 안내를 잠시 뒤에 띄운다(빌드 중 라우트 조작 금지).
  ///
  /// [SplashGate] 가 퇴장 연출(로고가 홈 상단 바로 날아가는 동안) 중에 이미
  /// 이 게이트를 만들어 두므로, 다음 프레임에 바로 띄우면 애니메이션 위로
  /// 다이얼로그가 겹친다 — 연출이 끝난 뒤로 미룬다.
  ///
  /// 확인 다이얼로그는 앱 공용 [VybeConfirmDialog] 를 쓴다 — 톤만 권유(퍼플).
  void _scheduleOptionalPrompt(VersionCheckResult result) {
    if (_optionalShown) return;
    _optionalShown = true;

    Future<void>.delayed(_kOptionalPromptDelay, () async {
      if (!mounted) return;
      final confirmed = await VybeConfirmDialog.show(
        context,
        title: result.updateTitleOr(_kOptionalTitle),
        message: result.updateMessageOr(_kOptionalMessage),
        confirmLabel: '업데이트',
        cancelLabel: '나중에',
        tone: VybeConfirmTone.primary,
      );
      if (!confirmed || !mounted) return;
      await _openStore(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(versionCheckProvider);
    final result = async.value;

    // 첫 조회 전. 에러는 오지 않지만(뷰모델이 삼킴) 와도 통과시킨다.
    if (result == null) {
      // 인트로는 SplashGate가 이미 재생했으므로 완성 프레임만 이어 그린다.
      return async.hasError ? widget.child : const VybeSplash(playIntro: false);
    }

    switch (result.action) {
      case VersionAction.maintenance:
        return VersionBlockScreen(
          icon: Icons.build_rounded,
          title: _kMaintenanceTitle,
          message: result.maintenanceMessageOr(_kMaintenanceMessage),
          actionLabel: '다시 시도',
          onAction: () => ref.read(versionCheckProvider.notifier).recheck(),
          versionLabel: result.versionLabel,
        );

      case VersionAction.force:
        return VersionBlockScreen(
          icon: Icons.system_update_rounded,
          title: result.updateTitleOr(_kForceTitle),
          message: result.updateMessageOr(_kForceMessage),
          actionLabel: '업데이트하기',
          onAction: () => _openStore(result),
          versionLabel: result.versionLabel,
        );

      case VersionAction.optional:
        _scheduleOptionalPrompt(result);
        return widget.child;

      case VersionAction.ok:
        return widget.child;
    }
  }
}
