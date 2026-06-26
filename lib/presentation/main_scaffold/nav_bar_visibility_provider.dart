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

/// 하단 floating nav 바의 완전 숨김 상태.
/// true = 화면 밖으로 슬라이드되어 사라짐 (모달 시트 등에서 사용).
class NavBarHidden extends Notifier<bool> {
  @override
  bool build() => false;

  void hide() {
    if (!state) state = true;
  }

  void show() {
    if (state) state = false;
  }
}

final navBarHiddenProvider =
    NotifierProvider<NavBarHidden, bool>(NavBarHidden.new);

/// 현재 활성 탭 인덱스 (PageView). 0=홈 1=주변 2=찜 3=검색 4=내정보.
/// 주변 탭의 네이버 지도 마커는 화면 밖(KeepAlive)에서 NOverlayImage.fromWidget을
/// 호출하면 크래시하므로, 활성 탭일 때만 렌더하도록 이 값을 참조한다.
class CurrentTabIndex extends Notifier<int> {
  @override
  int build() => 0;

  void set(int i) {
    if (state != i) state = i;
  }
}

final currentTabIndexProvider =
    NotifierProvider<CurrentTabIndex, int>(CurrentTabIndex.new);
