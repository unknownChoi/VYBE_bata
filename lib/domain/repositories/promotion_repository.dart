import 'package:vybe/data/models/promotion_model.dart';

abstract interface class PromotionRepository {
  /// 프로모션 1건. 없거나 비활성이면 null.
  Future<PromotionModel?> getPromotion(String promotionId);
}
