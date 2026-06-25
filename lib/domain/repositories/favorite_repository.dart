import 'package:vybe/data/models/favorite_model.dart';

abstract class FavoriteRepository {
  Stream<List<FavoriteModel>> watchUserFavorites(String userId);
  Future<bool> isFavorite(String userId, String clubId);
  Future<void> addFavorite(String userId, String clubId, {String? folderId});
  Future<void> removeFavorite(String userId, String clubId);
  Future<void> moveFavoriteToFolder(
    String userId,
    String clubId,
    String? folderId,
  );
}
