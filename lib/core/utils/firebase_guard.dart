/// 같은 리소스를 향한 **중복 요청 합류(coalescing)**.
///
/// 이미 떠 있는 요청과 같은 키로 들어온 호출은 새 왕복을 만들지 않고
/// 진행 중인 Future에 합류한다. 버튼 연타·리빌드 중복 호출이 서버 왕복
/// 두 번이 되는 것을 막는다.
///
/// **시간 임계값이 없다.** "몇 회/초"가 아니라 "앞선 요청이 끝났는가"로
/// 판단하므로 느린 네트워크에서도 튜닝 없이 맞는다. 초 단위 임계값은
/// 요청이 얼마나 걸리는지 모르는 채 찍는 숫자라 3G에서 그대로 무너진다.
///
/// ⚠ **키는 메서드명이 아니라 리소스 식별자로 잡는다.**
/// 찜 추가·해제가 같은 키(`favorite:$uid:$clubId`)를 쓰는 것이 의도다 —
/// 추가가 떠 있는 동안 들어온 해제가 별도 왕복을 만들면 서버 도착 순서에
/// 따라 DB와 화면이 어긋난다.
///
/// ⚠ 읽기에는 대체로 불필요하다 — Riverpod provider가 이미 같은 인자의
/// 조회를 한 번만 실행한다. 쓰기(뮤테이션)와 provider 밖에서 직접 부르는
/// 조회에 쓸 것.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

class FirebaseGuard {
  FirebaseGuard._();

  static final Map<String, Future<dynamic>> _inFlight = <String, Future<dynamic>>{};

  /// 진행 중인 요청 수 (테스트·디버깅용).
  @visibleForTesting
  static int get inFlightCount => _inFlight.length;

  /// [key] 요청이 진행 중이면 그 Future를 그대로 돌려주고, 아니면 [run] 실행.
  ///
  /// 합류한 호출은 원 요청의 결과·예외를 **그대로** 받는다. 따라서 호출부의
  /// try/catch·롤백 로직은 손댈 필요가 없다.
  ///
  /// ⚠ 같은 키에는 항상 같은 반환 타입을 쓸 것 (다르면 캐스트에서 터진다).
  static Future<T> dedupe<T>(String key, Future<T> Function() run) {
    final existing = _inFlight[key];
    if (existing != null) return existing as Future<T>;

    final future = run();
    _inFlight[key] = future;

    // 성공·실패 어느 쪽이든 반드시 키를 지운다. then으로 에러까지 흡수한
    // 파생 Future를 만들어야 아무도 안 듣는 예외가 unhandled로 새지 않는다
    // (원본 예외는 호출부가 받는다).
    //
    // ⚠ whenComplete 콜백을 화살표(`() => _inFlight.remove(key)`)로 쓰면 안 된다.
    // Map.remove가 **제거된 Future를 반환**하고, whenComplete는 콜백이 돌려준
    // Future를 기다렸다가 그 에러를 파생 Future로 옮긴다 → 실패한 요청마다
    // unhandled exception. 반환값을 버리도록 블록 본문으로 둔다.
    unawaited(
      future
          .then<void>((_) {}, onError: (Object _, StackTrace _) {})
          .whenComplete(() {
            _inFlight.remove(key);
          }),
    );

    return future;
  }

  /// 진행 중 목록 초기화 (테스트 전용).
  @visibleForTesting
  static void reset() => _inFlight.clear();
}
