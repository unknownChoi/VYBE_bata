import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/banner_model.dart';
import 'package:vybe/data/repositories/banner_repository_impl.dart';

part 'banner_viewmodel.g.dart';

// keepAlive: true — 앱 수명 동안 한 번만 fetch, 재실행 없음
@Riverpod(keepAlive: true)
Future<List<BannerModel>> bannerList(Ref ref) {
  return ref.read(bannerRepositoryProvider).getActiveBanners();
}
