import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_agreement.freezed.dart';

/// 약관 동의 기록 한 건 — `users/{uid}.agreements[key]` 에 저장되는 값.
///
/// 왜 서브컬렉션이 아니라 users 문서 안의 map 인가 —
/// 항목이 5개로 고정이고 프로필과 **항상 같이** 읽힌다. 서브컬렉션이면
/// 마이페이지에서 동의 현황을 보여줄 때마다 쿼리가 한 번 더 나간다.
///
/// ⚠ **덮어쓰기 방식이라 이력이 남지 않는다.** 마케팅 동의를 껐다 켜면
///    직전 상태는 사라지고 마지막 값만 남는다. 수신동의 철회 이력까지
///    보관해야 하면 `users/{uid}/agreementLogs` 를 따로 둘 것.
@freezed
abstract class TermsAgreement with _$TermsAgreement {
  const TermsAgreement._();

  const factory TermsAgreement({
    /// 동의 여부. 선택 항목을 체크하지 않았으면 false 로 **기록한다** —
    /// 필드를 빼면 '비동의'와 '아직 안 물어봤다'가 구분되지 않는다.
    required bool agreed,

    /// 동의한 문서의 개정일(`LegalDoc.version`). 읽을 문서가 없는 확인
    /// 항목([kAgreementAge19])은 빈 문자열.
    required String version,

    /// 동의(또는 철회)한 시각. 서버 시각으로 쓴다.
    DateTime? agreedAt,
  }) = _TermsAgreement;

  factory TermsAgreement.fromMap(Map<String, dynamic> data) => TermsAgreement(
    agreed: data['agreed'] as bool? ?? false,
    version: data['version'] as String? ?? '',
    agreedAt: (data['agreedAt'] as Timestamp?)?.toDate(),
  );
}

/// 화면이 만들어 넘기는 동의 입력값.
///
/// 문서 원문·개정일은 presentation(`legal_documents.dart`)에 있고 datasource 는
/// 그걸 import 할 수 없다(레이어 규칙) → 버전까지 실어서 내려보낸다.
typedef TermsAgreementInput = ({bool agreed, String version});

/// 읽을 문서가 없는 확인 항목 — 만 19세 이상.
///
/// `LegalDoc` 에 넣을 수 없어(전문이 없다) 키를 여기에 둔다.
/// 나머지 키는 `LegalDoc.name`(`terms`·`privacy`·`location`·`marketing`).
const kAgreementAge19 = 'age19';

/// Firestore 의 `agreements` map → 모델 map.
/// 필드가 없는 기존 유저는 빈 map (동의 기록 도입 전 가입자).
Map<String, TermsAgreement> parseAgreements(Object? raw) {
  if (raw is! Map) return const {};
  return {
    for (final entry in raw.entries)
      if (entry.value is Map)
        entry.key as String: TermsAgreement.fromMap(
          Map<String, dynamic>.from(entry.value as Map),
        ),
  };
}
