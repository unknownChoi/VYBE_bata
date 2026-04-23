import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_banner_datasource.dart';
import 'package:vybe/data/models/banner_model.dart';
import 'package:vybe/domain/repositories/banner_repository.dart';

part 'banner_repository_impl.g.dart';

@riverpod
BannerRepository bannerRepository(Ref ref) =>
    _BannerRepositoryImpl(FirebaseBannerDataSource());

class _BannerRepositoryImpl implements BannerRepository {
  final FirebaseBannerDataSource _dataSource;

  _BannerRepositoryImpl(this._dataSource);

  @override
  Future<List<BannerModel>> getActiveBanners() =>
      _dataSource.getActiveBanners();
}
