// 임시 개발용 진입점 — ClubDetailScreen 단독 실행(리팩토링 회귀 확인). 검증 후 삭제.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

const _clubId = '62VaHypRMWcCySNQZEaa';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: _DevApp()));
}

class _DevApp extends StatelessWidget {
  const _DevApp();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: child,
      ),
      child: const ClubDetailScreen(clubId: _clubId),
    );
  }
}
