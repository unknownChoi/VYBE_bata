import 'package:flutter/material.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';

/// 전체 화면 반투명 로딩 오버레이
///
/// [isLoading]이 true일 때 [child] 위에 검은 반투명 레이어 + [VybeSpinner]를 표시한다.
/// [ModalBarrier]로 로딩 중 사용자 입력을 차단한다.
class VybeLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const VybeLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          const ModalBarrier(dismissible: false, color: Colors.transparent),
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(child: VybeSpinner()),
          ),
        ],
      ],
    );
  }
}
