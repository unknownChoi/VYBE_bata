import 'dart:math';

class GeohashUtils {
  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  static String encode(double lat, double lng, int precision) {
    var idx = 0;
    var bits = 0;
    var isEven = true;
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;
    final hash = StringBuffer();

    while (hash.length < precision) {
      if (isEven) {
        final mid = (minLng + maxLng) / 2;
        if (lng >= mid) {
          idx = idx * 2 + 1;
          minLng = mid;
        } else {
          idx = idx * 2;
          maxLng = mid;
        }
      } else {
        final mid = (minLat + maxLat) / 2;
        if (lat >= mid) {
          idx = idx * 2 + 1;
          minLat = mid;
        } else {
          idx = idx * 2;
          maxLat = mid;
        }
      }
      isEven = !isEven;
      if (++bits == 5) {
        hash.write(_base32[idx]);
        bits = 0;
        idx = 0;
      }
    }
    return hash.toString();
  }

  static ({double latMin, double latMax, double lngMin, double lngMax}) _bounds(
      String geohash) {
    var isEven = true;
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;

    for (final c in geohash.split('')) {
      final ci = _base32.indexOf(c);
      for (var b = 4; b >= 0; b--) {
        final bit = (ci >> b) & 1;
        if (isEven) {
          if (bit == 1) {
            minLng = (minLng + maxLng) / 2;
          } else {
            maxLng = (minLng + maxLng) / 2;
          }
        } else {
          if (bit == 1) {
            minLat = (minLat + maxLat) / 2;
          } else {
            maxLat = (minLat + maxLat) / 2;
          }
        }
        isEven = !isEven;
      }
    }
    return (latMin: minLat, latMax: maxLat, lngMin: minLng, lngMax: maxLng);
  }

  /// 중심 좌표 주변 9개 geohash 셀 prefix 반환 (center + 8 neighbors)
  static List<String> neighborPrefixes(double lat, double lng, int precision) {
    final centerHash = encode(lat, lng, precision);
    final b = _bounds(centerHash);
    final latSpan = b.latMax - b.latMin;
    final lngSpan = b.lngMax - b.lngMin;
    final cellLat = (b.latMin + b.latMax) / 2;
    final cellLng = (b.lngMin + b.lngMax) / 2;

    final prefixes = <String>{};
    for (final dlat in const [-1, 0, 1]) {
      for (final dlng in const [-1, 0, 1]) {
        final nLat = (cellLat + dlat * latSpan).clamp(-90.0, 90.0);
        var nLng = cellLng + dlng * lngSpan;
        if (nLng > 180) nLng -= 360;
        if (nLng < -180) nLng += 360;
        prefixes.add(encode(nLat, nLng, precision));
      }
    }
    return prefixes.toList();
  }

  static double haversineKm(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * r * asin(sqrt(a));
  }

  static int precisionForRadius(double radiusKm) {
    if (radiusKm <= 0.5) return 7;
    if (radiusKm <= 1.0) return 6;
    if (radiusKm <= 5.0) return 5;
    if (radiusKm <= 40.0) return 4;
    return 3;
  }
}
