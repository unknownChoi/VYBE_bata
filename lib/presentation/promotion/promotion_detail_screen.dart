import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vybe/data/models/promotion_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_content_image.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/promotion/viewmodels/promotion_viewmodel.dart';

// ============================================================
// 프로모션 상세 (홈 배너 → 배너별 광고 페이지)
//
// 화면은 이 하나뿐이고 내용(히어로·제목·본문·사진·CTA)은 전부
// promotions/{promotionId} 문서에서 온다 — 배너를 추가해도 앱 배포가 필요 없다.
// 본문은 plain text — \n 줄바꿈만 반영하고 마크다운/HTML 파싱은 하지 않는다.
// ============================================================

class PromotionDetailScreen extends ConsumerWidget {
  final String promotionId;

  const PromotionDetailScreen({super.key, required this.promotionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(promotionProvider(promotionId));

    return Scaffold(
      backgroundColor: ClubGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: ClubAurora()),
          async.when(
            loading: () => const Center(child: VybeSpinner()),
            error: (_, __) => const _EmptyState(message: '내용을 불러오지 못했어요'),
            // 비활성·삭제된 프로모션도 null — 배너가 남아 있어도 빈 화면은 안 나온다.
            data: (promotion) => promotion == null
                ? const _EmptyState(message: '종료되었거나 찾을 수 없는 이벤트예요')
                : _Body(promotion: promotion),
          ),
          // 뒤로가기는 로딩·에러 상태에서도 항상 떠 있어야 한다 (히어로 위 오버레이).
          Positioned(
            top: MediaQuery.paddingOf(context).top + 6.h,
            left: 12.w,
            child: VybeGlassButton(
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PromotionModel promotion;

  const _Body({required this.promotion});

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            // CTA 바가 없으면 하단 안전영역만큼 스스로 띄운다.
            padding: EdgeInsets.only(
              bottom: 30.h + (promotion.hasCta ? 0 : safeBottom),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (promotion.heroImageUrl.isNotEmpty)
                  _Hero(url: promotion.heroImageUrl)
                else
                  // 히어로가 없으면 상단바 자리(뒤로가기 버튼)만 비워 둔다.
                  SizedBox(height: safeTop + 58.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (promotion.periodLabel.isNotEmpty) ...[
                        _PeriodPill(label: promotion.periodLabel),
                        SizedBox(height: 13.h),
                      ],
                      Text(
                        promotion.title,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 25.sp,
                          height: 35 / 25,
                          letterSpacing: 25 * -0.02,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (promotion.subtitle.isNotEmpty) ...[
                        SizedBox(height: 9.h),
                        Text(
                          promotion.subtitle,
                          style: ClubGlass.caption(
                            color: ClubGlass.t3,
                            size: 13.5,
                            lineHeight: 20,
                          ),
                        ),
                      ],
                      SizedBox(height: 18.h),
                      const GlassHairline(),
                      if (promotion.content.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        Text(
                          promotion.content,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14.5.sp,
                            height: 27 / 14.5,
                            letterSpacing: 14.5 * -0.025,
                            color: ClubGlass.t2,
                          ),
                        ),
                      ],
                      for (final url in promotion.imageUrls) ...[
                        SizedBox(height: 16.h),
                        VybeContentImage(url: url),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (promotion.hasCta) _CtaBar(promotion: promotion),
      ],
    );
  }
}

/// 상단 히어로. 아래쪽을 잉크로 녹여 본문과 이음새가 보이지 않게 한다.
class _Hero extends StatelessWidget {
  final String url;

  const _Hero({required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: VybeColors.surface),
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : const ColoredBox(color: VybeColors.surface),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Colors.transparent, ClubGlass.ink],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 진행 기간 pill.
class _PeriodPill extends StatelessWidget {
  final String label;

  const _PeriodPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0x29B5FF60), // rgba(181,255,96,0.16)
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0x61B5FF60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 12.r,
            color: VybeColors.mainLime500,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: ClubGlass.caption(
              color: VybeColors.mainLime500,
              size: 11,
              lineHeight: 13,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 하단 고정 CTA 바 — 클럽 상세 이동 또는 외부 링크.
class _CtaBar extends StatelessWidget {
  final PromotionModel promotion;

  const _CtaBar({required this.promotion});

  Future<void> _onTap(BuildContext context) async {
    switch (promotion.ctaType) {
      case PromotionCtaType.club:
        openClubDetail(context, promotion.ctaValue);
      case PromotionCtaType.url:
        final uri = Uri.tryParse(promotion.ctaValue);
        if (uri == null) return;
        // canLaunchUrl은 Android queries 설정에 걸려 false를 줄 수 있어 바로 시도한다.
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        ).catchError((_) => false);
        if (!opened && context.mounted) {
          VybeToast.show(context, message: '링크를 열 수 없습니다', isError: true);
        }
      case PromotionCtaType.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return GlassBar(
      border: false,
      topBorder: true,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h + safeBottom),
      child: VybeButton(
        label: promotion.ctaLabelOrDefault,
        onTap: () => _onTap(context),
      ),
    );
  }
}


/// 문서가 없거나 조회 실패했을 때.
class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_activity_outlined,
            size: 34.r,
            color: const Color(0x59FFFFFF),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: ClubGlass.caption(
              color: ClubGlass.t4,
              size: 13,
              lineHeight: 18,
            ),
          ),
        ],
      ),
    );
  }
}
