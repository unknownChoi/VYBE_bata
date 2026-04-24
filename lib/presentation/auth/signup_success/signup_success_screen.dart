// TODO: signup_success_screen.dart
// 회원가입 완료 화면 (SignupSuccessScreen)
// - 배경 동영상 무한 반복 재생 (assets/videos/signup_succes.mp4)
// - VYBE 로고 + "와 함께" 텍스트
// - 라임→핑크→퍼플 그라데이션 타이틀 텍스트
// - 검정→투명 오버레이 그라데이션 (영상과 자연스러운 전환)
// - 바이브 시작하기 버튼 (special variant, 그라데이션 border)
//
// Figma node: 219-2841

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';
import 'package:vybe/presentation/home/viewmodels/banner_viewmodel.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';

/// 회원가입 완료 화면
///
/// 배경: assets/videos/signup_succes.mp4 (무한 반복)
/// Figma node: 219-2841
class SignupSuccessScreen extends ConsumerStatefulWidget {
  const SignupSuccessScreen({super.key});

  @override
  ConsumerState<SignupSuccessScreen> createState() =>
      _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends ConsumerState<SignupSuccessScreen> {
  // iOS / Android 에서만 video_player 지원
  static bool get _videoSupported =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  // 그라데이션 텍스트용 셰이더 (Figma 방사형 그라디언트 → 대각 선형으로 근사)
  static const _titleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB5FF60), // lime
      Color(0xFFC8E77F),
      Color(0xFFDACA9E),
      Color(0xFFFF9EDB), // pink
      Color(0xFFDD82E4),
      Color(0xFFBB67ED),
      Color(0xFF994CF5),
      Color(0xFF7731FE), // purple
    ],
    stops: [0.0, 0.142, 0.285, 0.569, 0.677, 0.785, 0.892, 1.0],
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    if (_videoSupported) _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final ctrl =
          VideoPlayerController.asset('assets/videos/signup_succes.mp4');
      _videoCtrl = ctrl;
      await ctrl.initialize();
      if (!mounted) return;
      await ctrl.setLooping(true);
      await ctrl.setVolume(0);
      await ctrl.play();
      setState(() => _videoReady = true);
    } catch (_) {
      // 플러그인 미설치 또는 초기화 실패 시 배경색으로 폴백
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 배경 동영상 (top: 280.h 부터 화면 하단까지) ──
          if (_videoReady && _videoCtrl != null)
            Positioned(
              left: 0,
              right: 0,
              top: 280.h,
              bottom: 0,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoCtrl!.value.size.width,
                  height: _videoCtrl!.value.size.height,
                  child: VideoPlayer(_videoCtrl!),
                ),
              ),
            ),

          // 상단 어둠 → 투명 그라데이션 (비디오 페이드인 효과)
          Positioned(
            left: 0,
            right: 0,
            top: 200.h,
            height: 420.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    VybeColors.background,                    // 완전 불투명
                    VybeColors.background.withValues(alpha: 0.95),
                    VybeColors.background.withValues(alpha: 0.8),
                    VybeColors.background.withValues(alpha: 0.5),
                    VybeColors.background.withValues(alpha: 0.15),
                    Colors.transparent,                       // 완전 투명
                  ],
                  stops: const [0.0, 0.35, 0.55, 0.75, 0.9, 1.0],
                ),
              ),
            ),
          ),

          // ── VYBE 로고 + "와 함께" ──
          Positioned(
            left: 26.w,
            top: 156.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/common/vybe_white_logo.svg',
                  width: 120.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  '와 함께',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 36.sp,
                    color: VybeColors.gray200,
                    letterSpacing: -0.9,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          // ── 그라데이션 타이틀 텍스트 ──
          Positioned(
            left: 26.w,
            top: 220.h,
            width: 305.w,
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  _titleGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                '새로운\n클럽 라이프를\n시작해볼까요?',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 44.sp,
                  height: 1.25,
                  letterSpacing: 44 * -0.025,
                  color: Colors.white, // ShaderMask가 덮어씀
                ),
              ),
            ),
          ),

          // ── 바이브 시작하기 버튼 ──
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 40.h,
            child: VybeButton(
              label: '바이브 시작하기',
              onTap: () async {
                try {
                  final banners = await ref
                      .read(bannerListProvider.future)
                      .timeout(const Duration(seconds: 6));
                  if (!context.mounted) return;
                  await Future.wait(
                    banners.map((b) async {
                      try {
                        await precacheImage(NetworkImage(b.imageUrl), context)
                            .timeout(const Duration(seconds: 6));
                      } catch (_) {}
                    }),
                  );
                } catch (_) {}
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScaffold()),
                  (route) => false,
                );
              },
              variant: VybeButtonVariant.special,
            ),
          ),
        ],
      ),
    );
  }
}
