import 'package:vybe/data/models/club_model.dart';

/// Firestore에서 searchTokens(arrayContainsAny)로 받아온 후보 클럽들을
/// 관련도 점수로 정렬한다. (임시 더미용 club_search.dart 알고리즘을 ClubModel로 이식)
///
/// 후보 집합이 이미 서버에서 토큰 필터된 상태라 전체 fetch가 아니므로
/// 클라 점수 계산 비용이 작다.
///
/// 사전(지역 후보)은 하드코딩하지 않고 후보 데이터에서 동적 추출.
List<ClubModel> rankClubs(List<ClubModel> clubs, String rawQuery) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) return const [];

  final qNoSpace = q.replaceAll(RegExp(r'\s+'), '');
  final tokens =
      q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  final areaSet = clubs.map((c) => c.area.toLowerCase()).toSet();
  const noise = {'클럽', 'club', 'clubs', '클'};

  // 쿼리에 포함된 지역어 추출 (공백 무관, 가장 긴 매칭 우선).
  String? matchedArea;
  for (final a in areaSet) {
    if (a.isEmpty) continue;
    if (qNoSpace.contains(a)) {
      if (matchedArea == null || a.length > matchedArea.length) {
        matchedArea = a;
      }
    }
  }

  final scored = <(ClubModel, int)>[];
  for (final c in clubs) {
    final name = c.name.toLowerCase();
    final nameNoSpace = name.replaceAll(RegExp(r'\s+'), '');
    final area = c.area.toLowerCase();
    final genre = c.genre.toLowerCase();
    final address = c.address.toLowerCase();

    var score = 0;

    // 1) 이름 매칭 (가장 강함).
    if (name == q) {
      score += 100;
    } else if (nameNoSpace.startsWith(qNoSpace)) {
      score += 80;
    } else if (nameNoSpace.contains(qNoSpace)) {
      score += 60;
    }

    // 2) 지역어 매칭.
    if (matchedArea != null && area == matchedArea) score += 50;

    // 3) 토큰 단위 매칭 (노이즈어 제외).
    for (final t in tokens) {
      if (noise.contains(t)) continue;
      if (t == area) score += 30;
      if (genre.contains(t)) score += 40;
      if (name.contains(t)) score += 35;
      if (c.tags.any((tag) => tag.toLowerCase().contains(t))) score += 25;
      if (address.contains(t)) score += 10;
    }

    if (score > 0) scored.add((c, score));
  }

  // 점수 → 추천 → 평점 순.
  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    if (byScore != 0) return byScore;
    final byRec = (b.$1.isVybeRecommended ? 1 : 0)
        .compareTo(a.$1.isVybeRecommended ? 1 : 0);
    if (byRec != 0) return byRec;
    return b.$1.rating.compareTo(a.$1.rating);
  });

  return scored.map((e) => e.$1).toList();
}
