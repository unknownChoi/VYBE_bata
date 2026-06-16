import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_model.freezed.dart';

/// 갤러리 사진 카테고리 — Firestore에는 영문 키로 저장, UI는 한글 라벨 매핑.
enum PhotoCategory {
  venue('업체'),
  food('음식'),
  inside('내부');

  const PhotoCategory(this.label);
  final String label;

  /// Firestore 문자열 → enum (모르는 값은 venue로 폴백)
  static PhotoCategory fromKey(String? key) {
    return PhotoCategory.values.firstWhere(
      (c) => c.name == key,
      orElse: () => PhotoCategory.venue,
    );
  }
}

@freezed
abstract class PhotoModel with _$PhotoModel {
  const PhotoModel._();

  const factory PhotoModel({
    required String photoId,
    required String clubId,
    required String userId,
    required String url,
    required PhotoCategory category,
    required DateTime createdAt,
  }) = _PhotoModel;

  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel(
      photoId: doc.id,
      clubId: data['clubId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      url: data['url'] as String? ?? '',
      category: PhotoCategory.fromKey(data['category'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 사진 업로드용 (추후 사용자 업로드 기능에서 사용)
  Map<String, dynamic> toFirestore() => {
        'clubId': clubId,
        'userId': userId,
        'url': url,
        'category': category.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
