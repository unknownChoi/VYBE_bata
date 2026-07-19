import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/user_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/widgets/ambient_backdrop.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/profile/viewmodels/user_viewmodel.dart';

// ============================================================
// 내 정보 수정 화면 (my.html 디자인 기반)
//
// 디자인과 다른 점: 디자인의 아이디·한 줄 소개·성별·활동 지역 필드는
// users 스키마(uid/name/phone/birthDate/…)에 없어 제외 —
// 수정 가능한 값은 닉네임뿐이고 전화번호·생년월일은 본인인증 값이라
// 읽기 전용으로 표시한다. 프로필 사진 변경은 image_picker 미도입으로 보류.
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
      backgroundColor: VybeColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackdrop()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SubScreenHeader(title: '내 정보 수정'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              MyAvatar(
                                name: widget.user.name,
                                imageUrl: widget.user.profileImageUrl,
                                size: 92,
                                ring: false,
                              ),
                              Positioned(
                                right: -2.r,
                                bottom: -2.r,
                                child: GestureDetector(
                                  onTap: () => VybeToast.show(context,
                                      message: '사진 변경은 준비 중이에요'),
                                  child: Container(
                                    width: 32.r,
                                    height: 32.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: VybeColors.mainPurple500,
                                      border: Border.all(
                                        color: VybeColors.background,
                                        width: 3.r,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.photo_camera_outlined,
                                      size: 15.r,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 26.h),
                        _fieldLabel('닉네임'),
                        Container(
                          height: 50.h,
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: glassInputDecoration(),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _nameController,
                            style: VybeTypography.body3
                                .copyWith(color: Colors.white),
                            cursorColor: VybeColors.mainPurple500,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: '닉네임',
                              hintStyle: VybeTypography.body3
                                  .copyWith(color: VybeColors.gray600),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        _fieldLabel('생년월일'),
                        _readOnlyField(_birthLabel),
                        SizedBox(height: 18.h),
                        _fieldLabel('전화번호'),
                        _readOnlyField(
                          widget.user.phone.isEmpty ? '-' : widget.user.phone,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '생년월일·전화번호는 본인인증 정보라 변경할 수 없어요.',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12.sp,
                            color: VybeColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 저장 바
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: VybeColors.gray900)),
                  ),
                  child: GestureDetector(
                    onTap: _save,
                    child: Container(
                      height: 54.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _saving
                            ? VybeColors.mainPurpleDisabled
                            : VybeColors.mainPurple500,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: VybeColors.mainPurple500
                                .withValues(alpha: 0.4),
                            blurRadius: 24.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: Text(
                        _saving ? '저장 중…' : '저장하기',
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
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: VybeColors.gray500,
        ),
      ),
    );
  }

  Widget _readOnlyField(String value) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: glassInputDecoration(),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: VybeTypography.body3.copyWith(color: VybeColors.gray500),
      ),
    );
  }
}
