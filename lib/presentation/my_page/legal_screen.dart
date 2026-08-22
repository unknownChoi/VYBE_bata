import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';
import 'package:vybe/presentation/auth/terms/terms_detail_screen.dart';
import 'package:vybe/presentation/common/renew/renew_glass.dart';
import 'package:vybe/presentation/common/renew/renew_icons.dart';
import 'package:vybe/presentation/common/widgets/vybe_aurora.dart';
import 'package:vybe/presentation/main_scaffold/nav_bar_hide_route.dart';
import 'package:vybe/presentation/my_page/widgets/my_page_common.dart';
import 'package:vybe/presentation/my_page/widgets/setting_row.dart';

// ============================================================
// 이용약관 — 법적 고지 문서 목록
//
// 설정 화면에 문서를 한 줄씩 늘어놓지 않고 이 화면 하나로 모은다.
// 문서 원문은 여전히 [LegalDoc] 한 곳에만 있고, 탭하면 기존
// [TermsDetailScreen] 을 그대로 연다 — 화면이 늘어도 원문은 하나다.
//
// **문서를 한 화면에 합치지는 않는다** — 어느 문서에 동의했는지를
// 문서별 개정일(version)과 함께 확인할 수 있어야 하기 때문.
// ============================================================

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  /// 노출 순서 — 가입 시 약관 시트와 같은 순서(필수 3종 → 선택).
  static const _docs = [
    LegalDoc.terms,
    LegalDoc.privacy,
    LegalDoc.location,
    LegalDoc.marketing,
  ];

  /// 선택 동의 문서. 목록에서 '선택' 꼬리표를 붙인다.
  static const _optional = {LegalDoc.marketing};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RenewGlass.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: VybeAurora())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MyPushHeader(title: '이용약관'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    kMyPagePad.w,
                    18.h,
                    kMyPagePad.w,
                    40.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const RenewSectionHead(title: '약관 및 정책'),
                      for (final doc in _docs)
                        SettingRow(
                          icon: RenewIcons.doc,
                          label: _optional.contains(doc)
                              ? '${doc.title} (선택)'
                              : doc.title,
                          sub: '시행일 ${_formatVersion(doc.version)}',
                          control: const SettingValueChevron(),
                          onTap: () => pushHidingNavBar<void>(
                            context,
                            TermsDetailScreen(doc: doc),
                          ),
                          last: doc == _docs.last,
                        ),
                      SizedBox(height: 18.h),
                      const RenewFooterNote(
                        text:
                            '약관이 개정되면 시행일 전에 앱 공지로 알려드려요. '
                            '마케팅 정보 수신은 설정 > 알림에서 언제든 끌 수 있어요.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// `2026-08-20` → `2026.08.20`. 원문 상단 표기와 자릿수를 맞춘다.
  static String _formatVersion(String version) => version.replaceAll('-', '.');
}
