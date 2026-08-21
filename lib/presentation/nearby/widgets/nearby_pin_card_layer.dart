import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/core/providers/location_providers.dart';
import 'package:vybe/core/utils/map_launcher.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/presentation/clubs/viewmodels/favorite_viewmodel.dart';
import 'package:vybe/presentation/main_scaffold/main_scaffold.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_visibility_provider.dart';
import 'package:vybe/presentation/nearby/nearby_camera_math.dart';
import 'package:vybe/presentation/nearby/widgets/club_pin_card.dart';

/// 핀 탭으로 뜨는 클럽 요약 카드 레이어 (디자인 NGPinCard).
///
/// [club]이 null이어도 이 위젯은 남는다 — [ClubPinCardTransition]이 옛 카드를
/// 붙잡고 퇴장 애니메이션을 돌리기 때문. 대신 그동안 탭은 받지 않는다
/// (닫자마자 상세로 들어가는 사고 방지).
class NearbyPinCardLayer extends ConsumerWidget {
  /// 떠 있는 클럽. null이면 카드 없음(= 리스트 시트 표시).
  final ClubModel? club;

  final void Function(ClubModel club) onOpenDetail;
  final VoidCallback onClose;

  const NearbyPinCardLayer({
    super.key,
    required this.club,
    required this.onOpenDetail,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = club;
    // nav 바가 축소되면 그만큼 카드도 내려가 바와의 여백(10)을 유지한다.
    // 카드가 없을 땐 구독하지 않는다 — nav 축소마다 화면 전체가 리빌드되는 걸 막고,
    // 퇴장 애니메이션(240ms) 동안은 마지막 위치를 그대로 쓰면 충분하다.
    final navExpanded = current != null
        ? ref.watch(navBarVisibilityProvider)
        : ref.read(navBarVisibilityProvider);

    return AnimatedPositioned(
      duration: navBarResizeDuration,
      curve: navBarResizeCurve,
      left: 12.w,
      right: 12.w,
      bottom: navBarTotalHeight(context, expanded: navExpanded) + 10.h,
      child: IgnorePointer(
        ignoring: current == null,
        child: ClubPinCardTransition(
          child: current == null
              ? null
              : _Card(
                  // 다른 핀으로 갈아탈 때 새 카드로 인식돼 전환이 다시 돈다.
                  key: ValueKey(current.clubId),
                  club: current,
                  onOpenDetail: onOpenDetail,
                  onClose: onClose,
                ),
        ),
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  final ClubModel club;
  final void Function(ClubModel club) onOpenDetail;
  final VoidCallback onClose;

  const _Card({
    super.key,
    required this.club,
    required this.onOpenDetail,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final favoritedIds = ref.watch(mergedFavoriteIdsProvider);
    final myLocation = ref.watch(userLocationProvider);
    final isFavorited = favoritedIds.contains(club.clubId);

    return ClubPinCard(
      club: club,
      isFavorited: isFavorited,
      distanceMeters: NearbyCameraMath.distanceMeters(
        club,
        myLocation.lat,
        myLocation.lng,
      ),
      onTap: () => onOpenDetail(club),
      onClose: onClose,
      onDirectionsTap: () => launchDirections(
        context,
        lat: club.lat,
        lng: club.lng,
        destination: club.address,
      ),
      onFavoriteTap: uid == null
          ? null
          : () => ref
                .read(favoriteViewModelProvider.notifier)
                .toggleFavorite(uid, club.clubId, isFavorited),
    );
  }
}
