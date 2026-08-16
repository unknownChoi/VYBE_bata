import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/repositories/auth_repository_impl.dart';
import 'package:vybe/data/repositories/user_repository_impl.dart';

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

  bool get hasPendingToken => _pendingCustomToken != null;

  /// 지금 Firebase 세션이 있는지. 본인인증 화면이 '새 가입'인지 '이어서 가입'인지
  /// 가르는 데 쓴다 — 이미 로그인된 uid가 있으면 새 uid를 만들면 안 된다.
  bool get isSignedIn => ref.read(authRepositoryProvider).currentUid != null;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> kakaoLogin(String accessToken) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser) = await repo.kakaoLogin(accessToken);
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
    try {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser) = await repo.phoneLogin(phone);
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
    try {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser) = await repo.naverLogin(accessToken);
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
    await ref.read(userRepositoryProvider).setUserProfile(
          uid: uid,
          name: name,
          phone: phone,
          birthDate: birthDate,
          provider: provider,
        );
  }

  Future<bool> checkPhoneDuplicate(String phone) =>
      ref.read(authRepositoryProvider).checkPhoneDuplicate(phone);

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
}
