import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/widgets/vybe_glass_surface.dart';

/// 본문에 끼워 넣는 첨부 이미지 (공지 상세 · 프로모션 상세).
///
/// 원본 비율을 모르니 폭에 맞춰 늘리고, 로딩·실패는 고정 높이 플레이스홀더로 덮는다
/// (높이가 0이면 스크롤이 튀므로).
class VybeContentImage extends StatelessWidget {
  final String url;

  const VybeContentImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => _fallback(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
        height: 180.h,
        alignment: Alignment.center,
        color: VybeGlassSurface.quietFill,
        child: Icon(
          Icons.image_outlined,
          size: 26.r,
          color: const Color(0x59FFFFFF),
        ),
      );
}
