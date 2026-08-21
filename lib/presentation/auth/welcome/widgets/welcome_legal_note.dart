import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/auth/terms/legal_documents.dart';

/// `가입 시 서비스 이용약관, 개인정보처리방침 및 …에 동의합니다.` 문구.
///
/// 문서 이름마다 밑줄 링크가 걸린다. [TapGestureRecognizer]는 위젯이 아니라
/// 직접 dispose 해야 해서 — build 안에서 만들면 리빌드마다 새로 생겨 샌다 —
/// 이 위젯이 수명을 들고 있는다.
class WelcomeLegalNote extends StatefulWidget {
  /// 가입 시 동의하게 되는 **필수** 문서. 마케팅 수신 동의(선택)는 넣지 않는다 —
  /// "가입 시 동의합니다" 문구에 선택 동의를 섞으면 사실과 다르다.
  static const docs = [LegalDoc.terms, LegalDoc.privacy, LegalDoc.location];

  final ValueChanged<LegalDoc> onOpen;

  const WelcomeLegalNote({super.key, required this.onOpen});

  @override
  State<WelcomeLegalNote> createState() => _WelcomeLegalNoteState();
}

class _WelcomeLegalNoteState extends State<WelcomeLegalNote> {
  late final Map<LegalDoc, TapGestureRecognizer> _taps;

  @override
  void initState() {
    super.initState();
    _taps = {
      for (final doc in WelcomeLegalNote.docs)
        doc: TapGestureRecognizer()..onTap = () => widget.onOpen(doc),
    };
  }

  @override
  void dispose() {
    for (final recognizer in _taps.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const docs = WelcomeLegalNote.docs;

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
          fontSize: 12.sp,
          color: VybeColors.gray600,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: '가입 시 '),
          for (var i = 0; i < docs.length; i++) ...[
            if (i > 0) TextSpan(text: i == docs.length - 1 ? ' 및 ' : ', '),
            _link(docs[i]),
          ],
          const TextSpan(text: '에 동의합니다.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 밑줄 친 약관 링크 한 조각.
  TextSpan _link(LegalDoc doc) => TextSpan(
    text: doc.title,
    style: const TextStyle(
      color: VybeColors.gray400,
      decoration: TextDecoration.underline,
      decorationColor: VybeColors.gray400,
    ),
    recognizer: _taps[doc],
  );
}
