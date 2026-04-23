import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/banner_model.dart';
import 'package:vybe/data/repositories/banner_repository_impl.dart';

part 'banner_viewmodel.g.dart';

// keepAlive: true — 사전 로딩된 데이터가 홈 화면에서 즉시 사용되도록 유지
@Riverpod(keepAlive: true)
Future<List<BannerModel>> bannerList(Ref ref) {
  return ref.read(bannerRepositoryProvider).getActiveBanners();
}
