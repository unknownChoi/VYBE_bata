import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/data/models/service_drink.dart';

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
    @Default(0) int reviewCount,
    @Default(OperatingHours()) OperatingHours operatingHours,
    required int entryFeeMin,
    required int entryFeeMax,
    required List<String> imageUrls,
    @Default([]) List<String> heroImageUrls,
    required String thumbnailUrl,
    @Default([]) List<String> menuBoardUrls,
    required List<String> tags,
    required int favoriteCount,
    required bool isActive,
    required bool isVybeRecommended,
    @Default(false) bool isNonSmoking,
    @Default(ServiceDrink.none) ServiceDrink serviceDrink,
    @Default('') String freeEntryCondition,
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
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      operatingHours: OperatingHours.fromMap(
          data['operatingHours'] as Map<String, dynamic>?),
      entryFeeMin: (data['entryFeeMin'] as num?)?.toInt() ?? 0,
      entryFeeMax: (data['entryFeeMax'] as num?)?.toInt() ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      heroImageUrls:
          List<String>.from(data['heroImageUrls'] as List? ?? []),
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      menuBoardUrls:
          List<String>.from(data['menuBoardUrls'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      favoriteCount: (data['favoriteCount'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? false,
      isVybeRecommended: data['isVybeRecommended'] as bool? ?? false,
      isNonSmoking: data['isNonSmoking'] as bool? ?? false,
      serviceDrink: ServiceDrink.fromMap(
          data['serviceDrink'] as Map<String, dynamic>?),
      freeEntryCondition: data['freeEntryCondition'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
