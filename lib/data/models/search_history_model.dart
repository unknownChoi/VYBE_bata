import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_history_model.freezed.dart';

@freezed
abstract class SearchHistoryModel with _$SearchHistoryModel {
  const SearchHistoryModel._();

  const factory SearchHistoryModel({
    required String historyId,
    required String userId,
    required String keyword,
    required DateTime createdAt,
  }) = _SearchHistoryModel;

  factory SearchHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchHistoryModel(
      historyId: doc.id,
      userId: data['userId'] as String? ?? '',
      keyword: data['keyword'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'keyword': keyword,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
