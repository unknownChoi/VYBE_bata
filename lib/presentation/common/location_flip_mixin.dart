import 'package:flutter/material.dart';

/// 위치 칩이 원형으로 줄어드는 전환 시간. 이 애니메이션이 끝난 뒤 핀이 돈다.
///
/// 칩을 그리는 위젯(`VybeLocationSortBar`, 홈 인사말)과 시퀀스를 돌리는
/// [LocationFlipMixin]이 같은 값을 써야 해서 여기 한 곳에 둔다.
const kLocationChipShrinkDuration = Duration(milliseconds: 320);

/// 「내 위치」 칩 탭 → 칩 원형 축소 → 핀 3D 플립 → 위치 확정 시퀀스.
///
/// 홈 인사말·입장비 무료·서비스 음료가 같은 연출을 쓴다.
/// 화면은 [flip]을 `VybeLocationSortBar`/`VybePinFlip`에 넘기고
/// [locLoading]으로 칩 축소 여부만 그린다.
///
/// 사용:
/// ```dart
/// class _FooState extends ConsumerState<Foo>
///     with SingleTickerProviderStateMixin, LocationFlipMixin {
///   void _onTap() => runLocationFlip(onResolved: () => _loc = '홍대');
/// }
/// ```
mixin LocationFlipMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  /// 핀 한 바퀴(360도) 회전 시간.
  static const flipSpinDuration = Duration(milliseconds: 700);

  /// 위치 검색 로딩 지속 시간 — 핀 플립 노출 구간.
  static const searchDuration = Duration(milliseconds: 1600);

  /// 핀 플립 애니메이션. 화면이 위젯에 그대로 넘긴다.
  late final AnimationController flip = AnimationController(
    vsync: this,
    duration: flipSpinDuration,
  );

  /// 위치 인식 중이면 true — 칩이 원형으로 축소된다.
  bool locLoading = false;

  @override
  void dispose() {
    flip.dispose();
    super.dispose();
  }

  /// 위치 인식 시퀀스 1회 실행. 진행 중이면 무시한다.
  ///
  /// [onResolved]는 마지막 `setState` 안에서 호출되므로
  /// 위치 라벨 같은 상태를 그 안에서 대입하면 된다.
  Future<void> runLocationFlip({
    required VoidCallback onResolved,
    Duration shrinkDuration = kLocationChipShrinkDuration,
  }) async {
    if (locLoading) return;
    setState(() => locLoading = true);

    // 칩이 원형으로 줄어드는 애니메이션 완료 후 핀 플립 시작.
    await Future.delayed(shrinkDuration);
    if (!mounted) return;
    flip.repeat();

    await Future.delayed(searchDuration);
    if (!mounted) return;

    flip.stop();
    flip.reset();
    setState(() {
      locLoading = false;
      onResolved();
    });
  }
}
