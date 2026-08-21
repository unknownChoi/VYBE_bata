import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_model.freezed.dart';

/// 배너를 탭했을 때 어디로 보낼지.
///
/// - [promotion] : `promotions/{linkValue}` 콘텐츠를 범용 상세 화면으로 렌더.
///   배너마다 사진·본문이 다른 광고 페이지 — 앱 배포 없이 DB만으로 늘릴 수 있다.
/// - [club]      : 클럽 상세 (linkValue = clubId) — 미연결
/// - [page]      : 코드에 이미 있는 전용 화면 키 (searchHashtags와 키 공유) — 미연결
/// - [url]       : 외부 브라우저 — 미연결
/// - [none]      : 이동 없음. 알 수 없는 값도 여기로 폴백한다.
enum BannerLinkType { promotion, club, page, url, none }

@freezed
abstract class BannerModel with _$BannerModel {
  const BannerModel._();

  const factory BannerModel({
    required String bannerId,
    required String imageUrl,
    required BannerLinkType linkType,
    required String linkValue,
    required int order,
    required bool isActive,
    required DateTime startAt,
    required DateTime endAt,
    required DateTime createdAt,
  }) = _BannerModel;

  /// 탭 가능한 배너인지 (none이거나 값이 비면 단순 이미지 광고).
  bool get isTappable =>
      linkType != BannerLinkType.none && linkValue.isNotEmpty;

  static BannerLinkType _parseLinkType(String? raw) => switch (raw) {
    'promotion' => BannerLinkType.promotion,
    'club' => BannerLinkType.club,
    'page' => BannerLinkType.page,
    'url' => BannerLinkType.url,
    _ => BannerLinkType.none,
  };

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      bannerId: data['bannerId'] as String? ?? doc.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      linkType: _parseLinkType(data['linkType'] as String?),
      linkValue: data['linkValue'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? false,
      startAt: (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endAt: (data['endAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
