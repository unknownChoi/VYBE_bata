import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_surface.dart';
import 'package:vybe/presentation/my_page/viewmodels/notice_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/notice_glass.dart';

// ============================================================
// 공지사항 상세
//
// 디자인: notice_glass.jsx `NCDetail` — 글래스 상단바 + 배지 행 + 큰 제목 +
// 운영팀·날짜 메타 + 본문 + 잠금 안내 + 이전/다음 글 이동.
//
// 목록에서 받은 모델을 그대로 표시 — 재조회 없음(공지는 갱신 빈도가 낮고,
// 목록이 이미 전체 본문을 담고 있다).
// 본문은 plain text — \n 줄바꿈만 반영하고 마크다운/HTML 파싱은 하지 않는다.
// ============================================================

class NoticeDetailScreen extends ConsumerWidget {
  final NoticeModel notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = noticeCatStyleOf(notice.category);
    // 이전/다음 글은 이미 로드된 목록에서 찾는다 (추가 read 없음).
    // 목록 순서 = 고정 공지 우선 → 최신 게시순.
    final list = ref.watch(noticesProvider).value ?? const <NoticeModel>[];
    final index = list.indexWhere((n) => n.noticeId == notice.noticeId);
    final prev = index > 0 ? list[index - 1] : null;
    final next =
        index > -1 && index < list.length - 1 ? list[index + 1] : null;

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: ClubAurora()),
          Column(
            children: [
              const _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    22.h,
                    20.w,
                    30.h + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _badgeRow(c),
                      SizedBox(height: 13.h),
                      Text(
                        notice.title,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 25.sp,
                          height: 35 / 25,
                          letterSpacing: 25 * -0.02,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _metaRow(),
                      if (notice.content.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        Text(
                          notice.content,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14.5.sp,
                            height: 27 / 14.5,
                            letterSpacing: 14.5 * -0.025,
                            color: ClubGlass.t2,
                          ),
                        ),
                      ],
                      for (final url in notice.imageUrls) ...[
                        SizedBox(height: 16.h),
                        _NoticeImage(url: url),
                      ],
                      // 잠금 안내('운영팀만 등록')는 목록 하단에만 둔다 — 상세에선 중복.
                      SizedBox(height: 30.h),
                      if (prev != null)
                        _NavRow(label: '이전 글', notice: prev),
                      if (prev != null && next != null) SizedBox(height: 8.h),
                      if (next != null)
                        _NavRow(label: '다음 글', notice: next),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeRow(NoticeCatStyle c) {
    return Row(
      children: [
        if (notice.isPinned) ...[
          const NoticeImportantPill(fontSize: 10.5),
          SizedBox(width: 7.w),
        ],
        NoticeCategoryPill(style: c, fontSize: 11),
        if (notice.isNew) ...[
          SizedBox(width: 7.w),
          const NoticeNewBadge(fontSize: 10),
        ],
      ],
    );
  }

  /// 작성자(운영팀 배지) + 게시일. 아래 hairline으로 본문과 나뉜다.
  Widget _metaRow() {
    return Container(
      padding: EdgeInsets.only(bottom: 18.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ClubGlass.hair)),
      ),
      child: Row(
        children: [
          const NoticeTeamPill(),
          SizedBox(width: 9.w),
          Icon(
            Icons.schedule_rounded,
            size: 12.r,
            color: const Color(0x80FFFFFF),
          ),
          SizedBox(width: 5.w),
          Text(
            notice.dateLabel,
            style: ClubGlass.caption(
              color: ClubGlass.t4,
              size: 11.5,
              lineHeight: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// 상단 글래스 바 — 뒤로가기 + '공지사항'.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return GlassBar(
      padding: EdgeInsets.fromLTRB(16.w, top + 8.h, 16.w, 12.h),
      child: Row(
        children: [
          // 앱 공통 리퀴드 글래스 버튼 (누르면 줄어들며 라임 글로우).
          VybeGlassButton(
            onTap: () => Navigator.of(context).maybePop(),
            size: 38,
            iconSize: 17,
            hitSize: 42,
          ),
          SizedBox(width: 7.w),
          Text(
            '공지사항',
            style: VybeTypography.body3.copyWith(
              fontWeight: FontWeight.w700,
              color: ClubGlass.t2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 이전 글 / 다음 글 이동 줄. 스택을 쌓지 않게 현재 상세를 교체한다.
class _NavRow extends StatelessWidget {
  final String label;
  final NoticeModel notice;

  const _NavRow({required this.label, required this.notice});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => NoticeDetailScreen(notice: notice),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: VybeGlassSurface.quiet(
        radius: 15,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
          child: Row(
            children: [
              SizedBox(
                width: 40.w,
                child: Text(
                  label,
                  style: ClubGlass.caption(
                    color: ClubGlass.t4,
                    size: 11,
                    lineHeight: 13,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  notice.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClubGlass.caption(
                    color: ClubGlass.t2,
                    size: 12.5,
                    lineHeight: 18,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 15.r,
                color: const Color(0x80FFFFFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 본문 첨부 이미지. 원본 비율을 모르니 로딩·실패는 고정 높이 플레이스홀더.
class _NoticeImage extends StatelessWidget {
  final String url;

  const _NoticeImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => _fallback(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
        height: 180.h,
        alignment: Alignment.center,
        color: VybeGlassSurface.quietFill,
        child: Icon(
          Icons.image_outlined,
          size: 26.r,
          color: const Color(0x59FFFFFF),
        ),
      );
}
