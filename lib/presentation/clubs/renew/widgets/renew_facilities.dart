import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';

/// 편의시설 한 종류 — Firestore 키 ↔ 화면 라벨·아이콘 대응표.
///
/// Firestore(`clubs/{clubId}/info/{clubId}.facilities`)에는 **영문 키만** 저장하고
/// 라벨·아이콘은 앱이 정한다. 한글 라벨을 그대로 저장하면 문구를 고칠 때
/// 전 클럽 문서를 손봐야 하고, 오타 하나가 그대로 화면에 뜬다.
enum ClubFacility {
  parking('parking', '주차 가능', Icons.local_parking_rounded),
  restroom('restroom', '화장실 분리', Icons.wc_rounded),
  smoking('smoking', '흡연실', Icons.smoking_rooms_rounded),
  locker('locker', '물품보관함', Icons.lock_outline_rounded),
  card('card', '카드 결제', Icons.credit_card_rounded),
  groupSeat('groupSeat', '단체석', Icons.groups_rounded);

  /// Firestore에 저장되는 값.
  final String key;

  /// 화면 라벨.
  final String label;

  /// 디자인 SVG에 대응하는 머티리얼 아이콘 (전용 아이콘 에셋이 없어 근사).
  final IconData icon;

  const ClubFacility(this.key, this.label, this.icon);

  static ClubFacility? fromKey(String key) {
    for (final f in ClubFacility.values) {
      if (f.key == key) return f;
    }
    return null;
  }
}

/// 저장된 키 목록을 화면에 그릴 수 있는 항목으로 바꾼다.
///
/// - 모르는 키는 **버린다** — 영문 키를 그대로 노출하면 잘못된 안내가 된다.
///   시설을 늘리려면 [ClubFacility]에 항목을 추가할 것.
/// - 중복은 제거하고, 순서는 저장 순서가 아니라 [ClubFacility] 선언 순서를
///   따른다(클럽마다 아이콘 자리가 달라지지 않게).
List<ClubFacility> parseFacilities(List<String> keys) {
  final found = <ClubFacility>{};
  for (final k in keys) {
    final f = ClubFacility.fromKey(k);
    if (f != null) found.add(f);
  }
  return ClubFacility.values.where(found.contains).toList();
}

/// 클럽 상세 리뉴얼 · 편의시설 섹션 (디자인 `VRFacilities`).
///
/// 3열 그리드 — 원형 타일 + 라임 아이콘 + 라벨.
/// 항목이 하나도 없으면 호출부에서 섹션 자체를 빼므로 여기선 비어 있는 경우를
/// 따로 그리지 않는다.
class RenewFacilities extends StatelessWidget {
  final List<ClubFacility> items;

  const RenewFacilities({super.key, required this.items});

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    // 마지막 줄이 비면 빈 칸으로 채워 3열 폭을 유지한다.
    final rows = <List<ClubFacility?>>[];
    for (var i = 0; i < items.length; i += _columns) {
      final row = List<ClubFacility?>.filled(_columns, null);
      for (var c = 0; c < _columns && i + c < items.length; c++) {
        row[c] = items[i + c];
      }
      rows.add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(title: '편의시설', sub: '${items.length}가지'),
        RenewGlassCard(
          quiet: true,
          padding: 8,
          child: Column(
            children: [
              for (var r = 0; r < rows.length; r++)
                Padding(
                  padding: EdgeInsets.only(bottom: r == rows.length - 1 ? 0 : 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var c = 0; c < _columns; c++) ...[
                        if (c > 0) SizedBox(width: 8.w),
                        Expanded(
                          child: rows[r][c] == null
                              ? const SizedBox.shrink()
                              : _Cell(facility: rows[r][c]!),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final ClubFacility facility;

  const _Cell({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RenewGlass.tileFill,
              shape: BoxShape.circle,
              border: Border.all(color: RenewGlass.tileBorder),
            ),
            child: Icon(
              facility.icon,
              size: 19.r,
              color: VybeColors.mainLime500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            facility.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: RenewGlass.caption(
              color: RenewGlass.t3,
              size: 11,
              lineHeight: 14,
            ),
          ),
        ],
      ),
    );
  }
}
