import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart'
    show kVybeInk;

/// 인트로(조명 점등 → 로고 등장 → 빛 스침) 전체 길이.
/// [SplashGate.minDuration] 은 이보다 길어야 애니메이션이 중간에 잘리지 않는다.
///
/// 디자인 `splash.jsx` 타임라인:
///   0.25s 조명 점등 · 0.5s 바닥 광원 · 1.05s 로고 · 1.55s 빛 스침
/// (원본의 하단 로딩 라인은 뺐다 — 스플래시가 곧 넘어가는 걸 아는 화면에서
///  '로딩 중' 표시는 대기를 더 길게 읽히게 한다)
/// 원본의 빛 스침은 1.5s 짜리지만 여기선 0.95s 로 줄였다 — 원본은 스플래시가
/// 홈으로 넘어가는 **동안에도** 계속 스치지만, 앱은 게이트 전환 순간 스플래시가
/// 통째로 사라지므로 스침이 잘려 보인다.
const kSplashIntroDuration = Duration(milliseconds: 2500);

/// 앰비언트(조명 스윙·플리커·헤이즈·먼지) 타임라인 길이.
/// 각 요소의 주기가 서로 안 맞아 루프를 짧게 잡으면 감기는 순간이 눈에 띈다.
/// 스플래시는 몇 초만 살아 있으므로 사실상 감기지 않는 길이를 쓴다.
const _kAmbientPeriod = Duration(seconds: 600);

/// [VybeSplash.playIntro] 가 false일 때 시작 시각(초).
///
/// 인트로가 끝난 직후 지점([kSplashIntroDuration] + 0.1s) — 게이트가 바뀌어도
/// 조명·로고가 다시 켜지지 않는다. **넉넉히 뒤로 미루지 않는 이유**: 이 값이
/// 인수인계 시점과 멀수록 조명 스윙 각도가 튄다. [SplashGate] 가 넘겨주는
/// 순간과 맞춰 둬야 교차 페이드 중 두 화면이 거의 겹쳐 보인다.
const _kSettledAt = 2.6;

const Color _kBeamViolet = Color(0xFFC8A8FF);

/// 앱 진입 스플래시 — 디자인 `splash.html` (클럽 조명 기둥) 이식.
///
/// 무대 조명 4기가 위에서 내려와 좌우로 흔들리고, 헤이즈·바닥 광원·먼지가
/// 빛을 머금는다. 그 위로 로고가 blur → 선명하게 떠오르며 빛이 한 번 스친다.
///
/// [SplashGate] 가 앱 시작 시 인트로를 재생하고, 그 뒤로도 버전 게이트 →
/// 인증 게이트가 연달아 로딩 화면을 요구한다. **셋이 같은 화면**이라야
/// 게이트가 바뀌는 순간 화면이 튀지 않아 하나로 공용한다.
///
/// 게이트 로딩 용도로 쓸 때는 [playIntro] 를 false 로 — 인트로가 이미
/// 끝난 상태에서 시작해 조명·로고가 다시 등장하지 않는다.
///
/// 퇴장(디자인 `spStageOut`)은 [exit] 을 넘겨 [SplashGate] 가 몬다 — 조명은
/// 한 번 밝아졌다 커지며 빠지고, 로고만 [logoLanding] 자리로 날아가 사라진다.
class VybeSplash extends StatefulWidget {
  /// 인트로 재생 여부. false면 인트로가 끝난 프레임에서 시작한다.
  final bool playIntro;

  /// 퇴장 진행도(0 = 그대로, 1 = 완전히 빠짐). null이면 퇴장 연출 없음.
  final Animation<double>? exit;

  /// 로고가 착지할 화면 좌표. 넘기면 퇴장 중 로고가 중앙에서 이 자리로
  /// 축소·이동한 뒤 사라져, 뒤에 드러난 홈 상단 바 로고로 이어진다.
  /// null이면 로고도 조명과 함께 그냥 사라진다(착지할 자리가 없는 화면).
  final Rect? logoLanding;

  const VybeSplash({
    super.key,
    this.playIntro = true,
    this.exit,
    this.logoLanding,
  });

  @override
  State<VybeSplash> createState() => _VybeSplashState();
}

class _VybeSplashState extends State<VybeSplash> with TickerProviderStateMixin {
  /// 로고 등장 — 1회 재생.
  late final AnimationController _intro;

  /// 조명 스윙·플리커·헤이즈·먼지 — 끝나지 않는다(대기 중이라는 신호).
  /// 시간(초)을 뽑아 쓰는 시계 역할이라 CSS의 delay/duration 을 그대로 옮길 수 있다.
  late final AnimationController _ambient;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoMotion;

