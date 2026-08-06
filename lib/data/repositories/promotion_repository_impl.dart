import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_promotion_datasource.dart';
import 'package:vybe/data/models/promotion_model.dart';
import 'package:vybe/domain/repositories/promotion_repository.dart';

part 'promotion_repository_impl.g.dart';

@Riverpod(keepAlive: true)
PromotionRepository promotionRepository(Ref ref) =>
    _PromotionRepositoryImpl(FirebasePromotionDataSource());

class _PromotionRepositoryImpl implements PromotionRepository {
  final FirebasePromotionDataSource _dataSource;

  _PromotionRepositoryImpl(this._dataSource);

  @override
  Future<PromotionModel?> getPromotion(String promotionId) =>
      _dataSource.getPromotion(promotionId);
}
