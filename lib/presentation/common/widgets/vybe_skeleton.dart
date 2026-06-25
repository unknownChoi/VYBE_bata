import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

// ── Base shimmer block ──────────────────────────────────────────

class VybeSkel extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const VybeSkel({
    super.key,
    this.width,
    this.height,
    this.radius = 6,
  });

  @override
  State<VybeSkel> createState() => _VybeSkelState();
}

class _VybeSkelState extends State<VybeSkel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius.r),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              VybeColors.gray900,
              VybeColors.gray700,
              VybeColors.gray900,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton 이미지 ─────────────────────────────────────────────
//
// Image.network 로딩 중 + 디코드 완료 후에도 최소 [minSkeleton] 동안
// 스켈레톤(shimmer)을 유지한 뒤 페이드로 이미지를 노출한다.
// URL 로딩 지연 시 깜빡임을 막기 위한 위젯.

class SkeletonImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Duration minSkeleton;

  const SkeletonImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.minSkeleton = const Duration(seconds: 1),
  });

  @override
  State<SkeletonImage> createState() => _SkeletonImageState();
}

class _SkeletonImageState extends State<SkeletonImage> {
  bool _revealed = false;
  bool _loaded = false;
  late final DateTime _start;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();

    // 이미 ImageCache에 있으면(재방문) skeleton 없이 즉시 노출.
    // 최초 로드(캐시 없음)일 때만 minSkeleton 동안 shimmer 표시.
    final status = PaintingBinding.instance.imageCache
        .statusForKey(NetworkImage(widget.url));
    if (status.keepAlive || status.live) {
      _loaded = true;
      _revealed = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 이미지 디코드(또는 에러) 완료 시 호출 — 최소 표시 시간 보장 후 reveal.
  void _onSettled() {
    if (_loaded) return;
    _loaded = true;
    final remain = widget.minSkeleton - DateTime.now().difference(_start);
    if (remain > Duration.zero) {
      _timer = Timer(remain, () {
        if (mounted) setState(() => _revealed = true);
      });
    } else {
      if (mounted) setState(() => _revealed = true);
    }
  }

  void _scheduleSettle() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onSettled());
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (_, child, frame, wasSync) {
        if ((frame != null || wasSync) && !_loaded) _scheduleSettle();
        return child;
      },
      errorBuilder: (_, __, ___) {
        if (!_loaded) _scheduleSettle();
        return Container(
          width: widget.width,
          height: widget.height,
          color: VybeColors.gray900,
        );
      },
    );

    final content = Stack(
      fit: StackFit.passthrough,
      children: [
        image,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _revealed,
            child: AnimatedOpacity(
              opacity: _revealed ? 0 : 1,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: VybeSkel(
                width: widget.width,
                height: widget.height,
                radius: 0,
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.borderRadius == null) return content;
    return ClipRRect(borderRadius: widget.borderRadius!, child: content);
  }
}

// ── Hero skeleton ───────────────────────────────────────────────

class HeroSkeleton extends StatelessWidget {
  const HeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VybeSkel(width: double.infinity, height: 270.h, radius: 0);
  }
}

// ── Title block skeleton ────────────────────────────────────────

