import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/user_model.dart';
import 'package:vybe/data/repositories/user_repository_impl.dart';

part 'user_viewmodel.g.dart';

/// 현재 로그인 유저 실시간 스트림
@riverpod
Stream<UserModel?> currentUser(Ref ref, String uid) {
  return ref.watch(userRepositoryProvider).watchUser(uid);
}

@riverpod
class UserViewModel extends _$UserViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? profileImageUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
      await ref.read(userRepositoryProvider).updateUser(uid, data);
    });
  }

  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).uploadProfileImage(uid, imageFile),
    );
    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
    );
    return result.asData?.value;
  }
}
