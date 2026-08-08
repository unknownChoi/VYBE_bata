import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';

// ============================================================
// 마이페이지 공통 스타일/위젯 (my.html 디자인 기반)
// ============================================================

/// 글래스 카드 배경 (디자인 GLASS 토큰).
BoxDecoration glassDecoration({double radius = 16}) => BoxDecoration(
      color: const Color(0x29787880),
      borderRadius: BorderRadius.circular(radius.r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.36),
          blurRadius: 30.r,
          offset: Offset(0, 10.h),
        ),
      ],
    );

/// 글래스 타일 배경 (디자인 GLASS_TILE 토큰) — 버튼/아이콘 배경용.
BoxDecoration glassTileDecoration({double radius = 11}) => BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(radius.r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    );

/// 글래스 인풋 배경 (디자인 GLASS_INPUT 토큰).
BoxDecoration glassInputDecoration({double radius = 12}) => BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(radius.r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    );

/// 카드 내부 구분 헤어라인 색.
final Color hairColor = Colors.white.withValues(alpha: 0.08);

/// 섹션 캡션 타이틀 (예: "계정").
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const SectionTitle(this.title, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 10.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: VybeColors.gray600,
        ),
      ),
    );
  }
}

/// 프로필 아바타 — 이미지 있으면 네트워크 이미지, 없으면 이니셜 + 퍼플 그라데이션.
class MyAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double size;
  final bool ring;

  const MyAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    this.size = 72,
    this.ring = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = imageUrl.isNotEmpty
        ? ClipOval(
            child: Image.network(
              imageUrl,
              width: size.r,
              height: size.r,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial(),
            ),
          )
        : _initial();

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: ring
            ? [
                BoxShadow(
                  color: VybeColors.mainLime500.withValues(alpha: 0.55),
                  spreadRadius: 2.r,
                ),
                BoxShadow(
                  color: VybeColors.mainPurple500.withValues(alpha: 0.4),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.h),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  Widget _initial() {
    return Container(
      width: size.r,
      height: size.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B52FF), VybeColors.mainPurple500, VybeColors.mainPurple900],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.characters.first : '?',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w800,
          fontSize: (size * 0.42).sp,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

/// push 화면 공통 헤더 (뒤로가기 + 타이틀).
class SubScreenHeader extends StatelessWidget {
  final String title;

  /// 뒤로가기를 앱 공통 리퀴드 글래스 버튼([VybeGlassButton])으로 그릴지.
  ///
  /// 화면별로 글래스 디자인을 순차 적용하는 중이라 기본값은 기존 아이콘.
  /// 적용된 화면: 설정.
  final bool glassBack;

  const SubScreenHeader({
    super.key,
    required this.title,
    this.glassBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 16.w, 8.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: Row(
        children: [
          if (glassBack)
            // hitSize 40 — 기존 아이콘 탭 영역과 같은 폭이라 제목 위치가 안 밀린다.
            VybeGlassButton(
              onTap: () => Navigator.of(context).maybePop(),
              size: 36,
              iconSize: 16,
              hitSize: 40,
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: SizedBox(
                width: 40.w,
                height: 40.h,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20.r,
                  color: Colors.white,
                ),
              ),
            ),
          SizedBox(width: 2.w),
          Text(
            title,
            style: VybeTypography.heading4.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
