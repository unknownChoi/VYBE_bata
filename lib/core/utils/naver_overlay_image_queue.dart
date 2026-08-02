import 'dart:async';

/// 네이버 지도 마커 이미지(`NOverlayImage.fromWidget` 등) 생성 직렬화 큐.
///
/// **왜 필요한가 — iOS 강제종료(EXC_BREAKPOINT) 방지**
///
/// flutter_naver_map의 `ImageUtil`은 마커 이미지를 앱 temp 폴더
/// (`<temp>/fnm1_img/fnm1_img_XXXX/`)에 PNG로 쓰고 경로만 네이티브로 넘긴다.
/// 그런데 이 폴더를 만드는 `_getDir()` / `_initTempDir()`에 **락이 없다**:
///
/// 1. 첫 생성 요청 A·B가 동시에 들어오면 둘 다 `_imageTempDir == null`을 보고
///    각자 `_initTempDir()`을 돌린다.
/// 2. `_initTempDir()`은 `fnm1_img` **하위를 전부 삭제**한 뒤 새 폴더를 만든다
///    → 늦게 도는 쪽이 먼저 만들어진 폴더(=이미 저장된 마커 PNG)까지 지운다.
/// 3. 파일은 사라졌는데 경로는 살아 있으므로, 그 이미지를 마커에 붙이는 순간
///    네이티브 `NOverlayImage.swift:16`의 `UIImage(contentsOfFile:)!`가
///    nil을 force-unwrap 하며 앱이 즉사한다(`addOverlayAll` 스택).
///
/// 게다가 플러그인은 (이미지 해시 → 경로)를 static 캐시로 들고 있어, 한 번
/// 어긋나면 **같은 마커를 다시 만들어도 죽은 경로를 계속 돌려준다** — 그래서
/// 앱 쪽 아이콘 캐시를 비워도 소용이 없고, 프로세스가 살아 있는 동안 계속 죽는다.
///
/// → 마커 이미지 생성은 화면을 가리지 않고 **전부 이 큐로 한 번에 하나씩** 실행한다.
/// (첫 호출이 끝나면 `_imageTempDir`이 채워지므로 이후 경합 자체가 사라진다)
class NaverOverlayImageQueue {
  NaverOverlayImageQueue._();

  static Future<void> _tail = Future<void>.value();

  /// [create]를 앞선 요청들이 끝난 뒤에 실행하고 결과를 돌려준다.
  static Future<T> run<T>(Future<T> Function() create) {
    final completer = Completer<T>();
    // 실패해도 큐가 끊기지 않도록 예외는 completer로만 전달한다.
    _tail = _tail.then((_) async {
      try {
        completer.complete(await create());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}
