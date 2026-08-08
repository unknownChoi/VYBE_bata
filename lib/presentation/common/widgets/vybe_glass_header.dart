import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

/// 컨텐츠 위에 겹쳐 띄우는 투명 상단바 (뒤로가기 · 공유).
///
/// 배경을 칠하지 않아 뒤 백드롭이 그대로 비치고, 스크롤해도 등장/퇴장하지 않는다.
/// 전용 페이지(입장비 무료 · 서비스 음료 · 핫플레이스 · VYBE 추천)에서 공통 사용.
class VybeGlassHeader extends StatelessWidget {
  /// 뒤로가기 동작. 기본값은 현재 라우트 pop.
  final VoidCallback? onBack;

  /// 공유 동작. 기본값은 no-op (공유 기능 미구현).
  final VoidCallback? onShare;

  const VybeGlassHeader({super.key, this.onBack, this.onShare});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: top + 52.h,
      padding: EdgeInsets.only(top: top, left: 16.w, right: 16.w),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VybeGlassButton(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          VybeGlassButton(
            icon: Icons.share_outlined,
            onTap: onShare ?? () {},
          ),
        ],
      ),
    );
  }
}
