import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/my_page/notice_detail_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/notice_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 공지사항 목록 (마이페이지 → 계정 → 공지사항)
//
// notices 컬렉션 읽기 전용. 작성/수정은 어드민 페이지 전용.
// 고정 공지가 위, 나머지는 최신 게시순 (정렬은 datasource에서 완료).
// ============================================================

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesProvider);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackdrop()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SubScreenHeader(title: '공지사항'),
                Expanded(
                  child: noticesAsync.when(
                    loading: () => const Center(child: VybeSpinner()),
                    error: (_, __) => _message('공지사항을 불러오지 못했어요'),
                    data: (notices) => notices.isEmpty
                        ? _empty()
                        : RefreshIndicator(
                            color: VybeColors.mainLime500,
                            backgroundColor: VybeColors.surface,
                            onRefresh: () async =>
                                ref.invalidate(noticesProvider),
                            child: ListView.separated(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                              itemCount: notices.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, i) => _NoticeCard(
                                notice: notices[i],
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        NoticeDetailScreen(notice: notices[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String text) {
    return Center(
      child: Text(
        text,
        style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: glassTileDecoration(radius: 18),
            child: Icon(
              Icons.campaign_outlined,
              size: 26.r,
              color: VybeColors.gray600,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '등록된 공지가 없어요',
            style: VybeTypography.body3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            '새로운 소식이 생기면 여기에 올려드릴게요',
            style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onTap;

  const _NoticeCard({required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: glassDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (notice.isPinned) ...[
                  Icon(
                    Icons.push_pin_rounded,
                    size: 13.r,
                    color: VybeColors.mainLime500,
                  ),
                  SizedBox(width: 6.w),
                ],
                NoticeCategoryBadge(notice: notice),
                if (notice.isNew) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: VybeColors.accentRed500.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: VybeColors.accentRed500,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  notice.dateLabel,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    color: VybeColors.gray600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              notice.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: VybeTypography.body3.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (notice.content.isNotEmpty) ...[
              SizedBox(height: 7.h),
              Text(
                notice.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.body4.copyWith(
                  height: 20 / 14,
                  color: VybeColors.gray500,
                ),
              ),
            ],
            if (notice.imageUrls.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 13.r,
                    color: VybeColors.gray600,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    '사진 ${notice.imageUrls.length}장',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.sp,
                      color: VybeColors.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 카테고리 배지 — 목록·상세 공용.
class NoticeCategoryBadge extends StatelessWidget {
  final NoticeModel notice;

  const NoticeCategoryBadge({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final color = switch (notice.category) {
      'update' => VybeColors.accentBlue500,
      'event' => VybeColors.mainLime500,
      _ => VybeColors.mainPurple500,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        notice.categoryLabel,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
