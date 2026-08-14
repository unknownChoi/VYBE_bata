import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/models/app_version_config_model.dart';

/// 앱 전역 설정(`appConfig`) 조회. 현재는 버전 정책 1종.
class FirebaseAppConfigDataSource {
  final FirebaseFirestore _firestore;

  FirebaseAppConfigDataSource() : _firestore = FirebaseFirestore.instance;

  /// 플랫폼별 버전 정책 1건. 문서가 없으면 null(= 정책 없음 → 통과).
  ///
  /// **로그인 전에 호출되는 유일한 Firestore 경로** — Rules에서 auth를
  /// 요구하면 안 된다(`allow read: if true`).
  ///
  /// 실패는 여기서 삼키지 않고 그대로 올린다. fail-open 판단(통과 처리)은
  /// 뷰모델 한 곳에서만 한다 — 예외를 두 군데서 먹으면 원인을 못 찾는다.
  Future<AppVersionConfigModel?> getVersionConfig(String platform) async {
    logFirebaseAccess(
      file: 'firebase_app_config_datasource.dart',
      service: 'Firestore(appConfig/$platform)',
      purpose: '앱 실행 시 강제/선택 업데이트·점검 여부 확인',
    );
    final doc = await _firestore.collection('appConfig').doc(platform).get();
    if (!doc.exists) return null;
    return AppVersionConfigModel.fromFirestore(doc);
  }
}
