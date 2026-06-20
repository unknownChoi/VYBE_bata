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
            _SectionHeader('Button'),
            _Label('Default'),
            VybeButton(label: '버튼', onTap: () {}),
            SizedBox(height: 12.h),
            _Label('Special (라임 테두리)'),
            VybeButton(label: '버튼', onTap: () {}, variant: VybeButtonVariant.special),
            SizedBox(height: 12.h),
            _Label('withKeyboard (radius 없음)'),
            VybeButton(label: '버튼', onTap: () {}, variant: VybeButtonVariant.withKeyboard),
            SizedBox(height: 12.h),
            _Label('Disabled'),
            VybeButton(label: '버튼', onTap: null),
            SizedBox(height: 12.h),
            _Label('TextButton'),
            VybeButton(label: '텍스트 버튼', onTap: () {}, variant: VybeButtonVariant.textButton),
            _Divider(),

            // ─────────────────── TextField ───────────────────
            _SectionHeader('TextField'),
            _Label('Default (입력해보세요)'),
            VybeTextField(
              hint: 'placeholder',
              controller: _textController,
              onClear: () => setState(() {}),
            ),
            SizedBox(height: 24.h),
            _Label('Error'),
            VybeTextField(
              hint: 'placeholder',
              controller: _errorController,
              errorText: '상태 관련 메시지를 입력하세요.',
              onClear: () => setState(() {}),
            ),
            SizedBox(height: 24.h),
            _Label('Disabled'),
            VybeTextField(
              hint: 'placeholder',
              controller: _disabledController,
              label: 'label',
              enabled: false,
            ),
            _Divider(),

            // ─────────────────── Dropdown ───────────────────
            _SectionHeader('Dropdown'),
            _Label('Default'),
            VybeDropdown(
              hint: 'placeholder',
              items: const ['아이템 1', '아이템 2', '아이템 3'],
              value: _dropdownValue,
              onChanged: (val) => setState(() => _dropdownValue = val),
            ),
            SizedBox(height: 24.h),
            _Label('Error'),
            VybeDropdown(
              hint: 'placeholder',
              items: const ['아이템 1', '아이템 2'],
              value: null,
              onChanged: (val) => setState(() {}),
              errorText: '상태 관련 메시지를 입력하세요.',
            ),
            SizedBox(height: 24.h),
            _Label('Disabled'),
            const VybeDropdown(hint: 'placeholder', items: []),
            _Divider(),

            // ─────────────────── Status Message ───────────────────
            _SectionHeader('Status Message'),
            VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.'),
            SizedBox(height: 12.h),
            VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.', type: VybeStatusType.warn),
            SizedBox(height: 12.h),
            VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.', type: VybeStatusType.error),
            SizedBox(height: 12.h),
            VybeStatusMessage(message: '상태 관련 메시지를 입력하세요.', type: VybeStatusType.success),
            _Divider(),

            // ─────────────────── Page Title ───────────────────
            _SectionHeader('Page Title'),
            _Label('Default'),
            const VybePageTitle(highlightText: '타이틀', regularText: '을 입력해주세요.'),
            SizedBox(height: 24.h),
            _Label('With Caption'),
            const VybePageTitle(
              highlightText: '타이틀',
              regularText: '을 입력해주세요.',
              caption: '상태 관련 메시지를 입력하세요.',
              captionType: VybeStatusType.error,
            ),
            _Divider(),

            // ─────────────────── Select Item ───────────────────
            _SectionHeader('Select Item'),
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
            _SectionHeader('Certificate Input'),
            _Label('Default (탭해서 입력)'),
            VybeCertificateInput(
              controller: _certController,
              onCompleted: (val) => setState(() {}),
            ),
            SizedBox(height: 24.h),
            _Label('Error'),
            const VybeCertificateInput(errorText: '인증번호가 올바르지 않습니다.'),
            SizedBox(height: 24.h),
            _Label('Disabled'),
            const VybeCertificateInput(enabled: false),
            _Divider(),

            // ─────────────────── Checkbox ───────────────────
            _SectionHeader('Checkbox'),
            _Label('미선택'),
            VybeCheckbox(
              value: _checkbox1,
              onChanged: (val) => setState(() => _checkbox1 = val),
              label: '전체 동의하기',
            ),
            SizedBox(height: 16.h),
            _Label('선택됨'),
            VybeCheckbox(
              value: _checkbox2,
              onChanged: (val) => setState(() => _checkbox2 = val),
              label: '전체 동의하기',
            ),
            SizedBox(height: 16.h),
            _Label('Disabled'),
            const VybeCheckbox(value: false, onChanged: null, label: '전체 동의하기'),
            _Divider(),

            // ─────────────────── Terms List ───────────────────
            _SectionHeader('Terms List'),
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
      child: const Divider(color: Color(0xFF2F2F33), thickness: 1),
    );
  }
}
