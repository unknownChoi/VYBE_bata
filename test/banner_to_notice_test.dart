import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/banner_model.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/presentation/home/viewmodels/banner_viewmodel.dart';
import 'package:vybe/presentation/home/widgets/home_banner.dart';
import 'package:vybe/presentation/my_page/notice_detail_route.dart';
import 'package:vybe/presentation/my_page/viewmodels/notice_viewmodel.dart';

// 홈 배너 탭 → 공지 상세. 배너 doc의 linkType/linkValue 하나로 목적지가 정해지는
// 경로 전체(모델 파싱 → openBannerLink → openNoticeDetail → 화면)를 한 번에 본다.

const _noticeId = 'notice_ad_free_entry';

BannerModel _banner(BannerLinkType type, String value) => BannerModel(
  bannerId: 'banner_01_free_entry',
  imageUrl: 'https://example.com/banner.jpg',
  linkType: type,
  linkValue: value,
  order: 1,
  isActive: true,
  startAt: DateTime(2026, 8, 1),
  endAt: DateTime(2027, 8, 1),
  createdAt: DateTime(2026, 8, 1),
);

final _notice = NoticeModel(
  noticeId: _noticeId,
  title: '목요일은 프리 엔트리',
  content: '매주 목요일 제휴 클럽 42곳.',
  category: 'event',
  publishedAt: DateTime(2026, 8, 24),
  createdAt: DateTime(2026, 8, 24),
  updatedAt: DateTime(2026, 8, 24),
);

Future<void> _boot(WidgetTester tester, BannerModel banner) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bannerListProvider.overrideWith((ref) async => [banner]),
        noticeProvider(_noticeId).overrideWith((ref) async => _notice),
        noticesProvider.overrideWith((ref) async => [_notice]),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, __) => const MaterialApp(
          home: Scaffold(body: Center(child: HomeBanner())),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('notice 배너를 탭하면 공지 상세가 열린다', (tester) async {
    await _boot(tester, _banner(BannerLinkType.notice, _noticeId));

    // 카드 한가운데를 누른다 (HomeBanner 중앙은 인디케이터 dot 줄이라 빗나간다).
    await tester.tapAt(tester.getCenter(find.byType(PageView)));
    // 라우트 전환 + 공지 1건 조회.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(NoticeDetailById), findsOneWidget);
    expect(find.text('목요일은 프리 엔트리'), findsOneWidget);
  });

  testWidgets('링크 없는 배너는 탭해도 아무 데도 안 간다', (tester) async {
    await _boot(tester, _banner(BannerLinkType.none, ''));

    await tester.tapAt(tester.getCenter(find.byType(PageView)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(NoticeDetailById), findsNothing);
  });
}
