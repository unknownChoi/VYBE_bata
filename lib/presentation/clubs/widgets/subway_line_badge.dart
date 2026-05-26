import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

class SubwayLineBadge extends StatelessWidget {
  final int line;
  const SubwayLineBadge({super.key, required this.line});

  static Color _colorForLine(int line) {
    switch (line) {
      case 1:
        return const Color(0xFF0052A4);
      case 2:
        return const Color(0xFF009246);
      case 3:
        return const Color(0xFFF26C0D);
      case 4:
        return const Color(0xFF3C8DBC);
      case 5:
        return const Color(0xFF9B3493);
      case 6:
        return const Color(0xFFCD7C2F);
      case 7:
        return const Color(0xFF747F00);
      case 8:
        return const Color(0xFFE6186C);
      case 9:
        return const Color(0xFFBD941C);
      default:
        return VybeColors.gray700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.r,
      height: 18.r,
      decoration: BoxDecoration(
        color: _colorForLine(line),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$line',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          color: Colors.white,
          letterSpacing: -0.5,
          height: 1,
        ),
      ),
    );
  }
}
