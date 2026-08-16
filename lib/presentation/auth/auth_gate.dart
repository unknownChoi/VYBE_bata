import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/viewmodels/session_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
import 'package:vybe/presentation/common/splash_destination.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';
import 'package:vybe/presentation/home/viewmodels/home_skeleton_provider.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';

/// 앱 루트 라우트. 로그인 여부로 진입 화면을 강제한다.
///
/// - 비로그인(uid == null) → [WelcomeScreen]
/// - 로그인(uid != null)  → [MainScaffold]
/// - 세션 복원·검사 중     → 스플래시(스피너)
///
/// **자동 로그인** — Firebase Auth가 세션을 기기에 저장하므로 앱을 껐다 켜도
/// 로그인이 유지된다. 다만 그 세션을 그대로 믿으면 안 되는 경우(가입 도중
/// 끊긴 유령 세션, 다른 기기에서 탈퇴한 계정, 자동 로그인 OFF)가 있어
/// [SessionCheck] 가 먼저 검사하고, 검사가 끝날 때까지는 스플래시를 유지한다.
/// 검사 중에 [WelcomeScreen] 을 잠깐 보여주면 멀쩡히 로그인된 사용자에게
/// 로그인 화면이 번쩍인다.
///
/// 로그아웃/탈퇴로 uid가 null이 되면 루트 위에 쌓인 라우트를 전부 정리해
/// 로그인 화면 밖으로 나갈 수 없게 만든다.
/// (로그인 시점엔 팝하지 않는다 — 회원가입 플로우가 스스로 화면을 이동하므로)
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate>
    with WidgetsBindingObserver {
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
    // 앱을 계속 켜둔 기기가 '이미 삭제된 계정'으로 영영 남지 않게 복귀 시 재확인.
    // (프로필 완성 여부는 여기서 보지 않는다 — 본인인증 도중 외부 앱을
    //  다녀오는 사용자를 로그아웃시키게 된다)
    if (state == AppLifecycleState.resumed) {
      ref.read(sessionCheckProvider.notifier).recheckSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로그아웃 감지 → 루트 위 라우트 전부 제거.
    ref.listen<AsyncValue<String?>>(authStateProvider, (prev, next) {
      final wasLoggedIn = prev?.value != null;
      final isLoggedOut = next.hasValue && next.value == null;
      if (!wasLoggedIn || !isLoggedOut) return;

      // 리스너에서 바로 팝하면 진행 중인 빌드/전환과 겹칠 수 있어 다음 프레임에.
      // 스켈레톤 게이트 복구(다음 로그인 때 다시 표시)도 같은 이유로 프레임 이후에.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(homeSkeletonGateProvider.notifier).reset();
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      });
    });

    final session = ref.watch(sessionCheckProvider);
    final authState = ref.watch(authStateProvider);

    // 세션 검사가 끝나기 전 / 스트림 첫 이벤트 전.
    // 에러는 뷰모델이 삼키지만, 와도 통과시켜 uid로 판단한다(fail-open).
    final checking = !session.hasValue && !session.hasError;
    if (checking || authState.isLoading) {
      // 인트로는 SplashGate가 이미 재생했다 — 여기서 또 재생하면 로고가 두 번 뜬다.
      return const VybeSplash(playIntro: false);
    }

    // 검사가 끝난 뒤로는 uid 하나로 판단한다 — 앱 실행 중 로그인/로그아웃은
    // 그대로 따라가야 하고, 가입 도중(프로필 저장 직전) 사용자를 다시
    // 판정해 내쫓으면 안 된다. 스트림 에러도 비로그인으로 간주.
    final uid = authState.value;
    // isRoot: 스플래시 로고가 이 화면 로고 자리로 날아와 앉는다.
    // 확인용 스위치는 [splashDestinationProvider] 와 같은 값을 봐야 한다.
    const forceWelcome = kDebugMode && kDebugStartAtWelcome;
    return uid == null || forceWelcome
        ? const WelcomeScreen(isRoot: true)
        : const MainScaffold();
  }
}
