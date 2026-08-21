import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notice_model.freezed.dart';

/// 공지사항 1건 (마이페이지 → 공지사항).
/// 쓰기는 어드민 페이지 전용 — 앱은 읽기만 한다.
@freezed
abstract class NoticeModel with _$NoticeModel {
  const NoticeModel._();

  const factory NoticeModel({
    required String noticeId,
    required String title,
    required String content, // plain text, \n 줄바꿈 그대로 렌더
    @Default(<String>[]) List<String> imageUrls,
    // "notice" | "update" | "event" | "maint" | "ad"
    @Default('notice') String category,

    /// 연결된 프로모션 문서 id. 비어 있지 않으면 목록에서 탭했을 때 공지 상세가
    /// 아니라 `PromotionDetailScreen`으로 바로 보낸다 (광고 공지 = 배너와 같은 목적지).
    /// category와 분리한 이유 — 프로모션 문서가 없는 광고 공지도 있을 수 있고,
    /// 반대로 광고가 아닌 공지에서 이벤트 페이지로 보내고 싶을 수도 있다.
    @Default('') String promotionId,
    @Default(false) bool isPinned,

    /// 게시 상태 — true: 게시 / false: 게시중단.
    /// 게시중단이면 게시 기간 안이라도 노출하지 않는다 (isVisibleAt 참고).
    @Default(true) bool isActive,

    /// 게시 시작 시각 = 목록 정렬 키. 미래면 아직 노출 안 됨(예약 게시).
    required DateTime publishedAt,

    /// 게시 종료 시각. null이면 무기한 게시.
    DateTime? endAt,
    @Default('VYBE 운영팀') String authorName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoticeModel;

  /// 목록 배지 라벨. 알 수 없는 category는 '공지'로 폴백.
  String get categoryLabel => switch (category) {
    'update' => '업데이트',
    'event' => '이벤트',
    'maint' => '점검',
    'ad' => '광고',
    _ => '공지',
  };

  /// 탭했을 때 공지 상세 대신 프로모션(광고) 페이지로 보낼지.
  bool get opensPromotion => promotionId.isNotEmpty;

  /// 지금 앱에 노출할 공지인지. 판단 순서 —
  /// ① 게시 상태(isActive) → ② 게시 시작(publishedAt) → ③ 게시 종료(endAt).
  /// **게시중단이면 게시 기간 안이어도 노출하지 않는다** (isActive가 최우선).
  /// 목록·단건 조회가 같은 기준을 쓰도록 판정은 여기 한 곳에만 둔다.
  bool isVisibleAt(DateTime now) {
    if (!isActive) return false;
    if (publishedAt.isAfter(now)) return false;
    final end = endAt;
    if (end != null && !end.isAfter(now)) return false;
    return true;
  }

  bool get isVisible => isVisibleAt(DateTime.now());

  /// NEW 배지 — 게시 7일 이내. 읽음 상태를 저장하지 않는 대신 쓰는 기준.
  bool get isNew =>
      DateTime.now().difference(publishedAt) < const Duration(days: 7);

  /// 표시용 날짜 (예: 2026.08.03)
  String get dateLabel {
    final d = publishedAt.toLocal();
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.'
        '${d.day.toString().padLeft(2, '0')}';
  }

  factory NoticeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return NoticeModel(
      noticeId: data['noticeId'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrls:
          (data['imageUrls'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      category: data['category'] as String? ?? 'notice',
      promotionId: data['promotionId'] as String? ?? '',
      isPinned: data['isPinned'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      // publishedAt 미기입 문서는 createdAt으로 대체 — 목록에서 사라지지 않게.
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate() ?? createdAt,
      // endAt 없으면 null = 무기한 게시 (기존 문서 그대로 동작).
      endAt: (data['endAt'] as Timestamp?)?.toDate(),
      authorName: data['authorName'] as String? ?? 'VYBE 운영팀',
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt,
    );
  }
}
