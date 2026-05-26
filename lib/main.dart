import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
// import 'package:vybe/presentation/auth/signup_success/signup_success_screen.dart';
// import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
// import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수 로드
  await dotenv.load(fileName: '.env');

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  // 네이버맵 SDK 초기화
  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,
    onAuthFailed: (ex) => print('[NaverMap] 인증 실패: $ex'),
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
      child: const ClubDetailScreen(),
    );
  }
}
