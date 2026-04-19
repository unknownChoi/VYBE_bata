import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/favorite_data_source.dart';
import 'package:vybe/data/models/favorite_model.dart';
import 'package:vybe/domain/repositories/favorite_repository.dart';

part 'favorite_repository_impl.g.dart';

@riverpod
FavoriteRepository favoriteRepository(Ref ref) =>
    FavoriteRepositoryImpl(FavoriteDataSource());

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteDataSource _dataSource;

  FavoriteRepositoryImpl(this._dataSource);

  @override
  Stream<List<FavoriteModel>> watchUserFavorites(String userId) =>
      _dataSource.watchUserFavorites(userId);

  @override
  Future<bool> isFavorite(String userId, String clubId) =>
      _dataSource.isFavorite(userId, clubId);

  @override
  Future<void> addFavorite(String userId, String clubId) =>
      _dataSource.addFavorite(userId, clubId);

  @override
  Future<void> removeFavorite(String userId, String clubId) =>
      _dataSource.removeFavorite(userId, clubId);
}
