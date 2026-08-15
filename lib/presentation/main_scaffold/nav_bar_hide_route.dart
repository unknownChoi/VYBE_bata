import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';

/// 탭 안에서 전체화면 페이지를 열면서 floating 바텀 nav를 화면 밖으로 내린다.
///
/// MainScaffold의 nav 바는 탭 Navigator 위(Stack)에 떠 있어 새로 push된 페이지를
/// 그대로 덮는다 → 페이지가 열려 있는 동안만 아래로 슬라이드시킨다.
/// - 내리는 시점: 페이지 전환 애니메이션이 끝난 뒤 (전환 중에 내리면 새 페이지가
///   덮기 전에 이미 사라져 슬라이드가 안 보인다) — [_NavBarHideScope] 참고.
/// - 올리는 시점: pop 직후 — 페이지가 내려가는 동안 nav가 같이 올라온다.
///
/// 이미 nav가 내려간 화면에서 또 호출하면(상세 → 상세, 상세 → 리뷰 작성 등)
/// 감싸지 않고 평범하게 push한다 — 안쪽 페이지를 닫을 때 nav가 올라와
/// 뒤에 남는 페이지를 덮기 때문.
Future<T?> pushHidingNavBar<T>(
  BuildContext context,
  Widget screen, {
  bool rootNavigator = false,
}) {
  // WidgetRef 없는 호출 지점(StatelessWidget 등)도 있어 컨테이너를 직접 잡는다.
  // pop 시점엔 context가 이미 unmount일 수 있으므로 미리 확보해 둔다.
  final container = ProviderScope.containerOf(context, listen: false);
  final navigator = Navigator.of(context, rootNavigator: rootNavigator);
  final alreadyHidden = container.read(navBarHiddenProvider);

  final future = navigator.push<T>(
    SwipeBackPageRoute(
      builder: (_) => alreadyHidden ? screen : _NavBarHideScope(child: screen),
    ),
  );
  if (alreadyHidden) return future;
  return future.whenComplete(
    () => container.read(navBarHiddenProvider.notifier).show(),
  );
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
