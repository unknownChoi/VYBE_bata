import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/utils/session_utils.dart';

/// 세션 판정은 잘못되면 멀쩡한 사용자를 로그아웃시키거나(과잉 차단),
/// 프로필 없는 유령 계정을 홈에 들여보낸다(과소 차단).
/// Firestore 없이 순수 함수 단위로 검증한다.
void main() {
  group('decideSessionAction', () {
    test('세션이 없으면 none — 정리할 것도 없다', () {
      expect(
        decideSessionAction(
          uid: null,
          autoLoginEnabled: true,
          profileFound: false,
          isVerified: false,
        ),
        SessionAction.none,
      );
    });

    test('본인인증까지 끝난 계정은 그대로 통과', () {
      expect(
        decideSessionAction(
          uid: 'kakao:1',
          autoLoginEnabled: true,
          profileFound: true,
          isVerified: true,
        ),
        SessionAction.keep,
      );
    });

    test('문서는 있는데 isVerified=false — 가입 도중 끊긴 유령 세션은 정리', () {
      // onUserCreated 트리거가 uid·provider만으로 문서를 먼저 만들기 때문에
      // '문서 존재'는 가입 완료를 뜻하지 않는다.
      expect(
        decideSessionAction(
          uid: 'kakao:1',
          autoLoginEnabled: true,
          profileFound: true,
          isVerified: false,
        ),
        SessionAction.signOut,
      );
    });

    test('users 문서 자체가 없으면 정리', () {
      expect(
        decideSessionAction(
          uid: 'naver:1',
          autoLoginEnabled: true,
          profileFound: false,
          isVerified: false,
        ),
        SessionAction.signOut,
      );
    });

    test('자동 로그인 OFF면 프로필이 멀쩡해도 정리', () {
      expect(
        decideSessionAction(
          uid: 'kakao:1',
          autoLoginEnabled: false,
          profileFound: true,
          isVerified: true,
        ),
        SessionAction.signOut,
      );
    });

    test('조회 실패는 통과 (fail-open) — 오프라인 사용자를 튕기지 않는다', () {
      expect(
        decideSessionAction(
          uid: 'kakao:1',
          autoLoginEnabled: true,
          profileFound: false,
          isVerified: false,
          lookupFailed: true,
        ),
        SessionAction.keep,
      );
    });

    test('조회 실패여도 자동 로그인 OFF가 우선', () {
      expect(
        decideSessionAction(
          uid: 'kakao:1',
          autoLoginEnabled: false,
          profileFound: false,
          isVerified: false,
          lookupFailed: true,
        ),
        SessionAction.signOut,
      );
    });
  });

  group('isSessionRevokedCode', () {
    test('서버에서 계정이 사라졌거나 막힌 코드만 무효 처리', () {
      expect(isSessionRevokedCode('user-not-found'), isTrue);
      expect(isSessionRevokedCode('user-disabled'), isTrue);
      expect(isSessionRevokedCode('user-token-expired'), isTrue);
    });

    test('네트워크류 오류는 유효로 본다 (fail-open)', () {
      expect(isSessionRevokedCode('network-request-failed'), isFalse);
      expect(isSessionRevokedCode('too-many-requests'), isFalse);
      expect(isSessionRevokedCode(''), isFalse);
    });
  });
}
