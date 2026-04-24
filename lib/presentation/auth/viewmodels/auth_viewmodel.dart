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

  Future<bool> appleLogin({
    required String identityToken,
    required String rawNonce,
  }) async {
    state = const AsyncLoading();
    try {
      final isNewUser = await ref.read(authRepositoryProvider).appleLogin(
            identityToken: identityToken,
            rawNonce: rawNonce,
          );
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

  /// 본인인증 완료 후 실제 Firebase 로그인 처리
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

  Future<void> deleteUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).deleteUser(),
    );
  }
}
