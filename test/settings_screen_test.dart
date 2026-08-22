import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/storage/local_prefs.dart';
import 'package:vybe/data/models/terms_agreement.dart';
import 'package:vybe/data/models/user_model.dart';
import 'package:vybe/data/repositories/user_repository_impl.dart';
import 'package:vybe/domain/repositories/user_repository.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/common/version_gate/viewmodels/version_check_viewmodel.dart';
import 'package:vybe/presentation/my_page/settings_screen.dart';
import 'package:vybe/presentation/my_page/viewmodels/settings_viewmodel.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/my_page/widgets/setting_row.dart';

/// 설정 화면 스모크 — 디자인 my_renew.html `MRSettingsScreen` 이식 확인.
///
/// 기기·서버를 타는 provider(캐시 용량·버전 조회)는 값을 고정해 화면만 본다.

class _FakeCache extends CacheManager {
  @override
  Future<int> build() async => 50528000; // 48.2MB
}

class _FakeVersion extends VersionCheck {
  @override
  Future<VersionCheckResult> build() async =>
      const VersionCheckResult.pass(currentVersion: '1.0.0');
}

/// 마케팅 토글이 읽는 곳 = `users.agreements.marketing`.
/// Firestore 를 타지 않도록 repository 를 갈아끼우고 쓰기 호출을 받아 둔다.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({required bool marketingAgreed})
    : _user = _userWith(marketingAgreed);

  UserModel _user;
  final _controller = StreamController<UserModel?>.broadcast();

  /// setAgreement 로 들어온 (키, 동의 여부) 기록.
  final List<({String key, bool agreed, String version})> writes = [];

  static UserModel _userWith(bool marketingAgreed) => UserModel(
    uid: 'u1',
    name: '테스트',
    phone: '010-0000-0000',
    birthDate: '20000101',
    gender: 'male',
    profileImageUrl: '',
    provider: 'phone',
    isVerified: true,
    agreements: {
      LegalDoc.marketing.name: TermsAgreement(
        agreed: marketingAgreed,
        version: LegalDoc.marketing.version,
      ),
    },
    createdAt: DateTime(2026, 8, 22),
    updatedAt: DateTime(2026, 8, 22),
  );

  @override
  Stream<UserModel?> watchUser(String uid) async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<void> setAgreement({
    required String uid,
    required String key,
    required bool agreed,
    required String version,
  }) async {
    writes.add((key: key, agreed: agreed, version: version));
    // 실제 Firestore 스트림처럼 쓰기 직후 새 값을 흘려보낸다.
    _user = _userWith(agreed);
    _controller.add(_user);
  }

  @override
  Future<UserModel?> getUser(String uid) async => _user;

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {}

  @override
  Future<void> setUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String birthDate,
    required String provider,
    String? gender,
    Map<String, TermsAgreementInput>? agreements,
  }) async {}

  @override
  Future<bool> isPhoneDuplicate(String phone) async => false;

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async => '';
}

