import 'dart:math';

import 'package:flutter/services.dart';

/// 숫자 입력을 010-XXXX-XXXX 형식으로 자동 변환하는 TextInputFormatter
///
/// - 숫자 이외 문자는 자동 제거
/// - 최대 11자리(하이픈 제외)까지 입력 허용
class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 숫자만 추출 후 11자리 제한
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.substring(0, min(digits.length, 11));

    // 자리수에 따라 하이픈 삽입
    final String formatted;
    if (limited.length <= 3) {
      formatted = limited;
    } else if (limited.length <= 7) {
      formatted = '${limited.substring(0, 3)}-${limited.substring(3)}';
    } else {
      formatted =
          '${limited.substring(0, 3)}-${limited.substring(3, 7)}-${limited.substring(7)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
