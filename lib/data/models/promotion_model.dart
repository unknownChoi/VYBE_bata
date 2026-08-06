import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotion_model.freezed.dart';

/// 프로모션 상세 하단 CTA 동작.
enum PromotionCtaType {
  /// 버튼 없음
  none,

  /// 클럽 상세로 이동 (ctaValue = clubId)
  club,

  /// 외부 브라우저로 열기 (ctaValue = URL)
  url,
}

/// 배너 전용 상세 콘텐츠 1건 (promotions/{promotionId}).
///
/// 배너마다 사진·본문이 다른 광고 페이지를 **앱 배포 없이** 늘리기 위한 컬렉션.
/// 화면(`PromotionDetailScreen`)은 하나뿐이고 내용만 이 문서에서 갈아 끼운다.
/// 배너 doc에 본문을 박지 않는 이유 — 홈 진입마다 배너 N개를 읽는데 안 여는
/// 사용자까지 본문·사진 배열을 내려받게 된다. 탭했을 때만 1 read.
///
/// 쓰기는 어드민 페이지 전용 — 앱은 읽기만 한다.
@freezed
abstract class PromotionModel with _$PromotionModel {
  const PromotionModel._();

  const factory PromotionModel({
    required String promotionId,
    required String title,

    /// 제목 아래 한 줄 요약 (없으면 미표시)
    @Default('') String subtitle,

    /// 상세 상단 히어로 이미지. 비면 히어로 없이 제목부터 시작한다
    /// (배너 이미지는 목록용 비율이라 상세에서 재사용하지 않는다).
    @Default('') String heroImageUrl,

    /// 본문 plain text. \n 줄바꿈만 반영 — 마크다운/HTML 파싱 안 함.
    @Default('') String content,

    /// 본문 아래 첨부 사진 0~n장
    @Default(<String>[]) List<String> imageUrls,
    @Default(PromotionCtaType.none) PromotionCtaType ctaType,

    /// ctaType에 따라 clubId 또는 URL
    @Default('') String ctaValue,

    /// CTA 버튼 문구. 비면 ctaType 기본 문구 사용
    @Default('') String ctaLabel,
    @Default(true) bool isActive,

    /// 표시용 진행 기간 (없으면 기간 pill 미표시)
    DateTime? startAt,
    DateTime? endAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PromotionModel;

  /// 하단 CTA 버튼을 그릴지 — 타입과 값이 모두 있어야 한다.
  bool get hasCta => ctaType != PromotionCtaType.none && ctaValue.isNotEmpty;

  /// 버튼 문구. 어드민이 안 넣었으면 타입별 기본값.
  String get ctaLabelOrDefault {
    if (ctaLabel.isNotEmpty) return ctaLabel;
    return switch (ctaType) {
      PromotionCtaType.club => '클럽 보러가기',
      PromotionCtaType.url => '자세히 보기',
      PromotionCtaType.none => '',
    };
  }

  /// 기간 pill 문구 (예: `2026.08.01 ~ 08.31`). 한쪽만 있으면 그 쪽만 표시.
  String get periodLabel {
    if (startAt == null && endAt == null) return '';
    if (startAt == null) return '~ ${_fullDate(endAt!)}';
    if (endAt == null) return '${_fullDate(startAt!)} ~';
    final s = startAt!.toLocal();
    final e = endAt!.toLocal();
    // 같은 해면 종료일의 연도는 생략 — pill이 길어지지 않게.
    final end = s.year == e.year ? _monthDay(e) : _fullDate(e);
    return '${_fullDate(s)} ~ $end';
  }

  static String _fullDate(DateTime d) {
    final l = d.toLocal();
    return '${l.year}.${_two(l.month)}.${_two(l.day)}';
  }

  static String _monthDay(DateTime d) {
    final l = d.toLocal();
    return '${_two(l.month)}.${_two(l.day)}';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static PromotionCtaType _parseCtaType(String? raw) => switch (raw) {
        'club' => PromotionCtaType.club,
        'url' => PromotionCtaType.url,
        _ => PromotionCtaType.none,
      };

  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return PromotionModel(
      promotionId: data['promotionId'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      heroImageUrl: data['heroImageUrl'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrls:
          (data['imageUrls'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      ctaType: _parseCtaType(data['ctaType'] as String?),
      ctaValue: data['ctaValue'] as String? ?? '',
      ctaLabel: data['ctaLabel'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      startAt: (data['startAt'] as Timestamp?)?.toDate(),
      endAt: (data['endAt'] as Timestamp?)?.toDate(),
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt,
    );
  }
}
