import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/presentation/common/club_list_sorting.dart';

/// 목록 화면 카드 대역 — [ClubSortable] 최소 구현.
class _Card implements ClubSortable {
  @override
  final String area;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final double dist;
  @override
  final double rating;
  @override
  final bool open;

  const _Card({
    required this.area,
    this.lat = 0,
    this.lng = 0,
    this.dist = 0,
    this.rating = 0,
    this.open = true,
  });

  _Card copyWithDist(double d) => _Card(
    area: area,
    lat: lat,
    lng: lng,
    dist: d,
    rating: rating,
    open: open,
  );
}

// 홍대 / 강남 실좌표.
const _hongdaeLat = 37.5547;
const _hongdaeLng = 126.9230;
const _gangnamLat = 37.4979;
const _gangnamLng = 127.0276;

List<_Card> _run(
  List<_Card> src, {
  required String loc,
  double? myLat,
  double? myLng,
  String sort = '거리순',
}) => buildClubList(
  src,
  loc: loc,
  sort: sort,
  myLat: myLat,
  myLng: myLng,
  withDist: (c, d) => c.copyWithDist(d),
);

void main() {
  group('buildClubList 거리', () {
    test('좌표가 있으면 haversine 실거리를 쓴다', () {
      final list = _run(
        const [
          _Card(area: '강남', lat: _gangnamLat, lng: _gangnamLng),
          _Card(area: '홍대', lat: _hongdaeLat, lng: _hongdaeLng),
        ],
        loc: '홍대',
        myLat: _hongdaeLat,
        myLng: _hongdaeLng,
      );

      // 내 위치 = 홍대 → 홍대 클럽 0km, 강남 클럽 ~11km. 가까운 순.
      expect(list.first.area, '홍대');
      expect(list.first.dist, 0.0);
      expect(list.last.dist, greaterThan(9));
      expect(list.last.dist, lessThan(13));
    });

    test('거리표에 없는 지역이어도 좌표만 있으면 0km로 뭉치지 않는다', () {
      // 회귀 방지 — 예전엔 loc이 표에 없으면(신촌·마포구) 전부 fallback 0이 됐다.
      final list = _run(
        const [
          _Card(area: '강남', lat: _gangnamLat, lng: _gangnamLng),
          _Card(area: '홍대', lat: _hongdaeLat, lng: _hongdaeLng),
        ],
        loc: '신촌',
        myLat: 37.5559,
        myLng: 126.9368,
      );

      expect(list.map((c) => c.dist).toSet().length, 2);
      expect(list.every((c) => c.dist > 0), isTrue);
      expect(list.first.area, '홍대');
    });

    test('클럽 좌표가 없으면 지역 거리표로 떨어진다', () {
      final list = _run(
        const [_Card(area: '강남'), _Card(area: '홍대')],
        loc: '홍대',
        myLat: _hongdaeLat,
        myLng: _hongdaeLng,
      );

      expect(list.first.area, '홍대');
      expect(list.first.dist, closeTo(0.4, 0.5));
      expect(list.last.dist, closeTo(11.2, 0.5));
    });

    test('내 좌표가 없으면 지역 거리표로 떨어진다', () {
      final list = _run(
        const [
          _Card(area: '강남', lat: _gangnamLat, lng: _gangnamLng),
          _Card(area: '홍대', lat: _hongdaeLat, lng: _hongdaeLng),
        ],
        loc: '홍대',
      );

      expect(list.first.dist, closeTo(0.4, 0.5));
      expect(list.last.dist, closeTo(11.2, 0.5));
    });

    test('거리는 소수 1자리로 굳힌다', () {
      final list = _run(
        const [_Card(area: '강남', lat: _gangnamLat, lng: _gangnamLng)],
        loc: '홍대',
        myLat: _hongdaeLat,
        myLng: _hongdaeLng,
      );

      final d = list.single.dist;
      expect((d * 10).round() / 10, d);
    });
  });
}
