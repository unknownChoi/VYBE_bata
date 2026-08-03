import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/notice_model.dart';

class FirebaseNoticeDataSource {
  final FirebaseFirestore _firestore;

  FirebaseNoticeDataSource() : _firestore = FirebaseFirestore.instance;

  /// 활성 공지 목록. 최신 게시순으로 받아온 뒤 고정 공지를 메모리에서 위로 올린다.
  /// (isPinned를 서버 orderBy에 넣으면 3필드 복합 인덱스가 필요해짐 — 공지 건수가
  ///  적어 얻는 게 없다. 인덱스: notices(isActive, publishedAt DESC))
  Future<List<NoticeModel>> getNotices({int limit = 50}) async {
    logFirebaseAccess(
      file: 'firebase_notice_datasource.dart',
      service: 'Firestore(notices) [where isActive=true, orderBy publishedAt desc]',
      purpose: '마이페이지 공지사항 목록 조회',
    );
    final snapshot = await _firestore
        .collection('notices')
        .where('isActive', isEqualTo: true)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();

    final notices = snapshot.docs.map(NoticeModel.fromFirestore).toList();
    notices.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.publishedAt.compareTo(a.publishedAt);
    });
    return notices;
  }

  /// 공지 1건 조회 (딥링크·알림 진입용 — 목록을 거치지 않는 경로).
  Future<NoticeModel?> getNotice(String noticeId) async {
    logFirebaseAccess(
      file: 'firebase_notice_datasource.dart',
      service: 'Firestore(notices/$noticeId)',
      purpose: '공지사항 상세 조회',
    );
    final doc = await _firestore.collection('notices').doc(noticeId).get();
    if (!doc.exists) return null;
    return NoticeModel.fromFirestore(doc);
  }
}
