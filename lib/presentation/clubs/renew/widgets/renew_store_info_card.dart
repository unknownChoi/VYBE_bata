import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/url_utils.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_hours_table.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_icons.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart'
    show SubwayStationLine, formatEntryFee;

/// 홈 탭 '매장 정보' 카드 (디자인 VRToday).
///
/// 주소·영업시간은 눌러서 펼치고, 입장료·인스타는 한 줄로 끝난다.
///
/// 도형 규격 — quiet 글래스 카드(radius 19) · 좌우 16 / 위아래 13 여백,
/// 행 사이 12 + hairline 구분선(마지막 행 없음), 첫 행 위·마지막 행 아래는
/// 카드 여백이 맡아 0. 아이콘은 24 viewBox 스트로크([RenewIcons], 17px),
/// 펼침 꺾쇠는 15px·두께 2.2.
///
/// 디자인의 '지번 / 안내(입구 설명)'는 Firestore(`clubs`)에 대응 필드가 없어
/// 펼침 영역에는 주변 지하철역만 넣는다 — 없는 정보를 지어내지 않는다.
class RenewStoreInfoCard extends StatefulWidget {
  final ClubModel club;
  final ClubInfoModel? info;

  const RenewStoreInfoCard({super.key, required this.club, this.info});

  @override
  State<RenewStoreInfoCard> createState() => _RenewStoreInfoCardState();
}

class _RenewStoreInfoCardState extends State<RenewStoreInfoCard> {
  bool _addrOpen = false;
  bool _hoursOpen = false;

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final hours = club.operatingHours;
    final today = hours.today;
    final subways = widget.info?.nearbySubways ?? const [];
    final handle = instagramHandle(club.instagramUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RenewSectionHead(title: '매장 정보'),
        RenewGlassCard(
          quiet: true,
          // 디자인 VGlass pad 16 + paddingTop/Bottom 13
          paddingV: 13,
          child: Column(
            children: [
              // 주소 — 펼치면 주변 지하철역
              RenewInfoRow(
                svgPath: RenewIcons.pin,
                first: true,
                child: _expandable(
                  open: _addrOpen,
                  enabled: subways.isNotEmpty,
                  onToggle: () => setState(() => _addrOpen = !_addrOpen),
                  header: Text(
                    club.address.isEmpty ? '주소 정보가 없어요' : club.address,
                    style: RenewGlass.body(lineHeight: 20),
                  ),
                  headerCrossAxis: CrossAxisAlignment.start,
                  body: Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < subways.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == subways.length - 1 ? 0 : 7.h,
                            ),
                            // 디자인 펼침 영역 배지는 17 (위치 카드의 21보다 작다)
                            child: SubwayStationLine(
                              subway: subways[i],
                              badgeSize: 17,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // 영업시간 — 펼치면 요일별 전체
              RenewInfoRow(
                svgPath: RenewIcons.clock,
                child: _expandable(
                  open: _hoursOpen,
                  enabled: true,
                  onToggle: () => setState(() => _hoursOpen = !_hoursOpen),
                  header: Row(
                    children: [
                      RenewStatusPill(isOpen: today.isCurrentlyOpen),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          renewHoursSummary(today),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RenewGlass.body(
                            color: RenewGlass.t3,
                            lineHeight: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: RenewHoursTable(hours: hours),
                  ),
                ),
              ),
              // 입장료
              RenewInfoRow(
                svgPath: RenewIcons.ticket,
                child: Row(
                  children: [
                    Text('입장료 ', style: RenewGlass.body(lineHeight: 20)),
                    Text(
                      formatEntryFee(
                        min: club.entryFeeMin,
                        max: club.entryFeeMax,
                      ),
                      style: RenewGlass.body(
                        color: RenewGlass.t1,
                        lineHeight: 20,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 인스타그램
              RenewInfoRow(
                svgPath: RenewIcons.link,
                last: true,
                child: Text(
                  handle.isEmpty ? '등록된 링크가 없어요' : handle,
                  style: RenewGlass.body(
                    color: handle.isEmpty ? RenewGlass.t4 : RenewGlass.link,
                    lineHeight: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 헤더를 누르면 [body]가 펼쳐지는 행. [enabled]가 false면 화살표 없이 헤더만.
  Widget _expandable({
    required bool open,
    required bool enabled,
    required VoidCallback onToggle,
    required Widget header,
    required Widget body,
    CrossAxisAlignment headerCrossAxis = CrossAxisAlignment.center,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: enabled ? onToggle : null,
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: headerCrossAxis,
            children: [
              Expanded(child: header),
              if (enabled)
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.w,
                    top: headerCrossAxis == CrossAxisAlignment.start ? 3.h : 0,
                  ),
                  child: AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    // 디자인 VRChev — 15px · 두께 2.2 · rgba(255,255,255,0.5)
                    child: const RenewChevron(size: 15),
                  ),
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: open ? body : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
