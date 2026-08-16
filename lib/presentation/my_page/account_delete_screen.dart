import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:vybe/presentation/common/renew/renew_button.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_confirm_dialog.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

// ============================================================
// 회원 탈퇴
//
// 탈퇴는 즉시 파기가 아니라 **soft delete** 다 — 서버가 리뷰·사진·찜을
// 노출에서 빼고(집계도 감산) 계정을 비활성으로 돌린 뒤, 30일 뒤에
// purgeDeletedUsers 스케줄이 완전히 지운다.
//
// 화면이 지켜야 할 것 두 가지
//  1. 무엇이 사라지는지 · 언제 완전히 지워지는지 · 언제 다시 가입할 수 있는지를
//     **탈퇴 전에** 다 보여준다. 되돌릴 수 없는 동작이라 사후 안내는 늦다.
//  2. 오탭으로 실행될 수 없게 한다 — 동의 체크 + 확인 다이얼로그 2단계.
// ============================================================

/// 서버(`RETENTION_DAYS`)와 같은 값. 문구용이라 판정에는 쓰지 않는다 —
/// 실제 파기 시각은 탈퇴 응답의 `purgeAt` 이 알려준다.
const int _kRetentionDays = 30;

/// 탈퇴 사유 선택지. 선택은 자유(안 고르면 빈 문자열로 전송).
const List<String> _kReasons = [
  '이용 빈도가 낮아서',
  '원하는 클럽 정보가 없어서',
  '앱 사용이 불편해서',
  '개인정보가 걱정돼서',
  '기타',
];

class AccountDeleteScreen extends ConsumerStatefulWidget {
  const AccountDeleteScreen({super.key});

  @override
  ConsumerState<AccountDeleteScreen> createState() =>
      _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends ConsumerState<AccountDeleteScreen> {
  String? _reason;
  bool _agreed = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RenewGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: VybeAurora()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MyPushHeader(title: '회원 탈퇴'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    kMyPagePad.w,
                    kMySectionGap.h,
                    kMyPagePad.w,
                    32.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _headline(),
                      SizedBox(height: 20.h),
                      _deletedItemsCard(),
                      SizedBox(height: 14.h),
                      _retentionCard(),
                      SizedBox(height: kMySectionGap.h),
                      const RenewSectionHead(
                        title: '탈퇴 이유를 알려주세요',
                        sub: '선택 사항이에요',
                      ),
                      _reasonChips(),
                      SizedBox(height: kMySectionGap.h),
                      _agreeRow(),
                    ],
                  ),
                ),
              ),
              MyBottomBar(
                child: RenewButton(
                  label: _submitting ? '탈퇴 처리 중…' : '회원 탈퇴하기',
                  variant: RenewButtonVariant.danger,
                  onTap: (_agreed && !_submitting) ? _confirm : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ 조각 ============

  Widget _headline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정말 떠나시나요?',
          style: VybeTypography.heading2.copyWith(color: RenewGlass.t1),
        ),
        SizedBox(height: 8.h),
        Text(
          '탈퇴하면 아래 정보가 즉시 보이지 않게 되고,\n'
          '$_kRetentionDays일 뒤에 완전히 삭제돼요.',
          style: VybeTypography.body2.copyWith(
            color: RenewGlass.t3,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 무엇이 사라지는지. 추상적으로 "모든 데이터"라고만 쓰면 사용자가
  /// 자기 리뷰가 지워지는 줄 모르고 누른다.
  Widget _deletedItemsCard() {
    const items = [
      ('프로필', '이름 · 프로필 사진 · 본인인증 정보'),
      ('내가 쓴 리뷰', '별점 · 후기 · 첨부 사진'),
      ('찜한 클럽', '저장해 둔 클럽 목록'),
      ('검색 기록', '최근 검색어'),
    ];

    return RenewGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 21.h, color: RenewGlass.hair),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 5.h, right: 10.w),
                  child: Container(
                    width: 5.r,
                    height: 5.r,
                    decoration: const BoxDecoration(
                      color: kMyDanger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].$1,
                        style: VybeTypography.body2.copyWith(
                          color: RenewGlass.t1,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        items[i].$2,
                        style: VybeTypography.caption.copyWith(
                          color: RenewGlass.t4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 30일 보관과 재가입 제한. 둘 다 탈퇴 후에 알면 늦는 정보다.
  Widget _retentionCard() {
    return RenewGlassCard(
      quiet: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _noteLine(
            '탈퇴 즉시 리뷰·사진이 다른 사용자에게 보이지 않아요.',
          ),
          SizedBox(height: 9.h),
          _noteLine(
            '데이터는 $_kRetentionDays일간 보관된 뒤 완전히 삭제돼요.',
          ),
          SizedBox(height: 9.h),
          _noteLine(
            '보관 기간에는 같은 계정·전화번호로 다시 가입할 수 없어요.',
          ),
        ],
      ),
    );
  }

  Widget _noteLine(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h, right: 8.w),
          child: Icon(
            Icons.info_outline_rounded,
            size: 14.r,
            color: RenewGlass.t4,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: VybeTypography.caption.copyWith(
              color: RenewGlass.t3,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reasonChips() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final reason in _kReasons)
          GestureDetector(
            onTap: () => setState(
              () => _reason = _reason == reason ? null : reason,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: _reason == reason
                    ? VybeColors.mainPurple500
                    : RenewGlass.tileFill,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: _reason == reason
                      ? Colors.transparent
                      : RenewGlass.tileBorder,
                ),
              ),
              child: Text(
                reason,
                style: VybeTypography.caption.copyWith(
                  color: _reason == reason ? Colors.white : RenewGlass.t3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 동의 체크 — 버튼 활성 조건. 오탭 한 번으로 계정이 사라지면 안 된다.
  Widget _agreeRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _agreed = !_agreed),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 21.r,
            height: 21.r,
            decoration: BoxDecoration(
              color: _agreed ? VybeColors.mainPurple500 : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: _agreed ? Colors.transparent : RenewGlass.tileBorder,
              ),
            ),
            child: _agreed
                ? Icon(Icons.check_rounded, size: 15.r, color: Colors.white)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                '위 내용을 확인했으며, 데이터가 삭제되는 것에 동의합니다.',
                style: VybeTypography.caption.copyWith(
                  color: RenewGlass.t2,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ 동작 ============

  Future<void> _confirm() async {
    final confirmed = await VybeConfirmDialog.show(
      context,
      title: '정말 탈퇴할까요?',
      message: '탈퇴하면 되돌릴 수 없어요.\n'
          '$_kRetentionDays일간 같은 계정으로 다시 가입할 수 없습니다.',
      confirmLabel: '탈퇴하기',
    );
    if (!confirmed || !mounted) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(authViewModelProvider.notifier)
          .deleteAccount(_reason ?? '');

      // 성공하면 uid가 null이 되어 AuthGate가 루트를 WelcomeScreen으로 갈아끼우고
      // 그 위에 쌓인 라우트를 정리한다 — 여기서 pop 할 필요가 없다.
      if (!mounted) return;
      VybeToast.show(context, message: '탈퇴가 완료됐어요');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      VybeToast.show(context, message: e.toString(), isError: true);
    }
  }
}
