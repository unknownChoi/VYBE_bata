import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 클럽 상세 페이지 섹션 구분선 — 검정 배경 8.h + 상하 보더
class ClubSectionDivider extends StatelessWidget {
  const ClubSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF1F1F23)),
        ),
      ),
    );
  }
}
