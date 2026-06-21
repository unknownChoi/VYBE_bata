import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 하단 floating nav 바의 확대/축소 상태.
/// true = 원래 크기, false = 축소.
/// 스크롤·시트 드래그·지도 이동 등 여러 화면에서 갱신하므로 전역 provider로 둔다.
class NavBarVisibility extends Notifier<bool> {
  @override
  bool build() => true;

  void expand() {
    if (!state) state = true;
  }

  void collapse() {
    if (state) state = false;
  }
}

final navBarVisibilityProvider =
    NotifierProvider<NavBarVisibility, bool>(NavBarVisibility.new);