class TitleSkeleton extends StatelessWidget {
  const TitleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // area | genre
          VybeSkel(width: 120.w, height: 14.h),
          SizedBox(height: 8.h),
          // club name + phone button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VybeSkel(width: 160.w, height: 30.h, radius: 8),
              VybeSkel(width: 68.w, height: 32.h, radius: 99),
            ],
          ),
          SizedBox(height: 14.h),
          // rating row
          VybeSkel(width: 130.w, height: 18.h),
          SizedBox(height: 10.h),
          // description
          VybeSkel(width: double.infinity, height: 20.h),
          SizedBox(height: 14.h),
          // tags
          Row(
            children: [56, 70, 80, 50].map((w) {
              return Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: VybeSkel(width: w.w, height: 24.h, radius: 99),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Home tab skeletons ──────────────────────────────────────────

class InfoSkeleton extends StatelessWidget {
  const InfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        children: List.generate(4, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i < 3 ? 18.h : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VybeSkel(width: 17.r, height: 17.r, radius: 4),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VybeSkel(
                        width: double.infinity,
                        height: 14.h,
                      ),
                      if (i == 0) ...[
                        SizedBox(height: 6.h),
                        VybeSkel(width: 120.w, height: 12.h),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class MenuSkeleton extends StatelessWidget {
  const MenuSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VybeSkel(width: 64.w, height: 20.h),
              VybeSkel(width: 56.w, height: 14.h),
            ],
          ),
          SizedBox(height: 14.h),
          ...List.generate(3, (i) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: VybeColors.gray900),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VybeSkel(width: 100.w, height: 14.h),
                        SizedBox(height: 8.h),
                        VybeSkel(width: 160.w, height: 12.h),
                        SizedBox(height: 8.h),
                        VybeSkel(width: 70.w, height: 16.h),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  VybeSkel(width: 88.r, height: 88.r, radius: 10),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PhotosSkeleton extends StatelessWidget {
  const PhotosSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VybeSkel(width: 64.w, height: 20.h),
              VybeSkel(width: 56.w, height: 14.h),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 110.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: VybeSkel(
                    width: double.infinity,
                    height: double.infinity,
                    radius: 10,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: VybeSkel(
                                width: double.infinity,
                                height: double.infinity,
                                radius: 10,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: VybeSkel(
                                width: double.infinity,
                                height: double.infinity,
                                radius: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: VybeSkel(
                                width: double.infinity,
                                height: double.infinity,
                                radius: 10,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: VybeSkel(
                                width: double.infinity,
                                height: double.infinity,
                                radius: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class NearbySkeleton extends StatelessWidget {
  const NearbySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 24.h, left: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                VybeSkel(width: 80.w, height: 20.h),
                VybeSkel(width: 56.w, height: 14.h),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: List.generate(4, (i) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VybeSkel(width: 124.w, height: 124.h, radius: 10),
                      SizedBox(height: 8.h),
                      VybeSkel(width: 90.w, height: 14.h),
                      SizedBox(height: 6.h),
                      VybeSkel(width: 70.w, height: 12.h),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 주변 바텀시트 클럽 카드 스켈레톤 ───────────────────────────────
//
// ClubNearbyListItem 레이아웃(이름·평점·이미지·주소·영업)과 동일한 골격.
// 바텀시트 로딩 중 표시.

class NearbyListItemSkeleton extends StatelessWidget {
  const NearbyListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VybeColors.gray800, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름 + 추천 뱃지
          Row(
            children: [
              VybeSkel(width: 108.w, height: 18.h),
              SizedBox(width: 8.w),
              VybeSkel(width: 88.w, height: 18.h, radius: 999),
            ],
          ),
          SizedBox(height: 8.h),
          // 평점 · 지역 · 장르
          Row(
            children: [
              VybeSkel(width: 44.w, height: 12.h),
              SizedBox(width: 8.w),
              VybeSkel(width: 36.w, height: 12.h),
              SizedBox(width: 8.w),
              VybeSkel(width: 52.w, height: 12.h),
            ],
          ),
          SizedBox(height: 8.h),
          // 대표 이미지
          VybeSkel(width: double.infinity, height: 152.h, radius: 12),
          SizedBox(height: 8.h),
          // 주소
          VybeSkel(width: 220.w, height: 12.h),
          SizedBox(height: 4.h),
          // 영업 정보
          VybeSkel(width: 160.w, height: 12.h),
        ],
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const InfoSkeleton(),
        _divider(),
        const MenuSkeleton(),
        _divider(),
        const PhotosSkeleton(),
        _divider(),
        const NearbySkeleton(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _divider() => Container(
        height: 8.h,
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border.symmetric(
            horizontal: BorderSide(color: Color(0xFF1F1F23)),
          ),
        ),
      );
}

// ── Tab skeletons ───────────────────────────────────────────────

class MenuTabSkeleton extends StatelessWidget {
  const MenuTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // menu board image section
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 0, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VybeSkel(width: 88.w, height: 20.h),
              SizedBox(height: 16.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: VybeSkel(width: 121.r, height: 121.r, radius: 8),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        Container(height: 2, color: VybeColors.gray900),
        // category chips
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Row(
            children: [60, 48, 56, 80].map((w) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: VybeSkel(width: w.w, height: 32.h, radius: 99),
              );
            }).toList(),
          ),
        ),
        // menu items
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VybeSkel(width: 80.w, height: 20.h),
              SizedBox(height: 16.h),
              ...List.generate(3, (i) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: VybeColors.gray900),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VybeSkel(width: 110.w, height: 16.h),
                            SizedBox(height: 10.h),
                            VybeSkel(width: 170.w, height: 12.h),
                            SizedBox(height: 10.h),
                            VybeSkel(width: 70.w, height: 16.h),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      VybeSkel(width: 100.r, height: 100.r, radius: 6),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class PhotosTabSkeleton extends StatelessWidget {
  const PhotosTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // filter chips
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Row(
            children: [44, 64, 56, 50].map((w) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: VybeSkel(width: w.w, height: 30.h, radius: 99),
              );
            }).toList(),
          ),
        ),
        // masonry grid
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              [262, 180, 220, 270],
              [180, 220, 180, 200],
            ].map((heights) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Column(
                    children: heights.map((h) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: VybeSkel(
                          width: double.infinity,
                          height: h.h,
                          radius: 6,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ReviewsTabSkeleton extends StatelessWidget {
  const ReviewsTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20.h, 0, 32.h),
      child: Column(
        children: [
          // toggle
          VybeSkel(width: double.infinity, height: 44.h, radius: 99),
          SizedBox(height: 20.h),
          // rating summary
          VybeSkel(width: double.infinity, height: 92.h, radius: 12),
          SizedBox(height: 20.h),
          // sort row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VybeSkel(width: 56.w, height: 16.h),
              VybeSkel(width: 120.w, height: 20.h, radius: 99),
            ],
          ),
          SizedBox(height: 4.h),
          // review cards
          ...List.generate(3, (i) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: VybeColors.gray900),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VybeSkel(width: 32.r, height: 32.r, radius: 99),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VybeSkel(width: 70.w, height: 12.h),
                          SizedBox(height: 4.h),
                          VybeSkel(width: 40.w, height: 10.h),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  VybeSkel(width: double.infinity, height: 14.h),
                  SizedBox(height: 6.h),
                  VybeSkel(width: 220.w, height: 14.h),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class LocationSkeleton extends StatelessWidget {
  const LocationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // '위치' 타이틀
          VybeSkel(width: 60.w, height: 20.h),
          SizedBox(height: 16.h),
          // 지도 카드
          VybeSkel(width: double.infinity, height: 200.h, radius: 12),
          SizedBox(height: 16.h),
          // 주소 카드
          VybeSkel(width: double.infinity, height: 78.h, radius: 12),
          SizedBox(height: 10.h),
          // 액션 칩 3개
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 8.w : 0),
                  child: VybeSkel(
                    width: double.infinity,
                    height: 38.h,
                    radius: 8,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class DetailInfoSkeleton extends StatelessWidget {
  const DetailInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // '상세 정보' 타이틀
          VybeSkel(width: 80.w, height: 20.h),
          SizedBox(height: 16.h),
          // 정보 행 4개 (영업시간/전화/인스타/오픈채팅)
          ...List.generate(4, (i) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: VybeColors.gray900),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VybeSkel(width: 16.r, height: 16.r, radius: 4),
                      SizedBox(width: 8.w),
                      VybeSkel(width: 60.w, height: 13.h),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.only(left: 24.w),
                    child: VybeSkel(width: 130.w, height: 14.h),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 16.h),
          // 안내/유의사항 박스
          VybeSkel(width: double.infinity, height: 44.h, radius: 12),
        ],
      ),
    );
  }
}

// ── 찜 탭 스켈레톤 ───────────────────────────────────────────────
//
// SavedScreen 로딩 중 표시. 통계 바 + 그룹 칩 + 툴바 + 리스트 카드 골격.
// 실제 레이아웃(_StatsBar / _FolderTabs / _ToolBar / _ListCard)과 패딩 동일.

class _SavedListItemSkeleton extends StatelessWidget {
  const _SavedListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VybeSkel(width: 96.w, height: 96.w, radius: 10),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VybeSkel(width: 130.w, height: 16.h),
                SizedBox(height: 12.h),
                VybeSkel(width: 180.w, height: 12.h),
                SizedBox(height: 10.h),
                VybeSkel(width: 160.w, height: 12.h),
                SizedBox(height: 12.h),
                VybeSkel(width: 70.w, height: 11.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SavedSkeleton extends StatelessWidget {
  const SavedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 통계 바
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              VybeSkel(width: 140.w, height: 28.h, radius: 8),
              VybeSkel(width: 86.w, height: 14.h, radius: 99),
            ],
          ),
        ),
        // 그룹 칩
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Row(
            children: [
              ...[52, 64, 80, 56].map((w) => Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: VybeSkel(width: w.w, height: 34.h, radius: 99),
                  )),
            ],
          ),
        ),
        // 툴바 (정렬 + 뷰 전환)
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VybeSkel(width: 80.w, height: 14.h),
              VybeSkel(width: 64.w, height: 26.h, radius: 8),
            ],
          ),
        ),
        // 리스트 카드 5개
        ...List.generate(5, (_) => const _SavedListItemSkeleton()),
      ],
    );
  }
}

class InfoTabSkeleton extends StatelessWidget {
  const InfoTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(4, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Row(
                children: [
                  VybeSkel(width: 20.r, height: 20.r, radius: 6),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VybeSkel(width: 150.w, height: 14.h),
                        SizedBox(height: 8.h),
                        VybeSkel(width: 100.w, height: 12.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          VybeSkel(width: double.infinity, height: 160.h, radius: 12),
        ],
      ),
    );
  }
}
