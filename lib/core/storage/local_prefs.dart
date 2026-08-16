import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_prefs.g.dart';

/// 기기 로컬에 남기는 설정.
///
/// 지금 저장하는 값은 **자동 로그인 스위치 하나뿐**이다. 설정 화면의 알림
/// 토글들은 실제 푸시 연동이 없어서, 값만 저장하면 동작하지 않는 설정을
/// 동작하는 것처럼 보여주게 된다 — 그래서 그것들은 화면 상태로 둔다.
class LocalPrefs {
  static const _kAutoLogin = 'auto_login';

  final SharedPreferences _prefs;

  const LocalPrefs(this._prefs);

  /// 자동 로그인 유지 여부. 저장된 적 없으면 **켜짐**(기본 동작).
  bool get autoLogin => _prefs.getBool(_kAutoLogin) ?? true;

  Future<void> setAutoLogin(bool value) => _prefs.setBool(_kAutoLogin, value);
}

/// keepAlive — 앱 실행 내내 같은 인스턴스를 쓴다(매번 디스크를 열지 않게).
@Riverpod(keepAlive: true)
Future<LocalPrefs> localPrefs(Ref ref) async =>
    LocalPrefs(await SharedPreferences.getInstance());
