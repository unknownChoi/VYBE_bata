import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';

/// 앱 진입 게이트가 판정을 기다리는 동안 보여주는 스플래시.
///
/// 버전 게이트 → 인증 게이트가 연달아 뜨므로 **둘이 같은 화면**이라야
/// 게이트가 바뀌는 순간 화면이 튀지 않는다. 그래서 각자 두지 않고 공용.
class VybeSplash extends StatelessWidget {
  const VybeSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Center(child: VybeSpinner(size: 36.r)),
    );
  }
}
