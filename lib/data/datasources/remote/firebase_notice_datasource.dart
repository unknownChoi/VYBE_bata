import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/notice_model.dart';

class FirebaseNoticeDataSource {
  final FirebaseFirestore _firestore;

  FirebaseNoticeDataSource() : _firestore = FirebaseFirestore.instance;

  /// 게시 중인 공지 목록. 최신 게시순으로 받아온 뒤 고정 공지를 메모리에서 위로 올린다.
  /// (isPinned를 서버 orderBy에 넣으면 3필드 복합 인덱스가 필요해짐 — 공지 건수가
  ///  적어 얻는 게 없다. 인덱스: notices(isActive, publishedAt DESC))
  ///
  /// 노출 조건 3가지 중 게시상태(isActive)·게시시작(publishedAt)은 서버에서 거른다.
  /// publishedAt <= now 는 정렬 키와 같은 필드라 기존 인덱스로 그대로 처리된다.
  Future<List<NoticeModel>> getNotices({int limit = 50}) async {
    final now = DateTime.now();
    logFirebaseAccess(
      file: 'firebase_notice_datasource.dart',
      service:
          'Firestore(notices) [where isActive=true, publishedAt<=now, orderBy publishedAt desc]',
      purpose: '마이페이지 공지사항 목록 조회 (게시 기간 내 공지만)',
    );
    final snapshot = await _firestore
        .collection('notices')
        .where('isActive', isEqualTo: true)
        .where('publishedAt', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();

    // 게시 종료(endAt)는 메모리에서 거른다 — publishedAt과 다른 필드에 범위 조건을
    // 하나 더 걸면 복합 인덱스가 추가로 필요한데, 공지 건수가 적어 얻는 게 없다.
    // (limit이 종료된 공지까지 세므로 노출 건수가 limit보다 적어질 수 있다)
    final notices = snapshot.docs
        .map(NoticeModel.fromFirestore)
        .where((n) => n.isVisibleAt(now))
        .toList();
    notices.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.publishedAt.compareTo(a.publishedAt);
    });
    return notices;
  }

  /// 공지 1건 조회 (딥링크·알림 진입용 — 목록을 거치지 않는 경로).
  /// 목록과 같은 노출 기준을 적용 — 예약(게시 전)·종료·게시중단 공지는 null.
  /// 목록에 없는 공지가 링크로만 열리는 구멍을 막는다.
  Future<NoticeModel?> getNotice(String noticeId) async {
    logFirebaseAccess(
      file: 'firebase_notice_datasource.dart',
      service: 'Firestore(notices/$noticeId)',
      purpose: '공지사항 상세 조회',
    );
    final doc = await _firestore.collection('notices').doc(noticeId).get();
    if (!doc.exists) return null;
    final notice = NoticeModel.fromFirestore(doc);
    return notice.isVisible ? notice : null;
  }
}
