import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';

/// 인트로(로고 등장) 전체 길이. [SplashGate.minDuration] 은 이보다 길어야
/// 애니메이션이 중간에 잘리지 않는다.
const kSplashIntroDuration = Duration(milliseconds: 1150);

/// 앱 진입 스플래시 — 로고 등장 + 글로우 호흡 + 라임 언더라인.
///
/// [SplashGate] 가 앱 시작 시 인트로를 재생하고, 그 뒤로도 버전 게이트 →
/// 인증 게이트가 연달아 로딩 화면을 요구한다. **셋이 같은 화면**이라야
/// 게이트가 바뀌는 순간 화면이 튀지 않아 하나로 공용한다.
///
/// 게이트 로딩 용도로 쓸 때는 [playIntro] 를 false 로 — 인트로가 이미
/// 끝난 상태(마지막 프레임)에서 시작해 로고가 다시 나타나지 않는다.
class VybeSplash extends StatefulWidget {
  /// 로고 등장 애니메이션 재생 여부. false면 완성 프레임에서 시작한다.
  final bool playIntro;

  const VybeSplash({super.key, this.playIntro = true});

  @override
  State<VybeSplash> createState() => _VybeSplashState();
}

class _VybeSplashState extends State<VybeSplash>
    with TickerProviderStateMixin {
  /// 로고 등장 — 1회 재생.
  late final AnimationController _intro;

  /// 배경 글로우 호흡 — 인트로와 무관하게 계속 반복(대기 중이라는 신호).
  late final AnimationController _pulse;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowIn;
  late final Animation<double> _line;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: kSplashIntroDuration);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 각 요소는 인트로 타임라인의 구간을 나눠 쓴다 — 컨트롤러를 늘리지 않고
    // 순서(글로우 → 로고 → 언더라인)를 만들기 위함.
    _glowIn = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _logoFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.1, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _line = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    );

    if (widget.playIntro) {
      _intro.forward();
    } else {
      _intro.value = 1.0; // 완성 프레임 — 게이트 전환 시 로고 재등장 방지
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const VybeAurora(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [_buildGlow(), _buildLogo()],
                ),
                SizedBox(height: 22.h),
                _buildUnderline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 로고 뒤 퍼플 글로우 — 인트로에서 커지며 나타나고, 이후 호흡만 반복.
  Widget _buildGlow() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowIn, _pulse]),
      builder: (_, __) {
        final breath = _pulse.value; // 0 → 1 → 0
        return Opacity(
          opacity: _glowIn.value * (0.6 + 0.4 * breath),
          child: Transform.scale(
            scale: (0.7 + 0.3 * _glowIn.value) * (0.96 + 0.08 * breath),
            child: Container(
              width: 300.r,
              height: 300.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x807731FE), Color(0x00000000)],
                  stops: [0.0, 0.72],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _logoFade,
      child: ScaleTransition(
        scale: _logoScale,
        child: SvgPicture.asset(
          'assets/icons/common/vybe_white_logo.svg',
          width: 148.w,
        ),
      ),
    );
  }

  /// 로고 아래 라임 언더라인 — 가운데에서 좌우로 벌어진다.
  /// 로딩 스피너 대신 두는 이유: 스피너는 '지연'을, 이 선은 '등장'을 읽힌다.
  Widget _buildUnderline() {
    return AnimatedBuilder(
      animation: Listenable.merge([_line, _pulse]),
      builder: (_, __) {
        return Opacity(
          opacity: _line.value * (0.55 + 0.45 * _pulse.value),
          child: Container(
            width: 88.w * _line.value,
            height: 2.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.r),
              gradient: const LinearGradient(
                colors: [
                  Color(0x00B5FF60),
                  VybeColors.mainLime500,
                  Color(0x00B5FF60),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: VybeColors.mainLime500.withValues(alpha: 0.45),
                  blurRadius: 12.r,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
