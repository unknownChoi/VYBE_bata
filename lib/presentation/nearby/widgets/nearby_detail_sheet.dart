import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';

/// 주변 페이지 지도 위에 띄우는 클럽 상세 패널.
///
/// Container 기반 커스텀 드래그 패널 + 콘텐츠 스크롤 연동:
/// - 핀 탭 시 절반 높이로 슬라이드 인
/// - 상단 핸들 드래그 → 절반↔full, 충분히 내리면 닫힘
/// - 시트가 full이 아닐 때 본문을 아래로 스크롤하면 시트가 맨 위(full)로 올라옴
/// - 시트가 full일 때 본문 최상단에서 더 위로 당기면 시트가 절반으로 내려감
/// - 시트가 올라오면 하단 nav 바가 축소됨
class NearbyDetailSheet extends ConsumerStatefulWidget {
  final String clubId;
  // 패널이 완전히 닫힌(슬라이드 아웃) 뒤 호출 — 핀 복원/상태 정리용.
  final VoidCallback? onClosed;

  const NearbyDetailSheet({
    super.key,
    required this.clubId,
    this.onClosed,
  });

  @override
  ConsumerState<NearbyDetailSheet> createState() => _NearbyDetailSheetState();
}

class _NearbyDetailSheetState extends ConsumerState<NearbyDetailSheet> {
  static const double _half = 0.5;
  static const double _full = 1.0;
  // 이 비율 아래로 내리면 닫기.
  static const double _dismissBelow = 0.34;
  static const double _eps = 0.01;
  static const Duration _snapDur = Duration(milliseconds: 240);

  // 화면 높이 대비 패널 높이 비율.
  double _frac = 0;
  bool _dragging = false;
  double _maxH = 0;

  @override
  void initState() {
    super.initState();
    // 슬라이드 인 (0 → 절반).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _frac = _half);
    });
  }

  // 시트 올라오면 nav 축소, 절반 이하면 원래대로.
  void _syncNav() {
    final n = ref.read(navBarVisibilityProvider.notifier);
    if (_frac > _half + _eps) {
      n.collapse();
    } else {
      n.expand();
    }
  }

  void _setFrac(double f) {
    if ((f - _frac).abs() < 0.0001) return;
    setState(() => _frac = f);
    _syncNav();
  }

  void _onHandleDragUpdate(DragUpdateDetails d) {
    if (_maxH == 0) return;
    _dragging = true;
    _setFrac((_frac - d.delta.dy / _maxH).clamp(0.0, 1.0));
  }

  void _onHandleDragEnd(DragEndDetails d) {
    _dragging = false;
    if (_frac < _dismissBelow) {
      _close();
      return;
    }
    _setFrac((_full - _frac).abs() < (_frac - _half).abs() ? _full : _half);
  }

  // 본문 스크롤 → 시트 크기 연동.
  bool _onScroll(ScrollNotification n) {
    // 시트가 full이 아닐 때 아래로 스크롤(콘텐츠가 위로) → 시트 full로.
    if (_frac < _full - _eps &&
        n is ScrollUpdateNotification &&
        (n.scrollDelta ?? 0) > 0) {
      _setFrac(_full);
      return false;
    }
    // 시트 full + 최상단에서 더 위로 당김(overscroll top) → 절반으로 내림.
    if (_frac >= _full - _eps &&
        n is OverscrollNotification &&
        n.overscroll < 0) {
      _setFrac(_half);
      return false;
    }
    return false;
  }

  // 슬라이드 아웃 후 onClosed 호출.
  void _close() {
    _setFrac(0);
    Future.delayed(_snapDur, () {
      if (mounted) widget.onClosed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxH = constraints.maxHeight;
        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: _dragging ? Duration.zero : _snapDur,
            curve: Curves.easeOut,
            height: _maxH * _frac,
            decoration: BoxDecoration(
              color: VybeColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // 상단 핸들 영역(여백) — 잡고 드래그로 크기 조정/닫기.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: _onHandleDragUpdate,
                  onVerticalDragEnd: _onHandleDragEnd,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: VybeColors.gray700,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: ClubDetailScreen(
                      clubId: widget.clubId,
                      onClose: _close,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
