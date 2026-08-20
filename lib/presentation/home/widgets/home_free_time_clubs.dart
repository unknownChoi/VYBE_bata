import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/club_detail_route.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_meta_dot.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/free_entry/free_entry_screen.dart';
import 'package:vybe/presentation/home/home_models.dart';
import 'package:vybe/presentation/home/viewmodels/home_free_time_viewmodel.dart';
import 'package:vybe/presentation/home/widgets/home_section_head.dart';

/// 홈 '이 시간에만 무료입장' — 특정 시간대에만 입장료가 0원인 클럽 가로 목록.
///
/// 디자인 `home.jsx > FreeTimeClubs`.
/// 데이터는 `clubs.freeEntry.type == 'timed'`, 지금 무료인지는 앱이 판정한다
/// (Firestore는 요일×시:분×자정 넘김을 쿼리할 수 없다).
class HomeFreeTimeClubs extends ConsumerWidget {
  const HomeFreeTimeClubs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(homeFreeTimeClubsProvider);
    final cardHeight = 156.h;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHead(
            title: '이 시간에만 무료입장',
            sub: '이 시간 지나면 원래 입장료',
            onAction: () => Navigator.of(context).push(
              SwipeBackPageRoute<void>(builder: (_) => const FreeEntryScreen()),
            ),
          ),
          clubsAsync.when(
            data: (clubs) => clubs.isEmpty
                ? HomeSectionMessage(
                    text: '지금 예정된 무료입장 시간이 없어요',
                    height: cardHeight,
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: List.generate(clubs.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i < clubs.length - 1 ? 12.w : 0,
                          ),
                          child: VybeFadeInUp(
                            delay: Duration(milliseconds: 45 * i),
                            child: _FreeTimeCard(club: clubs[i]),
                          ),
                        );
                      }),
                    ),
                  ),
            loading: () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: List.generate(
                  2,
                  (i) => Padding(
                    padding: EdgeInsets.only(right: i == 0 ? 12.w : 0),
                    child: VybeSkel(
                      width: 250.w,
                      height: cardHeight,
                      radius: 16,
                    ),
                  ),
                ),
              ),
            ),
            error: (_, __) => HomeSectionMessage(
              text: '무료입장 정보를 불러오지 못했어요',
              height: cardHeight,
            ),
          ),
        ],
      ),
    );
  }
}

/// 250×156 카드 — 사진(또는 폴백 그라데이션) 위 상단 pill 줄 + 하단 글래스 정보 바.
class _FreeTimeCard extends StatelessWidget {
  final HomeFreeTimeClub club;

  const _FreeTimeCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openClubDetail(context, club.clubId),
      // 바깥 ClipRRect로 감싸면 코너 호에서 1px 테두리가 깎인다 — 컨테이너 자체 클립 사용.
      child: Container(
        width: 250.w,
        height: 156.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: club.gradient,
          ),
          // 카드 하단이 배경색과 거의 같아 라운딩이 안 보여 테두리를 한 단계 밝게.
          border: Border.all(color: VybeColors.gray700),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (club.thumbnailUrl.isNotEmpty)
              Image.network(
                club.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            // 하단 가독성 그라데이션 (주변 클럽 카드와 동일)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xF00A0A0E)],
                  stops: [0.32, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 12.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                children: [
                  if (club.freeNow)
                    const _LivePill(text: '지금 무료')
                  else if (club.startsLabel != null)
                    _QuietPill(
                      icon: Icons.schedule_rounded,
                      text: club.startsLabel!,
                    ),
                  const Spacer(),
                  if (club.remainingLabel != null)
                    _QuietPill(text: club.remainingLabel!, dark: true),
                ],
              ),
            ),
            // 정보 (하단) — 주변 클럽 카드와 같은 배치.
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 13.h,
              child: _CardInfo(club: club),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카드 하단 정보 — 주변 클럽(`HomeNearbyClubs`) 카드와 같은 구성·타이포.
/// 무료 시간대·평상시 요금 줄만 이 섹션 고유로 이름 위에 붙는다.
class _CardInfo extends StatelessWidget {
  final HomeFreeTimeClub club;

  const _CardInfo({required this.club});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // 시간 표기가 이 줄의 주인공 — 좁아지면 요금보다 먼저 자리를 갖는다.
            Flexible(
              child: Text(
                club.windowLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.tagline.copyWith(
                  height: 16 / 14,
                  color: VybeColors.mainLime500,
                ),
              ),
            ),
            if (club.normalFeeLabel.isNotEmpty) ...[
              SizedBox(width: 7.w),
              // 무료 시간이 끝나면 받는 값 — 취소선으로 대비를 준다.
              Text(
                club.normalFeeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.caption.copyWith(
                  color: VybeColors.gray400,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 5.h),
        Text(
          club.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 18 * -0.025,
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Text(
              club.area,
              style: VybeTypography.caption.copyWith(
                color: VybeColors.gray300,
              ),
            ),
            const VybeMetaDot(),
            Flexible(
              child: Text(
                club.genre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.caption.copyWith(
                  color: VybeColors.gray400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// '지금 무료' — 라임 틴트 pill + 맥박치는 점 (디자인 `livePulse`).
class _LivePill extends StatefulWidget {
  final String text;

  const _LivePill({required this.text});

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: VybeColors.mainLime500.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(
          color: VybeColors.mainLime500.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.55).animate(_c),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.35).animate(_c),
              child: Container(
                width: 5.r,
                height: 5.r,
                decoration: const BoxDecoration(
                  color: VybeColors.mainLime500,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            widget.text,
            style: _pillText.copyWith(color: VybeColors.mainLime500),
          ),
        ],
      ),
    );
  }
}

/// 보조 pill — 시작 시각 / 남은 시간.
class _QuietPill extends StatelessWidget {
  final String text;
  final IconData? icon;

  /// 사진 위에서 대비를 올려야 할 때(남은 시간) 어두운 바 채움을 쓴다.
  final bool dark;

  const _QuietPill({required this.text, this.icon, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final color = dark ? RenewGlass.t2 : RenewGlass.t3;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: dark ? RenewGlass.barFill : RenewGlass.tileFill,
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(
          color: dark ? RenewGlass.hair : RenewGlass.tileBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.r, color: color),
            SizedBox(width: 4.w),
          ],
          Text(text, style: _pillText.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// pill 안 문구 — 600 / 11 / 1.0 (디자인 Pill 규격).
final _pillText = TextStyle(
  fontFamily: 'Pretendard',
  fontSize: 11.sp,
  height: 1,
  fontWeight: FontWeight.w600,
  letterSpacing: 11 * -0.025,
);