Future<void> pumpSettings(
  WidgetTester tester, {
  String? uid,
  FakeUserRepository? userRepository,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localPrefsProvider.overrideWith((ref) async => LocalPrefs(prefs)),
        cacheManagerProvider.overrideWith(_FakeCache.new),
        versionCheckProvider.overrideWith(_FakeVersion.new),
        currentUidProvider.overrideWithValue(uid),
        if (userRepository != null)
          userRepositoryProvider.overrideWithValue(userRepository),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) => MaterialApp(home: child),
        child: const SettingsScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// 마케팅 · 홍보 알림 행의 토글. 행이 여럿이라 라벨로 찾는다
/// (순서로 집으면 알림 항목이 하나 늘 때마다 테스트가 엉뚱한 걸 본다).
Finder get _marketingToggle => find.descendant(
  of: find.ancestor(
    of: find.text('마케팅 · 홍보 알림'),
    matching: find.byType(SettingToggleRow),
  ),
  matching: find.byType(MyToggle),
);

bool _marketingOn(WidgetTester tester) =>
    tester.widget<MyToggle>(_marketingToggle).on;

void main() {
  testWidgets('4개 그룹과 각 행이 오버플로 없이 그려진다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpSettings(tester);

    for (final title in ['알림', '일반', '데이터', '계정']) {
      expect(find.text(title), findsOneWidget, reason: '$title 그룹 헤더');
    }
    expect(find.text('푸시 알림'), findsOneWidget);
    expect(find.text('자동 로그인 유지'), findsOneWidget);
    expect(find.text('테마'), findsOneWidget);
    expect(find.text('다크'), findsOneWidget);
    expect(find.text('한국어'), findsOneWidget);
    expect(find.text('48.2MB 사용 중'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
    // 법적 고지 4종은 '이용약관' 한 줄로 묶여 LegalScreen 에서 본다.
    expect(find.text('이용약관'), findsOneWidget);
    expect(find.text('서비스 이용약관 · 개인정보처리방침 등'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('푸시 알림을 끄면 헤더에 전체 꺼짐이 뜨고 하위 알림이 잠긴다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpSettings(tester);

    // 켜져 있는 동안은 잠금 표시가 없다.
    expect(find.text('전체 꺼짐'), findsNothing);
    expect(
      tester.widget<IgnorePointer>(find.byType(IgnorePointer).last).ignoring,
      isFalse,
    );

    // 첫 토글 = 푸시 알림(마스터).
    await tester.tap(find.byType(MyToggle).first);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('전체 꺼짐'), findsOneWidget);
    expect(
      tester.widget<IgnorePointer>(find.byType(IgnorePointer).last).ignoring,
      isTrue,
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byType(IgnorePointer).last,
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity,
      0.4,
    );
  });

  // ── 마케팅 수신 동의 ──────────────────────────────────────
  // 이 토글만 값이 로컬이 아니라 서버(users.agreements.marketing)에 있다.
  // 가입 때 받은 동의가 곧 기본값이고, 여기서 끄면 철회로 기록돼야 한다.

  testWidgets('가입 때 마케팅에 동의했으면 토글이 켜진 채로 시작한다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = FakeUserRepository(marketingAgreed: true);
    await pumpSettings(tester, uid: 'u1', userRepository: repo);

    expect(_marketingOn(tester), isTrue);
  });

  testWidgets('가입 때 마케팅에 동의하지 않았으면 꺼진 채로 시작한다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = FakeUserRepository(marketingAgreed: false);
    await pumpSettings(tester, uid: 'u1', userRepository: repo);

    expect(_marketingOn(tester), isFalse);
  });

  testWidgets('마케팅 토글을 끄면 철회가 서버에 기록된다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = FakeUserRepository(marketingAgreed: true);
    await pumpSettings(tester, uid: 'u1', userRepository: repo);

    await tester.tap(_marketingToggle);
    await tester.pump(const Duration(milliseconds: 250));

    expect(repo.writes, hasLength(1));
    expect(repo.writes.single.key, LegalDoc.marketing.name);
    expect(repo.writes.single.agreed, isFalse);
    // 어느 판본을 기준으로 철회했는지까지 남아야 재동의 대상을 고를 수 있다.
    expect(repo.writes.single.version, LegalDoc.marketing.version);
    // 서버 값이 바뀌었으니 임시 표시값이 사라져도 꺼진 채로 남는다.
    expect(_marketingOn(tester), isFalse);
  });

  testWidgets('하단에 탈퇴하기 링크와 버전 표기가 있다', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpSettings(tester);
    await tester.dragUntilVisible(
      find.text('탈퇴하기'),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );

    expect(find.text('탈퇴하기'), findsOneWidget);
    expect(find.text('vybe · 버전 1.0.0'), findsOneWidget);
  });
}
