import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

/// 클럽 상세(리뉴얼) 로딩 스켈레톤.
///
/// 진입 로딩에 스피너를 쓰면 화면이 통째로 비어 있다가 한 번에 나타나 위치가
/// 튄다. 스켈레톤은 실제 레이아웃과 같은 자리에 같은 크기의 블록을 미리 깔아
/// 데이터가 도착해도 요소가 제자리에 그대로 채워지게 한다.
///
/// 블록 그림은 공용 [VybeSkel](shimmer)을 그대로 쓴다.

// ============================================================================
// 블록 프리미티브
// ============================================================================

/// shimmer 막대. [w] 가 null 이면 가로를 꽉 채운다.
class RenewSkelBar extends StatelessWidget {
  final double? w;
  final double h;
  final double r;

  const RenewSkelBar({super.key, this.w, this.h = 14, this.r = 6});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: w == null ? double.infinity : w!.w,
    height: h.h,
    child: VybeSkel(radius: r),
  );
}

/// 섹션 제목 줄 — 제목 + 오른쪽 '전체보기' 자리.
class RenewSkelHead extends StatelessWidget {
  final bool trailing;

  const RenewSkelHead({super.key, this.trailing = true});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const RenewSkelBar(w: 96, h: 18, r: 6),
      if (trailing) const RenewSkelBar(w: 52, h: 13, r: 6),
    ],
  );
}

/// 글래스 카드 안에 본문 줄만 깔아 둔 스켈레톤.
class RenewSkelCard extends StatelessWidget {
  /// 각 줄의 가로 폭. null 이면 꽉 찬 줄.
  final List<double?> lines;
  final bool quiet;
  final Widget? top;

  const RenewSkelCard({
    super.key,
    required this.lines,
    this.quiet = false,
    this.top,
  });

  @override
  Widget build(BuildContext context) => RenewGlassCard(
    quiet: quiet,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (top != null) ...[top!, SizedBox(height: 14.h)],
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) SizedBox(height: 11.h),
          RenewSkelBar(w: lines[i], h: 14),
        ],
      ],
    ),
  );
}

/// 칩 한 줄 (필터·카테고리 바 자리).
class RenewSkelChips extends StatelessWidget {
  final List<double> widths;

  const RenewSkelChips({super.key, this.widths = const [58, 72, 64, 80]});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < widths.length; i++) ...[
        if (i > 0) SizedBox(width: 8.w),
        RenewSkelBar(w: widths[i], h: 30, r: 999),
      ],
    ],
  );
}

// ============================================================================
// 타이틀 블록 (히어로 아래 아이덴티티)
// ============================================================================

/// [RenewTitleBlock] 자리. 상태 pill · 이름 · 메타 · 평점 · 소개 · 태그 순서를
/// 그대로 따라 둬서 데이터가 들어와도 아래 탭 바가 위아래로 안 흔들린다.
class RenewTitleSkeleton extends StatelessWidget {
  const RenewTitleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        RenewGlass.pagePad.w,
        0,
        RenewGlass.pagePad.w,
        2.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RenewSkelBar(w: 108, h: 26, r: 999),
          SizedBox(height: 12.h),
          const RenewSkelBar(w: 188, h: 26, r: 8),
          SizedBox(height: 12.h),
          const RenewSkelBar(w: 152, h: 14),
          SizedBox(height: 12.h),
          const RenewSkelBar(w: 118, h: 15),
          SizedBox(height: 12.h),
          const RenewSkelBar(h: 14),
          SizedBox(height: 7.h),
          const RenewSkelBar(w: 214, h: 14),
          SizedBox(height: 12.h),
          const RenewSkelChips(widths: [64, 82, 56]),
        ],
      ),
    );
  }
}

// ============================================================================
// 탭별 스켈레톤
// ============================================================================

/// 홈 탭 — 매장 정보 / 라인업 / 테이블 / 메뉴 / 사진 순서.
class RenewHomeSkeleton extends StatelessWidget {
  final EdgeInsets padding;

  const RenewHomeSkeleton({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: RenewGlass.sectionGap.h);
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      children: [
        // 매장 정보
        const RenewSkelCard(lines: [null, 196, 148]),
        gap,
        // 오늘의 라인업
        const RenewSkelHead(),
        SizedBox(height: 14.h),
        const RenewSkelCard(lines: [172, null], quiet: true),
        gap,
        // 테이블 배치도
        const RenewSkelHead(),
        SizedBox(height: 14.h),
        const RenewSkelBar(h: 168, r: 19),
        gap,
        // 메뉴
        const RenewSkelHead(),
        SizedBox(height: 14.h),
        const RenewSkelMenuRow(),
        SizedBox(height: 12.h),
        const RenewSkelMenuRow(),
        SizedBox(height: 12.h),
        const RenewSkelMenuRow(),
        gap,
        // 사진
        const RenewSkelHead(),
        SizedBox(height: 14.h),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              const Expanded(
                child: AspectRatio(aspectRatio: 1, child: VybeSkel(radius: 14)),
              ),
            ],
          ],
        ),
        gap,
        // 주변 클럽
        const RenewSkelHead(),
        SizedBox(height: 14.h),
        SizedBox(
          height: 176.h,
          child: Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) SizedBox(width: 12.w),
                const Expanded(child: VybeSkel(radius: 16)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 메뉴 한 줄 — 썸네일 + 이름·설명 + 가격.
class RenewSkelMenuRow extends StatelessWidget {
  const RenewSkelMenuRow({super.key});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(width: 64.w, height: 64.h, child: const VybeSkel(radius: 14)),
      SizedBox(width: 12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RenewSkelBar(w: 132, h: 15),
            SizedBox(height: 8.h),
            const RenewSkelBar(w: 92, h: 12),
          ],
        ),
      ),
      SizedBox(width: 12.w),
      const RenewSkelBar(w: 58, h: 15),
    ],
  );
}

