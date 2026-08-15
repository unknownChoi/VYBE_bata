import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/review_model.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/viewmodels/review_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/clubs/widgets/review_write_cards.dart';
import 'package:vybe/presentation/clubs/widgets/review_write_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';

// 디자인: review_write.jsx (WRITE REVIEW — LIQUID GLASS)
// 섹션 카드는 전부 widgets/review_write_cards.dart — 여기엔 입력 상태와 제출만 둔다.

/// 리뷰 작성·수정 페이지.
///
/// [review]가 있으면 수정 모드 — 별점·후기·첨부 사진을 채워 열고, 등록 대신
/// 기존 문서를 갱신한다. 화면 구성이 작성과 완전히 같아 한 파일로 겸한다.
///
/// 별점은 0.5~5.0을 0.5 단위로 입력한다(디자인은 1점 단위 5개 별 → 반쪽 채움으로 확장).
/// 사진은 최대 4장까지 첨부하고, 등록 시
/// `reviews/{clubId}/{reviewId}/` 에 업로드한 뒤 URL을 리뷰 문서에 담는다.
class ReviewWriteScreen extends ConsumerStatefulWidget {
  final String clubId;

  /// 수정 대상 리뷰. null이면 새 리뷰 작성.
  final ReviewModel? review;

  const ReviewWriteScreen({super.key, required this.clubId, this.review});

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
    return pushHidingNavBar<bool>(context, ReviewWriteScreen(clubId: clubId));
  }

  /// 리뷰 수정 페이지로 이동. 수정 성공 시 true 반환.
  ///
  /// 호출 지점(마이페이지 '내 리뷰 관리')은 이미 바텀 nav가 내려간 화면이라
  /// [pushHidingNavBar] 대신 평범하게 push한다 — 여기서 또 감싸면 이 페이지를
  /// 닫을 때 nav가 올라와 뒤에 남는 목록 화면을 덮는다.
  static Future<bool?> pushEdit(
    BuildContext context, {
    required ReviewModel review,
  }) {
    return Navigator.of(context).push<bool>(
      SwipeBackPageRoute(
        builder: (_) =>
            ReviewWriteScreen(clubId: review.clubId, review: review),
      ),
    );
  }

  @override
  ConsumerState<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends ConsumerState<ReviewWriteScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();

  double _rating = 0;
  final List<ReviewPhoto> _photos = [];
  bool _submitting = false;

  bool get _isEdit => widget.review != null;

  @override
  void initState() {
    super.initState();
    final review = widget.review;
    if (review != null) {
      _rating = review.rating;
      _controller.text = review.content;
      _photos.addAll(review.imageUrls.map(ReviewPhoto.remote));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 등록 가능 여부. 본문은 controller를 구독하는 쪽에서 받은 값을 넘긴다
  /// (화면 전체를 타이핑마다 setState 하지 않으려고 — 하단 바 참고).
  bool _canSubmit(String text) =>
      _rating > 0 &&
      text.trim().characters.length >= kReviewMinLength &&
      !_submitting;

  Future<void> _pickPhotos() async {
    final remain = kReviewMaxPhotos - _photos.length;
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
        _photos.addAll(
          picked.take(remain).map((x) => ReviewPhoto.local(File(x.path))),
        );
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
    if (!_canSubmit(_controller.text)) return;

    final original = widget.review;
    if (original != null) {
      await _submitEdit(original);
      return;
    }

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
          images: _newImages,
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

  /// 수정 저장. 작성과 달리 uid·작성자 이름은 건드리지 않는다
  /// (문서에 이미 있고, datasource의 updateReview도 그 필드를 안 쓴다).
  Future<void> _submitEdit(ReviewModel original) async {
    setState(() => _submitting = true);

    final ok = await ref
        .read(reviewViewModelProvider.notifier)
        .submitReviewEdit(
          original: original,
          rating: _rating,
          content: _controller.text.trim(),
          // 태그 입력 UI는 아직 없어 원본 값을 그대로 유지한다(수정으로 날리지 않음).
          tags: original.tags,
          keptImageUrls: [
            for (final p in _photos)
              if (p.url != null) p.url!,
          ],
          newImages: _newImages,
        );

    if (!mounted) return;

    if (!ok) {
      setState(() => _submitting = false);
      VybeToast.show(context, message: '리뷰 수정에 실패했어요');
      return;
    }

    Navigator.of(context).pop(true);
  }

  /// 이번에 새로 고른 사진만 (기존 첨부는 URL이라 업로드 대상이 아니다).
  List<File> get _newImages => [
    for (final p in _photos)
      if (p.file != null) p.file!,
  ];

  @override
  Widget build(BuildContext context) {
    final club = ref.watch(clubDetailProvider(widget.clubId)).value;

    return Scaffold(
      backgroundColor: kReviewInk,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: VybeAurora()),
          SafeArea(
            child: Column(
              children: [
                GlassTopBar(title: _isEdit ? '리뷰 수정' : '리뷰 작성'),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                    children: [
                      ReviewClubCard(
                        club: club,
                        // 수정 모드에선 오늘이 아니라 원래 리뷰를 쓴 날을 보여준다.
                        visitedAt: widget.review?.createdAt ?? DateTime.now(),
                      ),
                      SizedBox(height: 14.h),
                      ReviewRatingCard(
                        rating: _rating,
                        onChanged: (v) => setState(() => _rating = v),
                      ),
                      SizedBox(height: 14.h),
                      ReviewPhotoCard(
                        photos: _photos,
                        onAdd: _pickPhotos,
                        onRemove: (i) => setState(() => _photos.removeAt(i)),
                      ),
                      SizedBox(height: 14.h),
                      ReviewContentCard(controller: _controller),
                      SizedBox(height: 16.h),
                      const ReviewCautions(),
                    ],
                  ),
                ),
                // 버튼 활성 여부만 타이핑을 구독한다 — 화면 전체를 다시 그리면
                // 글래스 카드(BackdropFilter)까지 매 글자마다 다시 그려진다.
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => ReviewSubmitBar(
                    enabled: _canSubmit(value.text),
                    submitting: _submitting,
                    label: _isEdit ? '수정 완료' : '리뷰 등록하기',
                    onTap: _submit,
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
