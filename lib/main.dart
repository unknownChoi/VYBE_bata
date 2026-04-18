import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Flutter 엔진 바인딩 초기화 — Firebase.initializeApp() 전에 반드시 호출
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (FlutterFire CLI가 생성한 플랫폼별 옵션 사용)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const VybeApp());
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
      child: WelcomeScreen(),
    );
  }
}
