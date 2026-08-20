import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/presentation/my_page/viewmodels/notice_viewmodel.dart';

part 'home_notices_viewmodel.g.dart';

/// 홈 공지 카드에 올릴 건수 (디자인 3줄).
const _kMaxNotices = 3;

/// 홈 공지사항 — 고정 공지 우선 → 최신 게시순 상위 [_kMaxNotices]건.
///
/// 별도 쿼리를 만들지 않고 [noticesProvider]를 그대로 재사용한다. 공지는 몇 건
/// 안 되고, 여기서 캐시를 데워 두면 '전체보기'로 들어간 목록 화면이 추가 read
/// 없이 바로 그려진다. 노출 조건(게시상태·기간)도 그쪽 한 곳에서만 판정된다.
@riverpod
Future<List<NoticeModel>> homeNotices(Ref ref) async {
  final all = await ref.watch(noticesProvider.future);
  return all.take(_kMaxNotices).toList();
}
