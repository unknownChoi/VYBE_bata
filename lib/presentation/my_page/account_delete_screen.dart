import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/auth/terms/terms_detail_screen.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_dialog.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';
import 'package:vybe/presentation/my_page/viewmodels/my_page_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/account_delete_parts.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';

// ============================================================
// 회원 탈퇴 — 만류 화면 (디자인 account_delete.html)
//
// 탈퇴는 즉시 파기가 아니라 **soft delete** 다 — 서버가 리뷰·사진·찜을
// 노출에서 빼고(집계도 감산) 계정을 비활성으로 돌린 뒤, 30일 뒤에
// purgeDeletedUsers 스케줄이 완전히 지운다.
//
// 화면이 지켜야 할 것 세 가지
//  1. **무엇을 잃는지 숫자로** 보여준다 — 내 찜 12곳·리뷰 7개가 사라진다는 걸
//     알고 누르는 것과 "모든 데이터 삭제"만 읽고 누르는 것은 다르다.
//  2. 언제 완전히 지워지고 언제 다시 가입할 수 있는지를 **탈퇴 전에** 다 말한다.
//  3. 오탭으로 실행될 수 없게 한다 — 주 버튼은 '계속 이용하기'이고,
//     탈퇴는 동의 체크 + 밑줄 링크 + 확인 다이얼로그 3단계를 지나야 한다.
//
// 디자인과 다른 점
// - 시안의 '30일 안에는 재가입할 수 있어요'는 서버 동작과 달라 고쳤다.
//   보관 기간에 **새로 가입하는 건** 막히고(`checkPhoneDuplicate` →
//   pendingDeletion), 대신 같은 계정으로 다시 로그인하면 서버가 계정을
//   되살린다(`restorePendingDeletionOnLogin`). 새 가입은 파기일 이후.
// - 사유 카드의 '클럽 제보하기'·'의견 보내기' 버튼은 뺐다 — 보낼 곳이 없다.
// - 상단바는 앱의 다른 마이 하위 화면과 같은 [MyPushHeader](가운데 제목).
// - 좌우 여백은 시안 16 대신 마이 하위 화면 공통값(24)을 쓴다.
// ============================================================

/// 디자인 ADSection 사이 간격.
const double _kSectionGap = 26;

class AccountDeleteScreen extends ConsumerStatefulWidget {
  const AccountDeleteScreen({super.key});

