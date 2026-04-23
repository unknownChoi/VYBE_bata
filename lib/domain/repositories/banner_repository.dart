import 'package:vybe/data/models/banner_model.dart';

abstract interface class BannerRepository {
  Future<List<BannerModel>> getActiveBanners();
}
