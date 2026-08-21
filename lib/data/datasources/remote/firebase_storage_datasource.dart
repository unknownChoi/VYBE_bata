import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:vybe/core/utils/firebase_logger.dart';
import 'package:vybe/data/datasources/remote/firestore_paths.dart';

class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource() : _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    logFirebaseAccess(
      file: 'firebase_storage_datasource.dart',
      service: 'Storage(users/$uid/profile.jpg)',
      purpose: '프로필 이미지 업로드',
    );
    final ref = _storage.ref(StoragePaths.profileImage(uid));
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  /// 리뷰 첨부 이미지 업로드 → 다운로드 URL 반환.
  /// 경로: reviews/{clubId}/{reviewId}/{fileName}
  Future<String> uploadReviewImage({
    required String clubId,
    required String reviewId,
    required String fileName,
    required File imageFile,
  }) async {
    logFirebaseAccess(
      file: 'firebase_storage_datasource.dart',
      service: 'Storage(reviews/$clubId/$reviewId/$fileName)',
      purpose: '리뷰 첨부 이미지 업로드',
    );
    final ref = _storage.ref(
      StoragePaths.reviewImage(clubId, reviewId, fileName),
    );
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  /// 다운로드 URL로 파일 삭제. 리뷰 수정에서 뺀 첨부 사진 정리용.
  ///
  /// 실패해도 예외를 던지지 않는다 — 이미 지워졌거나 URL이 이 버킷 것이 아닐 때
  /// 호출측(리뷰 수정)이 실패로 뒤집히면 안 된다. 문서는 이미 갱신된 상태다.
  Future<void> deleteFileByUrl(String url) async {
    logFirebaseAccess(
      file: 'firebase_storage_datasource.dart',
      service: 'Storage(refFromURL)',
      purpose: '리뷰 수정에서 제거된 첨부 이미지 삭제',
    );
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      debugPrint('[Storage] deleteFileByUrl failed: $url ($e)');
    }
  }
}
