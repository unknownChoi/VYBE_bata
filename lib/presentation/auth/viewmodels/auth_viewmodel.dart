import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/repositories/auth_repository_impl.dart';

part 'auth_viewmodel.g.dart';

/// 현재 Firebase Auth 상태 스트림
@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// 로그인 액션 ViewModel
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> kakaoLogin(String accessToken) async {
    state = const AsyncLoading();
    return await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser) = await repo.kakaoLogin(accessToken);
      await repo.signInWithCustomToken(customToken);
      state = const AsyncData(null);
      return isNewUser;
    }).then((result) {
      if (result is AsyncError) {
        state = AsyncError(result.error!, result.stackTrace!);
        return false;
      }
      return (result as AsyncData<bool>).value;
    });
  }

  Future<bool> naverLogin(String accessToken) async {
    state = const AsyncLoading();
    return await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final (:customToken, :isNewUser) = await repo.naverLogin(accessToken);
      await repo.signInWithCustomToken(customToken);
      state = const AsyncData(null);
      return isNewUser;
    }).then((result) {
      if (result is AsyncError) {
        state = AsyncError(result.error!, result.stackTrace!);
        return false;
      }
      return (result as AsyncData<bool>).value;
    });
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
