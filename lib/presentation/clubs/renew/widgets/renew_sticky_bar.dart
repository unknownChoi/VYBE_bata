import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';

/// 스크롤 안의 바가 탭 콘텐츠 위로 올라가면 같은 바를 맨 위에 고정한다
/// (CSS `position: sticky; top: 0` 대응).
///
/// pinned [SliverPersistentHeader]를 쓰지 않는 이유 — Flutter 3.41에서
/// 세만틱스 검증(`debugCheckForParentData`)이 매 프레임 assert를 던져 화면이
/// 통째로 안 그려진 전례가 있다(CLAUDE.md 클럽 상세 항목 참고).
///
/// 동작 — 스크롤 안의 원본 바 위치를 **프레임이 끝난 뒤** 재서 "스크롤 0 기준
/// 오프셋"을 기억해 두고, 스크롤 알림에서는 그 값과 현재 오프셋만 비교한다.
/// (스크롤 알림은 뷰포트 재배치 **전에** 오는 탓에, 그 시점에 위치를 재면
///  한 프레임 이전 값이 나와 영영 고정되지 않는다.)
/// 고정된 순간 원본은 이미 화면 밖이라 두 개가 겹쳐 보이지 않는다.
class RenewStickyBarHost extends StatefulWidget {
  /// 스크롤 뷰를 만든다. 넘겨받은 key를 스크롤 안의 바 위젯에 달아야
  /// 위치를 잴 수 있다.
  final Widget Function(GlobalKey barKey) scrollBuilder;

  /// 고정될 때 위에 그릴 바 (스크롤 안의 것과 같은 모양).
  final Widget bar;

  /// 고정된 바 뒤에 **화면 오로라 배경 조각**을 깐다.
  ///
  /// 반투명 유리 띠 대신 앱 배경 그대로를 불투명하게 깔아, 뒤로 지나가는
  /// 콘텐츠가 비치지 않게 한다(상단바처럼). 조각은 화면 전체 오로라를 그린 뒤
  /// 이 바 위치만큼 밀어 잘라내므로 배경과 색이 정확히 이어진다.
  final bool auroraBackdrop;

  const RenewStickyBarHost({
    super.key,
    required this.scrollBuilder,
    required this.bar,
    this.auroraBackdrop = false,
  });

  @override
  State<RenewStickyBarHost> createState() => _RenewStickyBarHostState();
}

class _RenewStickyBarHostState extends State<RenewStickyBarHost> {
  final GlobalKey _hostKey = GlobalKey();
  final GlobalKey _barKey = GlobalKey();

  /// 스크롤 0 기준 바의 y. 아직 못 쟀으면 null(= 고정 안 함).
  double? _barOffset;

  /// 화면 좌상단 기준 host의 위치 — 오로라 조각을 화면 배경과 맞추는 데 쓴다.
  Offset _hostOrigin = Offset.zero;
  double _pixels = 0;
  bool _sticky = false;

  @override
  void initState() {
    super.initState();
    _scheduleMeasure();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  /// 고정 전에만 잰다 — 위쪽 콘텐츠(이미지 등) 높이가 바뀌면 값도 따라 바뀐다.
  void _measure() {
    if (!mounted || _sticky) return;
    final barBox = _barKey.currentContext?.findRenderObject() as RenderBox?;
    final hostBox = _hostKey.currentContext?.findRenderObject() as RenderBox?;
    if (barBox == null || hostBox == null) return;
    if (!barBox.hasSize || !hostBox.hasSize) return;

    _barOffset =
        barBox.localToGlobal(Offset.zero, ancestor: hostBox).dy + _pixels;
    _hostOrigin = hostBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      // depth 0 = 이 탭의 세로 스크롤. 안쪽 가로 rail 알림은 무시한다.
      onNotification: (n) {
        if (n.depth != 0) return false;
        _pixels = n.metrics.pixels;

        final offset = _barOffset;
        final next = offset != null && _pixels >= offset;
        if (next != _sticky) setState(() => _sticky = next);
        if (!next) _scheduleMeasure();
        return false;
      },
      child: Stack(
        key: _hostKey,
        children: [
          widget.scrollBuilder(_barKey),
          if (_sticky)
            Positioned(top: 0, left: 0, right: 0, child: _stickyBar(context)),
        ],
      ),
    );
  }

  /// 고정된 바 — [RenewStickyBarHost.auroraBackdrop]이면 화면 배경 조각을 깔아
  /// 불투명하게 만든다.
  Widget _stickyBar(BuildContext context) {
    if (!widget.auroraBackdrop) return widget.bar;
    final screen = MediaQuery.sizeOf(context);
    return ClipRect(
      child: Stack(
        children: [
          // 화면 전체 오로라를 그린 뒤 바 위치만큼 밀어 이 띠 구간만 남긴다.
          Positioned(
            left: -_hostOrigin.dx,
            top: -_hostOrigin.dy,
            width: screen.width,
            height: screen.height,
            child: const VybeAurora(),
          ),
          widget.bar,
        ],
      ),
    );
  }
}
