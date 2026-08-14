import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 앱 스토어(Play 스토어 / App Store)를 연다.
///
/// [storeUrl] 은 서버(`appConfig/{platform}.storeUrl`)에서 받은 값 —
/// 앱 배포 없이 링크를 바꿀 수 있게 하드코딩하지 않는다.
/// 비어 있으면 Android만 패키지명으로 폴백한다(iOS는 앱 ID를 알 수 없음).
Future<void> launchStore(
  BuildContext context, {
  required String storeUrl,
  String packageName = '',
}) async {
  void notify(String message) {
    if (!context.mounted) return;
    VybeToast.show(context, message: message, isError: true);
  }

  final target = storeUrl.trim().isNotEmpty
      ? storeUrl.trim()
      : (Platform.isAndroid && packageName.isNotEmpty
          ? 'market://details?id=$packageName'
          : '');

  if (target.isEmpty) {
    notify('스토어 링크가 설정되지 않았습니다');
    return;
  }

  final uri = Uri.tryParse(target);
  if (uri == null) {
    notify('스토어를 열 수 없습니다');
    return;
  }

  // canLaunchUrl은 Android queries 권한에 걸려 false를 줄 수 있어 먼저 시도한다.
  final launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);
  if (!launched) {
    notify('스토어를 열 수 없습니다');
  }
}
