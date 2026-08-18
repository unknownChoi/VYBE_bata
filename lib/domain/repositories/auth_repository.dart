/// 전화번호 주인 조회 결과.
///
/// "중복이냐"가 아니라 "주인이 지금 시도 중인 그 계정이냐"를 담는다 —
/// 같은 계정이 같은 방식으로 다시 들어오는 재로그인까지 막으면 안 되기 때문.
typedef PhoneAccountResult = ({
  /// 이 번호를 쓰는 계정이 이미 있는지.
  bool isDuplicate,

  /// 그 계정이 **지금 시도 중인 방식의 내 계정**인지 (= 재로그인).
  bool sameAccount,

  /// 탈퇴 대기 중인 계정인지. 본인이어도 파기 전까진 쓸 수 없다.
  bool pendingDeletion,

  /// 완전 파기 예정 시각(= 재가입 가능 시점). [pendingDeletion] 일 때만.
  DateTime? purgeAt,
});

abstract class AuthRepository {
  /// 로그인 상태 스트림. null = 비로그인, non-null = uid
  Stream<String?> get authStateChanges;
  String? get currentUid;

  Future<({String customToken, bool isNewUser})> kakaoLogin(String accessToken);
  Future<({String customToken, bool isNewUser})> naverLogin(String accessToken);
  Future<({String customToken, bool isNewUser})> phoneLogin(String phone);
  Future<void> signInWithCustomToken(String customToken);
  Future<bool> userExists(String uid);
  /// 이 번호로 [method] 방식의 가입/로그인을 이어가도 되는지 조회한다.
  /// [method] 는 `users.provider` 와 같은 값(`identity`·`kakao`·`naver`·`apple`).
  Future<PhoneAccountResult> checkPhoneAccount(String phone, String method);
  Future<bool> verifyIdentity(String impUid);
  Future<void> signOut();

  /// 회원 탈퇴. 데이터는 즉시 지우지 않고 노출만 막은 뒤 30일 후 파기한다.
  /// 반환값 = 완전 파기 예정 시각(재가입 가능 시점). 성공 시 로그아웃까지 끝난다.
  Future<DateTime> requestAccountDeletion(String reason);

  /// 저장된 세션이 서버에서도 유효한지 확인. `false` 면 로그아웃해야 한다.
  /// 네트워크 오류는 `true`(fail-open).
  Future<bool> refreshSession();
}
