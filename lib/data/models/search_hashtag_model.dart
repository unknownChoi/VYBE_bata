import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_hashtag_model.freezed.dart';

/// 해시태그 탭 시 목적지 종류.
///
/// '입장료 무료'·'서비스 음료'·'힙합'처럼 전용 화면이 있는 태그가 있어서
/// 단순 검색어 목록으로는 라우팅을 표현할 수 없다 (banners의 linkType 패턴 재사용).
enum HashtagLinkType {
  /// 검색 결과 화면으로 이동
  keyword,

  /// 전용 화면으로 이동 (linkValue = 화면 키)
  page,
}

@freezed
abstract class SearchHashtagModel with _$SearchHashtagModel {
  const SearchHashtagModel._();

  const factory SearchHashtagModel({
    required String tagId,

    /// 표시 라벨 ('힙합' → UI에선 '#힙합')
    required String label,
    required HashtagLinkType linkType,

    /// keyword: 검색어 / page: 'freeEntry'|'serviceDrinks'|'hipHop'|
    /// 'hotPlaces'|'vybeRecommend'
    required String linkValue,

    /// 큐레이션 기본 순서
    required int order,

    /// 집계가 채우는 검색량 순위. null이면 [order]로 정렬.
    required int? popularityRank,
    required bool isActive,
  }) = _SearchHashtagModel;

  factory SearchHashtagModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchHashtagModel(
      tagId: data['tagId'] as String? ?? doc.id,
      label: data['label'] as String? ?? '',
      linkType: data['linkType'] == 'page'
          ? HashtagLinkType.page
          : HashtagLinkType.keyword,
      linkValue: data['linkValue'] as String? ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
      popularityRank: (data['popularityRank'] as num?)?.toInt(),
      isActive: data['isActive'] as bool? ?? false,
    );
  }
}
