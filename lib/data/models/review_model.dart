import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';

@freezed
abstract class ReviewModel with _$ReviewModel {
  const ReviewModel._();

  const factory ReviewModel({
    required String reviewId,
    required String clubId,
    required String userId,
    @Default('') String userName,
    required double rating,
    required String content,
    required List<String> imageUrls,
    @Default(<String>[]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ReviewModel;

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      reviewId: doc.id,
      clubId: data['clubId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      content: data['content'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'clubId': clubId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'content': content,
    'imageUrls': imageUrls,
    'tags': tags,
    // 작성자 탈퇴 시 서버가 true로 바꾼다. 여기서 false를 **반드시 써야** 한다 —
    // 목록 쿼리가 `where isHidden == false`라 필드가 없으면 Firestore가 문서를
    // 아예 못 잡아 방금 쓴 리뷰가 조용히 안 보인다. 모델 필드로는 두지 않는다
    // (화면이 쓰지 않고, 읽기는 이미 서버에서 걸러져 온다).
    'isHidden': false,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
