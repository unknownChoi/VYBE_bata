import 'package:flutter/material.dart';
import 'package:vybe/presentation/nearby/nearby_style.dart';
import 'package:vybe/presentation/nearby/widgets/nearby_bottom_sheet.dart';

/// 지도 아래 클럽 리스트 시트.
///
/// 핀 카드가 떠 있는 동안은 아래로 밀어 감춘다 — 디자인은 시트 높이를 0으로
/// 만들지만 `DraggableScrollableSheet` 는 `minChildSize` 아래로 못 내려가므로
/// 슬라이드로 처리한다(시트 상태·스크롤은 그대로 보존된다).
class NearbyListSheet extends StatelessWidget {
  final DraggableScrollableController controller;

  /// LayoutBuilder가 레이아웃 단계에서 Stack을 재빌드할 때 시트가 재생성
  /// (initState 재실행 → 컨트롤러 중복 attach 어설션)되지 않도록 element 고정.
  final Key sheetKey;

  /// 핀 카드가 떠 있어 시트를 감춰야 하는지.
  final bool hidden;

  /// 리스트에서 강조할 클럽 (지도에서 선택된 핀).
  final String? selectedClubId;

  const NearbyListSheet({
    super.key,
    required this.controller,
    required this.sheetKey,
    required this.hidden,
    required this.selectedClubId,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: hidden,
      child: AnimatedSlide(
        offset: Offset(0, hidden ? 1 : 0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: DraggableScrollableSheet(
          key: sheetKey,
          controller: controller,
          initialChildSize: kNearbySheetMin,
          minChildSize: kNearbySheetMin,
          maxChildSize: kNearbySheetMax,
          snap: true,
          snapSizes: const [kNearbySheetMin, kNearbySheetMid, kNearbySheetMax],
          builder: (_, scrollController) => NearbyBottomSheet(
            scrollController: scrollController,
            selectedClubId: selectedClubId,
          ),
        ),
      ),
    );
  }
}
