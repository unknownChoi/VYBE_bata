import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/auth/identity_verification/identity_verification_screen.dart';
import 'package:vybe/presentation/auth/signup_flow.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/auth/terms/terms_detail_screen.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/login_method_bottom_sheet.dart';
import 'package:vybe/presentation/auth/welcome/widgets/welcome_headline.dart';
import 'package:vybe/presentation/auth/welcome/widgets/welcome_legal_note.dart';
import 'package:vybe/presentation/auth/welcome/widgets/welcome_login_button.dart';
import 'package:vybe/presentation/common/splash_logo_landing.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
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

/// 소셜 로그인 버튼 한 줄의 생김새·식별자. 버튼 세 개가 색·아이콘만 다르고
/// 나머지가 같아 목록으로 두고 돌린다 (Apple은 아직 동작 없음 — CLAUDE.md 참고).
class _Social {
  /// [_loadingButton] 과 맞춰 쓰는 식별자.
  final String id;
  final Color background;
  final String iconPath;
  final double iconSize;
  final String label;
  final Color labelColor;

  const _Social({
    required this.id,
    required this.background,
    required this.iconPath,
    required this.iconSize,
    required this.label,
    required this.labelColor,
  });
}

const _socials = [
  _Social(
    id: 'kakao',
    background: Color(0xFFFEE500),
    iconPath: 'assets/icons/auth/social_login_kakao_icon.svg',
    iconSize: 20,
    label: '카카오로 시작하기',
    labelColor: Color(0xFF191919),
  ),
  _Social(
    id: 'naver',
    background: Color(0xFF02C75A),
    iconPath: 'assets/icons/auth/social_login_naver_icon.svg',
    iconSize: 14,
    label: '네이버로 시작하기',
    labelColor: Colors.white,
  ),
  _Social(
    id: 'apple',
    background: Colors.white,
    iconPath: 'assets/icons/auth/social_login_apple_icon.svg',
    iconSize: 18,
    label: 'Apple로 시작하기',
    labelColor: VybeColors.background,
  ),
];

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  String? _loadingButton;

  /// 약관 전문 화면을 연다.
  ///
  /// 로그인이 진행 중일 때는 막는다 — 소셜 SDK 창이 떠 있는 사이에 화면을
  /// 더 쌓으면 콜백이 돌아왔을 때 어디로 보낼지가 어긋난다.
  void _openLegal(LegalDoc doc) {
    if (_loadingButton != null) return;
    Navigator.push(
      context,
      SwipeBackPageRoute(builder: (_) => TermsDetailScreen(doc: doc)),
    );
  }

  /// 소셜 로그인 직후 분기.
  ///
  /// `isNewUser`(Auth user 존재 여부)만으로는 부족하다 — 가입 도중 앱을 끄면
  /// Auth user는 있는데 프로필이 비어 있고, 그 계정은 `isNewUser=false`로
  /// 돌아온다. 그대로 홈에 들여보내면 이름·전화번호가 없는 유령 계정이 된다.
  ///
  /// [method] 는 본인인증 화면까지 따라간다 — 거기서 전화번호가 이미 쓰이고
  /// 있을 때 '같은 방식의 재로그인'인지 가르는 기준이다.
  ///
  /// 탈퇴 대기(보관 30일) 계정의 복구는 **서버 로그인 함수가 이미 끝냈다** —
  /// 여기서는 결과만 알린다.
  Future<void> _afterSocialLogin(bool isNewUser, SignupMethod method) async {
    final vm = ref.read(authViewModelProvider.notifier);
    final needsSignup = isNewUser || await vm.needsProfileSetup();
    if (!mounted) return;

    // 탈퇴 대기 계정이면 서버가 로그인 시점에 되살렸다(보관 30일 안일 때만).
    // 조용히 복구하면 사용자가 탈퇴가 취소된 걸 모른다.
    if (vm.accountRestored) {
      VybeToast.show(context, message: kAccountRestoredMessage);
    }

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

  /// [_socials] 한 줄 → 버튼. Apple은 아직 연결 전이라 눌러도 아무 일도 없다.
  Widget _socialButton(_Social social) => WelcomeLoginButton(
    backgroundColor: social.background,
    iconPath: social.iconPath,
    iconSize: social.iconSize.r,
    label: social.label,
    labelColor: social.labelColor,
    isLoading: _loadingButton == social.id,
    disabled: _loadingButton != null,
    onTap: switch (social.id) {
      'kakao' => _onKakaoLogin,
      'naver' => _onNaverLogin,
      _ => () {},
    },
  );

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
                  WelcomeHeadline(
                    logoKey: widget.isRoot ? splashLogoLandingKey : null,
                  ),
                  const Spacer(flex: 10),
                  // Login buttons
                  for (var i = 0; i < _socials.length; i++) ...[
                    if (i > 0) SizedBox(height: 10.h),
                    _socialButton(_socials[i]),
                  ],
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
                  WelcomeLegalNote(onOpen: _openLegal),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
