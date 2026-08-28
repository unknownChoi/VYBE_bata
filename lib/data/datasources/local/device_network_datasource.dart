import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_network_datasource.g.dart';

/// 기기 네트워크 연결 확인 + 설정 앱 열기.
/// **네트워크 플러그인(connectivity_plus · app_settings) 코드는 여기에만 둔다.**
///
/// 판정은 **도달 확인(DNS)이 우선**이고, 그게 답을 못 낼 때만 연결 종류로 가른다.
/// 연결 종류만 믿지 않는 이유 — 와이파이가 막 붙은 직후·기기가 상태를 늦게
/// 갱신하는 경우 종류와 실제 통신이 어긋난다.
///
/// 확인이 통째로 실패하면 **fail-open**(연결됨) — 확인 실패로 앱 전체를 막으면
/// 잘못된 차단이 되고, 실제로 통신이 안 되면 그 다음 화면(Firestore 조회)이
/// 각자 실패를 보여준다. 단 **도달도 못 재고 연결 종류도 없으면**(비행기 모드)
/// 연결 없음으로 본다.
class DeviceNetworkDataSource {
  const DeviceNetworkDataSource();

  /// **디버그 전용 강제 오프라인 스위치.** true면 실제 연결과 무관하게
  /// '연결 없음'으로 판정해 [NetworkErrorScreen] 을 띄운다.
  ///
  /// iOS 시뮬레이터는 Mac 네트워크를 그대로 쓰기 때문에 화면을 보려면 Mac
  /// 와이파이를 꺼야 한다 — 이 스위치를 켜면 그럴 필요가 없다.
  /// 켠 채로 **핫리로드하면 바로** 안내 화면이 뜬다([NetworkGate.reassemble]
  /// 이 다시 검사한다).
  ///
  /// ⚠ **`const` 여야 한다** — 일반 `static` 변수는 이미 초기화된 뒤라
  /// 핫리로드가 초기화식을 다시 실행하지 않아 값이 바뀌지 않는다(앱을 껐다
  /// 켜야 반영됨). const는 읽는 코드가 다시 컴파일되므로 저장 즉시 먹는다.
  ///
  /// ⚠ `kDebugMode` 안에서만 읽는다 — 실수로 true인 채 커밋돼도 릴리즈 빌드는
  /// 영향받지 않는다(코드도 트리셰이킹으로 빠진다).
  static const bool debugForceOffline = false;

  /// 연결 종류 조회 한계. 앱 첫 화면을 붙잡는 구간이라 짧게.
  static const _checkTimeout = Duration(seconds: 3);

  /// 실제 도달 확인(DNS) 한계. 느린 망에서 오래 붙잡지 않는다.
  static const _probeTimeout = Duration(seconds: 2);

  /// 도달 확인을 다시 해 보기까지의 간격.
  ///
  /// 와이파이가 막 붙은 직후엔 **인터페이스만 올라오고 DNS는 아직 못 쓴다** —
  /// 그 순간 한 번 실패한 걸로 오프라인을 확정하면 연결이 돌아왔는데도
  /// 안내 화면에 갇힌다(재시도 버튼도 같은 이유로 계속 실패).
  static const _retryGap = Duration(milliseconds: 500);

  /// 도달 확인 대상. 앱이 실제로 쓰는 호스트라 여기가 막히면 어차피 못 쓴다.
  static const _probeHost = 'firestore.googleapis.com';

