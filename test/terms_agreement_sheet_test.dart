import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/terms_agreement.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/auth/widgets/terms_agreement_sheet.dart';

/// 약관 동의 시트가 **항목별 동의 여부**를 그대로 넘기는지.
///
/// 화면 모양이 아니라 저장될 값이 관심사다 — 선택 항목을 안 눌렀을 때 키가
/// 빠지면 `users.agreements` 에서 '비동의'와 '아직 안 물어봤다'가 섞인다.
///
/// 시트는 실제와 같이 `showModalBottomSheet` 로 띄운다 — '확인'이
/// `Navigator.pop` 을 먼저 부르기 때문에 걷어낼 라우트가 있어야 한다.

/// 시트를 띄우고, '확인'까지 눌렀을 때 콜백이 받은 값을 돌려준다.
/// 콜백이 안 불렸으면 null (= 필수 항목 미체크로 버튼이 죽어 있음).
Future<Map<String, TermsAgreementInput>?> pumpSheet(
  WidgetTester tester, {
  required List<String> uncheckAfterAll,
}) async {
  Map<String, TermsAgreementInput>? captured;
  late BuildContext ctx;

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) => MaterialApp(home: child),
      child: Builder(
        builder: (context) {
          ctx = context;
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ),
  );
  await tester.pump();

  showModalBottomSheet<void>(
    context: ctx,
    isScrollControlled: true,
    builder: (_) => TermsAgreementSheet(
      onConfirmed: (agreements) async => captured = agreements,
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('전체 동의하기'));
  await tester.pump();
  for (final label in uncheckAfterAll) {
    await tester.tap(find.textContaining(label));
    await tester.pump();
  }
  await tester.tap(find.text('확인'));
  await tester.pumpAndSettle();

  return captured;
}

void main() {
  testWidgets('전체 동의하면 5개 항목이 전부 agreed=true 로 넘어간다', (tester) async {
    final captured = await pumpSheet(tester, uncheckAfterAll: const []);

    expect(captured, isNotNull);
    expect(captured!.keys.toSet(), {
      LegalDoc.terms.name,
      LegalDoc.privacy.name,
      LegalDoc.location.name,
      LegalDoc.marketing.name,
      kAgreementAge19,
    });
    expect(captured.values.every((v) => v.agreed), isTrue);
    // 문서가 있는 항목엔 개정일이 실린다. 만 19세 확인은 읽을 문서가 없어 빈 값.
    expect(captured[LegalDoc.terms.name]!.version, LegalDoc.terms.version);
    expect(captured[kAgreementAge19]!.version, '');
  });

  testWidgets('마케팅(선택)만 빼도 확인이 눌리고, agreed=false 로 기록된다', (tester) async {
    final captured = await pumpSheet(
      tester,
      uncheckAfterAll: const ['마케팅 정보 수신 동의'],
    );

    expect(captured, isNotNull);
    // 키는 그대로 5개 — 빠지면 '거부'와 '안 물어봤다'가 구분되지 않는다.
    expect(captured!.length, 5);
    expect(captured[LegalDoc.marketing.name]!.agreed, isFalse);
    expect(captured[LegalDoc.terms.name]!.agreed, isTrue);
  });

  testWidgets('필수 항목이 하나라도 빠지면 확인이 안 눌린다', (tester) async {
    final captured = await pumpSheet(
      tester,
      uncheckAfterAll: const ['위치기반서비스 이용 동의'],
    );

    expect(captured, isNull);
  });
}
