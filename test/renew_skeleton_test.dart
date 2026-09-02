import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_skeleton.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 클럽 상세 로딩 스켈레톤이 오버플로 없이 그려지는지.
/// 가로를 꽉 채우는 막대가 많아 Row/Column 제약을 잘못 주면 바로 터진다.
Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
);

void main() {
  testWidgets('탭별 스켈레톤이 오버플로 없이 그려진다', (tester) async {
    const pad = EdgeInsets.all(24);
    for (final skeleton in <Widget>[
      const RenewTitleSkeleton(),
      const RenewHomeSkeleton(padding: pad),
      const RenewPhotoSkeleton(padding: pad),
      const RenewMenuSkeleton(padding: pad),
      const RenewReviewSkeleton(padding: pad),
      const RenewInfoSkeleton(padding: pad),
    ]) {
      await tester.pumpWidget(_host(skeleton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VybeSkel), findsWidgets);
    }
  });
}
