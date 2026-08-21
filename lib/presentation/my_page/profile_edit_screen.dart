import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/user_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/renew/renew_button.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';

// ============================================================
// 내 정보 수정 — 리뉴얼 (my_renew.html · MREditScreen)
//
// 디자인과 다른 점: 디자인의 아이디·한 줄 소개·성별·활동 지역 필드는
// users 스키마(uid/name/phone/birthDate/…)에 없어 제외 —
// 수정 가능한 값은 닉네임뿐이고 전화번호·생년월일은 본인인증 값이라
// 읽기 전용으로 표시한다. 프로필 사진 변경은 아직 미연결(준비 중 토스트).
// ============================================================

class ProfileEditScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 생년월일 YYYYMMDD → YYYY.MM.DD 표기.
  String get _birthLabel {
    final b = widget.user.birthDate;
    if (b.length != 8) return b.isEmpty ? '-' : b;
    return '${b.substring(0, 4)}.${b.substring(4, 6)}.${b.substring(6)}';
  }

  Future<void> _save() async {
    final uid = ref.read(currentUidProvider);
    final name = _nameController.text.trim();
    if (uid == null || name.isEmpty || _saving) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(userViewModelProvider.notifier)
          .updateProfile(uid: uid, name: name);
      if (!mounted) return;
      Navigator.of(context).pop();
      VybeToast.show(context, message: '프로필을 저장했어요');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      VybeToast.show(context, message: '저장에 실패했어요. 다시 시도해 주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RenewGlass.ink,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MyPushHeader(title: '내 정보 수정'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: kMyPagePad.w,
                vertical: 24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _avatar()),
                  SizedBox(height: 24.h),
                  MyField(
                    label: '닉네임',
                    child: TextField(
                      controller: _nameController,
                      style: VybeTypography.body3.copyWith(
                        color: RenewGlass.t1,
                      ),
                      cursorColor: VybeColors.mainPurple500,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '닉네임',
                        hintStyle: VybeTypography.body3.copyWith(
                          color: RenewGlass.t4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  MyField(label: '생년월일', child: _readOnly(_birthLabel)),
                  SizedBox(height: 16.h),
                  MyField(
                    label: '전화번호',
                    child: _readOnly(
                      widget.user.phone.isEmpty ? '-' : widget.user.phone,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const RenewFooterNote(text: '생년월일·전화번호는 본인인증 정보라 변경할 수 없어요.'),
                ],
              ),
            ),
          ),
          MyBottomBar(
            child: RenewButton(
              label: _saving ? '저장 중…' : '저장하기',
              onTap: _saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }

  /// 아바타 + 사진 변경 뱃지. 뱃지는 원 밖으로 살짝 걸치게 둔다(디자인 -2).
  Widget _avatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        MyAvatar(
          name: _nameController.text.isEmpty
              ? widget.user.name
              : _nameController.text,
          imageUrl: widget.user.profileImageUrl,
          size: 92,
          ring: false,
        ),
        Positioned(
          right: -2.r,
          bottom: -2.r,
          child: GestureDetector(
            onTap: () => VybeToast.show(context, message: '사진 변경은 준비 중이에요'),
            child: Container(
              width: 32.r,
              height: 32.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VybeColors.mainPurple500,
                border: Border.all(color: RenewGlass.ink, width: 3.r),
              ),
              child: const RenewIcon(
                path: RenewIcons.camera,
                size: 14,
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnly(String value) =>
      Text(value, style: VybeTypography.body3.copyWith(color: RenewGlass.t4));
}
