import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';

// 디자인: review_write.jsx (WRITE REVIEW — LIQUID GLASS)

const _kStarAsset = 'assets/icons/common/club_card/star.svg';

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

// 글래스 톤 (디자인 RG_GLASS / RG_TILE)
const _glassFill = Color(0x29787880); // rgba(120,120,128,0.16)
const _glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
const _tileFill = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
const _tileBorder = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)
const _barFill = Color(0x8C0E0D12); // rgba(14,13,18,0.55)
const _ink = Color(0xFF0E0D12);

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
  /// 이 페이지의 등록 버튼과 겹친다 → 페이지가 열려 있는 동안 화면 밖으로 내린다.
  /// 내리는 시점은 페이지 전환이 끝난 뒤(화면 안에서) — [_ReviewWriteScreenState] 참고.
  /// 복원은 pop 시점에 바로 해서 페이지가 내려가는 동안 nav가 같이 올라온다.
  static Future<bool?> push(
    BuildContext context,
    WidgetRef ref, {
    required String clubId,
  }) {
    return Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(builder: (_) => ReviewWriteScreen(clubId: clubId)),
        )
        .whenComplete(() => ref.read(navBarHiddenProvider.notifier).show());
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

  /// 페이지 전환 애니메이션. 완료를 감지해 그때 바텀 nav를 내린다.
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    // 페이지 진입 애니메이션이 끝난 뒤 nav를 내려야 슬라이드가 화면 안에서 보인다.
    // (push와 동시에 내리면 이 페이지가 덮기 전에 이미 사라져 있어 애니메이션을 놓친다)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final animation = ModalRoute.of(context)?.animation;
      if (animation == null || animation.isCompleted) {
        _hideNavBar();
        return;
      }
      _routeAnimation = animation..addStatusListener(_onRouteAnimation);
    });
  }

  void _onRouteAnimation(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _clearRouteAnimation();
    _hideNavBar();
  }

  void _hideNavBar() {
    if (!mounted) return;
    ref.read(navBarHiddenProvider.notifier).hide();
  }

  void _clearRouteAnimation() {
    _routeAnimation?.removeStatusListener(_onRouteAnimation);
    _routeAnimation = null;
  }

  @override
  void dispose() {
    // 전환 도중 바로 뒤로가기 하면 completed가 안 와서 리스너가 남는다.
    _clearRouteAnimation();
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
      backgroundColor: _ink,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _ReviewAurora()),
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
            color: _barFill,
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
                    color: _tileFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: _tileBorder),
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

    return _GlassCard(
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

    return _GlassCard(
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
          _HalfStarRating(
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
    return _GlassCard(
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
        painter: _DashedBorderPainter(radius: 14.r),
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

    return _GlassCard(
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
            color: _barFill,
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
                        color: _ink,
                      ),
                    )
                  : Text(
                      enabled ? '리뷰 등록하기' : '별점과 후기를 입력해주세요',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: enabled ? _ink : const Color(0x4DFFFFFF),
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

/// 별 하나를 반쪽 단위까지 채우는 별점 입력.
///
/// 별의 왼쪽 절반을 누르면 x.5, 오른쪽 절반을 누르면 x.0.
/// 가로로 드래그하면 값이 이어서 바뀐다. 최소 0.5, 최대 5.0.
class _HalfStarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _HalfStarRating({required this.rating, required this.onChanged});

  static const _count = 5;

  @override
  Widget build(BuildContext context) {
    final star = 40.r;
    final gap = 10.w;
    final width = star * _count + gap * (_count - 1);

    void update(double dx) {
      final unit = star + gap;
      final index = (dx / unit).floor().clamp(0, _count - 1);
      final inStar = dx - index * unit;
      // 별 안쪽 왼쪽 절반이면 반 개, 그 외(오른쪽 절반·별 사이 간격)면 한 개.
      final fill = inStar <= star / 2 ? 0.5 : 1.0;
      final next = index + fill;
      if (next != rating) onChanged(next);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => update(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => update(d.localPosition.dx),
      child: SizedBox(
        width: width,
        height: star,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _count; i++) ...[
              _StarIcon(size: star, fill: (rating - i).clamp(0.0, 1.0)),
              if (i != _count - 1) SizedBox(width: gap),
            ],
          ],
        ),
      ),
    );
  }
}

class _StarIcon extends StatelessWidget {
  final double size;

  /// 0.0(빈 별) ~ 1.0(꽉 찬 별). 0.5면 왼쪽 절반만 채워진다.
  final double fill;

  const _StarIcon({required this.size, required this.fill});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: fill > 0 ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            SvgPicture.asset(
              _kStarAsset,
              width: size,
              height: size,
              colorFilter: const ColorFilter.mode(
                Color(0x24FFFFFF), // rgba(255,255,255,0.14)
                BlendMode.srcIn,
              ),
            ),
            if (fill > 0)
              ClipRect(
                clipper: _StarFillClipper(fill),
                child: SvgPicture.asset(
                  _kStarAsset,
                  width: size,
                  height: size,
                  colorFilter: const ColorFilter.mode(
                    VybeColors.mainLime500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StarFillClipper extends CustomClipper<Rect> {
  final double fraction;

  const _StarFillClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_StarFillClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

// =============================================================================
// 공통 조각
// =============================================================================

/// 리퀴드 글래스 카드 (디자인 RG_GLASS + 좌상단 하이라이트).
class _GlassCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double radius;

  const _GlassCard({required this.child, this.padding = 18, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x5C000000),
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      // 테두리는 하이라이트 위에 그린다.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: _glassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: BackdropFilter(
          // CSS blur(18px) ≈ sigma 9.
          filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          // 채움색과 하이라이트는 레이어를 나눈다 — 한 BoxDecoration에
          // color·gradient를 같이 주면 gradient가 color를 덮어 카드가 사라진다.
          child: ColoredBox(
            color: _glassFill,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // 좌상단에서 번지는 유리 하이라이트.
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.76, -1),
                        radius: 1.1,
                        colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
                        stops: [0.0, 0.58],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: ColoredBox(color: Color(0x29FFFFFF)),
                ),
                Padding(padding: EdgeInsets.all(padding.r), child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 사진 추가 버튼의 점선 테두리 (Flutter 기본 Border에 dashed가 없어 직접 그림).
class _DashedBorderPainter extends CustomPainter {
  final double radius;

  const _DashedBorderPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0x38FFFFFF) // rgba(255,255,255,0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    const dash = 4.0;
    const space = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + space;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// 리뷰 작성 페이지 배경 (디자인 RG_AURORA).
class _ReviewAurora extends StatelessWidget {
  const _ReviewAurora();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120F1A), Color(0xFF101013), Color(0xFF0E0D12)],
          stops: [0.0, 0.34, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 좌상단 보라 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.88, -1),
                  radius: 1.3,
                  colors: [Color(0x577731FE), Color(0x00000000)],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
          // 우상단 라임 글로우
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1, -0.88),
                  radius: 1.3,
                  colors: [Color(0x21B5FF60), Color(0x00000000)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),
          // 우하단 보라 글로우
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 340,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.6, 0.88),
                  radius: 1.4,
                  colors: [Color(0x247731FE), Color(0x00000000)],
                  stops: [0.0, 0.66],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
