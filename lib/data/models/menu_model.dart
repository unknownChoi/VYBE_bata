import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_model.freezed.dart';

@freezed
abstract class MenuModel with _$MenuModel {
  const MenuModel._();

  const factory MenuModel({
    required String menuId,
    required String clubId,
    required String name,
    required String description,
    required int price,
    required String imageUrl,
    required String category,
    required bool isAvailable,
    @Default(false) bool isFeatured,
    required DateTime createdAt,
  }) = _MenuModel;

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuModel(
      menuId: doc.id,
      clubId: data['clubId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: data['price'] as int? ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      category: data['category'] as String? ?? '',
      isAvailable: data['isAvailable'] as bool? ?? true,
      isFeatured: data['isFeatured'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
