import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/utils/firebase_guard.dart';
import 'package:vybe/data/models/favorite_model.dart';
import 'package:vybe/data/repositories/favorite_repository_impl.dart';
import 'package:vybe/domain/repositories/favorite_repository.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';

/// 찜 연타 가드가 **뷰모델 경로에서** 실제로 도는지 검증.
///
/// Firestore를 타지 않도록 repository를 대역으로 갈아끼우고, 왕복이 끝나는
/// 시점을 Completer로 붙잡아 "서버 ack 전 연타" 상황을 재현한다.
class _FakeFavoriteRepository implements FavoriteRepository {
  final List<String> calls = <String>[];

  /// null이면 즉시 완료. 값이 있으면 그 Completer가 끝날 때까지 왕복이 안 끝난다.
  Completer<void>? gate;

  /// true면 왕복이 예외로 끝난다.
  bool shouldFail = false;

  Future<void> _run(String label) {
    calls.add(label);
    final pending = gate;
    if (pending == null) {
      return shouldFail
          ? Future<void>.error(StateError('boom'))
          : Future<void>.value();
    }
    return pending.future.then((_) {
      if (shouldFail) throw StateError('boom');
    });
  }

  @override
  Future<void> addFavorite(String userId, String clubId) => _run('add');

  @override
  Future<void> removeFavorite(String userId, String clubId) => _run('remove');

  @override
  Future<bool> isFavorite(String userId, String clubId) async => false;

  @override
  Stream<List<FavoriteModel>> watchUserFavorites(String userId) =>
      const Stream<List<FavoriteModel>>.empty();
}

void main() {
  late _FakeFavoriteRepository repo;
  late ProviderContainer container;

  setUp(() {
    FirebaseGuard.reset();
    repo = _FakeFavoriteRepository();
    container = ProviderContainer(
      overrides: [favoriteRepositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() {
    container.dispose();
    FirebaseGuard.reset();
  });

  FavoriteViewModel vm() =>
      container.read(favoriteViewModelProvider.notifier);
  Map<String, bool> overrides() => container.read(favoriteViewModelProvider);

  test('평상시 토글은 그대로 동작한다 (가드가 정상 요청을 막지 않는다)', () async {
    await vm().toggleFavorite('u1', 'c1', false);

    expect(repo.calls, ['add']);
    // 성공하면 낙관적 오버라이드는 걷힌다 (스트림 값에 맡김).
    expect(overrides().containsKey('c1'), isFalse);
    expect(FirebaseGuard.inFlightCount, 0);
  });

  test('서버 ack 전 반대 방향 연타 — 두 번째 요청이 나가지 않는다', () async {
    repo.gate = Completer<void>();

    final tap1 = vm().toggleFavorite('u1', 'c1', false); // 찜 추가
    // 낙관적 반영으로 하트는 이미 켜진 상태.
    expect(overrides()['c1'], isTrue);

    final tap2 = vm().toggleFavorite('u1', 'c1', true); // 해제 연타

    // 핵심: 요청은 add 하나뿐이고, 하트도 뒤집히지 않는다.
    expect(repo.calls, ['add']);
    expect(overrides()['c1'], isTrue);

    repo.gate!.complete();
    await Future.wait([tap1, tap2]);

    expect(repo.calls, ['add']);
    expect(FirebaseGuard.inFlightCount, 0);
  });

  test('같은 프레임 연타 — 스테일 currentIsFav로 add가 두 번 들어가지 않는다', () async {
    repo.gate = Completer<void>();

    // 호출부가 build 시점 값(false)을 캡처해 두 번 넘기는 상황.
    final tap1 = vm().toggleFavorite('u1', 'c1', false);
    final tap2 = vm().toggleFavorite('u1', 'c1', false);

    expect(repo.calls, ['add']);

    repo.gate!.complete();
    await Future.wait([tap1, tap2]);

    expect(repo.calls, ['add']);
  });

  test('다른 클럽은 서로 막지 않는다', () async {
    repo.gate = Completer<void>();

    final a = vm().toggleFavorite('u1', 'c1', false);
    final b = vm().toggleFavorite('u1', 'c2', false);

    expect(repo.calls, ['add', 'add']);

    repo.gate!.complete();
    await Future.wait([a, b]);
  });

  test('왕복이 끝나면 키가 풀려 다음 토글이 나간다', () async {
    await vm().toggleFavorite('u1', 'c1', false);
    await vm().toggleFavorite('u1', 'c1', true);

    expect(repo.calls, ['add', 'remove']);
  });

  test('실패하면 낙관적 오버라이드를 롤백하고 키도 정리된다', () async {
    repo.shouldFail = true;

    await vm().toggleFavorite('u1', 'c1', false);

    expect(repo.calls, ['add']);
    expect(overrides().containsKey('c1'), isFalse);
    expect(FirebaseGuard.inFlightCount, 0);

    // 실패 뒤에도 다시 시도할 수 있어야 한다.
    repo.shouldFail = false;
    await vm().toggleFavorite('u1', 'c1', false);
    expect(repo.calls, ['add', 'add']);
  });
}
