import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/data/repositories/notice_repository_impl.dart';

part 'notice_viewmodel.g.dart';

/// 공지사항 목록 (고정 공지 우선 → 최신 게시순).
/// 공지는 자주 바뀌지 않아 스트림 대신 단발 조회 + pull-to-refresh(invalidate).
@riverpod
Future<List<NoticeModel>> notices(Ref ref) =>
    ref.watch(noticeRepositoryProvider).getNotices();

/// 공지 1건. **배너에서 들어오는 경로 전용** — 목록을 거치지 않아 모델이 없고
/// noticeId만 있다(목록에서 탭한 경우엔 이미 받은 모델을 그대로 쓴다 = 조회 0회).
/// 게시 기간이 지났거나 게시중단이면 datasource가 null을 준다.
@riverpod
Future<NoticeModel?> notice(Ref ref, String noticeId) =>
    ref.watch(noticeRepositoryProvider).getNotice(noticeId);
