import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 스켈레톤 1회성 게이트.
///
/// true = "아직 스켈레톤을 안 보여줬다" → 다음 홈 진입 시 1회 표시.
///
/// 스켈레톤을 띄우는 경우:
///   1. 회원가입/로그인(인증번호 입력) 완료 → 홈 진입
///   2. 자동 로그인 상태로 앱 실행 → 홈 진입
///
/// 안 띄우는 경우:
///   - 이미 홈이 로드된 뒤 다른 탭 갔다 돌아올 때
///   - 홈에서 상세/검색 push 후 pop으로 복귀할 때
///   (탭은 KeepAlive라 HomeScreen state가 살아있지만, 어떤 이유로 재생성되더라도
///    이 게이트가 false라 스켈레톤은 다시 뜨지 않는다)
///
/// 로그아웃 시 [reset]으로 되돌려 다음 로그인 때 다시 표시한다.
class HomeSkeletonGate extends Notifier<bool> {
  @override
  bool build() => true;

  /// 스켈레톤 표시 후 게이트를 닫는다(1회성).
  ///
  /// ⚠️ initState/build 등 위젯 생명주기 안에서 직접 호출 금지
  /// (Riverpod "Tried to modify a provider while the widget tree was building").
  /// 호출부는 addPostFrameCallback 등으로 프레임 이후에 호출할 것.
  void close() {
    if (state) state = false;
  }

  /// 로그아웃 등으로 세션이 끝났을 때 — 다음 로그인 진입에서 다시 표시.
  void reset() => state = true;
}

final homeSkeletonGateProvider = NotifierProvider<HomeSkeletonGate, bool>(
  HomeSkeletonGate.new,
);
