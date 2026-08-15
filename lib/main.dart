import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:vybe/presentation/auth/auth_gate.dart';
import 'package:vybe/presentation/common/splash_gate.dart';
import 'package:vybe/presentation/common/version_gate/version_gate.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // flutter_naver_map 마커 이미지(NOverlayImage.fromWidget)가 임시파일을
  // 생성/정리하는 과정에서, 이미 삭제된 temp 디렉토리를 다시 지우려다 던지는
  // 무해한 비동기 FileSystemException(_Directory._delete)을 삼킨다.e
  // 앱 동작엔 영향 없고 콘솔만 오염시키므로 이 케이스만 처리 완료로 표시.
  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is FileSystemException &&
        error.message.toLowerCase().contains('delet')) {
      return true; // 처리됨 — 크래시/에러 로그 방지
    }
    return false; // 그 외 에러는 기본 처리(로그/리포트)
  };

  // 세로 방향 고정 (가로 회전 금지).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 환경변수 로드
  await dotenv.load(fileName: '.env');

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  // 네이버맵 SDK 초기화
  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,
    onAuthFailed: (ex) => debugPrint('[NaverMap] 인증 실패: $ex'),
  );

  runApp(const ProviderScope(child: VybeApp()));
}

class VybeApp extends StatelessWidget {
  const VybeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        title: 'VYBE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: child,
      ),
      // 루트는 SplashGate → VersionGate → AuthGate.
      // 스플래시가 맨 위 — 인트로 애니메이션이 끝날 때까지 아래 게이트를
      // 만들지 않는다(버전 체크·세션 복원은 그 동안 병렬 진행).
      // 버전 게이트가 인증보다 위 — 로그인 여부와 무관하게 먼저 걸러야 하고,
      // 강제 업데이트/점검 차단이 로그인 플로우 뒤로 밀리면 우회가 가능해진다.
      // 비로그인이면 AuthGate가 MainScaffold 진입 자체를 막는다.
      child: const SplashGate(child: VersionGate(child: AuthGate())),
    );
  }
}
