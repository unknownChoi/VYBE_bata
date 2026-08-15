import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/utils/map_launcher.dart';
import 'package:vybe/core/utils/phone_launcher.dart';
import 'package:vybe/core/utils/url_utils.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_glass.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_hours_table.dart';
import 'package:vybe/presentation/clubs/renew/widgets/renew_map_card.dart';
import 'package:vybe/presentation/clubs/viewmodels/club_detail_viewmodel.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart'
    show SubwayStationLine, formatEntryFee, subwayLabel;
import 'package:vybe/presentation/common/widgets/vybe_fade_in_up.dart';
import 'package:vybe/presentation/common/widgets/vybe_spinner.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 클럽 상세 리뉴얼 · 매장 정보 탭.
///
/// 디자인 매장정보 패널 — 위치 / 상세 정보 / 이용 안내 + 안내 문구.
///
/// 디자인의 '편의시설'(주차·화장실·흡연실 등) 카드는 Firestore `clubs`에
/// 대응 필드가 없어 넣지 않았다. 없는 정보를 채우면 잘못된 안내가 된다.
class RenewInfoTab extends ConsumerWidget {
  final String clubId;
  final EdgeInsets padding;

  const RenewInfoTab({super.key, required this.clubId, required this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubDetailProvider(clubId));
    final club = clubAsync.value;

    if (club == null) {
      return Center(
        child: clubAsync.isLoading
            ? const VybeSpinner(size: 40)
            : Text('클럽 정보를 불러올 수 없어요', style: RenewGlass.body()),
      );
    }

    final info = ref.watch(clubInfoProvider(clubId)).value;
    final subways = info?.nearbySubways ?? const [];
    final cautions = info?.cautions ?? const <String>[];

    final sections = <Widget>[
      _location(context, club, subways),
      _detail(context, club),
      if (cautions.isNotEmpty) _notice(cautions),
      const RenewFooterNote(
        text: '영업시간 · 입장료 · 라인업은 매장 사정에 따라 달라질 수 있으니 방문 전 확인해 주세요.',
      ),
    ];

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      itemCount: sections.length,
      separatorBuilder: (_, __) => SizedBox(height: RenewGlass.sectionGap.h),
      itemBuilder: (_, i) => VybeFadeInUp(
        delay: Duration(milliseconds: 40 + i * 45),
        child: sections[i],
      ),
    );
  }

  // ==========================================================================
  // 위치 (VRLocation)
  // ==========================================================================

  Widget _location(
    BuildContext context,
    ClubModel club,
    List<Map<String, dynamic>> subways,
  ) {
    final nearest = subways.isEmpty ? null : subways.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RenewSectionHead(
          title: '위치',
          sub: subwayLabel(nearest),
          actionLabel: '지도',
          onAction: () => launchDirections(
            context,
            lat: club.lat,
            lng: club.lng,
            // 목적지 라벨은 주소 — 주소가 비면 클럽 이름으로 폴백
            destination: club.address.isNotEmpty ? club.address : club.name,
          ),
        ),
        RenewMapCard(club: club),
        SizedBox(height: 12.h),
        RenewGlassCard(
          quiet: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 1.h, right: 12.w),
                    child: Icon(
                      Icons.place_outlined,
                      size: 17.r,
                      color: const Color(0x8CFFFFFF),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      club.address.isEmpty ? '주소 정보가 없어요' : club.address,
                      style: RenewGlass.body(lineHeight: 20),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => _copyAddress(context, club.address),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34.r,
                      height: 34.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: RenewGlass.tileFill,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: RenewGlass.tileBorder),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 15.r,
                        color: RenewGlass.t2,
                      ),
                    ),
                  ),
                ],
              ),
              if (subways.isNotEmpty) ...[
                Container(
                  height: 1,
                  color: RenewGlass.hair,
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                ),
                for (var i = 0; i < subways.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == subways.length - 1 ? 0 : 8.h,
                    ),
                    child: SubwayStationLine(subway: subways[i]),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copyAddress(BuildContext context, String address) async {
    if (address.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: address));
    if (!context.mounted) return;
    VybeToast.show(context, message: '주소가 복사되었습니다');
  }

  // ==========================================================================
  // 상세 정보 (VRDetailInfo)
  // ==========================================================================

  Widget _detail(BuildContext context, ClubModel club) {
    final hours = club.operatingHours;
    final today = hours.today;
    final handle = instagramHandle(club.instagramUrl);
    final phone = club.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RenewSectionHead(title: '상세 정보'),
        RenewGlassCard(
          quiet: true,
          child: Column(
            children: [
              RenewInfoRow(
                icon: Icons.schedule_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    SizedBox(height: 12.h),
                    RenewHoursTable(hours: hours),
                  ],
                ),
              ),
              RenewInfoRow(
                icon: Icons.confirmation_number_outlined,
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
              RenewInfoRow(
                icon: Icons.phone_rounded,
                child: GestureDetector(
                  onTap: phone.isEmpty
                      ? null
                      : () => launchPhoneCall(context, phone),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    phone.isEmpty ? '등록된 번호가 없어요' : phone,
                    style: RenewGlass.body(
                      color: phone.isEmpty ? RenewGlass.t4 : RenewGlass.link,
                      lineHeight: 20,
                    ),
                  ),
                ),
              ),
              RenewInfoRow(
                icon: Icons.link_rounded,
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

  // ==========================================================================
  // 이용 안내 (VRNotice)
  // ==========================================================================

  Widget _notice(List<String> cautions) {
    return RenewGlassCard(
      fill: VybeColors.mainPurple500.withValues(alpha: 0.16),
      border: VybeColors.mainPurple500.withValues(alpha: 0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16.r,
                color: VybeColors.mainLime500,
              ),
              SizedBox(width: 7.w),
              Text(
                '이용 안내',
                style: VybeTypography.button1.copyWith(color: RenewGlass.t1),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          for (var i = 0; i < cautions.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == cautions.length - 1 ? 0 : 8.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4.r,
                    height: 4.r,
                    margin: EdgeInsets.only(top: 8.h, right: 8.w),
                    decoration: const BoxDecoration(
                      color: VybeColors.mainLime500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      cautions[i],
                      style: RenewGlass.body(lineHeight: 20),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
