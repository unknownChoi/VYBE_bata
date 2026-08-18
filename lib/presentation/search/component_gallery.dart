import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/widgets/vybe_button.dart';
import 'package:vybe/presentation/common/widgets/vybe_certificate_input.dart';
import 'package:vybe/presentation/common/widgets/vybe_checkbox.dart';
import 'package:vybe/presentation/common/widgets/vybe_dropdown.dart';
import 'package:vybe/presentation/common/widgets/vybe_page_title.dart';
import 'package:vybe/presentation/common/widgets/vybe_select_item.dart';
import 'package:vybe/presentation/common/widgets/vybe_status_message.dart';
import 'package:vybe/presentation/common/widgets/vybe_terms_list.dart';
import 'package:vybe/presentation/common/widgets/vybe_text_field.dart';

class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  // TextField
  final _textController = TextEditingController();
  final _errorController = TextEditingController(text: 'value');
  final _disabledController = TextEditingController(text: 'value');

  // Dropdown
  String? _dropdownValue;

  // Checkbox
  bool _checkbox1 = false;
  bool _checkbox2 = true;

  // Terms
  final _terms = const [
    VybeTermsItem(id: 'privacy', label: '개인정보 수집∙이용 동의', isRequired: true),
    VybeTermsItem(id: 'age', label: '만 19세 이상입니다', isRequired: true),
    VybeTermsItem(id: 'service', label: '서비스 이용약관 동의', isRequired: true),
    VybeTermsItem(id: 'marketing', label: '개인정보 마케팅 활용 동의', isRequired: false),
  ];
  Set<String> _checkedTerms = {};

  // Certificate
  final _certController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _errorController.dispose();
    _disabledController.dispose();
    _certController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      appBar: AppBar(
        backgroundColor: VybeColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Component Gallery',
          style: TextStyle(color: Colors.white, fontFamily: 'Pretendard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────── Button ───────────────────
            const _SectionHeader('Button'),
            const _Label('Default'),
            VybeButton(label: '버튼', onTap: () {}),
            SizedBox(height: 12.h),
            const _Label('Special (라임 테두리)'),
            VybeButton(label: '버튼', onTap: () {}, variant: VybeButtonVariant.special),
            SizedBox(height: 12.h),
            const _Label('withKeyboard (radius 없음)'),
            VybeButton(label: '버튼', onTap: () {}, variant: VybeButtonVariant.withKeyboard),
            SizedBox(height: 12.h),
            const _Label('Disabled'),
            const VybeButton(label: '버튼', onTap: null),
            SizedBox(height: 12.h),
            const _Label('TextButton'),
            VybeButton(label: '텍스트 버튼', onTap: () {}, variant: VybeButtonVariant.textButton),
            _Divider(),

            // ─────────────────── TextField ───────────────────
            const _SectionHeader('TextField'),
            const _Label('Default (입력해보세요)'),
            VybeTextField(
              hint: 'placeholder',
              controller: _textController,
              onClear: () => setState(() {}),
            ),
            SizedBox(height: 24.h),
            const _Label('Error'),
            VybeTextField(
              hint: 'placeholder',
              controller: _errorController,
              errorText: '상태 관련 메시지를 입력하세요.',
              onClear: () => setState(() {}),
            ),
            SizedBox(height: 24.h),
            const _Label('Disabled'),
            VybeTextField(
              hint: 'placeholder',
              controller: _disabledController,
              label: 'label',
              enabled: false,
            ),
            _Divider(),

            // ─────────────────── Dropdown ───────────────────
            const _SectionHeader('Dropdown'),
            const _Label('Default'),
            VybeDropdown(
              hint: 'placeholder',
              items: const ['아이템 1', '아이템 2', '아이템 3'],
              value: _dropdownValue,
              onChanged: (val) => setState(() => _dropdownValue = val),
            ),
            SizedBox(height: 24.h),
            const _Label('Error'),
            VybeDropdown(
              hint: 'placeholder',
              items: const ['아이템 1', '아이템 2'],
              value: null,
              onChanged: (val) => setState(() {}),
              errorText: '상태 관련 메시지를 입력하세요.',
            ),
            SizedBox(height: 24.h),
            const _Label('Disabled'),
            const VybeDropdown(hint: 'placeholder', items: []),
            _Divider(),

            // ─────────────────── Status Message ───────────────────
            const _SectionHeader('Status Message'),
            const VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.'),
            SizedBox(height: 12.h),
            const VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.', type: VybeStatusType.warn),
            SizedBox(height: 12.h),
            const VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.', type: VybeStatusType.error),
            SizedBox(height: 12.h),
            const VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.', type: VybeStatusType.success),
            _Divider(),

            // ─────────────────── Page Title ───────────────────
            const _SectionHeader('Page Title'),
            const _Label('Default'),
            const VybePageTitle(highlightText: '타이틀', regularText: '을 입력해주세요.'),
            SizedBox(height: 24.h),
            const _Label('With Caption'),
            const VybePageTitle(
              highlightText: '타이틀',
              regularText: '을 입력해주세요.',
              caption: '상태 관련 메시지를 입력하세요.',
              captionType: VybeStatusType.error,
            ),
            _Divider(),

            // ─────────────────── Select Item ───────────────────
            const _SectionHeader('Select Item'),
            Container(
              decoration: BoxDecoration(
                color: VybeColors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  VybeSelectItem(label: '아이템', onTap: () {}),
                  VybeSelectItem(label: '아이템 (선택됨)', isSelected: true, onTap: () {}),
                  VybeSelectItem(label: '아이템', onTap: () {}),
                ],
              ),
            ),
            _Divider(),

            // ─────────────────── Certificate Input ───────────────────
            const _SectionHeader('Certificate Input'),
            const _Label('Default (탭해서 입력)'),
            VybeCertificateInput(
              controller: _certController,
              onCompleted: (val) => setState(() {}),
            ),
            SizedBox(height: 24.h),
            const _Label('Error'),
            const VybeCertificateInput(errorText: '인증번호가 올바르지 않습니다.'),
            SizedBox(height: 24.h),
            const _Label('Disabled'),
            const VybeCertificateInput(enabled: false),
            _Divider(),

            // ─────────────────── Checkbox ───────────────────
            const _SectionHeader('Checkbox'),
            const _Label('미선택'),
            VybeCheckbox(
              value: _checkbox1,
              onChanged: (val) => setState(() => _checkbox1 = val),
              label: '전체 동의하기',
            ),
            SizedBox(height: 16.h),
            const _Label('선택됨'),
            VybeCheckbox(
              value: _checkbox2,
              onChanged: (val) => setState(() => _checkbox2 = val),
              label: '전체 동의하기',
            ),
            SizedBox(height: 16.h),
            const _Label('Disabled'),
            const VybeCheckbox(value: false, onChanged: null, label: '전체 동의하기'),
            _Divider(),

            // ─────────────────── Terms List ───────────────────
            const _SectionHeader('Terms List'),
            VybeTermsList(
              items: _terms,
              checkedIds: _checkedTerms,
              onChanged: (id, isChecked) => setState(() {
                if (isChecked) {
                  _checkedTerms = {..._checkedTerms, id};
                } else {
                  _checkedTerms = _checkedTerms.where((e) => e != id).toSet();
                }
              }),
            ),

            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
          color: VybeColors.mainLime500,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
          fontSize: 12.sp,
          color: VybeColors.gray500,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: const Divider(color: VybeColors.gray900, thickness: 1),
    );
  }
}
