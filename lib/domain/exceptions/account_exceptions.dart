/// 탈퇴 대기(보관 기간) 중인 계정으로 로그인·가입을 시도했을 때.
///
/// Cloud Functions 가 `failed-precondition` + `details.purgeAt` 으로 거부한 것을
/// datasource 가 이 타입으로 바꿔 던진다. 화면은 `toString()` 을 그대로 토스트에
/// 띄우면 되도록 사용자 문구를 여기서 만든다.
class AccountPendingDeletionException implements Exception {
  /// 완전 파기 예정 시각 = 재가입 가능 시점. 서버가 안 실어 보내면 null.
  final DateTime? purgeAt;

  const AccountPendingDeletionException(this.purgeAt);

  @override
  String toString() {
    if (purgeAt == null) {
      return '탈퇴 처리 중인 계정입니다. 잠시 후 다시 시도해주세요.';
    }
    final d = purgeAt!;
    final date = '${d.year}.${_two(d.month)}.${_two(d.day)}';
    return '탈퇴 처리 중인 계정입니다. $date 이후 다시 가입할 수 있어요.';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
