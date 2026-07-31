import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_trend_model.freezed.dart';

/// 검색 로그의 유입 경로.
///
/// 집계는 [input] / [suggestion]만 순위에 반영한다. 트렌드·해시태그 칩을 눌러
/// 들어온 검색까지 세면 1위가 계속 1위가 되는 되먹임이 생기기 때문.
enum SearchSource { input, suggestion, hashtag, trend, history, map }

/// 순위 변동 상태. Cloud Functions가 직전 스냅샷과 비교해 계산한 값.
enum TrendStatus { up, down, newEntry, same }

TrendStatus _statusFromString(String? raw) {
  switch (raw) {
    case 'up':
      return TrendStatus.up;
    case 'down':
      return TrendStatus.down;
    case 'newEntry':
      return TrendStatus.newEntry;
    default:
      return TrendStatus.same;
  }
}

@freezed
abstract class SearchTrendItem with _$SearchTrendItem {
  const SearchTrendItem._();

  const factory SearchTrendItem({
    required int rank,
    required String keyword,
    required TrendStatus status,
    required int? change,

    /// 0이면 실데이터가 아니라 fallback 큐레이션으로 채운 자리.
    required int uniqueUsers,
  }) = _SearchTrendItem;

  /// 실검색 데이터에서 나온 순위인지. false면 증감 표시를 하지 않는다
  /// (유저가 없는데 순위가 오르내리는 것처럼 보이면 안 됨).
  bool get isReal => uniqueUsers > 0;

  factory SearchTrendItem.fromMap(Map<String, dynamic> data) {
    return SearchTrendItem(
      rank: (data['rank'] as num?)?.toInt() ?? 0,
      keyword: data['keyword'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      change: (data['change'] as num?)?.toInt(),
      uniqueUsers: (data['uniqueUsers'] as num?)?.toInt() ?? 0,
    );
  }
}

@freezed
abstract class SearchTrendSnapshot with _$SearchTrendSnapshot {
  const SearchTrendSnapshot._();

  const factory SearchTrendSnapshot({
    required List<SearchTrendItem> items,

    /// 실데이터로 채워진 항목 수 (나머지는 fallback).
    required int realCount,
    required DateTime? updatedAt,
  }) = _SearchTrendSnapshot;

  static const empty = SearchTrendSnapshot(
    items: [],
    realCount: 0,
    updatedAt: null,
  );

  /// 실데이터가 하나도 없으면 '실시간'이라는 표현을 쓰지 않는다.
  bool get isLive => realCount > 0;

  factory SearchTrendSnapshot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return empty;

    final rawItems = (data['items'] as List<dynamic>? ?? const []);
    return SearchTrendSnapshot(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(SearchTrendItem.fromMap)
          .toList(),
      realCount: (data['realCount'] as num?)?.toInt() ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
