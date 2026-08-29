/// 클럽 목록 화면(입장비 무료 · 서비스 음료 등)이 공유하는 거리·정렬 로직.
///
/// 순수 함수만 둔다 — Flutter·Firebase 의존 없음.
library;

import 'package:vybe/core/utils/geohash_utils.dart';

/// 목록 정렬에 필요한 최소 필드. 화면별 카드 뷰모델이 구현한다.
abstract interface class ClubSortable {
  /// 클럽 지역 (예: '홍대').
  String get area;

  /// 클럽 좌표. 둘 다 0이면 좌표 없음으로 보고 [ClubAreaDistance] 표로 떨어진다.
  double get lat;
  double get lng;

  /// 내 위치 기준 거리(km). [buildClubList] 가 채운다.
  double get dist;

  double get rating;

  /// 지금 영업 중인지.
  bool get open;
}

/// 정렬 옵션 라벨. 드롭다운 표시값 = 정렬 키.
const kClubSorts = ['거리순', '평점순', '추천순'];

/// 필터 '전체' 라벨 — 이 값이면 필터를 걸지 않는다.
const kFilterAll = '전체';

/// [kClubSorts] 기준 비교자.
///
/// - `평점순`: 평점 내림차순
/// - `추천순`: 영업 중 우선 → 평점 내림차순
/// - 그 외(`거리순`): 거리 오름차순
int compareClubs(ClubSortable a, ClubSortable b, String sort) {
  if (sort == '평점순') return b.rating.compareTo(a.rating);
  if (sort == '추천순') {
    final byOpen = (b.open ? 1 : 0) - (a.open ? 1 : 0);
    return byOpen != 0 ? byOpen : b.rating.compareTo(a.rating);
  }
  return a.dist.compareTo(b.dist);
}

/// 내 위치(지역) → 클럽 지역 대략 거리 추정. **좌표가 없을 때만 쓰는 폴백.**
///
/// ⚠ 표에 있는 5개 상권끼리만 값이 있다 — 내 위치가 '신촌'·'마포구'처럼 표에 없는
/// 지역이면 전부 [estimate] 의 fallback(대개 0)으로 떨어져 거리가 0km로 보인다.
/// 그래서 좌표를 아는 클럽은 [buildClubList] 가 haversine 실거리를 먼저 쓴다.
///
/// 같은 지역 클럽이 전부 같은 거리로 뭉치지 않도록 인덱스 기반 미세 편차를 더한다
/// (결정적 — 리스트를 다시 그려도 순서가 흔들리지 않음).
class ClubAreaDistance {
  const ClubAreaDistance._();

  static const _table = <String, Map<String, double>>{
    '홍대': {'홍대': 0.4, '강남': 11.2, '이태원': 7.1, '압구정': 9.3, '건대': 12.8},
    '강남': {'홍대': 11.0, '강남': 0.5, '이태원': 4.8, '압구정': 2.9, '건대': 7.9},
    '이태원': {'홍대': 7.0, '강남': 4.9, '이태원': 0.4, '압구정': 3.6, '건대': 8.8},
    '압구정': {'홍대': 9.1, '강남': 3.0, '이태원': 3.7, '압구정': 0.5, '건대': 6.2},
    '건대': {'홍대': 12.5, '강남': 7.8, '이태원': 8.7, '압구정': 6.1, '건대': 0.4},
  };

  /// [from] 에서 [to] 지역까지 추정 거리(km, 소수 1자리).
  ///
  /// 표에 없는 조합이면 [fallback] 을 기준값으로 쓴다.
  static double estimate({
    required String from,
    required String to,
    required int index,
    double fallback = 0,
  }) {
    final base = _table[from]?[to] ?? fallback;
    return ((base + (index % 5) * 0.16) * 10).round() / 10;
  }
}

/// [source] 에 거리 재계산 → 필터 → 정렬을 순서대로 적용한다.
///
/// [withDist] 는 거리만 바꾼 복사본을 돌려주는 함수(`copyWithDist`),
/// [keep] 은 필터 술어(null이면 전부 통과).
///
/// 거리는 **내 좌표([myLat]·[myLng])와 클럽 좌표의 haversine 실거리**가 기본이다.
/// 둘 중 한쪽이라도 좌표가 없을 때만 [loc] 기준 [ClubAreaDistance] 표로 떨어진다 —
/// 표는 상권 5곳끼리만 값이 있어 '신촌'·'마포구'에 있으면 전부 0km가 되기 때문.
List<T> buildClubList<T extends ClubSortable>(
  List<T> source, {
  required String loc,
  required String sort,
  required T Function(T item, double dist) withDist,
  double? myLat,
  double? myLng,
  bool Function(T item)? keep,
}) {
  final hasMe = myLat != null && myLng != null && !(myLat == 0 && myLng == 0);

  final mapped = <T>[];
  for (var i = 0; i < source.length; i++) {
    final item = source[i];
    final hasClub = !(item.lat == 0 && item.lng == 0);
    final km = hasMe && hasClub
        ? GeohashUtils.haversineKm(myLat, myLng, item.lat, item.lng)
        : ClubAreaDistance.estimate(
            from: loc,
            to: item.area,
            index: i,
            fallback: item.dist,
          );
    mapped.add(withDist(item, (km * 10).round() / 10));
  }
  final list = keep == null ? mapped : mapped.where(keep).toList();
  return list..sort((a, b) => compareClubs(a, b, sort));
}
