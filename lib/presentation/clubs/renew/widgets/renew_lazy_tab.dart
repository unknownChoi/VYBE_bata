import 'package:flutter/material.dart';

/// 탭을 실제로 열었을 때만 만들고, 한 번 만든 뒤에는 살려 둔다.
///
/// 상세는 탭마다 Firestore 조회가 따로 붙어 있어, 진입하자마자 5개를 다 만들면
/// 안 보는 탭까지 읽는다. 반대로 매번 새로 만들면 스크롤 위치·필터가 날아간다.
class RenewLazyTab extends StatefulWidget {
  final bool selected;
  final Widget Function() builder;

  const RenewLazyTab({
    super.key,
    required this.selected,
    required this.builder,
  });

  @override
  State<RenewLazyTab> createState() => _RenewLazyTabState();
}

class _RenewLazyTabState extends State<RenewLazyTab>
    with AutomaticKeepAliveClientMixin {
  Widget? _cached;

  @override
  bool get wantKeepAlive => _cached != null;

  @override
  void didUpdateWidget(RenewLazyTab old) {
    super.didUpdateWidget(old);
    if (widget.selected && _cached == null) {
      setState(() {
        _cached = widget.builder();
        updateKeepAlive();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _cached ?? const SizedBox.shrink();
  }
}
