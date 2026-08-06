import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/promotion_model.dart';

class FirebasePromotionDataSource {
  final FirebaseFirestore _firestore;

  FirebasePromotionDataSource() : _firestore = FirebaseFirestore.instance;

  /// 프로모션 1건 조회 (배너 탭 진입 전용 — 목록 조회는 없다).
  ///
  /// 비활성 문서는 null로 돌려 화면이 '종료된 이벤트' 상태를 그리게 한다.
  /// Rules에서 isActive를 막지 않는 이유 — 막으면 permission-denied 예외가 되어
  /// '없음'과 '오류'를 구분할 수 없다 (banners와 동일하게 read: if true).
  Future<PromotionModel?> getPromotion(String promotionId) async {
    logFirebaseAccess(
      file: 'firebase_promotion_datasource.dart',
      service: 'Firestore(promotions/$promotionId)',
      purpose: '홈 배너 → 프로모션 상세 조회',
    );
    final doc =
        await _firestore.collection('promotions').doc(promotionId).get();
    if (!doc.exists) return null;
    final promotion = PromotionModel.fromFirestore(doc);
    return promotion.isActive ? promotion : null;
  }
}
