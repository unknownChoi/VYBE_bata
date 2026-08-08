import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/review_star_rating.dart';
import 'package:vybe/presentation/clubs/widgets/review_write_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';

// 디자인: review_write.jsx (WRITE REVIEW — LIQUID GLASS)

/// 별점 라벨 — rating.ceil() 인덱스로 조회.
/// 0.5 단위라 0.5~1.0 → '별로예요', 1.5~2.0 → '아쉬워요' … 로 묶인다.
const _kRatingLabels = ['별을 눌러 평가해주세요', '별로예요', '아쉬워요', '괜찮아요', '좋아요', '최고예요'];

const _kCautions = [
  '실제 방문한 클럽에 대한 후기만 등록할 수 있어요.',
  '허위·비방·욕설이 담긴 리뷰는 사전 고지 없이 삭제될 수 있어요.',
  '광고, 홍보, 외부 링크가 포함된 리뷰는 노출이 제한돼요.',
  '타인의 사진이나 개인정보가 담긴 사진은 첨부하지 말아주세요.',
  '작성한 리뷰는 내 정보 > 내 리뷰에서 언제든 삭제할 수 있어요.',
];

const _kMaxPhotos = 4;
const _kMaxLength = 500;
const _kMinLength = 5;

/// 리뷰 작성 페이지.
///
/// 별점은 0.5~5.0을 0.5 단위로 입력한다(디자인은 1점 단위 5개 별 → 반쪽 채움으로 확장).
/// 사진은 최대 4장까지 첨부하고, 등록 시
/// `reviews/{clubId}/{reviewId}/` 에 업로드한 뒤 URL을 리뷰 문서에 담는다.
class ReviewWriteScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ReviewWriteScreen({super.key, required this.clubId});

  /// 리뷰 작성 페이지로 이동. 등록 성공 시 true 반환.
  ///
  /// MainScaffold의 floating 바텀 nav는 탭 Navigator 위(Stack)에 떠 있어
  /// 이 페이지의 등록 버튼과 겹친다 → 열려 있는 동안 화면 밖으로 내린다.
  /// (내리는/올리는 시점은 [pushHidingNavBar] 참고)
  static Future<bool?> push(
    BuildContext context,
    WidgetRef ref, {
    required String clubId,
  }) {
    return pushHidingNavBar<bool>(
      context,
      ref,
      ReviewWriteScreen(clubId: clubId),
    );
  }

  @override
  ConsumerState<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends ConsumerState<ReviewWriteScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();

  double _rating = 0;
  final List<File> _photos = [];
  bool _submitting = false;

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
      _controller.text.trim().characters.length >= _kMinLength &&
      !_submitting;

  Future<void> _pickPhotos() async {
    final remain = _kMaxPhotos - _photos.length;
    if (remain <= 0) return;

    try {
      final List<XFile> picked;
      if (remain == 1) {
        // pickMultiImage의 limit은 2 미만이면 ArgumentError → 한 장 남았을 땐 단일 선택.
        final one = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1440,
        );
        picked = one == null ? const [] : [one];
      } else {
        picked = await _picker.pickMultiImage(
          limit: remain,
          imageQuality: 85,
          maxWidth: 1440,
        );
      }
      if (picked.isEmpty || !mounted) return;

      setState(() {
        _photos.addAll(picked.take(remain).map((x) => File(x.path)));
      });
    } catch (e) {
      // 권한 거부·플러그인 미등록(MissingPluginException) 등은 조용히 삼키면
      // "버튼을 눌러도 아무 일도 안 남"으로 보여서 반드시 토스트로 알린다.
      if (!mounted) return;
      VybeToast.show(context, message: '사진을 불러올 수 없어요');
      debugPrint('[ReviewWrite] pickPhotos failed: $e');
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      VybeToast.show(context, message: '로그인 후 리뷰를 작성할 수 있어요');
      return;
    }

    setState(() => _submitting = true);

    // 작성자 이름은 ViewModel이 users/{uid}에서 직접 채운다 (submitReview 주석 참고).
    final ok = await ref
        .read(reviewViewModelProvider.notifier)
        .submitReview(
          clubId: widget.clubId,
          userId: uid,
          rating: _rating,
          content: _controller.text.trim(),
          tags: const [],
          images: List<File>.from(_photos),
        );

    if (!mounted) return;

    // provider state 대신 반환값으로 분기 — autoDispose로 인스턴스가 갈릴 수 있음.
    if (!ok) {
      setState(() => _submitting = false);
      VybeToast.show(context, message: '리뷰 등록에 실패했어요');
      return;
    }

    // 등록 성공 → 바로 이전 페이지(클럽 상세 리뷰 탭)로 복귀.
    // 완료 안내는 돌아간 화면에서 토스트로 띄운다.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;

    return Scaffold(
      backgroundColor: kReviewInk,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: ReviewAurora()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody(club)),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: const BoxDecoration(
            color: kReviewBarFill,
            border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: kReviewTileFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: kReviewTileBorder),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15.r,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '리뷰 작성',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 34.r),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody(ClubModel? club) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
      children: [
        _buildClubCard(club),
        SizedBox(height: 14.h),
        _buildRatingCard(),
        SizedBox(height: 14.h),
        _buildPhotoCard(),
        SizedBox(height: 14.h),
        _buildContentCard(),
        SizedBox(height: 16.h),
        _buildCautions(),
      ],
    );
  }

  Widget _buildClubCard(ClubModel? club) {
    final now = DateTime.now();
    final visited =
        '${now.year}.${now.month.toString().padLeft(2, '0')}'
        '.${now.day.toString().padLeft(2, '0')} 방문';

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

  Widget _buildRatingCard() {
    final label = _kRatingLabels[_rating.ceil()];

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
          ReviewHalfStarRating(
            rating: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),
          SizedBox(height: 14.h),
          Text(
            // 0.5 단위라 라벨만으로는 4.0/4.5 구분이 안 돼 숫자를 함께 노출(디자인 변경).
            _rating > 0 ? '${_rating.toStringAsFixed(1)} · $label' : label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _rating > 0
                  ? VybeColors.mainLime500
                  : const Color(0x59FFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return ReviewGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '사진 첨부',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '선택 · ${_photos.length}/$_kMaxPhotos',
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
                if (_photos.length < _kMaxPhotos) ...[
                  _buildAddPhotoButton(),
                  SizedBox(width: 10.w),
                ],
                for (var i = 0; i < _photos.length; i++) ...[
                  _buildPhotoTile(i),
                  if (i != _photos.length - 1) SizedBox(width: 10.w),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickPhotos,
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

  Widget _buildPhotoTile(int index) {
    return SizedBox(
      width: 72.r,
      height: 72.r,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.file(_photos[index], fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 5.r,
            right: 5.r,
            child: GestureDetector(
              onTap: () => setState(() => _photos.removeAt(index)),
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

  Widget _buildContentCard() {
    final length = _controller.text.characters.length;

    return ReviewGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('후기를 들려주세요'),
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
              controller: _controller,
              maxLines: null,
              minLines: 4,
              maxLength: _kMaxLength,
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
                hintText: '음악, 분위기, 사운드, 서비스는 어땠나요? (최소 $_kMinLength자)',
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
            child: Text(
              '$length/$_kMaxLength',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.sp,
                height: 14 / 12,
                color: const Color(0x59FFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCautions() {
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

  // ---------------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------------

  Widget _buildBottomBar() {
    final enabled = _canSubmit;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          decoration: const BoxDecoration(
            color: kReviewBarFill,
            border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
          ),
          child: GestureDetector(
            onTap: _submit,
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
              child: _submitting
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        color: kReviewInk,
                      ),
                    )
                  : Text(
                      enabled ? '리뷰 등록하기' : '별점과 후기를 입력해주세요',
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

  Widget _cardTitle(String title, {String? trailing}) {
    final titleText = Text(
      title,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
    if (trailing == null) return titleText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        titleText,
        Text(
          trailing,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12.sp,
            height: 14 / 12,
            color: const Color(0x66FFFFFF),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 별점 — 0.5 단위
// =============================================================================
