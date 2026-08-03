import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/data/repositories/notice_repository_impl.dart';

part 'notice_viewmodel.g.dart';

/// 공지사항 목록 (고정 공지 우선 → 최신 게시순).
/// 공지는 자주 바뀌지 않아 스트림 대신 단발 조회 + pull-to-refresh(invalidate).
@riverpod
Future<List<NoticeModel>> notices(Ref ref) =>
    ref.watch(noticeRepositoryProvider).getNotices();