/// 사진 탭 — 필터 칩 + 2열 매스너리.
class RenewPhotoSkeleton extends StatelessWidget {
  final EdgeInsets padding;

  const RenewPhotoSkeleton({super.key, required this.padding});

  /// 실제 타일과 같은 들쭉날쭉한 높이 (renew_photo_tab 의 높이 표와 같은 결).
  static const List<double> _left = [200, 160, 190];
  static const List<double> _right = [150, 210, 170];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      children: [
        const RenewSkelChips(widths: [56, 74, 68, 62]),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _column(_left)),
            SizedBox(width: 10.w),
            Expanded(child: _column(_right)),
          ],
        ),
      ],
    );
  }

  Widget _column(List<double> heights) => Column(
    children: [
      for (var i = 0; i < heights.length; i++) ...[
        if (i > 0) SizedBox(height: 10.h),
        RenewSkelBar(h: heights[i], r: 16),
      ],
    ],
  );
}

/// 메뉴 탭 — 메뉴판 + 카테고리 칩 + 메뉴 행.
class RenewMenuSkeleton extends StatelessWidget {
  final EdgeInsets padding;

  const RenewMenuSkeleton({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      children: [
        const RenewSkelBar(h: 208, r: 19),
        SizedBox(height: 20.h),
        const RenewSkelChips(),
        SizedBox(height: 18.h),
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) SizedBox(height: 14.h),
          const RenewSkelMenuRow(),
        ],
      ],
    );
  }
}

/// 리뷰 탭 — 평점 요약 + 작성 버튼 + 정렬 칩 + 리뷰 카드.
class RenewReviewSkeleton extends StatelessWidget {
  final EdgeInsets padding;

  const RenewReviewSkeleton({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      children: [
        // 평점 요약 — 큰 숫자 + 분포 바 5줄
        RenewGlassCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const RenewSkelBar(w: 64, h: 34, r: 8),
                  SizedBox(height: 10.h),
                  const RenewSkelBar(w: 80, h: 12),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < 5; i++) ...[
                      if (i > 0) SizedBox(height: 7.h),
                      const RenewSkelBar(h: 8, r: 999),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        const RenewSkelBar(h: 46, r: 14),
        SizedBox(height: 16.h),
        const RenewSkelChips(widths: [62, 62, 62]),
        SizedBox(height: 18.h),
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(height: 14.h),
          const RenewSkelReviewCard(),
        ],
      ],
    );
  }
}

/// 리뷰 카드 한 장 — 아바타 + 이름/별점 + 본문 2줄 + 사진.
class RenewSkelReviewCard extends StatelessWidget {
  const RenewSkelReviewCard({super.key});

  @override
  Widget build(BuildContext context) => RenewGlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 36.w,
              height: 36.h,
              child: const VybeSkel(radius: 999),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RenewSkelBar(w: 88, h: 14),
                SizedBox(height: 7.h),
                const RenewSkelBar(w: 112, h: 12),
              ],
            ),
          ],
        ),
        SizedBox(height: 14.h),
        const RenewSkelBar(h: 14),
        SizedBox(height: 7.h),
        const RenewSkelBar(w: 196, h: 14),
        SizedBox(height: 12.h),
        SizedBox(
          height: 72.h,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: 8.w),
                SizedBox(width: 72.w, child: const VybeSkel(radius: 12)),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// 매장정보 탭 — 지도 카드 + 상세 정보 + 편의시설 그리드.
class RenewInfoSkeleton extends StatelessWidget {
  final EdgeInsets padding;

  const RenewInfoSkeleton({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: RenewGlass.sectionGap.h);
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      children: [
        // 위치
        const RenewSkelHead(trailing: false),
        SizedBox(height: 14.h),
        const RenewSkelBar(h: 172, r: 19),
        SizedBox(height: 12.h),
        const RenewSkelCard(lines: [null, 168]),
        gap,
        // 상세 정보
        const RenewSkelHead(trailing: false),
        SizedBox(height: 14.h),
        const RenewSkelCard(lines: [null, null, 208, 150]),
        gap,
        // 편의시설 3열
        const RenewSkelHead(trailing: false),
        SizedBox(height: 14.h),
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) SizedBox(height: 10.h),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: 10.w),
                const Expanded(child: RenewSkelBar(h: 78, r: 16)),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
