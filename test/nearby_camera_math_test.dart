import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/operating_hours.dart';
import 'package:vybe/presentation/nearby/nearby_camera_math.dart';

ClubModel _club({required String id, required double lat, required double lng}) {
  return ClubModel(
    clubId: id,
    name: id,
    description: '',
    address: '',
    area: '홍대',
    phone: '',
    instagramUrl: '',
    lat: lat,
    lng: lng,
    geohash: '',
    genre: '힙합',
    genreStyles: const [],
    rating: 4.0,
    reviewCount: 1,
    operatingHours: const OperatingHours(),
    entryFeeMin: 0,
    entryFeeMax: 0,
    heroImageUrls: const [],
    imageUrls: const [],
    menuBoardUrls: const [],
    thumbnailUrl: '',
    tags: const [],
    favoriteCount: 0,
    isActive: true,
    isVybeRecommended: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('pinCardPivotY', () {
    test('높이를 아직 못 쟀으면 폴백', () {
      expect(
        NearbyCameraMath.pinCardPivotY(
          stackHeight: 0,
          topInset: 170,
          cardTop: 400,
        ),
        NearbyCameraMath.fallbackPinPivotY,
      );
    });

    test('카드가 상단 스크림까지 올라와 지도 밴드가 없으면 폴백', () {
      expect(
        NearbyCameraMath.pinCardPivotY(
          stackHeight: 800,
          topInset: 170,
          cardTop: 120, // 스크림보다 위
        ),
        NearbyCameraMath.fallbackPinPivotY,
      );
    });

    test('밴드가 있으면 그 한가운데 비율', () {
      // 밴드 170~570 → 중심 370 / 800 = 0.4625
      expect(
        NearbyCameraMath.pinCardPivotY(
          stackHeight: 800,
          topInset: 170,
          cardTop: 570,
        ),
        closeTo(0.4625, 1e-9),
      );
    });

    test('중심이 아래로 치우쳐도 0.5를 넘지 않는다 (핀 카드에 가림)', () {
      final pivot = NearbyCameraMath.pinCardPivotY(
        stackHeight: 800,
        topInset: 170,
        cardTop: 790,
      );
      expect(pivot, lessThanOrEqualTo(NearbyCameraMath.maxPivotY));
    });
  });

  group('searchCameraPadding', () {
    const args = (topInset: 170.0, sheetMid: 0.56, minBand: 120.0);

    test('보통 화면에서는 시트 높이만큼 아래를 비운다', () {
      final pad = NearbyCameraMath.searchCameraPadding(
        stackHeight: 800,
        topInset: args.topInset,
        sheetMid: args.sheetMid,
        minBand: args.minBand,
        sidePad: 40,
        gap: 16,
      );
      expect(pad.top, 170);
      expect(pad.bottom, 800 * 0.56 + 16);
      expect(pad.left, 40);
    });

    test('화면이 짧으면 최소 지도 밴드를 남긴다', () {
      // 400 - 170 - (400*0.56+16) = 400-170-240 = -10 → 밴드 부족
      final pad = NearbyCameraMath.searchCameraPadding(
        stackHeight: 400,
        topInset: args.topInset,
        sheetMid: args.sheetMid,
        minBand: args.minBand,
        sidePad: 40,
        gap: 16,
      );
      expect(400 - pad.top - pad.bottom, greaterThanOrEqualTo(0));
      expect(pad.bottom, lessThanOrEqualTo(400 * 0.56 + 16));
    });

    test('여백이 화면보다 커도 bottom은 음수가 되지 않는다', () {
      final pad = NearbyCameraMath.searchCameraPadding(
        stackHeight: 200,
        topInset: args.topInset,
        sheetMid: args.sheetMid,
        minBand: args.minBand,
        sidePad: 40,
        gap: 16,
      );
      expect(pad.bottom, greaterThanOrEqualTo(0));
    });
  });

  group('searchPivotY', () {
    test('밴드가 사라지면 폴백', () {
      expect(
        NearbyCameraMath.searchPivotY(
          stackHeight: 300,
          padding: const EdgeInsets.only(top: 200, bottom: 200),
        ),
        NearbyCameraMath.fallbackSearchPivotY,
      );
    });

    test('밴드 한가운데 비율을 0.15~0.5로 자른다', () {
      final pivot = NearbyCameraMath.searchPivotY(
        stackHeight: 800,
        padding: const EdgeInsets.only(top: 170, bottom: 464),
      );
      expect(pivot, inInclusiveRange(0.15, 0.5));
    });
  });

  group('boundsOf', () {
    test('1개 이하는 null — fitBounds가 성립하지 않는다', () {
      expect(NearbyCameraMath.boundsOf([]), isNull);
      expect(
        NearbyCameraMath.boundsOf([_club(id: 'a', lat: 37.5, lng: 127.0)]),
        isNull,
      );
    });

    test('전부 감싸는 남서·북동 모서리', () {
      final bounds = NearbyCameraMath.boundsOf([
        _club(id: 'a', lat: 37.5, lng: 127.0),
        _club(id: 'b', lat: 37.1, lng: 127.9),
        _club(id: 'c', lat: 37.8, lng: 126.5),
      ])!;
      expect(bounds.southWest.latitude, closeTo(37.1, 1e-9));
      expect(bounds.southWest.longitude, closeTo(126.5, 1e-9));
      expect(bounds.northEast.latitude, closeTo(37.8, 1e-9));
      expect(bounds.northEast.longitude, closeTo(127.9, 1e-9));
    });
  });

  test('centerOf — 그룹 좌표 평균', () {
    final center = NearbyCameraMath.centerOf([
      _club(id: 'a', lat: 37.0, lng: 127.0),
      _club(id: 'b', lat: 38.0, lng: 128.0),
    ]);
    expect(center.latitude, closeTo(37.5, 1e-9));
    expect(center.longitude, closeTo(127.5, 1e-9));
  });

  group('viewportQuery', () {
    test('중심은 bounds 중점, 반경엔 버퍼가 붙는다', () {
      const bounds = NLatLngBounds(
        southWest: NLatLng(37.4, 126.8),
        northEast: NLatLng(37.6, 127.2),
      );
      final plain = NearbyCameraMath.viewportQuery(bounds, buffer: 1.0);
      final buffered = NearbyCameraMath.viewportQuery(bounds);

      expect(plain.lat, closeTo(37.5, 1e-9));
      expect(plain.lng, closeTo(127.0, 1e-9));
      expect(buffered.radiusKm, closeTo(plain.radiusKm * 1.2, 1e-6));
      expect(plain.radiusKm, greaterThan(0));
    });
  });

  group('distanceMeters', () {
    test('좌표가 없는 클럽(0,0)은 거리 표기를 생략한다', () {
      expect(
        NearbyCameraMath.distanceMeters(
          _club(id: 'x', lat: 0, lng: 0),
          37.5,
          127.0,
        ),
        isNull,
      );
    });

    test('같은 좌표면 0m', () {
      expect(
        NearbyCameraMath.distanceMeters(
          _club(id: 'x', lat: 37.5, lng: 127.0),
          37.5,
          127.0,
        ),
        closeTo(0, 1e-6),
      );
    });
  });
}
