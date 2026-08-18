import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/data/datasources/local/device_network_datasource.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/design_system/typography.dart';
import 'package:vybe/presentation/common/network_gate/viewmodels/network_status_viewmodel.dart';
import 'package:vybe/presentation/common/network_gate/widgets/no_signal_icon.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/common/widgets/vybe_toast.dart';

/// 재시도 스피너를 최소한 이 시간은 보여 준다. 확인이 즉시 끝나면(캐시된 DNS 등)
/// 버튼이 깜빡이기만 해서 눌린 건지 알 수 없다.
const Duration _kRetryMinDuration = Duration(milliseconds: 700);

/// 네트워크 없음 안내 — 앱 최초 진입에서 연결이 없을 때 [NetworkGate] 가 그린다.
///
/// 디자인 `network_error.jsx` 이식. 뒤로가기로 빠져나갈 수 없다
/// (`PopScope canPop: false`) — 통신이 안 되는 채로 들어가면 빈 화면만 남는다.
class NetworkErrorScreen extends ConsumerStatefulWidget {
  const NetworkErrorScreen({super.key});

  @override
  ConsumerState<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends ConsumerState<NetworkErrorScreen> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);

    final connected = await ref.read(networkStatusProvider.notifier).recheck();
    // 확인이 먼저 끝나도 스피너를 최소 시간은 채운다.
    await Future<void>.delayed(_kRetryMinDuration);
    if (!mounted) return;

    // 연결되면 게이트가 이 화면을 트리에서 빼므로 여기선 실패만 처리한다.
    if (connected) return;
    setState(() => _retrying = false);
    VybeToast.show(context, message: '여전히 연결되지 않아요', isError: true);
  }

  Future<void> _openSettings() async {
    final opened = await ref
        .read(deviceNetworkDataSourceProvider)
        .openNetworkSettings();
    if (opened || !mounted) return;
    VybeToast.show(context, message: '설정을 열 수 없어요', isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kVybeInk,
        // ⚠ fit: expand 필수 — Stack은 Positioned가 아닌 자식(SafeArea)에게 loose
        // 제약을 준다. 그러면 Column이 글자 폭만큼 줄고, Stack도 그 폭이 되며,
        // Positioned.fill인 오로라까지 같이 줄어 화면 왼쪽 일부만 그려진다.
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: VybeAurora()),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NoSignalIcon(retrying: _retrying),
                          SizedBox(height: 26.h),
                          _title(),
                          SizedBox(height: 14.h),
                          _message(),
                          SizedBox(height: 22.h),
                          _retryButton(),
                          // 디자인의 paddingBottom 20 — 아래 링크와 겹치지 않게
                          // 본문 덩어리를 화면 중앙보다 살짝 위로 올린다.
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                    _settingsLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    final style = VybeTypography.heading2.copyWith(color: Colors.white);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '네트워크 연결',
            style: style.copyWith(color: VybeColors.mainLime500),
          ),
          const TextSpan(text: '을\n확인해 주세요'),
        ],
      ),
      textAlign: TextAlign.center,
      style: style,
    );
  }

  Widget _message() {
    return Text(
      '인터넷에 연결되어 있지 않아\n클럽 정보를 불러올 수 없어요.',
      textAlign: TextAlign.center,
      style: VybeTypography.body4.copyWith(
        color: VybeColors.gray500,
        height: 21 / 14,
      ),
    );
  }

  /// 폭이 글자에 맞는 알약 버튼. 전체 폭 [VybeButton] 을 쓰지 않는 이유는
  /// 디자인이 본문 가운데 놓인 짧은 버튼이기 때문.
  Widget _retryButton() {
    return GestureDetector(
      onTap: _retrying ? null : _retry,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: _retrying ? 20.w : 24.w),
        decoration: BoxDecoration(
          color: _retrying
              ? VybeColors.mainPurpleDisabled
              : VybeColors.mainPurple500,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: _retrying
              ? null
              : [
                  BoxShadow(
                    color: VybeColors.mainPurple500.withValues(alpha: 0.35),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_retrying) ...[
              SizedBox(
                width: 17.r,
                height: 17.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.r,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              _retrying ? '연결 확인 중' : '다시 시도',
              style: VybeTypography.button1.copyWith(
                color: _retrying
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsLink() {
    return GestureDetector(
      onTap: _openSettings,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Text(
          '네트워크 설정 열기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12.sp,
            height: 14 / 12,
            letterSpacing: 12 * -0.025,
            color: const Color(0xFFD9D9D9),
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFFD9D9D9),
          ),
        ),
      ),
    );
  }
}
