// 가입·로그인 플로우 공용 조각
// - 진행 중인 로그인 방식 (SignupMethod)
// - 전화번호 주인 판정 결과 (PhoneAccountStatus / PhoneAccountCheck)
// - 막힌 번호 안내 문구 (phoneBlockedMessage)
// - 인증 완료 후 홈 진입 (enterHomeAfterAuth)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vybe/presentation/home/viewmodels/banner_viewmodel.dart';

/// 지금 진행 중인 가입/로그인 방식.
///
/// [key] 는 `users.provider` 와 **같은 값**이어야 한다 — 서버가 이 값으로
/// '같은 방식의 재로그인'인지 판정한다.
enum SignupMethod {
  identity('identity'),
  kakao('kakao'),
  naver('naver'),
  apple('apple');

  const SignupMethod(this.key);

  final String key;
}

/// 주민등록번호 뒷자리 첫 숫자 → `users.gender` 에 저장할 키.
/// 1·3·5·7 = 남, 2·4·6·8 = 여 (1·2 1900년대 / 3·4 2000년대 / 5~8 외국인).
///
/// 저장은 **영문 키만** — 화면 문구를 바꿀 때 전 유저 문서를 손대지 않기 위해서다
/// (`provider` · `facilities` 와 같은 규칙). 한글 라벨은 화면에서 붙인다.
///
/// 알 수 없는 코드면 null 이고 **필드 자체를 쓰지 않는다** — 빈 문자열로
/// 채우면 나중에 '미입력'과 구분할 수 없다.
String? genderFromCode(String code) {
  final n = int.tryParse(code);
  if (n == null || n < 1 || n > 8) return null;
  return n.isOdd ? 'male' : 'female';
}

/// 전화번호 주인 판정.
enum PhoneAccountStatus {
  /// 처음 보는 번호 — 그대로 가입 진행.
  available,

  /// 같은 방식으로 가입한 내 계정 — 가입이 아니라 **로그인**으로 진행.
  ownAccount,

  /// 다른 방식으로 이미 가입된 번호 — 막는다. 계정도 만들지 않는다.
  takenByOther,

  /// 탈퇴 대기인데 **되살릴 수 없는** 경우 — 남의 계정이거나 파기 시각이
  /// 이미 지났다. 보관 기간 안에 본인이 돌아온 경우는 [ownAccount] 로 온다
  /// (로그인하면 서버가 복구한다).
  pendingDeletion,
}

typedef PhoneAccountCheck = ({
  PhoneAccountStatus status,
  DateTime? purgeAt,

  /// 탈퇴 대기 계정인데 파기 전이라 **로그인하면 복구**되는 상태.
  /// [PhoneAccountStatus.ownAccount] 일 때만 true 가 될 수 있다.
  bool restorable,
});

/// 탈퇴 대기 계정이 복구될 예정일 때, 인증 화면으로 넘어가기 전 안내 문구.
const kAccountRestoreNotice = '탈퇴 대기 중인 계정이에요. 인증하면 계정이 복구됩니다';

/// 복구가 끝난 뒤 보여줄 문구.
const kAccountRestoredMessage = '계정이 복구되었어요. 다시 만나서 반가워요!';

/// 막힌 번호일 때 보여줄 문구.
///
/// 어떤 방식으로 가입됐는지는 **알려주지 않는다** — 번호만 넣어 보면 그 사람이
/// 카카오를 쓰는지 알아낼 수 있게 되므로. 탈퇴 대기만 예외로, 언제부터 다시
/// 쓸 수 있는지 모르면 사용자가 할 수 있는 게 없어 날짜를 알려준다.
String phoneBlockedMessage(PhoneAccountCheck check) {
  if (check.status != PhoneAccountStatus.pendingDeletion) {
    return '이미 존재하는 계정입니다.';
  }
  final purgeAt = check.purgeAt;
  // purgeAt 이 없으면 파기가 임박·진행 중이라 복구도 재가입도 지금은 안 된다.
  if (purgeAt == null) {
    return '탈퇴 처리 중인 계정입니다. 잠시 후 다시 시도해주세요.';
  }
  final m = purgeAt.month.toString().padLeft(2, '0');
  final d = purgeAt.day.toString().padLeft(2, '0');
  return '탈퇴 처리 중인 계정입니다. ${purgeAt.year}.$m.$d부터 다시 가입할 수 있어요';
}

/// 로그인/가입이 끝난 뒤 홈으로 들어간다.
///
/// 이 시점엔 이미 로그인 상태라 루트(AuthGate)가 MainScaffold로 바뀌어 있다.
/// 위에 쌓인 인증 플로우 라우트만 걷어내면 된다.
///
/// 홈 첫 화면이 배너부터 그리므로 이미지를 미리 받아 두고 넘어간다 —
/// 실패·지연은 삼킨다(홈 진입을 이것 때문에 막지 않는다).
Future<void> enterHomeAfterAuth(BuildContext context, WidgetRef ref) async {
  try {
    final banners = await ref
        .read(bannerListProvider.future)
        .timeout(const Duration(seconds: 6));
    if (!context.mounted) return;
    await Future.wait(
      banners.map((b) async {
        try {
          await precacheImage(NetworkImage(b.imageUrl), context)
              .timeout(const Duration(seconds: 6));
        } catch (_) {}
      }),
    );
  } catch (_) {}
  if (!context.mounted) return;
  Navigator.popUntil(context, (route) => route.isFirst);
}
