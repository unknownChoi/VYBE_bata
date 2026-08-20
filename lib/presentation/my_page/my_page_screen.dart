import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/navigation/swipe_back_page_route.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/auth/welcome/welcome_screen.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_dialog.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/my_page/my_reviews_screen.dart';
import 'package:vybe/presentation/my_page/notices_screen.dart';
import 'package:vybe/presentation/my_page/profile_edit_screen.dart';
import 'package:vybe/presentation/my_page/settings_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';

// ============================================================
// 마이페이지 — 리뉴얼 (my_renew.html 디자인 기반)
//
// 오로라 배경 + 가로 프로필 행 + 통계 카드 2칸 +
// '내 활동'·'계정' 메뉴 목록(카드 없이 헤어라인으로만 구분) + 버전 표기.
//
// 디자인의 @핸들·한 줄 소개는 users 스키마에 없어 가입 방식(provider)
// 표기로 대체. '알림' 화면은 베타 범위 외 — 준비 중 토스트.
// 디자인 하단 탭바는 MainScaffold가 이미 그리므로 여기선 그리지 않는다.
// ============================================================

/// 찜 탭 인덱스 (MainScaffold PageView 기준).
const int _kSavedTabIndex = 2;

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);

    return Scaffold(
      backgroundColor: RenewGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: VybeAurora()),
          uid == null ? const _LoggedOutView() : _LoggedInView(uid: uid),
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
          const MyGlassTile(icon: RenewIcons.user, size: 72, radius: 22),
          SizedBox(height: 18.h),
          Text('로그인이 필요해요', style: RenewGlass.title()),
          SizedBox(height: 8.h),
          Text(
            '로그인하고 리뷰·찜 목록을 관리해 보세요',
            style: RenewGlass.body(color: RenewGlass.t4),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              SwipeBackPageRoute(builder: (_) => const WelcomeScreen()),
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
  void _push(BuildContext context, Widget screen) =>
      pushHidingNavBar<void>(context, screen);

  void _openSaved(WidgetRef ref) =>
      ref.read(tabSwitchRequestProvider.notifier).request(_kSavedTabIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider(uid)).value;
    final reviewCount = ref.watch(myReviewsProvider).value?.length;
    final savedCount = ref.watch(savedClubsProvider).value?.length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        kMyPagePad.w,
        MediaQuery.paddingOf(context).top + kMySectionGap.h,
        kMyPagePad.w,
        // 하단 floating nav 바에 가리지 않도록 확보하는 여백.
        130.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyFadeUp(
            index: 0,
            child: _Profile(
              name: user?.name ?? '',
              imageUrl: user?.profileImageUrl ?? '',
              subtitle: _providerLabels[user?.provider] ?? '',
              onEdit: user == null
                  ? null
                  : () => _push(context, ProfileEditScreen(user: user)),
            ),
          ),
          SizedBox(height: kMySectionGap.h),

          MyFadeUp(
            index: 1,
            child: _Stats(
              reviewCount: reviewCount,
              savedCount: savedCount,
              onReviews: () => _push(context, const MyReviewsScreen()),
              onSaved: () => _openSaved(ref),
            ),
          ),
          SizedBox(height: kMySectionGap.h),

          MyFadeUp(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RenewSectionHead(title: '내 활동'),
                MyMenuRow(
                  icon: RenewIcons.review,
                  label: '내 리뷰 관리',
                  value: reviewCount?.toString(),
                  onTap: () => _push(context, const MyReviewsScreen()),
                ),
                MyMenuRow(
                  icon: RenewIcons.heart,
                  label: '찜한 클럽',
                  value: savedCount?.toString(),
                  onTap: () => _openSaved(ref),
                  last: true,
                ),
              ],
            ),
          ),
          SizedBox(height: kMySectionGap.h),

          MyFadeUp(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const RenewSectionHead(title: '계정'),
                MyMenuRow(
                  icon: RenewIcons.bell,
                  label: '알림',
                  onTap: () => VybeToast.show(context, message: '알림은 준비 중이에요'),
                ),
                MyMenuRow(
                  icon: RenewIcons.mega,
                  label: '공지사항',
                  onTap: () => _push(context, const NoticesScreen()),
                ),
                MyMenuRow(
                  icon: RenewIcons.gear,
                  label: '설정',
                  onTap: () => _push(context, const SettingsScreen()),
                ),
                // 회원 탈퇴는 설정 화면 하단 '탈퇴하기' 링크로만 진입한다 —
                // 되돌릴 수 없는 동작이라 마이페이지 메뉴에 노출하지 않는다.
                MyMenuRow(
                  icon: RenewIcons.logout,
                  label: '로그아웃',
                  danger: true,
                  last: true,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
          SizedBox(height: kMySectionGap.h),

          const AppVersionLabel(),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    // 다이얼로그는 루트 Navigator에 떠서 스크림이 floating 바텀 nav까지 덮는다
    // → 예전 바텀시트처럼 nav를 따로 내렸다 올릴 필요가 없다.
    final confirmed = await VybeConfirmDialog.show(
      context,
      title: '로그아웃할까요?',
      message: '언제든 다시 로그인할 수 있어요.',
      confirmLabel: '로그아웃',
    );
    if (!confirmed) return;

    // 로그아웃하면 AuthGate가 루트를 WelcomeScreen으로 교체하고
    // 그 위에 쌓인 라우트를 전부 정리한다.
    await ref.read(authViewModelProvider.notifier).signOut();
  }
}

