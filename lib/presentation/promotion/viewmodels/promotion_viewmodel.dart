import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/models/promotion_model.dart';
import 'package:vybe/data/repositories/promotion_repository_impl.dart';

part 'promotion_viewmodel.g.dart';

/// 프로모션 상세 1건. 배너 탭 시점에만 조회한다(홈 목록엔 본문이 없다).
@riverpod
Future<PromotionModel?> promotion(Ref ref, String promotionId) =>
    ref.watch(promotionRepositoryProvider).getPromotion(promotionId);