  /// 시작 이후 경과 초. CSS 애니메이션의 delay 계산 기준.
  double get _t =>
      _ambient.value * _kAmbientPeriod.inSeconds +
      (widget.playIntro ? 0.0 : _kSettledAt);

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: kSplashIntroDuration);
    _ambient = AnimationController(vsync: this, duration: _kAmbientPeriod)
      ..repeat();

    // 로고는 인트로 타임라인의 1.05s~2.05s 구간을 쓴다(= 0.42~0.82).
    // 불투명도만 먼저(60% 지점에) 차고, 크기·이동·blur 는 끝까지 이어진다.
    _logoFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.42, 0.66, curve: Curves.easeOut),
    );
    _logoMotion = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.42, 0.82, curve: Cubic(0.2, 0.9, 0.25, 1)),
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
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 디자인 px → 기기 px 배율. 화면 전체를 채우는 페인터가 CSS 수치를
    // 그대로 쓰기 위해 screenutil 배율 하나만 넘긴다.
    final px = 1.w;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      // 퇴장 중에는 아래 화면이 비쳐야 한다 — 잉크 배경은 같이 사라지도록
      // Scaffold가 아니라 무대 레이어 안에 둔다.
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildStage(px, size),
          _buildAfterglow(),
          Center(child: _buildLogo(px, size)),
        ],
      ),
    );
  }

  /// 조명 무대(잉크 배경 + 기둥·헤이즈·광원·먼지).
  ///
  /// 퇴장(디자인 `spStageOut`) — 잠깐 그대로 버텼다가 위쪽을 축으로 커지며
  /// 사라진다. 원본의 `filter: brightness(1.5)` 번쩍임은 옮기지 않았다.
  /// 전체화면 [ColorFiltered] 는 매 프레임 레이어를 뜨는데, 같은 순간 아래에서
  /// 앱 첫 프레임이 그려지느라 가장 바쁘다. 대신 잔광([_buildAfterglow])이
  /// 같은 타이밍에 확 밝아져 번쩍임을 대신한다.
  Widget _buildStage(double px, Size size) {
    final stage = RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: kVybeInk),
          AnimatedBuilder(
            animation: _ambient,
            builder: (_, __) => CustomPaint(
              painter: _StagePainter(t: _t, px: px),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );

    final exit = widget.exit;
    if (exit == null) return stage;

    return AnimatedBuilder(
      animation: exit,
      builder: (_, child) {
        final p = exit.value;
        final opacity = _keyframes(p, const [0, 0.16, 1], const [1, 1, 0]);
        if (opacity <= 0.001) return const SizedBox.shrink();
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 1 + 0.10 * p,
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, -0.03 * p * size.height),
              child: child,
            ),
          ),
        );
      },
      child: stage,
    );
  }

  /// 조명이 빠진 뒤 다음 화면 위에 남는 잔광(디자인 `spGlowOut`).
  ///
  /// 원본은 무대보다 오래(1.5s) 남지만 여기선 퇴장이 끝나면 스플래시가 트리에서
  /// 통째로 빠지므로 같은 길이 안에 접어 넣었다.
  Widget _buildAfterglow() {
    final exit = widget.exit;
    if (exit == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: exit,
      builder: (_, __) {
        final o = _keyframes(exit.value, const [0, 0.14, 1], const [0, 0.6, 0]);
        if (o <= 0.001) return const SizedBox.shrink();
        return IgnorePointer(
          child: CustomPaint(
            painter: _AfterglowPainter(o),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// 로고 — blur 6px · scale .92 · 아래 10px 에서 제자리로 떠오른다.
  /// 퇴장 때는 [VybeSplash.logoLanding] 자리로 축소·이동한 뒤 사라진다.
  Widget _buildLogo(double px, Size size) {
    final width = 238.w;
    final logo = _buildLogoBody(px, width);

    final exit = widget.exit;
    if (exit == null) return logo;

    return AnimatedBuilder(
      animation: exit,
      builder: (_, child) {
        final p = exit.value;
        final landing = widget.logoLanding;

        // 착지할 자리가 없는 화면(로그인·차단)에선 조명과 같이 사라진다.
        if (landing == null) {
          final o = _keyframes(p, const [0, 0.16, 1], const [1, 1, 0]);
          return o <= 0.001
              ? const SizedBox.shrink()
              : Opacity(opacity: o, child: child);
        }

        final e = const Cubic(0.58, 0.02, 0.2, 1).transform(p);
        final delta = landing.center - Offset(size.width / 2, size.height / 2);
        final scale = 1 + (landing.width / width - 1) * e;
        // 다 도착하기 직전부터 지운다 — 뒤에 이미 그려져 있는 상단 바 로고가
        // 그대로 이어받아, 사라지는 순간이 보이지 않는다.
        // 디자인은 .58s(≈0.71)부터 지우지만 그 지점은 아직 6% 남은 자리라
        // 두 로고가 한 글자쯤 어긋난 채 겹친다 — 착지 직전으로 미뤘다.
        final o = 1 - ((p - 0.84) / 0.16).clamp(0.0, 1.0);
        if (o <= 0.001) return const SizedBox.shrink();

        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: delta * e,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: logo,
    );
  }

  Widget _buildLogoBody(double px, double width) {
    return FadeTransition(
      opacity: _logoFade,
      child: AnimatedBuilder(
        animation: Listenable.merge([_logoMotion, _ambient]),
        builder: (_, __) {
          final v = _logoMotion.value;
          final blur = 6 * px * (1 - v);

          Widget logo = Stack(
            alignment: Alignment.center,
            children: [
              // drop-shadow(0 0 26px rgba(119,49,254,.55)) — 알파 모양을 따라가야
              // 하므로 로고를 보라로 물들여 흐린 복사본을 뒤에 깐다.
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: 13 * px,
                  sigmaY: 13 * px,
                ),
                child: SvgPicture.asset(
                  'assets/icons/common/vybe_white_logo.svg',
                  width: width,
                  colorFilter: ColorFilter.mode(
                    VybeColors.mainPurple500.withValues(alpha: 0.55),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/common/vybe_white_logo.svg',
                width: width,
              ),
              _buildShine(width),
            ],
          );

          if (blur > 0.1) {
            logo = ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: logo,
            );
          }

          return Transform.translate(
            offset: Offset(0, 10 * px * (1 - v)),
            child: Transform.scale(
              scale: 0.92 + 0.08 * v,
              alignment: Alignment.center,
              child: logo,
            ),
          );
        },
      ),
    );
  }

  /// 로고 알파에 마스킹된 빛 스침 — 왼쪽 밖에서 오른쪽 밖으로 한 번 지나간다.
  Widget _buildShine(double width) {
    const start = 1.55; // 초
    const duration = 0.95;
    final p = ((_t - start) / duration).clamp(0.0, 1.0);
    if (p <= 0 || p >= 1) return const SizedBox.shrink();
    final e = Curves.easeOut.transform(p);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) {
        // background-size 260% + position-x 160% → -60%.
        // CSS 퍼센트 포지셔닝: offset = (컨테이너 - 이미지) * P → -1.6W * P.
        final gw = rect.width * 2.6;
        final x = rect.width * (-2.56 + 3.52 * e);
        // 105deg — 위쪽 기준 시계방향. 살짝 기운 대각선.
        const dir = Offset(0.966, 0.259);
        return ui.Gradient.linear(
          Offset(x, 0),
          Offset(x + dir.dx * gw, dir.dy * gw),
          const [Color(0x00FFFFFF), Color(0xEBFFFFFF), Color(0x00FFFFFF)],
          const [0.38, 0.50, 0.62],
        );
      },
      child: SvgPicture.asset(
        'assets/icons/common/vybe_white_logo.svg',
        width: width,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 조명 무대
// ---------------------------------------------------------------------------

/// 조명 기둥 하나. 디자인 `BEAMS` 항목 그대로.
class _Beam {
  /// 색.
  final Color hue;

  /// 기둥 중심 x — 화면 너비 대비 %.
  final double x;

  /// 아래쪽 폭(디자인 px).
  final double w;

  /// 스윙 각도(도).
  final double from;
  final double to;

  /// 스윙 편도 시간(초) / 시작 지연(초).
  final double dur;
  final double delay;

  /// 기본 불투명도.
  final double op;

  const _Beam({
    required this.hue,
    required this.x,
    required this.w,
    required this.from,
    required this.to,
    required this.dur,
    required this.delay,
    required this.op,
  });
}

const List<_Beam> _kBeams = [
  _Beam(
    hue: VybeColors.mainPurple500,
    x: 16,
    w: 190,
    from: -18,
    to: 12,
    dur: 6.4,
    delay: 0,
    op: 0.60,
  ),
  _Beam(
    hue: VybeColors.mainLime500,
    x: 38,
    w: 140,
    from: 12,
    to: -14,
    dur: 5.2,
    delay: 0.35,
    op: 0.46,
  ),
  _Beam(
    hue: _kBeamViolet,
    x: 62,
    w: 140,
    from: -12,
    to: 14,
    dur: 7.1,
    delay: 0.35,
    op: 0.46,
  ),
  _Beam(
    hue: VybeColors.mainPurple500,
    x: 84,
    w: 190,
    from: 18,
    to: -12,
    dur: 5.8,
    delay: 0,
    op: 0.60,
  ),
];

// --- 미러볼 ----------------------------------------------------------------

/// 미러볼 중심 y (디자인 px, 화면 위에서). 로고(화면 중앙)와 겹치지 않는 자리.
/// 반지름을 키운 만큼 같이 내려야 매달린 줄이 너무 짧아지지 않는다.
const double _kBallCenterY = 158;

/// 구체 반지름(디자인 px).
const double _kBallRadius = 62;

/// 한 바퀴 도는 데 걸리는 시간(초). 클럽 미러볼은 느리게 돈다 —
/// 빨리 돌리면 반사광 점이 흘러가는 선처럼 보여 '조명'이 아니라 '스크롤'이 된다.
const double _kBallSpin = 16.0;

/// 거울 타일 격자. 위도 9 × 경도 20 = 180칸, 앞면만 그리므로 실제 draw는 ~90칸.
const int _kBallRows = 9;
const int _kBallCols = 20;

/// 타일 사이 이음매 비율(1이면 빈틈 없음).
const double _kBallTileFill = 0.86;

/// 미러볼이 켜지는 시각(초). 조명 기둥(0.25s)과 로고(1.05s) 사이.
const double _kBallAppearAt = 0.4;

/// 낙하 시작 y (디자인 px). 화면 위 밖 — 줄에 매달린 채 떨어져 내려온다.
const double _kBallDropFrom = -80;

/// 낙하 시간(초). 짧게 잡아야 '떨어진다'로 읽힌다 — 길면 그냥 내려오는 연출.
const double _kBallDrop = 0.38;

/// 최하점이 정착 위치([_kBallCenterY])보다 더 내려가는 양(디자인 px).
/// 첫 반동 폭도 이 값이 정한다.
const double _kBallOvershoot = 30;

/// 튕김 진동수(Hz)와 감쇠율. 감쇠율이 높을수록 빨리 멎는다.
/// 1.9Hz · 2.4 → 눈에 띄는 튕김 3~4번 뒤 약 1.5초에 정착.
const double _kBallBounceHz = 1.9;
const double _kBallBounceDecay = 2.4;

/// 스쿼시&스트레치 폭. 낙하 중엔 세로로 늘고, 최하점에서 눌린다.
/// 0이면 강체처럼 보여 '퉁퉁'이 안 읽힌다.
const double _kBallStretch = 0.05;
const double _kBallSquash = 0.12;

/// 미러볼 조명 방향(단위 벡터). 좌·우 조명 기둥 + 위쪽 흰빛 순.
/// 화면 좌표계라 y는 아래가 +, 위에서 비추므로 y가 음수다.
/// 색 조명은 옆으로 크게 벌려 각자 구체의 한쪽 면을 맡는다 — 가운데로 모으면
/// 둘이 겹쳐 상쇄돼 흰 공이 된다.
const List<(double, double, double)> _kBallLights = [
  (-0.74, -0.42, 0.52), // 보라 (왼쪽 기둥)
  (0.74, -0.42, 0.52), // 라임 (오른쪽 기둥)
  (0.0, -0.58, 0.81), // 흰빛 (정면 위) — 하이라이트
];

/// 조명별 감쇠 지수. 낮을수록 넓게 퍼진다(면 조명), 높을수록 점처럼 좁다(거울).
const List<double> _kBallLightExp = [2.2, 2.2, 22];

/// 조명별 세기. 색 조명을 1 이상으로 둬야 채도가 살아난다.
const List<double> _kBallLightGain = [1.35, 1.15, 0.95];

/// 미러볼이 화면에 뿌리는 반사광 점.
/// (시작 x%, y%, 반지름 px, 밝기, 회전 대비 이동 배율, 색 인덱스)
/// 색 인덱스: 0 흰빛 · 1 보라 · 2 라임 · 3 연보라
const List<(double, double, double, double, double, int)> _kSpecks = [
  (0.06, 0.30, 2.6, 0.85, 1.00, 0),
  (0.21, 0.52, 2.0, 0.60, -0.80, 1),
  (0.35, 0.24, 2.3, 0.70, 1.35, 2),
  (0.48, 0.68, 1.8, 0.55, -1.10, 3),
  (0.60, 0.38, 2.8, 0.80, 0.90, 1),
  (0.72, 0.60, 2.1, 0.62, -1.30, 0),
  (0.83, 0.28, 2.4, 0.72, 1.15, 2),
  (0.94, 0.55, 1.9, 0.58, -0.95, 1),
  (0.14, 0.74, 2.2, 0.66, 1.45, 3),
  (0.41, 0.86, 1.7, 0.48, -0.70, 0),
  (0.66, 0.82, 2.0, 0.54, 1.05, 1),
  (0.88, 0.76, 1.6, 0.45, -1.20, 2),
  (0.28, 0.42, 1.5, 0.50, 0.75, 0),
  (0.55, 0.18, 1.7, 0.52, -1.40, 3),
];

/// 먼지 입자 — (x%, y%, 반지름 px, 알파).
const List<(double, double, double, double)> _kDust = [
  (12, 30, 1.6, 0.70),
  (34, 62, 1.4, 0.50),
  (58, 24, 1.8, 0.55),
  (76, 70, 1.3, 0.45),
  (88, 42, 1.5, 0.50),
  (22, 82, 1.2, 0.40),
];

/// 조명 기둥 · 헤이즈 · 바닥 광원 · 먼지를 한 캔버스에 그린다.
///
/// ⚠ CSS `mix-blend-mode: screen` 은 [BlendMode.screen] 으로 그대로 옮겼다.
/// 겹칠수록 밝아져야 조명이 조명처럼 보인다 — srcOver로 바꾸면 탁해진다.
class _StagePainter extends CustomPainter {
  /// 시작 이후 경과 초.
  final double t;

  /// 디자인 px → 기기 px 배율.
  final double px;

  const _StagePainter({required this.t, required this.px});

  /// 상시 레이어(바닥 안개·헤이즈·먼지)가 차오르는 정도.
  ///
  /// 디자인엔 없는 단계다. 이 셋은 원본에서 0초부터 full로 깔려 있는데,
  /// 그러면 **첫 프레임이 단색이 아니라** 네이티브 스플래시(잉크 단색)에서
  /// 넘어오는 순간 바닥 보라빛이 툭 튀어나온다. 앞의 0.45초 동안 차오르게 해
  /// 프레임 0을 네이티브와 같은 평면 `kVybeInk` 로 맞춘다.
  /// (조명 기둥·바닥 광원은 원래 각자 0.25s·0.5s에 켜지므로 손대지 않는다)
  double get _rise => Curves.easeOut.transform((t / 0.45).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;

    _paintFloorFog(canvas, rect);
    for (var i = 0; i < _kBeams.length; i++) {
      _paintBeam(canvas, size, _kBeams[i], i);
    }
    _paintHaze(canvas, size);
    _paintPool(canvas, size);
    // 미러볼은 기둥·헤이즈 위. 반사광 점은 볼보다 먼저 깔아 볼이 점에 덮이지 않게.
    _paintSpecks(canvas, size);
    _paintMirrorBall(canvas, size);
    _paintDust(canvas, size);
  }

  // --- 레이어 -------------------------------------------------------------

  /// 무대 바닥 안개 — radial(120% 60% at 50% 108%, purple .30, transparent 70%).
  void _paintFloorFog(Canvas canvas, Rect rect) {
    final rise = _rise;
    if (rise <= 0.001) return;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = _radial(
          center: Offset(rect.width * 0.5, rect.height * 1.08),
          rx: rect.width * 1.20,
          ry: rect.height * 0.60,
          colors: [
            VybeColors.mainPurple500.withValues(alpha: 0.30 * rise),
            VybeColors.mainPurple500.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.70],
        ),
    );
  }

  /// 조명 기둥 하나 — 원뿔 2겹(넓고 흐린 것 + 좁고 진한 것) + 렌즈 코어.
  void _paintBeam(Canvas canvas, Size size, _Beam b, int i) {
    // spBeamIn — 켜지는 순간 과하게 밝았다가 한 번 죽고 제자리를 찾는다.
    final inDelay = 0.25 + math.min(i, 3 - i) * 0.12;
    final o = _keyframes(
      (t - inDelay) / 0.9,
      const [0.0, 0.22, 0.40, 1.0],
      [0.0, b.op * 1.5, b.op * 0.35, b.op],
    );
    if (o <= 0.001) return;

    // spFlicker — 주기 끝자락에서 한 번 번쩍였다 꺼졌다 돌아온다.
    final flick = _keyframes(
      ((t - (1.0 + i * 0.3)) / (2.7 + i * 0.6)) % 1.0,
      const [0.0, 0.92, 0.94, 0.96, 1.0],
      const [1.0, 1.0, 1.55, 0.7, 1.0],
    );
    final alpha = (o * flick).clamp(0.0, 1.0);

    final w = b.w * px;
    final h = size.height * 1.08;

    canvas.save();
    // transform-origin: top center — 기둥은 렌즈(꼭짓점)를 축으로 흔들린다.
    canvas.translate(size.width * b.x / 100, -30 * px);
    canvas.rotate(_swing(b) * math.pi / 180);

    _paintCone(canvas, w, h, b.hue, 16 * px, 0.75 * alpha);
    _paintCone(canvas, w * 0.52, h, b.hue, 5 * px, 0.85 * alpha);
    _paintLens(canvas, b.hue, alpha);

    canvas.restore();
  }

  /// 원뿔 — 위 10%만 좁고 아래로 갈수록 벌어지는 사다리꼴.
  void _paintCone(
    Canvas canvas,
    double w,
    double h,
    Color hue,
    double sigma,
    double alpha,
  ) {
    final path = Path()
      ..moveTo(-0.05 * w, 0)
      ..lineTo(0.05 * w, 0)
      ..lineTo(w / 2, h)
      ..lineTo(-w / 2, h)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..blendMode = BlendMode.screen
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma)
        // 불투명도는 saveLayer 대신 그라디언트 알파에 곱해 넣는다 — 레이어를
        // 뜨면 화면 크기 버퍼가 기둥 수만큼 생긴다.
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          [
            hue.withValues(alpha: alpha),
            hue.withValues(alpha: alpha),
            hue.withValues(alpha: 0.60 * alpha),
            hue.withValues(alpha: 0.20 * alpha),
            hue.withValues(alpha: 0),
          ],
          const [0.0, 0.12, 0.42, 0.68, 0.90],
        ),
    );
  }

  /// 렌즈 코어 — 흰 점 + 같은 색 헤일로.
  void _paintLens(Canvas canvas, Color hue, double alpha) {
    final c = Offset(0, 1 * px);
    canvas.drawCircle(
      c,
      19 * px,
      Paint()
        ..blendMode = BlendMode.screen
        ..color = hue.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 11 * px),
    );
    canvas.drawCircle(
      c,
      11 * px,
      Paint()
        ..blendMode = BlendMode.screen
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * px),
    );
  }

  /// 헤이즈 — 빛을 머금은 공기. 아주 느리게 흘러 화면이 멎어 보이지 않게 한다.
  void _paintHaze(Canvas canvas, Size size) {
    final rise = _rise;
    if (rise <= 0.001) return;
    final e = Curves.easeInOut.transform(_pingPong(t / 9.0));
    // inset: -20% — 흘러도 가장자리가 비지 않도록 화면보다 크게 잡는다.
    final box = Rect.fromLTRB(
      -0.2 * size.width,
      -0.2 * size.height,
      1.2 * size.width,
      1.2 * size.height,
    );

    canvas.save();
    canvas.translate(
      box.width * (-0.03 + 0.07 * e),
      box.height * (-0.02 + 0.05 * e),
    );
    // scale(1 → 1.08), transform-origin 은 요소 중심.
    final s = 1.0 + 0.08 * e;
    canvas.translate(box.center.dx, box.center.dy);
    canvas.scale(s);
    canvas.translate(-box.center.dx, -box.center.dy);

    void layer(double cx, double cy, double rx, double ry, Color color) {
      canvas.drawRect(
        box,
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = _radial(
            center: Offset(
              box.left + box.width * cx,
              box.top + box.height * cy,
            ),
            rx: box.width * rx,
            ry: box.height * ry,
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 0.70],
          ),
      );
    }

    // opacity: .5 는 각 레이어 알파에 곱해 넣었다.
    layer(0.28, 0.34, 0.48, 0.38, _kBeamViolet.withValues(alpha: 0.095 * rise));
    layer(0.72, 0.34, 0.48, 0.38, _kBeamViolet.withValues(alpha: 0.095 * rise));
    layer(
      0.50,
      0.58,
      0.40,
      0.30,
      VybeColors.mainLime500.withValues(alpha: 0.06 * rise),
    );

    canvas.restore();
  }

  /// 바닥 광원 풀 — 무대 아래에서 올라오는 빛. 천천히 숨 쉰다.
  ///
  /// 원본의 `filter: blur(38px)` 는 옮기지 않았다 — 그라디언트가 이미 반지름
  /// 72%에서 투명으로 빠져 경계가 없고, 여기에 레이어 블러까지 걸면
  /// 화면 크기 버퍼를 매 프레임 뜨게 된다.
  void _paintPool(Canvas canvas, Size size) {
    final appear = ((t - 0.5) / 1.2).clamp(0.0, 1.0);
    if (appear <= 0) return;
    // spPulse — 1.7s 부터 3.4s 주기로 커졌다 작아진다.
    final pulse = t < 1.7
        ? 0.0
        : Curves.easeInOut.transform(_pingPong((t - 1.7) / 1.7));
    final scale = 1.0 + 0.08 * pulse;
    final alpha = appear * (0.9 + 0.1 * pulse);

    final center = Offset(size.width / 2, size.height - 10 * px);
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: 640 * px * scale,
        height: 360 * px * scale,
      ),
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = _radial(
          center: center,
          rx: 260 * px * scale,
          ry: 120 * px * scale,
          colors: [
            VybeColors.mainLime500.withValues(alpha: 0.30 * alpha),
            VybeColors.mainPurple500.withValues(alpha: 0.20 * alpha),
            VybeColors.mainPurple500.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.45, 0.72],
        ),
    );
  }

  // --- 미러볼 -------------------------------------------------------------

  /// 미러볼이 켜진 정도(0~1).
  ///
  /// 낙하가 짧으므로 조명도 그 안에 다 켜져야 한다 — 떨어지는 동안 어두우면
  /// 볼이 아니라 검은 덩어리가 떨어지는 것으로 보인다.
  double get _ballAppear =>
      Curves.easeOut.transform(((t - _kBallAppearAt) / 0.24).clamp(0.0, 1.0));

  /// 미러볼 낙하·튕김 상태 — (중심 y, 가로 배율, 세로 배율).
  ///
  /// 위 밖에서 중력 가속으로 떨어져([_kBallDrop]) 정착 위치보다
  /// [_kBallOvershoot] 만큼 더 내려간 뒤, 감쇠 진동으로 위아래 튕기다 멎는다.
  /// 낙하 끝값과 진동 시작값이 같은 지점([_kBallOvershoot])이라 이어 붙어도
  /// 튀지 않는다.
  ///
  /// 스쿼시&스트레치는 위상 하나(k)에서 같이 뽑는다 — 최하점(k=1)에서 눌리고
  /// 되튄 꼭대기(k=-1)에서 늘어나야 탄성으로 읽힌다. 충돌 순간 늘어남 →
  /// 눌림으로 값이 한 번 꺾이는 건 의도된 것(그게 '부딪힌' 신호다).
  (double, double, double) _ballMotion() {
    final rest = _kBallCenterY * px;
    final over = _kBallOvershoot * px;
    final tau = t - _kBallAppearAt;

    double cy;
    double squash; // + 눌림 / - 늘어남
    if (tau < _kBallDrop) {
      final from = _kBallDropFrom * px;
      // p² — 등가속 낙하. easeIn 곡선을 쓰면 착지 직전 속도가 죽어 안 떨어진다.
      final e = (tau / _kBallDrop).clamp(0.0, 1.0);
      cy = from + (rest + over - from) * e * e;
      squash = -_kBallStretch * e * e;
    } else {
      final s = tau - _kBallDrop;
      final k =
          math.exp(-_kBallBounceDecay * s) *
          math.cos(2 * math.pi * _kBallBounceHz * s);
      cy = rest + over * k;
      squash = _kBallSquash * k;
    }

    // 부피 보존 흉내 — 눌리면 옆으로 퍼진다.
    return (cy, 1 + squash * 0.6, 1 - squash);
  }

  /// 회전량(바퀴 수). 타일 밝기와 반사광 점이 이 값 하나를 공유해야
  /// 점이 볼의 회전에 맞춰 움직이는 것처럼 읽힌다.
  double get _ballTurns => t / _kBallSpin;

  /// 매달린 미러볼 — 줄 + 어두운 구체 + 회전하는 거울 타일 + 헤일로.
  ///
  /// 3D 에셋 대신 구면 좌표를 직접 투영한다. 타일 하나하나가 실제 법선을 갖기
  /// 때문에 조명 기둥과 같은 색으로 반짝이고, 같은 회전값으로 [_paintSpecks]
  /// 의 반사광까지 몰 수 있다(정지 이미지로는 못 하는 부분).
  void _paintMirrorBall(Canvas canvas, Size size) {
    final appear = _ballAppear;
    if (appear <= 0.001) return;

    final r = _kBallRadius * px;
    final cx = size.width / 2;
    final (cy, sx, sy) = _ballMotion();

    // 줄은 스쿼시를 반영한 실제 볼 꼭대기까지 — 안 그러면 눌릴 때 줄이 볼을 파고든다.
    _paintBallCord(canvas, cx, cy, r * sy, appear);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(sx, sy);

    // 헤일로 — 볼 주변에 번지는 빛. 구체보다 먼저 깔아야 뒤로 간다.
    // 타일 조명과 같은 편(보라 왼쪽 · 라임 오른쪽)에 하나씩 둬서, 볼이 실제로
    // 그 색을 되쏘고 있다는 걸 주변 공기에서도 읽히게 한다.
    void halo(double dx, Color hue, double alpha, double spread) {
      canvas.drawCircle(
        Offset(dx * r, -0.1 * r),
        r * spread,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = hue.withValues(alpha: alpha * appear)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 26 * px),
      );
    }

    halo(-0.55, VybeColors.mainPurple500, 0.30, 1.25);
    halo(0.55, VybeColors.mainLime500, 0.20, 1.10);

    // 구체 바탕 — 타일 사이 이음매로 비치는 어두운 몸통.
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = _radial(
          center: Offset(-r * 0.25, -r * 0.25),
          rx: r * 1.5,
          ry: r * 1.5,
          colors: [
            const Color(0xFF2A2140).withValues(alpha: 0.95 * appear),
            const Color(0xFF0B0916).withValues(alpha: 0.95 * appear),
          ],
          stops: const [0.0, 1.0],
        ),
    );

    _paintBallTiles(canvas, r, appear);

    canvas.restore();
  }

  /// 천장에서 내려오는 줄과 고리.
  void _paintBallCord(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double appear,
  ) {
    final top = cy - r;
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, top),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16 * appear)
        ..strokeWidth = 1.6 * px,
    );
    canvas.drawCircle(
      Offset(cx, top + 1 * px),
      3.2 * px,
      Paint()..color = Colors.white.withValues(alpha: 0.28 * appear),
    );
  }

  /// 거울 타일 격자.
  ///
  /// 위도 [_kBallRows] × 경도 [_kBallCols] 로 구면을 잘라 **앞면 타일만** 그린다.
  /// 각 타일은 구면 접선 야코비안을 그대로 canvas 변환으로 써서, 가장자리로
  /// 갈수록 눌리는 원근이 근사가 아니라 정확하게 나온다.
  void _paintBallTiles(Canvas canvas, double r, double appear) {
    const dTheta = math.pi / _kBallRows;
    const dPhi = 2 * math.pi / _kBallCols;
    final spin = _ballTurns * 2 * math.pi;

    final paint = Paint();

    for (var i = 0; i < _kBallRows; i++) {
      final theta = -math.pi / 2 + (i + 0.5) * dTheta;
      final st = math.sin(theta);
      final ct = math.cos(theta);

      for (var j = 0; j < _kBallCols; j++) {
        final phi = j * dPhi + spin;
        final sp = math.sin(phi);
        final cp = math.cos(phi);

        // 뒷면 컬링. 가장자리 한 줄은 남겨야 실루엣이 각지지 않는다.
        if (cp <= 0.06) continue;

        // 화면 좌표계 법선(= 정규화한 위치). y는 아래가 +.
        final nx = ct * sp;
        final ny = st;
        final nz = ct * cp;

        var wp = 0.0, wl = 0.0, ww = 0.0;
        for (var k = 0; k < _kBallLights.length; k++) {
          final (lx, ly, lz) = _kBallLights[k];
          final d = nx * lx + ny * ly + nz * lz;
          if (d <= 0) continue;
          // 색 조명은 지수를 낮게(넓게), 흰 하이라이트는 높게(좁게).
          // 셋 다 좁으면 '거울'은 되지만 볼이 거의 회색으로 보인다 —
          // 보라·라임이 구체 절반씩 물들어야 클럽 미러볼로 읽힌다.
          final v = math.pow(d, _kBallLightExp[k]).toDouble();
          if (k == 0) {
            wp = v * _kBallLightGain[0];
          } else if (k == 1) {
            wl = v * _kBallLightGain[1];
          } else {
            ww = v * _kBallLightGain[2];
          }
        }

        // 타일마다 다른 위상으로 깜빡인다 — 전부 같이 밝아지면 공처럼 보인다.
        final phase = ((i * 7 + j * 13) % 20) / 20.0;
        final tw = 0.55 + 0.45 * math.sin(2 * math.pi * (t / 1.9 + phase));
        ww *= tw;
        // 색 조명도 같이 흔든다(폭은 절반) — 흰 점만 깜빡이면 반짝임이
        // 흑백으로만 보이고 색은 멈춰 있는 배경처럼 죽는다.
        final ctw = 0.75 + 0.25 * tw;
        wp *= ctw;
        wl *= ctw;

        final peak = math.max(wp, math.max(wl, ww)).clamp(0.0, 1.0);
        // 가장자리 타일은 비스듬해 빛을 덜 되쏜다.
        final edge = 0.35 + 0.65 * nz;
        final alpha = (0.16 + 0.84 * peak) * edge * appear;
        if (alpha <= 0.01) continue;

        const purple = VybeColors.mainPurple500;
        const lime = VybeColors.mainLime500;
        // 흰빛을 채널마다 그대로 더하면 색이 씻겨 회색이 된다 —
        // 색 성분이 강한 타일일수록 흰빛 기여를 깎는다.
        final wash = ww * (1 - 0.55 * math.max(wp, wl).clamp(0.0, 1.0));
        final cr = (purple.r * wp + lime.r * wl + wash).clamp(0.0, 1.0);
        final cg = (purple.g * wp + lime.g * wl + wash).clamp(0.0, 1.0);
        final cb = (purple.b * wp + lime.b * wl + wash).clamp(0.0, 1.0);

        // 구면 접선 → 화면. col0 = ∂P/∂φ, col1 = ∂P/∂θ.
        final m = Matrix4(
          r * ct * cp,
          0,
          0,
          0, //
          -r * st * sp,
          r * ct,
          0,
          0, //
          0,
          0,
          1,
          0, //
          0,
          0,
          0,
          1,
        );

        canvas.save();
        canvas.translate(r * nx, r * ny);
        canvas.transform(m.storage);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: dPhi * _kBallTileFill,
            height: dTheta * _kBallTileFill,
          ),
          paint..color = Color.from(alpha: alpha, red: cr, green: cg, blue: cb),
        );
        canvas.restore();
      }
    }
  }

  /// 미러볼이 화면에 뿌리는 반사광 점.
  ///
  /// 볼과 같은 회전값([_ballTurns])으로 흘러가 둘이 한 몸으로 읽힌다.
  /// 점마다 이동 방향·속도가 달라야 한 덩어리로 스크롤되지 않는다.
  void _paintSpecks(Canvas canvas, Size size) {
    // 볼이 착지(첫 충돌)한 뒤에야 반사광이 퍼진다 — 떨어지는 중에 이미 빛이
    // 깔려 있으면 원인(볼)보다 결과(빛)가 먼저 보인다.
    final appear = Curves.easeOut.transform(
      ((t - _kBallAppearAt - _kBallDrop) / 0.7).clamp(0.0, 1.0),
    );
    if (appear <= 0.001) return;

    final turns = _ballTurns;
    // 화면 밖에서 들어오고 나가도록 여유 폭을 준다.
    final span = size.width * 1.24;

    for (final (bx, by, radius, bright, drift, hueIndex) in _kSpecks) {
      var u = (bx + turns * drift) % 1.0;
      if (u < 0) u += 1.0;
      final x = u * span - size.width * 0.12;
      final y =
          size.height * by + math.sin(2 * math.pi * (t / 6.0 + bx)) * 8 * px;

      final tw =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(2 * math.pi * (t / 2.4 + by)));
      // 흰 점은 조금 눌러 둔다 — 색 점과 같은 세기로 두면 화면에 도는 빛이
      // 흰색으로만 기억된다.
      final tone = hueIndex == 0 ? 0.52 : 0.72;
      final alpha = (bright * tw * tone * appear).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final hue = switch (hueIndex) {
        1 => VybeColors.mainPurple500,
        2 => VybeColors.mainLime500,
        3 => _kBeamViolet,
        _ => Colors.white,
      };

      canvas.drawCircle(
        Offset(x, y),
        radius * px * (0.85 + 0.3 * tw),
        Paint()
          ..blendMode = BlendMode.screen
          ..color = hue.withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.2 * px),
      );
    }
  }

  /// 먼지 입자 — 조명 속을 떠다니는 티끌. 12초에 걸쳐 좌상단으로 흐른다.
  void _paintDust(Canvas canvas, Size size) {
    final rise = _rise;
    if (rise <= 0.001) return;
    final p = (t / 12.0) % 1.0;
    final dx = size.width * -0.06 * p;
    final dy = size.height * -0.14 * p;

    for (final (x, y, r, a) in _kDust) {
      canvas.drawCircle(
        Offset(size.width * x / 100 + dx, size.height * y / 100 + dy),
        r * px,
        Paint()
          ..color = Colors.white.withValues(alpha: a * 0.5 * rise)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.8 * px),
      );
    }
  }

  // --- 계산 ---------------------------------------------------------------

  /// spSwing — ease-in-out 왕복(alternate). 편도 [dur] 초.
  double _swing(_Beam b) {
    final elapsed = t - b.delay;
    if (elapsed <= 0) return b.from;
    final e = Curves.easeInOut.transform(_pingPong(elapsed / b.dur));
    return b.from + (b.to - b.from) * e;
  }

  @override
  bool shouldRepaint(_StagePainter old) => old.t != t || old.px != px;
}

