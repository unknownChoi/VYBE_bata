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
/// 판정은 **fail-open** — 플러그인 오류·타임아웃은 전부 '연결됨'으로 돌린다.
/// 확인 자체가 실패했다고 앱 전체를 막으면 잘못된 차단이 되고, 실제로 통신이
/// 안 되면 그 다음 화면(Firestore 조회)이 각자 실패를 보여준다.
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

  /// 도달 확인 대상. 앱이 실제로 쓰는 호스트라 여기가 막히면 어차피 못 쓴다.
  static const _probeHost = 'firestore.googleapis.com';

  /// 지금 인터넷에 연결돼 있는지.
  ///
  /// ① 연결 종류(wifi/mobile/…)가 하나도 없으면 곧바로 false — 비행기 모드·
  ///    데이터 꺼짐이 여기서 걸린다.
  /// ② 연결은 있는데 실제로 못 나가는 경우(공용 와이파이 로그인 페이지 등)를
  ///    DNS 조회로 한 번 더 확인한다.
  Future<bool> isConnected() async {
    if (kDebugMode && debugForceOffline) {
      debugPrint('[DeviceNetwork] debugForceOffline — 강제 연결 없음');
      return false;
    }

    try {
      final results = await Connectivity().checkConnectivity().timeout(
        _checkTimeout,
      );
      if (_isOffline(results)) {
        debugPrint('[DeviceNetwork] 연결 없음($results)');
        return false;
      }
      // 판정 근거를 남긴다 — 안내 화면이 안 뜰 때 연결 종류 때문인지
      // 도달 확인 때문인지 콘솔만 보고 갈라낼 수 있어야 한다.
      final reachable = await _canReachInternet();
      debugPrint('[DeviceNetwork] 연결 종류 $results · 도달 $reachable');
      return reachable;
    } catch (e) {
      // 플러그인 미등록(테스트) · 조회 타임아웃 — 막지 않는다.
      debugPrint('[DeviceNetwork] 연결 확인 실패: $e → 통과');
      return true;
    }
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

  bool _isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  /// DNS 한 번으로 실제 도달 확인.
  ///
  /// 이름을 못 찾는 경우([SocketException])만 오프라인으로 본다 —
  /// 타임아웃은 '느린 망'일 수 있어 통과시킨다(잘못된 차단 방지).
  Future<bool> _canReachInternet() async {
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
      return true;
    }
  }
}

@riverpod
DeviceNetworkDataSource deviceNetworkDataSource(Ref ref) =>
    const DeviceNetworkDataSource();
