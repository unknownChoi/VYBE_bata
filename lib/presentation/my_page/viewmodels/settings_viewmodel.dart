import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_viewmodel.g.dart';

/// 앱 캐시(임시 디렉토리 + 메모리 이미지 캐시) 관리.
/// state = 임시 디렉토리 용량(bytes).
@riverpod
class CacheManager extends _$CacheManager {
  @override
  Future<int> build() => _computeSize();

  Future<int> _computeSize() async {
    final dir = await getTemporaryDirectory();
    var total = 0;
    if (!await dir.exists()) return 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {
          // 순회 중 삭제된 파일 등은 무시.
        }
      }
    }
    return total;
  }

  /// 캐시 삭제 — 메모리 이미지 캐시 + 임시 디렉토리 내용물 제거 후 용량 재계산.
  Future<void> clearCache() async {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();

    final dir = await getTemporaryDirectory();
    if (await dir.exists()) {
      await for (final entity in dir.list(followLinks: false)) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {
          // 사용 중인 파일(지도 SDK 등)은 건너뜀.
        }
      }
    }
    state = AsyncData(await _computeSize());
  }
}

/// bytes → 표시 문자열 (예: 48.2MB).
String formatCacheSize(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
}
