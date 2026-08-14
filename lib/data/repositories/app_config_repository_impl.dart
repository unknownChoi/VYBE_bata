import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_app_config_datasource.dart';
import 'package:vybe/data/models/app_version_config_model.dart';
import 'package:vybe/domain/repositories/app_config_repository.dart';

part 'app_config_repository_impl.g.dart';

@Riverpod(keepAlive: true)
AppConfigRepository appConfigRepository(Ref ref) =>
    _AppConfigRepositoryImpl(FirebaseAppConfigDataSource());

class _AppConfigRepositoryImpl implements AppConfigRepository {
  final FirebaseAppConfigDataSource _dataSource;

  _AppConfigRepositoryImpl(this._dataSource);

  @override
  Future<AppVersionConfigModel?> getVersionConfig(String platform) =>
      _dataSource.getVersionConfig(platform);
}
