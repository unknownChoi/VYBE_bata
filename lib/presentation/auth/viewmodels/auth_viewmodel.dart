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

    final String provider;
    if (uid.startsWith('kakao:')) {
      provider = 'kakao';
    } else if (uid.startsWith('naver:')) {
      provider = 'naver';
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

  /// 본인인증 완료 후 실제 Firebase 로그인 처리.
  /// - 카카오/네이버: pendingCustomToken으로 signInWithCustomToken 실행
  /// - 본인인증 직접 경로: 기존 세션 sign out → 익명 로그인으로 새 uid 생성
  /// 반환값: 항상 true (실패 시 throw)
  Future<bool> finalizeLogin() async {
    final token = _pendingCustomToken;
    state = const AsyncLoading();
    try {
      if (token != null) {
        await ref.read(authRepositoryProvider).signInWithCustomToken(token);
        _pendingCustomToken = null;
      } else {
        // 소셜 로그인 없이 본인인증으로 직접 가입하는 경로
        // 기존 세션이 남아있을 수 있으므로 먼저 sign out
        await ref.read(authRepositoryProvider).signOut();
        await ref.read(authRepositoryProvider).signInAnonymously();
      }
      state = const AsyncData(null);
      return true;
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

  Future<void> signInAnonymously() async {
    await ref.read(authRepositoryProvider).signInAnonymously();
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }

  Future<void> deleteUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).deleteUser(),
    );
  }
}
