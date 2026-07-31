import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/my_page/my_reviews_screen.dart';
import 'package:vybe/presentation/my_page/profile_edit_screen.dart';
import 'package:vybe/presentation/my_page/settings_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';

// ============================================================
// 마이페이지 (my.html 디자인 기반)
//
// 히어로(아바타·프로필 수정) + 리뷰/찜 통계 + 기능 카드 +
// 계정 메뉴(알림·설정) + 로그아웃.
// 디자인의 @핸들·한 줄 소개는 users 스키마에 없어 가입 방식(provider)
// 표기로 대체. '알림' 화면은 베타 범위 외 — 준비 중 토스트.
// ============================================================

/// 찜 탭 인덱스 (MainScaffold PageView 기준).
const int _kSavedTabIndex = 2;

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);

    return Scaffold(
      backgroundColor: VybeColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackdrop()),
          SafeArea(
            bottom: false,
            child: uid == null
                ? const _LoggedOutView()
                : _LoggedInView(uid: uid),
          ),
        ],
      ),
    );
  }
}

// ============ 비로그인 ============

class _LoggedOutView extends StatelessWidget {
  const _LoggedOutView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: glassTileDecoration(radius: 22),
            child: Icon(
              Icons.person_outline_rounded,
              size: 34.r,
              color: VybeColors.gray500,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            '로그인이 필요해요',
            style: VybeTypography.heading4.copyWith(color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            '로그인하고 리뷰·찜 목록을 관리해 보세요',
            style: VybeTypography.body4.copyWith(color: VybeColors.gray500),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            ),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 34.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VybeColors.mainPurple500,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '로그인하기',
                style: VybeTypography.button1.copyWith(
                  fontWeight: FontWeight.w700,
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

// ============ 로그인 ============

class _LoggedInView extends ConsumerWidget {
  final String uid;

  const _LoggedInView({required this.uid});

  static const _providerLabels = {
    'naver': '네이버로 가입',
    'kakao': '카카오로 가입',
    'apple': 'Apple로 가입',
    'phone': '휴대폰으로 가입',
  };

  // 하위 페이지(프로필 수정·내 리뷰·설정)는 바텀 nav를 아래로 내린 채 연다.
  // 돌아오면 다시 올라온다. (pushHidingNavBar 참고)
  void _push(BuildContext context, WidgetRef ref, Widget screen) {
    pushHidingNavBar<void>(context, ref, screen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider(uid)).value;
    final reviewCount =
        ref.watch(myReviewsProvider).value?.length;
    final savedCount = ref.watch(savedClubsProvider).value?.length;

    final name = user?.name ?? '';
    final providerLabel = _providerLabels[user?.provider] ?? '';

    return SingleChildScrollView(
      // 하단 floating nav 바 높이만큼 여백.
      padding: EdgeInsets.only(bottom: 130.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- 히어로 ----------
          // 상단 우측 알림·설정 버튼 제거 — 아래 '계정' 메뉴에 동일 항목이 있어 중복.
          SizedBox(height: 72.h),
          MyAvatar(
            name: name,
            imageUrl: user?.profileImageUrl ?? '',
            size: 98,
          ),
          SizedBox(height: 15.h),
          Text(
            name.isEmpty ? ' ' : name,
            textAlign: TextAlign.center,
            style: VybeTypography.heading2.copyWith(
              fontSize: 27.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (providerLabel.isNotEmpty) ...[
            SizedBox(height: 7.h),
            Text(
              providerLabel,
              textAlign: TextAlign.center,
              style: VybeTypography.body4.copyWith(
                color: Colors.white.withValues(alpha: 0.68),
              ),
            ),
          ],
          SizedBox(height: 18.h),
          Center(
            child: GestureDetector(
              onTap: user == null
                  ? null
                  : () => _push(context, ref, ProfileEditScreen(user: user)),
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 26.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 14.r, color: const Color(0xFF0C0A1A)),
                    SizedBox(width: 7.w),
                    Text(
                      '프로필 수정',
                      style: VybeTypography.button1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0C0A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // ---------- 통계 ----------
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: glassDecoration(radius: 20),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _stat(
                    context,
                    label: '리뷰',
                    value: reviewCount,
                    onTap: () => _push(context, ref, const MyReviewsScreen()),
                  ),
                  VerticalDivider(width: 1, thickness: 1, color: hairColor),
                  _stat(
                    context,
                    label: '찜',
                    value: savedCount,
                    onTap: () => ref
                        .read(tabSwitchRequestProvider.notifier)
                        .request(_kSavedTabIndex),
                  ),
                ],
              ),
            ),
          ),

          // ---------- 기능 카드 ----------
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '내 리뷰',
                    count: reviewCount,
                    caption: '개',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7731FE), Color(0xFF4E24A0)],
                    ),
                    onTap: () => _push(context, ref, const MyReviewsScreen()),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.favorite_border_rounded,
                    label: '찜한 클럽',
                    count: savedCount,
                    caption: '곳',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A3A4A),
                        Color(0xFF148A9A),
                        Color(0xFF28E0E0),
                      ],
                    ),
                    onTap: () => ref
                        .read(tabSwitchRequestProvider.notifier)
                        .request(_kSavedTabIndex),
                  ),
                ),
              ],
            ),
          ),

          // ---------- 계정 ----------
          const SectionTitle('계정'),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: glassDecoration(radius: 18),
            child: Column(
              children: [
                _accountRow(
                  context,
                  icon: Icons.notifications_none_rounded,
                  label: '알림',
                  onTap: () =>
                      VybeToast.show(context, message: '알림은 준비 중이에요'),
                ),
                Divider(height: 1, thickness: 1, color: hairColor),
                _accountRow(
                  context,
                  icon: Icons.settings_outlined,
                  label: '설정',
                  onTap: () => _push(context, ref, const SettingsScreen()),
                ),
              ],
            ),
          ),

          // ---------- 로그아웃 ----------
          SizedBox(height: 26.h),
          Center(
            child: GestureDetector(
              onTap: () => _confirmLogout(context, ref),
              child: Container(
                height: 46.h,
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                decoration: glassTileDecoration(radius: 999),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded,
                        size: 17.r, color: VybeColors.accentRed500),
                    SizedBox(width: 8.w),
                    Text(
                      '로그아웃',
                      style: VybeTypography.button2
                          .copyWith(color: VybeColors.accentRed500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context, {
    required String label,
    required int? value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value?.toString() ?? '-',
              style: VybeTypography.heading4.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12.sp,
                color: VybeColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, size: 18.r, color: VybeColors.gray200),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Text(
                label,
                style: VybeTypography.body3.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: Colors.white.withValues(alpha: 0.32),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    // MainScaffold의 floating 바텀 nav는 body 위 Stack에 떠 있어 시트 버튼과
    // 겹친다 → 시트가 떠 있는 동안 nav를 화면 밖으로 내린다.
    ref.read(navBarHiddenProvider.notifier).hide();
    showModalBottomSheet<void>(
      context: context,
      // 탭 Navigator 대신 루트에 띄워 시트가 nav 레이어보다 위에 오게 한다.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (sheetContext) => _LogoutSheet(
        onConfirm: () async {
          Navigator.of(sheetContext).pop();
          // 로그아웃하면 AuthGate가 루트를 WelcomeScreen으로 교체하고
          // 그 위에 쌓인 라우트를 전부 정리한다.
          await ref.read(authViewModelProvider.notifier).signOut();
        },
      ),
    ).whenComplete(() => ref.read(navBarHiddenProvider.notifier).show());
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final String caption;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.caption,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 132.h,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.34),
              blurRadius: 30.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  child: Icon(icon, size: 21.r, color: Colors.white),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.r,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  count?.toString() ?? '-',
                  style: VybeTypography.heading3.copyWith(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  caption,
                  style: VybeTypography.body4.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: VybeTypography.body3.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 로그아웃 확인 바텀시트.
class _LogoutSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _LogoutSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xF01C1C20),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38.w,
            height: 4.h,
            decoration: BoxDecoration(
              // gray700(#535355)은 시트 배경과 명도차가 작아 핸들이 안 보임.
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(99.r),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            '로그아웃할까요?',
            style: VybeTypography.heading4.copyWith(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '언제든 다시 로그인할 수 있어요.',
            textAlign: TextAlign.center,
            style: VybeTypography.body4.copyWith(color: VybeColors.gray400),
          ),
          SizedBox(height: 22.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 50.h,
                    alignment: Alignment.center,
                    // glassTile(alpha 0.08)은 시트 위에서 버튼 경계가 거의
                    // 안 보여 대비를 올린다.
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: VybeTypography.button1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: VybeColors.accentRed500,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      '로그아웃',
                      style: VybeTypography.button1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
