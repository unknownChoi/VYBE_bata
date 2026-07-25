import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/auth/identity_verification/identity_verification_screen.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/login_method_bottom_sheet.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/home/viewmodels/banner_viewmodel.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const _kakaoIconPath = 'assets/icons/auth/social_login_kakao_icon.svg';
  static const _naverIconPath = 'assets/icons/auth/social_login_naver_icon.svg';
  static const _appleIconPath = 'assets/icons/auth/social_login_apple_icon.svg';
  static const _vybeWhiteLogo = 'assets/icons/common/vybe_white_logo.svg';

  String? _loadingButton;

  Future<void> _navigateHome() async {
    try {
      final banners = await ref
          .read(bannerListProvider.future)
          .timeout(const Duration(seconds: 6));
      if (!mounted) return;
      await Future.wait(
        banners.map((b) async {
          try {
            await precacheImage(NetworkImage(b.imageUrl), context)
                .timeout(const Duration(seconds: 6));
          } catch (_) {}
        }),
      );
    } catch (_) {}
    if (!mounted) return;
    // 로그인 성공 시 루트(AuthGate)가 이미 MainScaffold로 바뀌어 있다.
    // 이 화면이 push된 상태(마이페이지 등에서 진입)면 스택만 정리하면 된다.
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _onKakaoLogin() async {
    if (_loadingButton != null) return;
    setState(() => _loadingButton = 'kakao');
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final isNewUser = await ref
          .read(authViewModelProvider.notifier)
          .kakaoLogin(token.accessToken);

      if (!mounted) return;

      if (isNewUser) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const IdentityVerificationScreen()),
        );
      } else {
        await _navigateHome();
      }
    } catch (e, st) {
      final log = '${DateTime.now()}\n$e\n$st\n\n';
      File('/Users/justinchoi/Desktop/업무/소스코드/vybe_bata/kakao_error.txt')
          .writeAsStringSync(log, mode: FileMode.append);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loadingButton = null);
    }
  }

  Future<void> _onNaverLogin() async {
    if (_loadingButton != null) return;
    setState(() => _loadingButton = 'naver');
    try {
      final result = await FlutterNaverLogin.logIn();
      if (result.status != NaverLoginStatus.loggedIn) return;

      final accessToken = result.accessToken?.accessToken;
      if (accessToken == null) return;

      final isNewUser = await ref
          .read(authViewModelProvider.notifier)
          .naverLogin(accessToken);

      if (!mounted) return;

      if (isNewUser) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IdentityVerificationScreen()),
        );
      } else {
        await _navigateHome();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loadingButton = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF101013),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _HeroVisual()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 7),
                  SvgPicture.asset(_vybeWhiteLogo, height: 44.h),
                  SizedBox(height: 20.h),
                  // Line 1: "바이브 탈 준비 됐어?"
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 28.sp,
                        letterSpacing: -0.025 * 28,
                        height: 30 / 28,
                      ),
                      children: [
                        TextSpan(
                          text: '바이브',
                          style: TextStyle(color: VybeColors.mainLime500),
                        ),
                        const TextSpan(
                          text: ' 탈 준비 됐어?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Line 2: "우린 끝냈어!" — "끝냈어!" in purple gradient
                  Row(
                    children: [
                      Text(
                        '우린 ',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 42.sp,
                          letterSpacing: -0.025 * 42,
                          height: 46 / 42,
                          color: Colors.white,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF7731FE), Color(0xFFB377FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          '끝냈어!',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            fontSize: 42.sp,
                            letterSpacing: -0.025 * 42,
                            height: 46 / 42,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 10),
                  // Login buttons
                  _LoginButton(
                    backgroundColor: const Color(0xFFFEE500),
                    iconPath: _kakaoIconPath,
                    iconSize: 20.r,
                    label: '카카오로 시작하기',
                    labelColor: const Color(0xFF191919),
                    isLoading: _loadingButton == 'kakao',
                    disabled: _loadingButton != null,
                    onTap: _onKakaoLogin,
                  ),
                  SizedBox(height: 10.h),
                  _LoginButton(
                    backgroundColor: const Color(0xFF02C75A),
                    iconPath: _naverIconPath,
                    iconSize: 14.r,
                    label: '네이버로 시작하기',
                    labelColor: Colors.white,
                    isLoading: _loadingButton == 'naver',
                    disabled: _loadingButton != null,
                    onTap: _onNaverLogin,
                  ),
                  SizedBox(height: 10.h),
                  _LoginButton(
                    backgroundColor: Colors.white,
                    iconPath: _appleIconPath,
                    iconSize: 18.r,
                    label: 'Apple로 시작하기',
                    labelColor: const Color(0xFF101013),
                    isLoading: _loadingButton == 'apple',
                    disabled: _loadingButton != null,
                    onTap: () {},
                  ),
                  SizedBox(height: 18.h),
                  // 다른 방법으로 로그인
                  GestureDetector(
                    onTap: _loadingButton != null
                        ? null
                        : () => showLoginMethodBottomSheet(
                              context,
                              onIdentityLogin: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const IdentityVerificationScreen(),
                                  ),
                                );
                              },
                            ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '다른 방법으로 로그인',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          letterSpacing: -0.025 * 14,
                          color: _loadingButton != null
                              ? VybeColors.gray600
                              : VybeColors.gray400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Legal text
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: VybeColors.gray600,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: '가입 시 '),
                        TextSpan(
                          text: '서비스 약관',
                          style: TextStyle(
                            color: VybeColors.gray400,
                            decoration: TextDecoration.underline,
                            decorationColor: VybeColors.gray400,
                          ),
                        ),
                        const TextSpan(text: ' 및 '),
                        TextSpan(
                          text: '개인정보 처리방침',
                          style: TextStyle(
                            color: VybeColors.gray400,
                            decoration: TextDecoration.underline,
                            decorationColor: VybeColors.gray400,
                          ),
                        ),
                        const TextSpan(text: '에 동의합니다.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Animated background blobs
// ============================================================

class _HeroVisual extends StatefulWidget {
  const _HeroVisual();

  @override
  State<_HeroVisual> createState() => _HeroVisualState();
}

class _HeroVisualState extends State<_HeroVisual> with TickerProviderStateMixin {
  late final AnimationController _c1;
  late final AnimationController _c2;
  late final AnimationController _c3;
  late final Animation<double> _a1;
  late final Animation<double> _a2;
  late final Animation<double> _a3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _c2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
    _c3 = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _a1 = CurvedAnimation(parent: _c1, curve: Curves.easeInOut);
    _a2 = CurvedAnimation(parent: _c2, curve: Curves.easeInOut);
    _a3 = CurvedAnimation(parent: _c3, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2, _c3]),
      builder: (context, _) {
        final t1 = _a1.value;
        final t2 = _a2.value;
        final t3 = _a3.value;
        return Stack(
          children: [
            // Purple bloom — top-left, breath1 8s
            Positioned(
              top: -80.h,
              left: -100.w,
              child: Opacity(
                opacity: ui.lerpDouble(1.0, 0.75, t1)!,
                child: Transform.scale(
                  scale: ui.lerpDouble(1.0, 1.15, t1)!,
                  child: Transform.translate(
                    offset: Offset(
                      ui.lerpDouble(0.0, 20.0, t1)!,
                      ui.lerpDouble(0.0, 10.0, t1)!,
                    ),
                    child: _Blob(
                      size: 360.w,
                      color: const Color(0xFF7731FE).withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
            // Lime bloom — mid-right, breath2 10s
            Positioned(
              top: 180.h,
              right: -120.w,
              child: Opacity(
                opacity: ui.lerpDouble(0.9, 0.6, t2)!,
                child: Transform.scale(
                  scale: ui.lerpDouble(1.0, 1.2, t2)!,
                  child: Transform.translate(
                    offset: Offset(
                      ui.lerpDouble(0.0, -15.0, t2)!,
                      ui.lerpDouble(0.0, -15.0, t2)!,
                    ),
                    child: _Blob(
                      size: 320.w,
                      color: const Color(0xFFB5FF60).withValues(alpha: 0.32),
                    ),
                  ),
                ),
              ),
            ),
            // Pink/magenta bloom — bottom-left, breath1 12s
            Positioned(
              bottom: 200.h,
              left: 40.w,
              child: Opacity(
                opacity: ui.lerpDouble(1.0, 0.75, t3)!,
                child: Transform.scale(
                  scale: ui.lerpDouble(1.0, 1.15, t3)!,
                  child: Transform.translate(
                    offset: Offset(
                      ui.lerpDouble(0.0, 20.0, t3)!,
                      ui.lerpDouble(0.0, 10.0, t3)!,
                    ),
                    child: _Blob(
                      size: 260.w,
                      color: const Color(0xFFFF4D8D).withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 0.65],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Login button
// ============================================================

class _LoginButton extends StatelessWidget {
  final Color backgroundColor;
  final String iconPath;
  final double iconSize;
  final String label;
  final Color labelColor;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const _LoginButton({
    required this.backgroundColor,
    required this.iconPath,
    required this.iconSize,
    required this.label,
    required this.labelColor,
    required this.isLoading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled && !isLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: isLoading
              ? Center(child: VybeSpinner(size: 28.r))
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 22.w,
                      child: SvgPicture.asset(
                        iconPath,
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        letterSpacing: -0.025 * 16,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