  /// 지금 인터넷에 연결돼 있는지.
  ///
  /// ① 실제 도달(DNS)이 가장 강한 근거 — 되면 연결됨, 안 되면 연결 없음.
  /// ② 도달 확인이 판정을 못 냈을 때(타임아웃 등)만 연결 종류로 가른다.
  ///    종류가 하나도 없으면(비행기 모드·데이터 꺼짐) 연결 없음, 그 외엔 통과.
  ///
  /// [attempts] 는 도달 확인을 몇 번까지 다시 해 볼지. 첫 진입은 1회(스플래시를
  /// 오래 붙잡지 않는다), **재시도 버튼·앱 복귀·연결 변화**처럼 "방금 연결됐다"고
  /// 볼 만한 순간엔 여러 번 — 붙은 직후 DNS가 아직 안 잡힌 구간을 넘긴다.
  Future<bool> isConnected({int attempts = 1}) async {
    if (kDebugMode && debugForceOffline) {
      debugPrint('[DeviceNetwork] debugForceOffline — 강제 연결 없음');
      return false;
    }

    final results = await _connectivity();
    final reachable = await _reachable(attempts);

    // 판정 근거를 남긴다 — 안내 화면이 안 뜰(또는 안 사라질) 때 연결 종류
    // 때문인지 도달 확인 때문인지 콘솔만 보고 갈라낼 수 있어야 한다.
    debugPrint(
      '[DeviceNetwork] 연결 종류 ${results ?? '조회실패'} · 도달 '
      '${reachable ?? '판정불가'} (시도 $attempts)',
    );

    if (reachable != null) return reachable;
    // 도달을 못 재는 상황에서 연결 종류마저 없으면 오프라인으로 본다.
    if (results != null && _isOffline(results)) return false;
    // 그 밖에는 통과(fail-open) — 확인 실패로 앱을 막지 않는다.
    return true;
  }

  /// 기기 연결 상태가 바뀔 때마다 흐르는 스트림(true = 연결 종류가 생김).
  ///
  /// 여기서 오는 true는 '연결 종류가 생겼다'는 뜻일 뿐이라 실제 도달 여부는
  /// 받는 쪽이 [isConnected] 로 다시 확인한다.
  Stream<bool> connectionChanges() =>
      Connectivity().onConnectivityChanged.map((r) => !_isOffline(r));

  /// 기기 네트워크 설정 열기. 열었으면 true.
  ///
  /// Android는 와이파이 설정으로 바로 간다. iOS는 와이파이 설정 직접 진입을
  /// 허용하지 않아 앱 설정 화면으로 열린다(플러그인 폴백).
  Future<bool> openNetworkSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.wifi);
      return true;
    } catch (e) {
      debugPrint('[DeviceNetwork] 설정 열기 실패: $e');
      return false;
    }
  }

  /// 연결 종류. 조회가 실패하면 null(= 이 근거는 못 쓴다).
  Future<List<ConnectivityResult>?> _connectivity() async {
    try {
      return await Connectivity().checkConnectivity().timeout(_checkTimeout);
    } catch (e) {
      // 플러그인 미등록(테스트) · 조회 타임아웃.
      debugPrint('[DeviceNetwork] 연결 종류 조회 실패: $e');
      return null;
    }
  }

  /// 도달 확인을 [attempts] 번까지. false(못 나감)일 때만 다시 해 본다 —
  /// 성공이나 판정 불가는 더 기다려도 답이 안 바뀐다.
  Future<bool?> _reachable(int attempts) async {
    bool? last;
    for (var i = 0; i < attempts; i++) {
      if (i > 0) await Future<void>.delayed(_retryGap);
      last = await _canReachInternet();
      if (last != false) return last;
    }
    return last;
  }

  bool _isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  /// DNS 한 번으로 실제 도달 확인.
  ///
  /// true = 나갈 수 있음 / false = 이름을 못 찾음([SocketException]) /
  /// null = 판정 못 함(타임아웃 등). null은 부르는 쪽이 다른 근거로 가른다 —
  /// 타임아웃을 '오프라인'으로 읽으면 느린 망에서 잘못된 차단이 된다.
  Future<bool?> _canReachInternet() async {
    try {
      final records = await InternetAddress.lookup(
        _probeHost,
      ).timeout(_probeTimeout);
      return records.isNotEmpty && records.first.rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('[DeviceNetwork] 도달 실패($_probeHost): ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[DeviceNetwork] 도달 확인 건너뜀: $e');
      return null;
    }
  }
}

@riverpod
DeviceNetworkDataSource deviceNetworkDataSource(Ref ref) =>
    const DeviceNetworkDataSource();
