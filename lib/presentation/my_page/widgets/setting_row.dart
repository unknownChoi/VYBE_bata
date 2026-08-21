import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';

/// 설정 행 (디자인 MRSetRow) — `[아이콘] 라벨/보조설명 … 컨트롤`.
///
/// [onTap]을 주면 행 전체가 눌린다(값+꺾쇠 행). 토글 행은 토글만 눌린다 —
/// 행 전체를 누르게 하면 스크롤하다 실수로 켜진다.
class SettingRow extends StatelessWidget {
  /// 왼쪽 사각 타일 아이콘 경로. null이면 타일 없이 라벨부터 시작한다
  /// (같은 그룹의 하위 항목을 들여쓴 것처럼 보이게 하는 용도).
  final String? icon;

  final String label;

  /// 라벨 아래 보조 설명. 없으면 한 줄 행.
  final String? sub;

  /// 오른쪽 컨트롤 (토글 · 값+꺾쇠 · 버튼).
  final Widget control;

  final VoidCallback? onTap;

  /// 그룹의 마지막 행이면 아래 헤어라인을 그리지 않는다.
  final bool last;

  const SettingRow({
    super.key,
    this.icon,
    required this.label,
    this.sub,
    required this.control,
    this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: BoxConstraints(minHeight: 46.h),
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: RenewGlass.hair)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[_IconTile(path: icon!), SizedBox(width: 12.w)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: RenewGlass.body(color: RenewGlass.t1)),
                if (sub != null) ...[
                  SizedBox(height: 3.h),
                  Text(sub!, style: RenewGlass.caption(lineHeight: 15)),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          control,
        ],
      ),
    );

    if (onTap == null) return row;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

/// 켬/끔 토글이 달린 설정 행.
class SettingToggleRow extends StatelessWidget {
  final String label;
  final String sub;
  final bool on;
  final VoidCallback onToggle;
  final String? icon;
  final bool last;

  const SettingToggleRow({
    super.key,
    required this.label,
    required this.sub,
    required this.on,
    required this.onToggle,
    this.icon,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      icon: icon,
      label: label,
      sub: sub,
      control: MyToggle(on: on, onTap: onToggle),
      last: last,
    );
  }
}

/// 값 + 꺾쇠 (디자인 MRSetValue). 값이 없으면 꺾쇠만.
class SettingValueChevron extends StatelessWidget {
  final String? value;

  const SettingValueChevron({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null) ...[
          Text(
            value!,
            style: RenewGlass.caption(color: RenewGlass.t3, lineHeight: 14),
          ),
          SizedBox(width: 4.w),
        ],
        const RenewChevron(
          dir: RenewChevronDir.right,
          size: 12,
          color: RenewGlass.t4,
          strokeWidth: 2,
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  final String path;
  const _IconTile({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RenewGlass.tileFill,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RenewGlass.tileBorder),
      ),
      child: RenewIcon(
        path: path,
        size: 15,
        color: RenewGlass.t2,
        strokeWidth: 1.9,
      ),
    );
  }
}
