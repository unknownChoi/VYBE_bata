import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';

part 'auth_providers.g.dart';

/// 현재 로그인한 사용자의 uid. 비로그인 시 null.
@riverpod
String? currentUid(Ref ref) {
  return ref.watch(authStateProvider).value;
}
