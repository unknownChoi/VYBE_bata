import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 전화번호로 기기 전화 앱을 연다.
///
/// 번호가 비었거나 전화 앱을 열 수 없는 기기(시뮬레이터·태블릿 등)면
/// 토스트로 안내만 하고 조용히 종료한다.
Future<void> launchPhoneCall(BuildContext context, String phone) async {
  void notify(String message) {
    if (!context.mounted) return;
    VybeToast.show(context, message: message, isError: true);
  }

  // 하이픈·공백 등 표시용 구분자 제거 (tel: 스킴은 숫자와 +만 허용).
  final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.isEmpty) {
    notify('등록된 전화번호가 없습니다');
    return;
  }

  final uri = Uri(scheme: 'tel', path: digits);
  // canLaunchUrl은 플랫폼 조회 권한(Android queries)에 걸려 false를 줄 수 있어
  // 먼저 시도하고, 실패했을 때만 안내한다.
  final launched = await launchUrl(uri).catchError((_) => false);
  if (!launched) {
    notify('전화 앱을 열 수 없습니다');
  }
}
