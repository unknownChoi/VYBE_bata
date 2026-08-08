import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_skeleton.dart';

// 주변 리스트 아이템 로딩 스켈레톤.

class NearbyListItemSkeleton extends StatelessWidget {
  const NearbyListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 글래스 시트 안 카드와 같은 골격 (ClubNearbyListItem: 좌우 4 · 상하 18,
      // 구분선은 CG.hair = rgba(255,255,255,0.09)).
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x17FFFFFF), width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름 + 추천 뱃지
          Row(
            children: [
              VybeSkel(width: 108.w, height: 20.h),
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
          VybeSkel(width: double.infinity, height: 152.h, radius: 14),
          SizedBox(height: 8.h),
          // 주소
          VybeSkel(width: 220.w, height: 12.h),
          SizedBox(height: 8.h),
          // 영업 정보
          VybeSkel(width: 200.w, height: 12.h),
        ],
      ),
    );
  }
}

// ── 검색결과 클럽 카드 스켈레톤 ─────────────────────────────────────
//
// ClubListItem과 같은 골격(208.h 카드 · 하단 글래스 바 · 우상단 pill/찜).
// 검색결과 리스트에서 다음 페이지 로드 중 하단에 표시.
// VYBE 추천 리본은 클럽마다 유무가 달라 스켈레톤에선 생략.
