import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_model.freezed.dart';

@freezed
abstract class ClubModel with _$ClubModel {
  const ClubModel._();

  const factory ClubModel({
    required String clubId,
    required String name,
    required String description,
    required String address,
    required String area,
    required String phone,
    required String instagramUrl,
    required double lat,
    required double lng,
    required String geohash,
    required String genre,
    required double rating,
    required String closeTime,
    required int entryFeeMin,
    required int entryFeeMax,
    required List<String> imageUrls,
    required String thumbnailUrl,
    required List<String> tags,
    required int favoriteCount,
    required bool isActive,
    required bool isOpen,
    required bool isVybeRecommended,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ClubModel;

  factory ClubModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final location = data['location'] as Map<String, dynamic>? ?? {};
    return ClubModel(
      clubId: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      address: data['address'] as String? ?? '',
      area: data['area'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      instagramUrl: data['instagramUrl'] as String? ?? '',
      lat: (location['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (location['lng'] as num?)?.toDouble() ?? 0.0,
      geohash: location['geohash'] as String? ?? '',
      genre: data['genre'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      closeTime: data['closeTime'] as String? ?? '',
      entryFeeMin: (data['entryFeeMin'] as num?)?.toInt() ?? 0,
      entryFeeMax: (data['entryFeeMax'] as num?)?.toInt() ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List? ?? []),
      favoriteCount: (data['favoriteCount'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? false,
      isOpen: data['isOpen'] as bool? ?? false,
      isVybeRecommended: data['isVybeRecommended'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