// ============ 프로필 행 (MRProfile) ============

class _Profile extends StatelessWidget {
  final String name;
  final String imageUrl;

  /// 디자인의 `@handle` 자리 — 스키마에 없어 가입 방식으로 대체.
  final String subtitle;

  final VoidCallback? onEdit;

  const _Profile({
    required this.name,
    required this.imageUrl,
    required this.subtitle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MyAvatar(name: name, imageUrl: imageUrl),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name.isEmpty ? ' ' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VybeTypography.heading4.copyWith(
                  fontSize: 21.sp,
                  color: RenewGlass.t1,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RenewGlass.body(color: RenewGlass.t4),
                ),
              ],
              SizedBox(height: 12.h),
              _EditPill(onTap: onEdit),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditPill extends StatelessWidget {
  final VoidCallback? onTap;

  const _EditPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: RenewGlass.tileFill,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: RenewGlass.tileBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '프로필 수정',
                style: VybeTypography.button2.copyWith(color: RenewGlass.t1),
              ),
              SizedBox(width: 5.w),
              const RenewChevron(
                dir: RenewChevronDir.right,
                size: 13,
                color: RenewGlass.t1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ 통계 카드 (MRStats) ============

class _Stats extends StatelessWidget {
  final int? reviewCount;
  final int? savedCount;
  final VoidCallback onReviews;
  final VoidCallback onSaved;

  const _Stats({
    required this.reviewCount,
    required this.savedCount,
    required this.onReviews,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return RenewGlassCard(
      quiet: true,
      padding: 0,
      child: IntrinsicHeight(
        child: Row(
          children: [
            _cell('리뷰', reviewCount, onReviews),
            // 구분선은 위아래 12씩 띄워 카드 모서리까지 닿지 않게 한다.
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const VerticalDivider(
                width: 1,
                thickness: 1,
                color: RenewGlass.hair,
              ),
            ),
            _cell('찜', savedCount, onSaved),
          ],
        ),
      ),
    );
  }

  Widget _cell(String label, int? value, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value?.toString() ?? '-',
                style: VybeTypography.heading4.copyWith(
                  fontSize: 22.sp,
                  color: RenewGlass.t1,
                ),
              ),
              SizedBox(height: 6.h),
              Text(label, style: RenewGlass.caption(lineHeight: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
