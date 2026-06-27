import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_screen.dart';

/// 주변 페이지 지도 위에 띄우는 클럽 상세 패널.
///
/// DraggableScrollableSheet + NestedScrollView 조합이 스크롤-리사이즈 연동이
/// 안 되는 문제를 피해, Container 기반 커스텀 드래그 패널로 구현한다.
/// - 핀 탭 시 절반 높이로 슬라이드 인
/// - 상단 핸들(여백) 드래그 → 절반↔full 사이 크기 조정, 충분히 내리면 닫힘
/// - 상세 본문(ClubDetailScreen)은 자체 스크롤로 독립 동작
class NearbyDetailSheet extends StatefulWidget {
  final String clubId;
  // 패널이 완전히 닫힌(슬라이드 아웃) 뒤 호출 — 핀 복원/상태 정리용.
  final VoidCallback? onClosed;

  const NearbyDetailSheet({
    super.key,
    required this.clubId,
    this.onClosed,
  });

  @override
  State<NearbyDetailSheet> createState() => _NearbyDetailSheetState();
}

class _NearbyDetailSheetState extends State<NearbyDetailSheet> {
  static const double _half = 0.5;
  static const double _full = 1.0;
  // 이 비율 아래로 내리면 닫기.
  static const double _dismissBelow = 0.34;
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

  void _onDragUpdate(DragUpdateDetails d) {
    if (_maxH == 0) return;
    setState(() {
      _dragging = true;
      _frac = (_frac - d.delta.dy / _maxH).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    _dragging = false;
    if (_frac < _dismissBelow) {
      _close();
      return;
    }
    // 가까운 스냅 지점(절반/full)으로.
    final target =
        (_full - _frac).abs() < (_frac - _half).abs() ? _full : _half;
    setState(() => _frac = target);
  }

  // 슬라이드 아웃 후 onClosed 호출.
  void _close() {
    setState(() => _frac = 0);
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
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
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
                  child: ClubDetailScreen(
                    clubId: widget.clubId,
                    onClose: _close,
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
