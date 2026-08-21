import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/repositories/auth_repository_impl.dart';
import 'package:vybe/data/repositories/user_repository_impl.dart';
import 'package:vybe/presentation/auth/signup_flow.dart';

part 'auth_viewmodel.g.dart';

/// 로그인 상태 스트림 (null = 비로그인, non-null = uid)
@riverpod
Stream<String?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// 로그인 액션 ViewModel
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  String? _pendingCustomToken;
  bool _accountRestored = false;

  bool get hasPendingToken => _pendingCustomToken != null;

  /// 직전 로그인이 **탈퇴 대기 계정을 되살린** 로그인이었는지.
  /// 화면이 "계정이 복구되었어요" 안내를 띄우는 데만 쓴다.
  /// 다음 로그인 시도 때 초기화된다.
  bool get accountRestored => _accountRestored;

  /// 지금 Firebase 세션이 있는지. 본인인증 화면이 '새 가입'인지 '이어서 가입'인지
  /// 가르는 데 쓴다 — 이미 로그인된 uid가 있으면 새 uid를 만들면 안 된다.
  bool get isSignedIn => ref.read(authRepositoryProvider).currentUid != null;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> kakaoLogin(String accessToken) async {
    state = const AsyncLoading();
    _accountRestored = false;
    try {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser, :restored) = await repo.kakaoLogin(
        accessToken,
      );
      _accountRestored = restored;
      if (isNewUser) {
        _pendingCustomToken = customToken;
      } else {
        await repo.signInWithCustomToken(customToken);
      }
      state = const AsyncData(null);
      return isNewUser;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> phoneLogin(String phone) async {
    state = const AsyncLoading();
    _accountRestored = false;
    try {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser, :restored) = await repo.phoneLogin(
        phone,
      );
      _accountRestored = restored;
      _pendingCustomToken = customToken;
      state = const AsyncData(null);
      return isNewUser;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> naverLogin(String accessToken) async {
    state = const AsyncLoading();
    _accountRestored = false;
    try {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser, :restored) = await repo.naverLogin(
        accessToken,
      );
      _accountRestored = restored;
      if (isNewUser) {
        _pendingCustomToken = customToken;
      } else {
        await repo.signInWithCustomToken(customToken);
      }
      state = const AsyncData(null);
      return isNewUser;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// 본인인증 완료 후 Firestore에 사용자 프로필 저장
  Future<void> saveUserProfile({
    required String name,
    required String phone,
    required String birthDate,
    String? gender,
  }) async {
    final uid = ref.read(authRepositoryProvider).currentUid;
    if (uid == null) return;

    // uid prefix는 Custom Token을 발급한 Cloud Functions가 정한다
    // (kakaoLogin / naverLogin / phoneLogin). onUserCreated 트리거가 쓰는
    // 라벨과 같은 값을 써야 가입 방식 표시가 어긋나지 않는다.
    final String provider;
    if (uid.startsWith('kakao:')) {
      provider = 'kakao';
    } else if (uid.startsWith('naver:')) {
      provider = 'naver';
    } else if (uid.startsWith('phone:')) {
      provider = 'identity';
    } else {
      provider = 'apple';
    }
    await ref
        .read(userRepositoryProvider)
        .setUserProfile(
          uid: uid,
          name: name,
          phone: phone,
          birthDate: birthDate,
          provider: provider,
          gender: gender,
        );
  }

  /// 이 번호로 [method] 방식의 가입/로그인을 이어가도 되는지 판정한다.
  ///
  /// 번호가 이미 쓰인다고 무조건 막으면 재로그인이 영영 불가능해진다 —
  /// **주인이 나인지**까지 서버가 보고 알려준다.
  Future<PhoneAccountCheck> checkPhoneAccount(
    String phone,
    SignupMethod method,
  ) async {
    final r = await ref
        .read(authRepositoryProvider)
        .checkPhoneAccount(phone, method.key);
    if (!r.isDuplicate) {
      return (
        status: PhoneAccountStatus.available,
        purgeAt: null,
        restorable: false,
      );
    }
    if (r.pendingDeletion) {
      return (
        status: PhoneAccountStatus.pendingDeletion,
        purgeAt: r.purgeAt,
        restorable: false,
      );
    }
    return (
      status: r.sameAccount
          ? PhoneAccountStatus.ownAccount
          : PhoneAccountStatus.takenByOther,
      purgeAt: null,
      // 탈퇴 대기지만 파기 전이라 로그인하면 되살아나는 내 계정.
      restorable: r.restorable,
    );
  }

  /// 가입을 중단한다 — 받아 둔 Custom Token을 버리고, 프로필이 없는 채로
  /// 만들어진 세션이 남아 있으면 로그아웃까지 한다.
  ///
  /// 소셜 로그인은 Auth 계정이 이미 있으면 본인인증 화면에 오기 전에
  /// 세션이 붙는다. 여기서 막고 그냥 두면 이름·전화번호가 빈 계정으로
  /// 앱에 들어가 버린다 ("계정 생성도 하면 안 된다"가 깨진다).
  Future<void> abortSignup() async {
    _pendingCustomToken = null;
    _accountRestored = false;
    if (ref.read(authRepositoryProvider).currentUid == null) return;
    await signOut();
  }

  /// 로그인 세션은 있는데 프로필(본인인증)이 아직 안 끝났는지.
  ///
  /// Cloud Functions가 돌려주는 `isNewUser`는 **Auth user 존재 여부**일 뿐이라
  /// 이걸로는 알 수 없다 — 가입 도중 앱을 끄면 Auth user만 생기고 프로필은
  /// 비어 있는 상태가 되는데, 다시 로그인하면 `isNewUser=false`로 온다.
  ///
  /// 조회 실패는 false(통과) — 오프라인 사용자를 가입 화면으로 되돌리지 않는다.
  Future<bool> needsProfileSetup() async {
    final uid = ref.read(authRepositoryProvider).currentUid;
    if (uid == null) return false;
    try {
      final user = await ref
          .read(userRepositoryProvider)
          .getUser(uid)
          .timeout(const Duration(seconds: 3));
      return user == null || !user.isVerified;
    } catch (_) {
      return false;
    }
  }

  /// 본인인증 완료 후 실제 Firebase 로그인 처리.
  /// - 카카오/네이버: pendingCustomToken으로 signInWithCustomToken 실행
  /// - 본인인증 직접 경로: 기존 세션 sign out → 익명 로그인으로 새 uid 생성
  /// 반환값: 항상 true (실패 시 throw)
  Future<void> finalizeLogin() async {
    final token = _pendingCustomToken;
    if (token == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithCustomToken(token);
      _pendingCustomToken = null;
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> verifyIdentity(String impUid) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).verifyIdentity(impUid),
    );
    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
    );
    return result.asData?.value ?? false;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }

  /// 회원 탈퇴. 성공하면 uid가 null이 되어 AuthGate가 알아서 루트를
  /// WelcomeScreen으로 교체한다 (로그아웃과 같은 경로).
  /// 반환값 = 완전 파기 예정 시각(재가입 가능 시점). 실패는 rethrow.
  Future<DateTime> deleteAccount(String reason) async {
    state = const AsyncLoading();
    try {
      final purgeAt = await ref
          .read(authRepositoryProvider)
          .requestAccountDeletion(reason);
      state = const AsyncData(null);
      return purgeAt;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
