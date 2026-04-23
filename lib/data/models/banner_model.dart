import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_model.freezed.dart';

@freezed
abstract class BannerModel with _$BannerModel {
  const BannerModel._();

  const factory BannerModel({
    required String bannerId,
    required String imageUrl,
    required String linkType,
    required String linkValue,
    required int order,
    required bool isActive,
    required DateTime startAt,
    required DateTime endAt,
    required DateTime createdAt,
  }) = _BannerModel;

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      bannerId: data['bannerId'] as String? ?? doc.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      linkType: data['linkType'] as String? ?? '',
      linkValue: data['linkValue'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? false,
      startAt: (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endAt: (data['endAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
