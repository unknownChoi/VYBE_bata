import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_model.freezed.dart';

/// 찜 그룹(폴더) — users/{uid}/folders/{folderId}
@freezed
abstract class FolderModel with _$FolderModel {
  const FolderModel._();

  const factory FolderModel({
    required String folderId,
    required String name,
    @Default('') String emoji,
    @Default(0) int order,
    required DateTime createdAt,
  }) = _FolderModel;

  factory FolderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FolderModel(
      folderId: doc.id,
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
