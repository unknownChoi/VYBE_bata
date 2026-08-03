import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/my_page/notices_screen.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 공지사항 상세
//
// 목록에서 받은 모델을 그대로 표시 — 재조회 없음(공지는 갱신 빈도가 낮고,
// 목록이 이미 전체 본문을 담고 있다).
// 본문은 plain text — \n 줄바꿈만 반영하고 마크다운/HTML 파싱은 하지 않는다.
// ============================================================

class NoticeDetailScreen extends StatelessWidget {
  final NoticeModel notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            NoticeCategoryBadge(notice: notice),
                            if (notice.isPinned) ...[
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.push_pin_rounded,
                                size: 13.r,
                                color: VybeColors.mainLime500,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          notice.title,
                          style: VybeTypography.heading4.copyWith(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w700,
                            height: 30 / 21,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Text(
                              notice.authorName,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12.sp,
                                color: VybeColors.gray500,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '·',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12.sp,
                                color: VybeColors.gray700,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              notice.dateLabel,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12.sp,
                                color: VybeColors.gray500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        Divider(height: 1, thickness: 1, color: hairColor),
                        SizedBox(height: 20.h),
                        if (notice.content.isNotEmpty)
                          Text(
                            notice.content,
                            style: VybeTypography.body3.copyWith(
                              height: 24 / 15,
                              color: VybeColors.gray200,
                            ),
                          ),
                        for (final url in notice.imageUrls) ...[
                          SizedBox(height: 16.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: Image.network(
                              url,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                              loadingBuilder: (_, child, progress) =>
                                  progress == null ? child : _imageFallback(),
                            ),
                          ),
                        ],
                      ],
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

  /// 로딩·실패 공통 플레이스홀더 (원본 비율을 모르니 고정 높이).
  Widget _imageFallback() => Container(
        height: 180.h,
        alignment: Alignment.center,
        color: VybeColors.surface,
        child: Icon(
          Icons.image_outlined,
          size: 26.r,
          color: VybeColors.gray700,
        ),
      );
}
