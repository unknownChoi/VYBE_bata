import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

/// 법적 고지 문서 전문 화면.
///
/// 원문은 [LegalDoc] 한 곳에만 있고 이 화면은 그리기만 한다 —
/// 웹 공개본(`legal/*.html`)과 내용이 어긋나지 않게 하기 위해서다.
///
/// Figma node: 2151:7512
class TermsDetailScreen extends StatelessWidget {
  /// 보여줄 문서. 상단바 제목도 여기서 나온다.
  final LegalDoc doc;

  const TermsDetailScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      appBar: AppBar(
        backgroundColor: VybeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: VybeGlassButton(
            onTap: () => Navigator.pop(context),
            size: 34,
            iconSize: 18,
            hitSize: 40,
          ),
        ),
        title: Text(
          doc.title,
          // 17sp Medium — VybeTypography 미정의 (iOS 표준 네비게이션 바 크기) → 하드코딩
          style: TextStyle(
            color: const Color(0xFFEBEDF0),
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      // 법률 문서는 길어서 문단 간격이 좁으면 못 읽는다 — 행간을 1.6 으로 벌린다.
      body: SelectionArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
          child: Text(
            doc.body,
            style: VybeTypography.body4.copyWith(
              color: VybeColors.gray500,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
