import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/clubs/widgets/club_glass.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';
import 'package:vybe/presentation/saved/saved_common.dart';
import 'package:vybe/presentation/saved/viewmodels/saved_viewmodel.dart';

// 찜 카드 썸네일 (리스트·그리드 공용).

class SavedThumb extends StatelessWidget {
  final SavedEntry entry;

  /// 리스트용 고정 한 변 길이 (그리드는 부모가 정한다).
  final double size;
  final double radius;
  final bool isGrid;
  final VoidCallback? onUnsave;

  const SavedThumb({super.key, 
    required this.entry,
    this.size = 92,
    this.radius = 14,
    this.isGrid = false,
    this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final club = entry.club;
    final gradient = savedGradientFor(club.clubId);
    final url = club.thumbnailUrl;

    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isNotEmpty)
              SkeletonImage(
                url: url,
                fit: BoxFit.cover,
                // 최초 로드 시 최소 1초 shimmer 후 페이드 — 검정 화면 깜빡임 방지.
                minSkeleton: const Duration(seconds: 1),
              ),
            // 좌상단에서 번지는 광택.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.4, -0.44),
                  radius: 0.86,
                  colors: [Color(0x42FFFFFF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
            if (isGrid) ...[
              // 하단 정보가 읽히도록 어둡게 깔아준다.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xAD000000)],
                    stops: [0.46, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onUnsave,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 30.r,
                    height: 30.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // 이미지 위 blur는 비용이 커 반투명 채움으로 대체.
                      color: const Color(0x8014121A),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x29FFFFFF)),
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 15.r,
                      color: ClubGlass.saved,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 9.w,
                right: 9.w,
                bottom: 9.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.r,
                            height: 5.r,
                            decoration: BoxDecoration(
                              color: entry.isOpen
                                  ? VybeColors.mainLime500
                                  : const Color(0x73FFFFFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            entry.isOpen ? '영업중' : '영업종료',
                            style: savedCaption(
                              color: Colors.white,
                              size: 10.5,
                              lineHeight: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x800E0D12),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: const Color(0x24FFFFFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 10.r, color: VybeColors.mainLime500),
                          SizedBox(width: 3.w),
                          Text(
                            entry.club.rating.toStringAsFixed(1),
                            style: savedCaption(
                              color: Colors.white,
                              size: 10.5,
                              lineHeight: 12,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isGrid) return thumb;
    return SizedBox(width: size.w, height: size.w, child: thumb);
  }
}

// ============ 전체 비었을 때 ============
