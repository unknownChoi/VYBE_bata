import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/constants/app_geo.dart';
import 'package:vybe/core/constants/korea_regions.dart';

void main() {
  group('AppGeo.areaOf — 클럽 상권 우선', () {
    test('상권 중심 좌표는 행정구역명이 아니라 상권명으로 잡힌다', () {
      for (final entry in AppGeo.hotspotCenters.entries) {
        expect(
          AppGeo.areaOf(entry.value.lat, entry.value.lng),
          entry.key,
          reason: '${entry.key} 중심 좌표',
        );
      }
    });

    test('가까이 붙은 상권은 반경이 아니라 최근접으로 갈린다', () {
      // 홍대·신촌은 1.2km라 서로의 반경 안에 있다.
      expect(AppGeo.areaOf(37.5547, 126.9230), '홍대');
      expect(AppGeo.areaOf(37.5559, 126.9368), '신촌');
    });

    test('폴백 좌표(홍대)는 상권으로 잡힌다 — 칩이 빈 채로 시작하지 않게', () {
      expect(
        AppGeo.areaOf(AppGeo.hongdaeLat, AppGeo.hongdaeLng),
        AppGeo.hongdaeLabel,
      );
    });

    test('같은 구 안이어도 상권 반경 밖이면 행정구역명', () {
      // 상암동 — 마포구지만 홍대에서 4km 넘게 떨어져 있다.
      expect(AppGeo.areaOf(37.5794, 126.8894), '마포구');
    });
  });

  group('AppGeo.areaOf — 전국 시군구', () {
    test('서울 밖 주요 지점이 실제 시군구로 잡힌다', () {
      expect(AppGeo.areaOf(35.1587, 129.1604), '해운대구'); // 부산 해운대
      expect(AppGeo.areaOf(33.4996, 126.5312), '제주시'); // 제주
      expect(AppGeo.areaOf(37.2812, 127.0128), '팔달구'); // 경기 수원 화성행궁
      expect(AppGeo.areaOf(36.4800, 127.2890), '세종'); // 세종
      expect(AppGeo.areaOf(35.8714, 128.6014), '대구 중구'); // 대구 중구
    });

    test('이름이 겹치는 구는 시도가 앞에 붙는다', () {
      // 서울 중구(명동)와 부산 중구(남포동)가 서로 다른 라벨로 나와야 한다.
      expect(AppGeo.areaOf(37.5636, 126.9970), '서울 중구');
      expect(AppGeo.areaOf(35.1030, 129.0324), '부산 중구');
    });

    test('국내에서 멀면 null — 해외에 한국 지역명을 붙이지 않는다', () {
      expect(AppGeo.areaOf(35.6762, 139.6503), isNull); // 도쿄
      expect(AppGeo.areaOf(0, 0), isNull); // 좌표 없음(0,0)
    });
  });

  group('국내 밖 대체 상권', () {
    test('후보가 전부 hotspotCenters에 있다 — 좌표를 못 찾으면 대체가 무너진다', () {
      for (final area in AppGeo.overseasFallbackAreas) {
        expect(AppGeo.hotspotCenters.containsKey(area), isTrue, reason: area);
      }
    });

    test('후보 좌표는 자기 상권으로 되잡힌다', () {
      for (final area in AppGeo.overseasFallbackAreas) {
        final c = AppGeo.hotspotCenters[area]!;
        expect(AppGeo.areaOf(c.lat, c.lng), area);
      }
    });
  });

  group('koreaRegions 표', () {
    test('라벨이 전부 유일하다 — 같은 이름이 둘이면 어느 지역인지 못 읽는다', () {
      final labels = koreaRegions.map((r) => r.label).toList();
      expect(labels.toSet().length, labels.length);
    });

    test('좌표가 전부 대한민국 범위 안', () {
      for (final r in koreaRegions) {
        expect(r.lat, inInclusiveRange(33.0, 38.7), reason: r.label);
        expect(r.lng, inInclusiveRange(124.5, 132.0), reason: r.label);
      }
    });

    test('252개 (세종 포함, 군위군은 대구, 구가 있는 12개 시는 구 단위)', () {
      expect(koreaRegions.length, 252);
    });

    test('구가 있는 시는 시 이름이 아니라 구로 잡힌다', () {
      // 시 하나로 두면 분당·일산 같은 생활권이 한 이름으로 뭉개진다.
      expect(AppGeo.areaOf(37.3827, 127.1187), '분당구'); // 성남 분당
      expect(AppGeo.areaOf(37.6586, 126.7700), '일산동구'); // 고양 일산
      expect(AppGeo.areaOf(37.3221, 127.0977), '수지구'); // 용인 수지
      expect(AppGeo.areaOf(35.2018, 128.6800), '성산구'); // 창원 성산
    });

    test('경기 광주시는 광주광역시와 다른 좌표·라벨', () {
      // 원본 표가 경기 광주시에 광주광역시 좌표를 넣어 둬 교정한 자리.
      expect(AppGeo.areaOf(37.4295, 127.2550), '경기 광주시');
      expect(AppGeo.areaOf(35.1394, 126.7913), '광산구'); // 광주광역시 송정역
    });
  });
}
