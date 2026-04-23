void logFirebaseAccess({
  required String file,
  required String service,
  required String purpose,
}) {
  // ignore: avoid_print
  print('[Firebase] 접근 파일: $file / 접근 서비스: $service / 사용 데이터 목적: $purpose');
}
