import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

/// '내 리뷰' 목록의 리뷰 카드 1장 (디자인 MRReviewCard).
///
/// `[클럽명 / 별점 · 지역 · 작성일]  [수정][삭제]` → 본문(2줄 + 더보기)
/// → 첨부 사진 → 하단 메타 줄.
///
/// 디자인의 '좋아요 수'는 reviews 스키마에 없어 하단 줄을 태그 + 공개 표기로
/// 대체했다. 태그 입력 UI가 아직 없어 대부분 비어 있고, 그때는 '공개'만 남는다.
class MyReviewCard extends StatelessWidget {
  final MyReviewEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyReviewCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final review = entry.review;

    return RenewGlassCard(
      radius: 20,
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: 12.h),
          _ReviewText(text: review.content),
          if (review.imageUrls.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _PhotoStrip(imageUrls: review.imageUrls),
          ],
          _footer(),
        ],
      ),
    );
  }

  /// 클럽명 + `별점 · 지역 · 작성일` / 오른쪽 수정·삭제 버튼.
  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.clubName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.button1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: RenewGlass.t1,
                ),
              ),
              SizedBox(height: 6.h),
              _metaRow(),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        _RoundIconButton(icon: RenewIcons.pencil, onTap: onEdit),
        SizedBox(width: 6.w),
        _RoundIconButton(
          icon: RenewIcons.trash,
          onTap: onDelete,
          danger: true,
        ),
      ],
    );
  }

  /// 별 5개 + 숫자 · 지역 · 작성일. 좁아지면 지역부터 줄인다
  /// (작성일은 잘리면 뜻이 사라진다).
  Widget _metaRow() {
    return Row(
      children: [
        RenewStarRow(rating: entry.review.rating, size: 12),
        SizedBox(width: 6.w),
        Text(
          entry.review.rating.toStringAsFixed(1),
          style: RenewGlass.caption(
            color: RenewGlass.t1,
            lineHeight: 13,
            weight: FontWeight.w700,
          ),
        ),
        if (entry.clubArea.isNotEmpty) ...[
          _dot(),
          Flexible(
            child: Text(
              entry.clubArea,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RenewGlass.caption(lineHeight: 14),
            ),
          ),
        ],
        _dot(),
        Text(entry.dateLabel, style: RenewGlass.caption(lineHeight: 14)),
      ],
    );
  }

  Widget _dot() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 6.w),
    child: const RenewDot(),
  );

  /// 하단 메타 줄 — 태그(최대 3개) + 공개 여부.
  Widget _footer() {
    final tags = entry.review.tags.take(3).toList();

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.only(top: 12.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RenewGlass.hair)),
      ),
      child: Row(
        children: [
          for (final tag in tags) ...[
            Flexible(
              child: Text(
                '#$tag',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RenewGlass.caption(
                  color: RenewGlass.t3,
                  lineHeight: 14,
                ),
              ),
            ),
            _dot(),
          ],
          Text(
            '공개',
            style: RenewGlass.caption(
              color: RenewGlass.lavender,
              lineHeight: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 본문 (2줄 접기 + 더보기)
// ============================================================

/// 기본 2줄로 접고, 실제로 넘칠 때만 더보기/접기를 보여준다.
///
/// 디자인은 글자 수(62자)로 판단하지만 그러면 한글·영문·기기 폭에 따라
/// 안 넘치는데 버튼이 뜨거나 그 반대가 된다 — [TextPainter]로 직접 잰다.
class _ReviewText extends StatefulWidget {
  final String text;

  const _ReviewText({required this.text});

  @override
  State<_ReviewText> createState() => _ReviewTextState();
}

class _ReviewTextState extends State<_ReviewText> {
  static const int _collapsedLines = 2;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = RenewGlass.body(color: RenewGlass.t2, lineHeight: 21);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _collapsedLines,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : _collapsedLines,
              overflow: _expanded
                  ? TextOverflow.clip
                  : TextOverflow.ellipsis,
              style: style,
            ),
            if (overflows)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    _expanded ? '접기' : '더보기',
                    style: RenewGlass.caption(
                      color: RenewGlass.lavender,
                      lineHeight: 14,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ============================================================
// 첨부 사진
// ============================================================

/// 첨부 사진 한 줄 (최대 4장). 한 줄에 다 못 들어가면 정사각을 줄여 맞춘다 —
/// 가로 스크롤을 두면 3px 넘칠 때마다 스크롤 바가 생겨 지저분하다.
class _PhotoStrip extends StatelessWidget {
  final List<String> imageUrls;

  const _PhotoStrip({required this.imageUrls});

  static const double _maxSide = 72;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = _gap.w;
        final side = math.min(
          _maxSide.r,
          (constraints.maxWidth - gap * 3) / 4,
        );

        return Row(
          children: [
            for (var i = 0; i < imageUrls.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              _Photo(url: imageUrls[i], side: side),
            ],
          ],
        );
      },
    );
  }
}

class _Photo extends StatelessWidget {
  final String url;
  final double side;

  const _Photo({required this.url, required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RenewGlass.tileFill,
        borderRadius: BorderRadius.circular(12.r),
      ),
      // 테두리는 자식(사진) 위에 — decoration 에 두면 코너 호에서 선이 덮인다.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: RenewGlass.quietBorder),
      ),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

// ============================================================
// 수정 · 삭제 버튼
// ============================================================

/// 32 원형 아이콘 버튼. [danger]는 붉은 톤(삭제).
class _RoundIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final bool danger;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32.r,
        height: 32.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: danger
              ? kMyDanger.withValues(alpha: 0.10)
              : RenewGlass.tileFill,
          border: Border.all(
            color: danger
                ? kMyDanger.withValues(alpha: 0.26)
                : RenewGlass.tileBorder,
          ),
        ),
        child: RenewIcon(
          path: icon,
          size: 14,
          color: danger ? kMyDanger : RenewGlass.t2,
          strokeWidth: 1.9,
        ),
      ),
    );
  }
}
