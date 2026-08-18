import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/providers/network_failure_observer.dart';
import 'package:vybe/data/datasources/local/device_network_datasource.dart';
import 'package:vybe/presentation/common/network_gate/viewmodels/network_status_viewmodel.dart';

/// 플러그인을 타지 않는 대역. 확인 결과를 마음대로 바꾸고 호출 횟수를 센다.
class _FakeNetwork extends DeviceNetworkDataSource {
  _FakeNetwork(this.connected);

  bool connected;
  int checks = 0;

  @override
  Future<bool> isConnected() async {
    checks++;
    return connected;
  }

  @override
  Stream<bool> connectionChanges() => const Stream.empty();
}

/// 마이크로태스크(관찰자) + 비동기 확인이 끝날 때까지 흘려 보낸다.
Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _FakeNetwork network;
  late ProviderContainer container;

  ProviderContainer makeContainer({bool withObserver = false}) =>
      ProviderContainer(
        observers: withObserver ? const [NetworkFailureObserver()] : const [],
        overrides: [deviceNetworkDataSourceProvider.overrideWithValue(network)],
      );

  setUp(() => network = _FakeNetwork(true));
  tearDown(() => container.dispose());

  group('NetworkStatus.reportRequestFailure', () {
    test('요청이 실패했고 실제로 끊겨 있으면 상태가 연결 없음이 된다', () async {
      container = makeContainer();
      expect(await container.read(networkStatusProvider.future), isTrue);

      network.connected = false;
      await container.read(networkStatusProvider.notifier).reportRequestFailure();

      expect(container.read(networkStatusProvider).value, isFalse);
    });

    test('연결이 멀쩡하면(권한 오류 등) 상태를 건드리지 않는다', () async {
      container = makeContainer();
      expect(await container.read(networkStatusProvider.future), isTrue);

      await container.read(networkStatusProvider.notifier).reportRequestFailure();

      expect(container.read(networkStatusProvider).value, isTrue);
    });

    test('연달아 보고해도 확인은 한 번만 — 화면 여러 개가 동시에 실패하는 경우', () async {
      container = makeContainer();
      await container.read(networkStatusProvider.future);
      final afterBuild = network.checks;

      final notifier = container.read(networkStatusProvider.notifier);
      await Future.wait([
        notifier.reportRequestFailure(),
        notifier.reportRequestFailure(),
        notifier.reportRequestFailure(),
      ]);

      expect(network.checks - afterBuild, 1);
    });

    test('재시도 버튼(recheck)은 디바운스와 무관하게 매번 확인한다', () async {
      container = makeContainer();
      await container.read(networkStatusProvider.future);
      final afterBuild = network.checks;

      final notifier = container.read(networkStatusProvider.notifier);
      await notifier.recheck();
      await notifier.recheck();

      expect(network.checks - afterBuild, 2);
    });
  });

  group('NetworkFailureObserver', () {
    test('provider가 실패하면 연결을 다시 확인해 안내 화면으로 넘긴다', () async {
      container = makeContainer(withObserver: true);
      expect(await container.read(networkStatusProvider.future), isTrue);

      network.connected = false;
      final boom = FutureProvider<int>(
        (ref) => Future<int>.error(StateError('요청 실패')),
      );
      await expectLater(container.read(boom.future), throwsStateError);
      await settle();

      expect(container.read(networkStatusProvider).value, isFalse);
    });

    test('연결 확인 자체가 실패해도 되받지 않는다', () async {
      container = makeContainer(withObserver: true);
      await container.read(networkStatusProvider.future);
      final afterBuild = network.checks;

      // networkStatusProvider를 실패시키면 관찰자가 다시 확인을 걸어 무한 반복이
      // 될 수 있다 — 자기 자신은 건너뛴다.
      container.read(networkStatusProvider.notifier).state = AsyncError(
        StateError('확인 실패'),
        StackTrace.current,
      );
      await settle();

      expect(network.checks - afterBuild, 0);
    });
  });
}
