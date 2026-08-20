/// 로그인 계열 Cloud Functions(`kakaoLogin`·`naverLogin`·`phoneLogin`) 응답.
typedef LoginTokenResult = ({
  /// Firebase 로그인에 쓸 Custom Token.
  String customToken,

  /// Auth 계정이 이 호출로 처음 만들어졌는지 (프로필 유무와는 무관).
  bool isNewUser,

  /// 탈퇴 대기(보관 30일) 중이던 계정이 이 로그인으로 **복구**됐는지.
  /// 화면이 "계정이 복구되었어요" 안내를 띄우는 데만 쓴다.
  bool restored,
});

/// 전화번호 주인 조회 결과.
///
/// "중복이냐"가 아니라 "주인이 지금 시도 중인 그 계정이냐"를 담는다 —
/// 같은 계정이 같은 방식으로 다시 들어오는 재로그인까지 막으면 안 되기 때문.
typedef PhoneAccountResult = ({
  /// 이 번호를 쓰는 계정이 이미 있는지.
  bool isDuplicate,

  /// 그 계정이 **지금 시도 중인 방식의 내 계정**인지 (= 재로그인).
  bool sameAccount,

  /// 탈퇴 대기 계정이라 **막아야** 하는지. 본인이 보관 기간 안에 돌아온
  /// 경우는 복구 대상이라 여기 안 걸린다([restorable] 참고).
  bool pendingDeletion,

  /// 완전 파기 예정 시각(= 재가입 가능 시점). [pendingDeletion] 일 때만.
  DateTime? purgeAt,

  /// 탈퇴 대기지만 **본인이 파기 전에 돌아온** 경우 — 로그인하면 복구된다.
  /// 이때는 [pendingDeletion] 이 false 이고 [sameAccount] 가 true 다.
  bool restorable,
});

abstract class AuthRepository {
  /// 로그인 상태 스트림. null = 비로그인, non-null = uid
  Stream<String?> get authStateChanges;
  String? get currentUid;

  Future<LoginTokenResult> kakaoLogin(String accessToken);
  Future<LoginTokenResult> naverLogin(String accessToken);
  Future<LoginTokenResult> phoneLogin(String phone);
  Future<void> signInWithCustomToken(String customToken);
  Future<bool> userExists(String uid);
  /// 이 번호로 [method] 방식의 가입/로그인을 이어가도 되는지 조회한다.
  /// [method] 는 `users.provider` 와 같은 값(`identity`·`kakao`·`naver`·`apple`).
  Future<PhoneAccountResult> checkPhoneAccount(String phone, String method);
  Future<bool> verifyIdentity(String impUid);
  Future<void> signOut();

  /// 회원 탈퇴. 데이터는 즉시 지우지 않고 노출만 막은 뒤 30일 후 파기한다.
  /// 그 안에 같은 계정으로 다시 로그인하면 서버가 되살린다(복구).
  /// 반환값 = 완전 파기 예정 시각(재가입 가능 시점). 성공 시 로그아웃까지 끝난다.
  Future<DateTime> requestAccountDeletion(String reason);

  /// 저장된 세션이 서버에서도 유효한지 확인. `false` 면 로그아웃해야 한다.
  /// 네트워크 오류는 `true`(fail-open).
  Future<bool> refreshSession();
}
