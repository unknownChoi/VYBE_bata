import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/review_star_rating.dart';
import 'package:vybe/presentation/clubs/widgets/review_write_glass.dart';

// ============================================================
// 리뷰 작성·수정 화면(review_write_screen)의 섹션 카드들.
//
// 전부 상태를 갖지 않고 값 + 콜백만 받는다 — 입력 상태는 화면이 들고 있고
// 여기선 그리기만 한다. 디자인: review_write.jsx
// ============================================================

const int kReviewMaxPhotos = 4;
const int kReviewMaxLength = 500;
const int kReviewMinLength = 5;

/// 별점 라벨 — rating.ceil() 인덱스로 조회.
/// 0.5 단위라 0.5~1.0 → '별로예요', 1.5~2.0 → '아쉬워요' … 로 묶인다.
const _kRatingLabels = ['별을 눌러 평가해주세요', '별로예요', '아쉬워요', '괜찮아요', '좋아요', '최고예요'];

const _kCautions = [
  '실제 방문한 클럽에 대한 후기만 등록할 수 있어요.',
  '허위·비방·욕설이 담긴 리뷰는 사전 고지 없이 삭제될 수 있어요.',
  '광고, 홍보, 외부 링크가 포함된 리뷰는 노출이 제한돼요.',
  '타인의 사진이나 개인정보가 담긴 사진은 첨부하지 말아주세요.',
  '작성한 리뷰는 내 정보 > 내 리뷰에서 언제든 수정·삭제할 수 있어요.',
];

/// 첨부 사진 1장.
///
/// 수정 모드에선 이미 올라간 사진(URL)과 이번에 고른 사진(File)이 한 줄에 섞여
/// 있고 순서·삭제가 같이 다뤄져야 한다 → 두 목록을 따로 두지 않고 한 타입으로 묶는다.
/// 둘 중 하나만 non-null.
class ReviewPhoto {
  final String? url;
  final File? file;

  const ReviewPhoto.remote(String this.url) : file = null;
  const ReviewPhoto.local(File this.file) : url = null;
}

/// 카드 제목 (16sp Bold).
class ReviewCardTitle extends StatelessWidget {
  final String title;

  const ReviewCardTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

/// 어떤 클럽에 남기는 리뷰인지 — 썸네일 + 이름 + 지역·방문일.
class ReviewClubCard extends StatelessWidget {
  final ClubModel? club;

  /// 방문일로 표시할 날짜. 수정 모드에선 원래 리뷰를 쓴 날.
  final DateTime visitedAt;

  const ReviewClubCard({
    super.key,
    required this.club,
    required this.visitedAt,
  });