/// 조명이 빠진 뒤 화면 위쪽에 남는 잔광 — 디자인 `spGlowOut` 의 두 겹.
class _AfterglowPainter extends CustomPainter {
  final double opacity;

  const _AfterglowPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;

    void layer(double cx, double cy, double rx, double ry, Color color) {
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = _radial(
            center: Offset(size.width * cx, size.height * cy),
            rx: size.width * rx,
            ry: size.height * ry,
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 0.70],
          ),
      );
    }

    layer(
      0.22,
      -0.06,
      0.85,
      0.45,
      VybeColors.mainPurple500.withValues(alpha: 0.50 * opacity),
    );
    layer(
      0.78,
      -0.04,
      0.60,
      0.35,
      VybeColors.mainLime500.withValues(alpha: 0.22 * opacity),
    );
  }

  @override
  bool shouldRepaint(_AfterglowPainter old) => old.opacity != opacity;
}

/// 0 → 1 → 0 을 오가는 삼각파. [v] 는 편도 1 기준의 진행값.
double _pingPong(double v) {
  final cycle = v % 2.0;
  return cycle <= 1.0 ? cycle : 2.0 - cycle;
}

/// CSS keyframes 선형 보간. [p] < 0 이면 첫 값, > 1 이면 마지막 값(= forwards).
double _keyframes(double p, List<double> stops, List<double> values) {
  if (p <= stops.first) return values.first;
  if (p >= stops.last) return values.last;
  for (var i = 1; i < stops.length; i++) {
    if (p > stops[i]) continue;
    final span = stops[i] - stops[i - 1];
    final local = span == 0 ? 1.0 : (p - stops[i - 1]) / span;
    return values[i - 1] + (values[i] - values[i - 1]) * local;
  }
  return values.last;
}

/// CSS 타원 radial-gradient. Skia radial 은 정원뿐이라 가로 반지름 기준 원을
/// 그린 뒤 중심을 붙박아 둔 채 세로로 ry/rx 배 늘린다 (`vybe_aurora` 와 같은 방식).
ui.Shader _radial({
  required Offset center,
  required double rx,
  required double ry,
  required List<Color> colors,
  required List<double> stops,
}) {
  final k = ry / rx;
  final matrix = Matrix4.identity()
    ..setEntry(1, 1, k)
    ..setEntry(1, 3, center.dy * (1 - k));
  return ui.Gradient.radial(
    center,
    rx,
    colors,
    stops,
    TileMode.clamp,
    matrix.storage,
  );
}
