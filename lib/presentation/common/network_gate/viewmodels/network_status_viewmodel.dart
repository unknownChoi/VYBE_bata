import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/local/device_network_datasource.dart';

part 'network_status_viewmodel.g.dart';

/// 요청 실패가 몰릴 때 연결 확인을 접는 간격.
const Duration _kFailureDebounce = Duration(seconds: 3);

/// 기기 네트워크 연결 상태. `true` = 연결됨.
///
/// 앱 첫 로딩(스플래시)에서 [SplashDestination] 판정이 이 provider를 보며 시작되고,
/// [NetworkGate] 가 같은 값으로 차단 화면을 그린다 — 판정은 여기 한 곳뿐.
///
/// **keepAlive인 이유** — 게이트가 트리 최상단이라 재생성될 일이 없고,
/// 기기 연결 변화 구독도 앱이 사는 동안 계속 유지돼야 한다.
///
/// **fail-open** — 확인 실패는 datasource에서 이미 '연결됨'으로 접힌다.
@Riverpod(keepAlive: true)
class NetworkStatus extends _$NetworkStatus {
  /// 마지막 확인 시각 · 확인 진행 여부. [reportRequestFailure] 가 확인을
  /// 한 번으로 접는 데 쓴다.
  DateTime? _lastCheckedAt;
  bool _checking = false;

  @override
  Future<bool> build() {
    final dataSource = ref.watch(deviceNetworkDataSourceProvider);

    // 와이파이를 켜거나 비행기 모드를 풀면 버튼을 누르지 않아도 앱이 살아난다.
    // 스트림의 true는 '연결 종류가 생겼다'까지라 실제 도달은 recheck가 다시 본다.
    // 스트림 에러는 흘려보낸다 — 구독이 끊겨도 재시도 버튼·앱 복귀 경로가 남는다.
    final subscription = dataSource
        .connectionChanges()
        .listen((_) => recheck(), onError: (_) {});
    ref.onDispose(subscription.cancel);

    return dataSource.isConnected();
  }

  /// 재확인. 확인이 끝난 뒤의 연결 상태를 돌려준다.
  ///
  /// 재시도 버튼 · 앱 복귀(resumed) · 기기 연결 변화 · 요청 실패에서 호출.
  /// 확인 중에도 직전 결과를 유지한다(로딩으로 되돌리면 차단 화면이 스플래시로
  /// 깜빡인다 — 재시도 중 표시는 화면이 자기 상태로 그린다).
  Future<bool> recheck() async {
    _checking = true;
    try {
      final connected = await ref
          .read(deviceNetworkDataSourceProvider)
          .isConnected();
      _lastCheckedAt = DateTime.now();
      if (!ref.mounted) return connected;
      state = AsyncData(connected);
      return connected;
    } finally {
      _checking = false;
    }
  }

  /// 데이터 요청이 실패했을 때 호출. 실제로 연결이 없으면 상태가 false가 되고
  /// [NetworkGate] 가 곧바로 연결 안내 화면으로 넘긴다.
  ///
  /// 화면 여러 개가 동시에 실패하면 호출도 같이 쏟아지므로 **확인을 한 번으로
  /// 접는다** — 확인 중이거나 방금 확인했으면 그냥 돌아간다. 연결이 멀쩡한데
  /// 난 실패(권한 오류 등)면 확인이 통과해 아무 일도 일어나지 않는다.
  ///
  /// 대부분의 실패는 [NetworkFailureObserver] 가 자동으로 넘겨준다.
  /// provider를 거치지 않는 호출(버튼 핸들러의 try/catch 등)에서만 직접 부르면 된다.
  Future<void> reportRequestFailure() async {
    if (_checking) return;
    final last = _lastCheckedAt;
    if (last != null && DateTime.now().difference(last) < _kFailureDebounce) {
      return;
    }
    await recheck();
  }
}