  @override
  Widget build(BuildContext context) {
    final visited =
        '${visitedAt.year}.${visitedAt.month.toString().padLeft(2, '0')}'
        '.${visitedAt.day.toString().padLeft(2, '0')} 방문';
    final club = this.club;

    return ReviewGlassCard(
      padding: 14,
      radius: 18,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: 46.r,
              height: 46.r,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [VybeColors.mainPurple500, Color(0xFFC04BD0)],
                ),
              ),
              child: (club != null && club.thumbnailUrl.isNotEmpty)
                  ? Image.network(club.thumbnailUrl, fit: BoxFit.cover)
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  club?.name ?? '이 클럽',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  club == null || club.area.isEmpty
                      ? visited
                      : '${club.area} · $visited',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    height: 14 / 12,
                    color: const Color(0x80FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 별점 입력 (0.5 단위 반쪽 별) + 점수 라벨.
class ReviewRatingCard extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const ReviewRatingCard({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = _kRatingLabels[rating.ceil()];

    return ReviewGlassCard(
      padding: 22,
      child: Column(
        children: [
          Text(
            '이 클럽, 어떠셨나요?',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14.sp,
              color: const Color(0x8CFFFFFF),
            ),
          ),
          SizedBox(height: 14.h),
          ReviewHalfStarRating(rating: rating, onChanged: onChanged),
          SizedBox(height: 14.h),
          Text(
            // 0.5 단위라 라벨만으로는 4.0/4.5 구분이 안 돼 숫자를 함께 노출(디자인 변경).
            rating > 0 ? '${rating.toStringAsFixed(1)} · $label' : label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: rating > 0
                  ? VybeColors.mainLime500
                  : const Color(0x59FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

/// 사진 첨부 — 추가 버튼 + 첨부된 사진 타일 가로 목록.
class ReviewPhotoCard extends StatelessWidget {
  final List<ReviewPhoto> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ReviewPhotoCard({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ReviewGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const ReviewCardTitle('사진 첨부'),
              SizedBox(width: 6.w),
              Text(
                '선택 · ${photos.length}/$kReviewMaxPhotos',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  height: 14 / 12,
                  color: const Color(0x66FFFFFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 72.r,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (photos.length < kReviewMaxPhotos) ...[
                  _AddPhotoButton(onTap: onAdd),
                  SizedBox(width: 10.w),
                ],
                for (var i = 0; i < photos.length; i++) ...[
                  _PhotoTile(photo: photos[i], onRemove: () => onRemove(i)),
                  if (i != photos.length - 1) SizedBox(width: 10.w),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: ReviewDashedBorderPainter(radius: 14.r),
        child: Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 19.r,
                color: const Color(0x99FFFFFF),
              ),
              SizedBox(height: 4.h),
              Text(
                '추가',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  height: 12 / 12,
                  color: const Color(0x80FFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final ReviewPhoto photo;
  final VoidCallback onRemove;

  const _PhotoTile({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.r,
      height: 72.r,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: photo.url != null
                  ? Image.network(
                      photo.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0x14FFFFFF)),
                    )
                  : Image.file(photo.file!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 5.r,
            right: 5.r,
            child: GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 19.r,
                height: 19.r,
                decoration: const BoxDecoration(
                  color: Color(0x9E000000),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 12.r,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 후기 본문 입력 + 글자수 카운터.
class ReviewContentCard extends StatelessWidget {
  final TextEditingController controller;

  const ReviewContentCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ReviewGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReviewCardTitle('후기를 들려주세요'),
          SizedBox(height: 12.h),
          Container(
            constraints: BoxConstraints(minHeight: 116.h),
            decoration: BoxDecoration(
              color: const Color(0x0FFFFFFF),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            padding: EdgeInsets.all(14.r),
            child: TextField(
              controller: controller,
              maxLines: null,
              minLines: 4,
              maxLength: kReviewMaxLength,
              cursorColor: VybeColors.mainLime500,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16.sp,
                height: 22 / 16,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '음악, 분위기, 사운드, 서비스는 어땠나요? (최소 $kReviewMinLength자)',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16.sp,
                  height: 22 / 16,
                  color: const Color(0x59FFFFFF),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            // 카운터만 타이핑에 반응하면 된다 — 화면 전체를 setState로 다시
            // 그리면 글래스 카드(BackdropFilter)까지 매 글자마다 다시 그려진다.
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => Text(
                '${value.text.characters.length}/$kReviewMaxLength',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12.sp,
                  height: 14 / 12,
                  color: const Color(0x59FFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 작성 주의사항 목록 (정적 문구).
class ReviewCautions extends StatelessWidget {
  const ReviewCautions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '리뷰 작성 시 주의사항',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              height: 14 / 12,
              fontWeight: FontWeight.w600,
              color: const Color(0x73FFFFFF),
            ),
          ),
          SizedBox(height: 7.h),
          ..._kCautions.map(
            (text) => Padding(
              padding: EdgeInsets.only(bottom: 7.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3.r,
                    height: 3.r,
                    margin: EdgeInsets.only(top: 7.h, right: 6.w),
                    decoration: const BoxDecoration(
                      color: Color(0x47FFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.sp,
                        height: 17 / 12,
                        color: const Color(0x52FFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 하단 고정 등록·수정 버튼 바.
class ReviewSubmitBar extends StatelessWidget {
  final bool enabled;
  final bool submitting;

  /// 활성 상태 문구. 비활성일 땐 안내 문구가 대신 나온다.
  final String label;
  final VoidCallback onTap;

  const ReviewSubmitBar({
    super.key,
    required this.enabled,
    required this.submitting,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          decoration: const BoxDecoration(
            color: kReviewBarFill,
            border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
          ),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 17.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: enabled
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          VybeColors.mainLime500,
                          VybeColors.mainLime700,
                        ],
                      )
                    : null,
                color: enabled ? null : const Color(0x12FFFFFF),
                borderRadius: BorderRadius.circular(16.r),
                border: enabled
                    ? null
                    : Border.all(color: const Color(0x1AFFFFFF)),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: VybeColors.mainLime500.withValues(alpha: 0.22),
                          blurRadius: 30.r,
                          offset: Offset(0, 10.h),
                        ),
                      ]
                    : null,
              ),
              child: submitting
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        color: kReviewInk,
                      ),
                    )
                  : Text(
                      enabled ? label : '별점과 후기를 입력해주세요',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: enabled ? kReviewInk : const Color(0x4DFFFFFF),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
