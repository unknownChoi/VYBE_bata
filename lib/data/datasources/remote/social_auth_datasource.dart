import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 소셜 로그인 SDK(카카오·네이버) 세션 정리 전담 datasource.
///
/// Firebase가 아니라 외부 SDK를 다루지만, SDK 호출을 presentation/domain에
/// 노출하지 않기 위해 다른 datasource와 같은 자리에 둔다.
class SocialAuthDataSource {
  /// SDK 호출 제한 시간. 로그아웃이 네트워크 때문에 매달리면 안 된다.
  static const _timeout = Duration(seconds: 3);

  /// 카카오·네이버 세션을 모두 끊는다.
  ///
  /// Firebase 세션만 지우면 SDK 세션이 남아, 다시 로그인할 때 계정 선택 없이
  /// 직전 계정으로 붙어버려 **계정 전환이 불가능**해진다.
  ///
  /// 로그인한 적 없는 SDK는 에러를 던지므로 각각 따로 삼킨다 — 로그아웃은
  /// 어떤 경우에도 실패하면 안 된다. 두 SDK는 서로 무관하므로 동시에 호출해
  /// 로그아웃 대기 시간이 합산되지 않게 한다.
  Future<void> signOutAll() => Future.wait([
        _ignoreErrors('kakao', () => UserApi.instance.logout()),
        _ignoreErrors('naver', FlutterNaverLogin.logOut),
      ]);

  Future<void> _ignoreErrors(
    String label,
    Future<Object?> Function() action,
  ) async {
    try {
      await action().timeout(_timeout);
    } catch (e) {
      debugPrint('[SocialAuth] $label 로그아웃 무시된 오류: $e');
    }
  }
}
