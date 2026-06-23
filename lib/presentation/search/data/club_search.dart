import 'package:vybe/presentation/search/data/dummy_clubs.dart';

/// 테스트용 클럽 검색 알고리즘 (가상 데이터 DummyClub 대상).
///
/// 사용자가 클럽 이름("버뮤다"), 지역+카테고리("홍대클럽"), 장르("테크노") 등
/// 제각각 검색해도 관련도 점수로 정렬해 가장 맞는 결과가 위로 오게 한다.
///
/// 사전(지역·장르 후보)은 코드에 하드코딩하지 않고 **데이터에서 동적 추출**한다.
/// → 새 지역/장르가 추가돼도 자동 반영.
List<DummyClub> searchDummyClubs(List<DummyClub> clubs, String rawQuery) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) return const [];

  // 공백 제거 버전 ("홍대 클럽" / "홍대클럽" 동일 취급).
  final qNoSpace = q.replaceAll(RegExp(r'\s+'), '');
  // 공백 토큰 (다중어 검색 "강남 테크노").
  final tokens =
      q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  // ── 데이터 기반 동적 사전 ──
  final areaSet = clubs.map((c) => c.area.toLowerCase()).toSet();

  // 거의 모든 장르/이름에 흔해 변별력 없는 노이즈어.
  const noise = {'클럽', 'club', 'clubs', '클'};

  // 쿼리에 포함된 지역어 추출 (공백 무관, 가장 긴 매칭 우선).
  String? matchedArea;
  for (final a in areaSet) {
    if (qNoSpace.contains(a)) {
      if (matchedArea == null || a.length > matchedArea.length) {
        matchedArea = a;
      }
    }
  }

  final scored = <(DummyClub, int)>[];
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
    if (matchedArea != null && area == matchedArea) {
      score += 50;
    }

    // 3) 토큰 단위 매칭 (노이즈어 제외).
    for (final t in tokens) {
      if (noise.contains(t)) continue;
      if (t == area) score += 30;
      if (genre.contains(t)) score += 40;
      if (name.contains(t)) score += 35;
      if (address.contains(t)) score += 10;
    }

    if (score > 0) scored.add((c, score));
  }

  // 점수순 → 추천 → 평점 순.
  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    if (byScore != 0) return byScore;
    final byRec =
        (b.$1.isVybeRecommended ? 1 : 0).compareTo(a.$1.isVybeRecommended ? 1 : 0);
    if (byRec != 0) return byRec;
    return b.$1.rating.compareTo(a.$1.rating);
  });

  return scored.map((e) => e.$1).toList();
}
