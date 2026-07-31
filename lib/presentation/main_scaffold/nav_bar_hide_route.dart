import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';

/// 탭 안에서 전체화면 페이지를 열면서 floating 바텀 nav를 화면 밖으로 내린다.
///
/// MainScaffold의 nav 바는 탭 Navigator 위(Stack)에 떠 있어 새로 push된 페이지를
/// 그대로 덮는다 → 페이지가 열려 있는 동안만 아래로 슬라이드시킨다.
/// - 내리는 시점: 페이지 전환 애니메이션이 끝난 뒤 (전환 중에 내리면 새 페이지가
///   덮기 전에 이미 사라져 슬라이드가 안 보인다) — [_NavBarHideScope] 참고.
/// - 올리는 시점: pop 직후 — 페이지가 내려가는 동안 nav가 같이 올라온다.
Future<T?> pushHidingNavBar<T>(
  BuildContext context,
  WidgetRef ref,
  Widget screen,
) {
  return Navigator.of(context)
      .push<T>(
        MaterialPageRoute(
          builder: (_) => _NavBarHideScope(child: screen),
        ),
      )
      .whenComplete(() => ref.read(navBarHiddenProvider.notifier).show());
}

/// 자기 라우트의 전환 애니메이션이 끝나면 바텀 nav를 내리는 래퍼.
class _NavBarHideScope extends ConsumerStatefulWidget {
  final Widget child;

  const _NavBarHideScope({required this.child});

  @override
  ConsumerState<_NavBarHideScope> createState() => _NavBarHideScopeState();
}

class _NavBarHideScopeState extends ConsumerState<_NavBarHideScope> {
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final animation = ModalRoute.of(context)?.animation;
      if (animation == null || animation.isCompleted) {
        _hideNavBar();
        return;
      }
      _routeAnimation = animation..addStatusListener(_onRouteAnimation);
    });
  }

  void _onRouteAnimation(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _clearRouteAnimation();
    _hideNavBar();
  }

  void _hideNavBar() {
    if (!mounted) return;
    ref.read(navBarHiddenProvider.notifier).hide();
  }

  void _clearRouteAnimation() {
    _routeAnimation?.removeStatusListener(_onRouteAnimation);
    _routeAnimation = null;
  }

  @override
  void dispose() {
    // 전환 도중 바로 뒤로가기 하면 completed가 안 와서 리스너가 남는다.
    _clearRouteAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
