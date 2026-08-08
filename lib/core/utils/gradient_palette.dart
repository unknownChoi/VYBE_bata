import 'dart:ui' show Color;

/// 키(보통 clubId) 해시로 팔레트에서 그라데이션 하나를 **결정적으로** 고른다.
///
/// 썸네일이 없거나 로딩 전인 카드의 배경 폴백용. 같은 클럽은 화면을 다시 그려도
/// 늘 같은 색이 나온다.
///
/// 팔레트 자체는 화면마다 다르다(카드 크기·배경 톤에 맞춘 큐레이션) — 공유하지 않는다.
List<Color> gradientForKey(List<List<Color>> palette, String key) =>
    palette[key.hashCode.abs() % palette.length];
