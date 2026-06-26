import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_model.freezed.dart';

@freezed
abstract class FavoriteModel with _$FavoriteModel {
  const FavoriteModel._();

  const factory FavoriteModel({
    required String favoriteId,
    required String userId,
    required String clubId,
    required DateTime createdAt,
  }) = _FavoriteModel;

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteModel(
      favoriteId: doc.id,
      userId: data['userId'] as String? ?? '',
      clubId: data['clubId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'clubId': clubId,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
