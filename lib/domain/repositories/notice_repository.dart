import 'package:vybe/data/models/notice_model.dart';

abstract interface class NoticeRepository {
  /// 활성 공지 목록 (고정 공지 우선 → 최신 게시순).
  Future<List<NoticeModel>> getNotices({int limit});

  /// 공지 1건. 없으면 null.
  Future<NoticeModel?> getNotice(String noticeId);
}
