import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';

// 별점별 라벨 (디자인 club_detail RATING_LABEL).
const _kRatingLabels = ['평점을 선택해주세요', '별로예요', '아쉬워요', '괜찮아요', '좋아요', '최고예요'];

const _kMaxLength = 500;
const _kMinLength = 5;

/// 리뷰 작성 바텀시트.
///
/// 디자인(club_detail.html WriteReviewSheet) 기준 — 별점 → 내용 → 등록하기.
/// 디자인의 추천 태그 칩·사진 추가 버튼은 Firestore reviews 스키마
/// (rating/content/imageUrls)에 저장할 자리가 없어 제외했다.
class WriteReviewSheet extends ConsumerStatefulWidget {
  final String clubId;
  final String clubName;

  const WriteReviewSheet({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  /// 바텀시트로 띄우기. 등록 성공 시 true 반환.
  static Future<bool?> show(
    BuildContext context, {
    required String clubId,
    required String clubName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => WriteReviewSheet(clubId: clubId, clubName: clubName),
    );
  }

  @override
  ConsumerState<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<WriteReviewSheet> {
  final _controller = TextEditingController();
  int _rating = 0;
  bool _submitting = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _rating > 0 &&
      _controller.text.trim().length >= _kMinLength &&
      !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      VybeToast.show(context, message: '로그인 후 리뷰를 작성할 수 있어요');
      return;
    }

    setState(() => _submitting = true);

    final userName = ref.read(currentUserProvider(uid)).value?.name ?? '';
    final now = DateTime.now();
    await ref
        .read(reviewViewModelProvider.notifier)
        .createReview(
          widget.clubId,
          ReviewModel(
            reviewId: '',
            clubId: widget.clubId,
            userId: uid,
            userName: userName,
            rating: _rating.toDouble(),
            content: _controller.text.trim(),
            imageUrls: const [],
            createdAt: now,
            updatedAt: now,
          ),
        );

    if (!mounted) return;

    final state = ref.read(reviewViewModelProvider);
    if (state.hasError) {
      setState(() => _submitting = false);
      VybeToast.show(context, message: '리뷰 등록에 실패했어요');
      return;
    }

    // 등록 완료 화면을 잠깐 보여준 뒤 닫는다.
    setState(() => _done = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: VybeColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: const Border(top: BorderSide(color: VybeColors.gray800)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 28.h),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 그랩 핸들
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: VybeColors.gray800,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
                if (_done) _buildDone() else ..._buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDone() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 40.h, 0, 32.h),
      child: Column(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: const BoxDecoration(
              color: VybeColors.mainLime500,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 30.r,
              color: VybeColors.background,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '리뷰가 등록됐어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '소중한 후기 감사합니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14.sp,
              color: VybeColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildForm() {
    final length = _controller.text.characters.length;

    return [
      Text(
        '${widget.clubName} 어떠셨나요?',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        '솔직한 후기를 남겨주세요',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14.sp,
          color: VybeColors.gray500,
        ),
      ),
      SizedBox(height: 22.h),

      // 별점
      Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final index = i + 1;
                final on = _rating >= index;
                return GestureDetector(
                  onTap: () => setState(() => _rating = index),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: AnimatedScale(
                      scale: on ? 1 : 0.92,
                      duration: const Duration(milliseconds: 150),
                      child: SvgPicture.asset(
                        'assets/icons/common/club_card/star.svg',
                        width: 38.r,
                        height: 38.r,
                        colorFilter: on
                            ? null
                            : const ColorFilter.mode(
                                VybeColors.gray800,
                                BlendMode.srcIn,
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 10.h),
            Text(
              _kRatingLabels[_rating],
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _rating > 0
                    ? VybeColors.mainLime500
                    : VybeColors.gray600,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 22.h),

      // 내용
      TextField(
        controller: _controller,
        maxLines: null,
        minLines: 4,
        maxLength: _kMaxLength,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15.sp,
          color: Colors.white,
          height: 22 / 15,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: '음악, 분위기, 서비스는 어땠나요? (최소 $_kMinLength자)',
          hintStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15.sp,
            color: VybeColors.gray600,
          ),
          filled: true,
          fillColor: VybeColors.gray900,
          contentPadding: EdgeInsets.all(14.r),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: VybeColors.gray800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: VybeColors.gray800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: VybeColors.mainPurple500),
          ),
        ),
      ),
      SizedBox(height: 8.h),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$length/$_kMaxLength',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12.sp,
            color: VybeColors.gray600,
          ),
        ),
      ),
      SizedBox(height: 22.h),

      // 등록
      GestureDetector(
        onTap: _submit,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _canSubmit
                ? VybeColors.mainLime500
                : VybeColors.mainLimeDisabled,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: _submitting
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: VybeColors.background,
                  ),
                )
              : Text(
                  '등록하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _canSubmit
                        ? VybeColors.background
                        : VybeColors.gray600,
                  ),
                ),
        ),
      ),
    ];
  }
}
