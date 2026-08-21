import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/datasources/remote/firestore_paths.dart';
import 'package:vybe/data/models/search_hashtag_model.dart';
import 'package:vybe/data/models/search_trend_model.dart';

/// 검색 트렌드 / 인기 해시태그 datasource.
///
/// 순위 집계는 Cloud Functions(aggregateSearchTrends)가 담당하고, 앱은
/// 결과 문서를 읽기만 한다. 앱이 하는 쓰기는 searchLogs 원본 로그뿐.
class FirebaseSearchTrendDataSource {
  final FirebaseFirestore _firestore;

  FirebaseSearchTrendDataSource() : _firestore = FirebaseFirestore.instance;

  /// 로그 보존 기간 — Firestore TTL 정책(searchLogs.expireAt)이 자동 삭제한다.
  static const _retention = Duration(days: 14);

  /// 실시간 인기 검색어 스냅샷. 문서 1개만 읽는다 (read 1회).
  Future<SearchTrendSnapshot> getTrendSnapshot() async {
    logFirebaseAccess(
      file: 'firebase_search_trend_datasource.dart',
      service: 'Firestore(searchTrends/current)',
      purpose: '실시간 인기 검색어 순위 표시',
    );
    final doc = await _firestore
        .collection(FirestorePaths.searchTrends)
        .doc(FirestorePaths.trendsCurrentDoc)
        .get();
    if (!doc.exists) return SearchTrendSnapshot.empty;
    return SearchTrendSnapshot.fromFirestore(doc);
  }

  /// 인기 해시태그 목록. popularityRank(집계) 우선, 없으면 order(큐레이션).
  Future<List<SearchHashtagModel>> getActiveHashtags() async {
    logFirebaseAccess(
      file: 'firebase_search_trend_datasource.dart',
      service: 'Firestore(searchHashtags) [where isActive=true]',
      purpose: '검색 화면 인기 해시태그 표시',
    );
    final snapshot = await _firestore
        .collection(FirestorePaths.searchHashtags)
        .where('isActive', isEqualTo: true)
        .get();

    final tags = snapshot.docs.map(SearchHashtagModel.fromFirestore).toList();
    tags.sort((a, b) {
      final ar = a.popularityRank;
      final br = b.popularityRank;
      // 검색량 순위가 있는 태그가 항상 앞. 둘 다 없으면 큐레이션 순서.
      if (ar != null && br != null) return ar.compareTo(br);
      if (ar != null) return -1;
      if (br != null) return 1;
      return a.order.compareTo(b.order);
    });
    return tags;
  }

  /// 검색 로그 1건 기록. 집계 원본이며 개별 조회 용도는 없다.
  ///
  /// 키워드 정규화 규칙은 Cloud Functions(compute_trends.ts)와 동일하게
  /// 맞춰야 한다 — 선행 '#' 제거 + 연속 공백 축약 + 2~30자.
  Future<void> logSearch({
    required String userId,
    required String keyword,
    required SearchSource source,
  }) async {
    final normalized = normalizeSearchKeyword(keyword);
    if (normalized == null) return;

    logFirebaseAccess(
      file: 'firebase_search_trend_datasource.dart',
      service: 'Firestore(searchLogs)',
      purpose: '검색어 "$normalized" 로그 기록 (인기 검색어 집계용)',
    );
    await _firestore.collection(FirestorePaths.searchLogs).add({
      'keyword': normalized,
      'userId': userId,
      'source': source.name,
      'createdAt': FieldValue.serverTimestamp(),
      'expireAt': Timestamp.fromDate(DateTime.now().add(_retention)),
    });
  }
}

/// 로그로 남길 수 있는 형태로 정리. 부적합하면 null.
///
/// 대소문자는 보존한다 ('EDM'을 'edm'으로 기록하지 않음) — 소문자 병합은
/// 서버 집계 단계에서 처리한다.
String? normalizeSearchKeyword(String raw) {
  final trimmed = raw
      .replaceAll(RegExp(r'^#+'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (trimmed.length < 2 || trimmed.length > 30) return null;
  if (!RegExp(r'[a-zA-Z가-힣ㄱ-ㆎ]').hasMatch(trimmed)) return null;
  return trimmed;
}
