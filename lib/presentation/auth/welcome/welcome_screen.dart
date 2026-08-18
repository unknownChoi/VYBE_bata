import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/auth/identity_verification/identity_verification_screen.dart';
import 'package:vybe/presentation/auth/signup_flow.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/login_method_bottom_sheet.dart';
import 'package:vybe/presentation/common/splash_logo_landing.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  /// 앱 루트로 그려지는 화면인지. true면 로고에 [splashLogoLandingKey] 를 달아
  /// 스플래시 로고가 이 자리로 날아와 앉는다.
  ///
  /// ⚠ 마이페이지에서 push 로 열 때는 false — 같은 GlobalKey 를 단 위젯이
  /// 트리에 둘 있으면 프레임워크가 죽는다.
  final bool isRoot;

  const WelcomeScreen({super.key, this.isRoot = false});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const _kakaoIconPath = 'assets/icons/auth/social_login_kakao_icon.svg';
  static const _naverIconPath = 'assets/icons/auth/social_login_naver_icon.svg';
  static const _appleIconPath = 'assets/icons/auth/social_login_apple_icon.svg';
  static const _vybeWhiteLogo = 'assets/icons/common/vybe_white_logo.svg';

  String? _loadingButton;

  /// 소셜 로그인 직후 분기.
  ///
  /// `isNewUser`(Auth user 존재 여부)만으로는 부족하다 — 가입 도중 앱을 끄면
  /// Auth user는 있는데 프로필이 비어 있고, 그 계정은 `isNewUser=false`로
  /// 돌아온다. 그대로 홈에 들여보내면 이름·전화번호가 없는 유령 계정이 된다.
  ///
  /// [method] 는 본인인증 화면까지 따라간다 — 거기서 전화번호가 이미 쓰이고
  /// 있을 때 '같은 방식의 재로그인'인지 가르는 기준이다.
  Future<void> _afterSocialLogin(bool isNewUser, SignupMethod method) async {
    final needsSignup = isNewUser ||
        await ref.read(authViewModelProvider.notifier).needsProfileSetup();
    if (!mounted) return;

    if (needsSignup) {
      Navigator.push(
        context,
        SwipeBackPageRoute(
          builder: (_) => IdentityVerificationScreen(method: method),
        ),
      );
      return;
    }
    await enterHomeAfterAuth(context, ref);
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
      await _afterSocialLogin(isNewUser, SignupMethod.kakao);
    } catch (e) {
      if (!mounted) return;
      VybeToast.show(context, message: e.toString(), isError: true);
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
      await _afterSocialLogin(isNewUser, SignupMethod.naver);
    } catch (e) {
      if (!mounted) return;
      VybeToast.show(context, message: e.toString(), isError: true);
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
      backgroundColor: kVybeInk,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 7),
                  SvgPicture.asset(
                    _vybeWhiteLogo,
                    key: widget.isRoot ? splashLogoLandingKey : null,
                    height: 44.h,
                  ),
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
                      children: const [
                        TextSpan(
                          text: '바이브',
                          style: TextStyle(color: VybeColors.mainLime500),
                        ),
                        TextSpan(
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
                          colors: [VybeColors.mainPurple500, Color(0xFFB377FF)],
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
                    labelColor: VybeColors.background,
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
                                  SwipeBackPageRoute(
                                    builder: (_) =>
                                        const IdentityVerificationScreen(
                                      method: SignupMethod.identity,
                                    ),
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
                      children: const [
                        TextSpan(text: '가입 시 '),
                        TextSpan(
                          text: '서비스 약관',
                          style: TextStyle(
                            color: VybeColors.gray400,
                            decoration: TextDecoration.underline,
                            decorationColor: VybeColors.gray400,
                          ),
                        ),
                        TextSpan(text: ' 및 '),
                        TextSpan(
                          text: '개인정보 처리방침',
                          style: TextStyle(
                            color: VybeColors.gray400,
                            decoration: TextDecoration.underline,
                            decorationColor: VybeColors.gray400,
                          ),
                        ),
                        TextSpan(text: '에 동의합니다.'),
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
