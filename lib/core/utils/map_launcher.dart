import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 네이버 지도로 길찾기를 연다.
///
/// 앱이 설치돼 있으면 `nmap://` 스킴으로 바로 경로 화면을 열고,
/// 실패하면 웹 지도(map.naver.com)로 폴백한다.
Future<void> launchDirections(
  BuildContext context, {
  required double lat,
  required double lng,
  required String name,
}) async {
  if (lat == 0 && lng == 0) {
    VybeToast.show(context, message: '위치 정보가 없습니다', isError: true);
    return;
  }

  final encodedName = Uri.encodeComponent(name);
  final appUri = Uri.parse(
    'nmap://route/public?dlat=$lat&dlng=$lng&dname=$encodedName'
    '&appname=com.justinchoi.vybe',
  );
  final webUri = Uri.parse(
    'https://map.naver.com/p/directions/-/$lng,$lat,$encodedName/-/transit',
  );

  // canLaunchUrl은 Android queries 설정에 걸려 false를 줄 수 있어 바로 시도한다.
  final opened = await launchUrl(
    appUri,
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);
  if (opened) return;

  final fallback = await launchUrl(
    webUri,
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);
  if (!fallback && context.mounted) {
    VybeToast.show(context, message: '지도 앱을 열 수 없습니다', isError: true);
  }
}