  @override
  ConsumerState<AccountDeleteScreen> createState() =>
      _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends ConsumerState<AccountDeleteScreen> {
  /// 선택한 사유 = [LeaveReason.key] (그대로 서버 `deletionReason`으로 간다).
  String? _reason;
  bool _agreed = false;
  bool _submitting = false;

  /// 미동의 상태로 탈퇴를 눌렀을 때 체크 행을 흔든다.
  int _nudgeTick = 0;
  bool _nudging = false;

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    final user = uid == null ? null : ref.watch(currentUserProvider(uid)).value;
    final reviews = ref.watch(myReviewsProvider).value;
    final savedCount = ref.watch(savedClubsProvider).value?.length;

    // 리뷰 사진 수는 이미 받아온 목록에서 세면 된다 — 별도 조회 없음.
    final photoCount = reviews?.fold<int>(
      0,
      (sum, e) => sum + e.review.imageUrls.length,
    );

    final purgeDate = DateTime.now().add(
      const Duration(days: kLeaveRetentionDays),
    );

    return Scaffold(
      backgroundColor: RenewGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MyPushHeader(title: '회원 탈퇴'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    kMyPagePad.w,
                    0,
                    kMyPagePad.w,
                    34.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LeaveHeadline(
                        name: user?.name ?? '',
                        joined: _joinedDate(user?.createdAt),
                      ),
                      LeaveStatCard(
                        savedCount: savedCount,
                        reviewCount: reviews?.length,
                        photoCount: photoCount,
                      ),
                      SizedBox(height: _kSectionGap.h),
                      const LeaveSection(
                        title: '놓치게 되는 것',
                        sub: '탈퇴하면 아래 정보는 더 이상 볼 수 없어요.',
                        child: LeaveBenefitList(),
                      ),
                      SizedBox(height: _kSectionGap.h),
                      LeaveSection(
                        title: '탈퇴 후 $kLeaveRetentionDays일',
                        sub: '보관 기간이 끝나면 계정과 기록이 완전히 사라져요.',
                        child: LeaveTimelineCard(
                          leaveDate: DateTime.now(),
                          purgeDate: purgeDate,
                        ),
                      ),
                      SizedBox(height: _kSectionGap.h),
                      LeaveSection(
                        title: '떠나시는 이유를 알려 주세요',
                        sub: '이유에 맞는 방법이 따로 있을 수도 있어요.',
                        child: LeaveReasonPicker(
                          selected: _reason,
                          onSelect: (key) => setState(() => _reason = key),
                          onCta: _onReasonCta,
                        ),
                      ),
                      SizedBox(height: _kSectionGap.h),
                      LeaveAgreeRow(
                        checked: _agreed,
                        nudgeTick: _nudgeTick,
                        onTap: () => setState(() => _agreed = !_agreed),
                      ),
                      SizedBox(height: 22.h),
                      LeaveActions(
                        agreed: _agreed,
                        submitting: _submitting,
                        nudging: _nudging,
                        onStay: () => Navigator.of(context).maybePop(),
                        onLeave: () =>
                            _tryLeave(purgeDate, reviews?.length, savedCount),
                      ),
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

  // ============ 조각 ============

  /// 가입일이 **믿을 수 있는 값일 때만** 돌려준다.
  ///
  /// `users.createdAt`이 비어 있는 문서가 아직 많고(백필 전),
  /// [UserModel.fromFirestore]는 그 자리를 `DateTime.now()`로 메운다.
  /// 그대로 쓰면 오래된 계정이 "오늘부터 쌓은 기록"으로 읽힌다.
  /// 오늘 가입한 사람은 날짜가 빠지지만 문장은 그대로 성립한다.
  DateTime? _joinedDate(DateTime? createdAt) {
    if (createdAt == null) return null;
    if (DateTime.now().difference(createdAt) < const Duration(days: 1)) {
      return null;
    }
    return createdAt;
  }

  // ============ 동작 ============

  void _onReasonCta(LeaveReasonCta cta) {
    switch (cta) {
      case LeaveReasonCta.settings:
        // 이 화면의 유일한 진입점이 설정 하단 '탈퇴하기' 링크라 뒤로 가면
        // 곧 알림 설정이다. 새로 push하면 설정 화면이 두 번 쌓이는 데다,
        // 알림 토글이 화면 안에만 있는 상태라 초기값으로 돌아간 사본이 열린다.
        // (다른 곳에서 이 화면을 열게 되면 이 분기부터 손볼 것)
        Navigator.of(context).maybePop();
      case LeaveReasonCta.privacy:
        pushHidingNavBar<void>(
          context,
          const TermsDetailScreen(doc: LegalDoc.privacy),
        );
      case LeaveReasonCta.none:
        break;
    }
  }

  void _tryLeave(DateTime purgeDate, int? reviewCount, int? savedCount) {
    if (_submitting) return;
    if (!_agreed) {
      setState(() {
        _nudgeTick++;
        _nudging = true;
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _nudging = false);
      });
      return;
    }
    _confirm(purgeDate, reviewCount, savedCount);
  }

  Future<void> _confirm(
    DateTime purgeDate,
    int? reviewCount,
    int? savedCount,
  ) async {
    // 숫자를 아직 못 받았으면 그 문장을 빼고 남은 사실만 말한다.
    final lost = (reviewCount == null || savedCount == null)
        ? '작성한 리뷰와 찜한 클럽이 지금 사라져요.'
        : '리뷰 $reviewCount개와 찜 $savedCount곳이 지금 사라져요.';

    final confirmed = await VybeConfirmDialog.show(
      context,
      title: '탈퇴를 진행할까요?',
      message:
          '$lost\n'
          '${leaveDateLabel(purgeDate)}까지는 같은 번호로\n다시 가입할 수 없어요.',
      icon: const LeaveDialogIcon(),
      // 권하는 쪽은 '더 써볼게요' — 그래서 취소가 채운 버튼이다.
      cancelLabel: '더 써볼게요',
      cancelTone: VybeConfirmTone.primary,
      confirmLabel: '탈퇴',
      tone: VybeConfirmTone.dangerQuiet,
    );
    if (!confirmed || !mounted) return;

    // 완료 안내는 라우트가 아니라 **오버레이**로 띄운다 — 탈퇴가 끝나면
    // 세션이 끊겨 AuthGate가 루트 위 라우트를 전부 걷어내기 때문에
    // (이 화면 포함) 화면으로 띄우면 뜨자마자 사라진다.
    // OverlayState는 반드시 await 전에 잡아 둔다.
    final overlay = Overlay.of(context, rootOverlay: true);

    setState(() => _submitting = true);
    try {
      final purgeAt = await ref
          .read(authViewModelProvider.notifier)
          .deleteAccount(_reason ?? '');

      // 성공하면 uid가 null이 되어 AuthGate가 루트를 WelcomeScreen으로 갈아끼우고
      // 그 위에 쌓인 라우트를 정리한다 — 여기서 pop 할 필요가 없다.
      // 파기 시각은 서버가 돌려준 값을 그대로 쓴다(로컬 +30일 추정이 아니라).
      LeaveDoneOverlay.show(overlay, purgeAt);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      VybeToast.show(context, message: e.toString(), isError: true);
    }
  }
}
