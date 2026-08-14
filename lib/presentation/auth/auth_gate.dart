import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
import 'package:vybe/presentation/common/widgets/vybe_splash.dart';
import 'package:vybe/presentation/home/viewmodels/home_skeleton_provider.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';

/// 앱 루트 라우트. 로그인 여부로 진입 화면을 강제한다.
///
/// - 비로그인(uid == null) → [WelcomeScreen]
/// - 로그인(uid != null)  → [MainScaffold]
/// - 세션 복원 중         → 스플래시(스피너)
///
/// 로그아웃/탈퇴로 uid가 null이 되면 루트 위에 쌓인 라우트를 전부 정리해
/// 로그인 화면 밖으로 나갈 수 없게 만든다.
/// (로그인 시점엔 팝하지 않는다 — 회원가입 플로우가 스스로 화면을 이동하므로)
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
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

    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const VybeSplash(),
      // 스트림 에러는 비로그인으로 간주 — 로그인 화면으로.
      error: (_, __) => const WelcomeScreen(),
      data: (uid) => uid == null ? const WelcomeScreen() : const MainScaffold(),
    );
  }
}
