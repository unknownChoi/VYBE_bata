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
    // "notice" | "update" | "event" | "maint"
    @Default('notice') String category,
    @Default(false) bool isPinned,
    @Default(true) bool isActive,
    required DateTime publishedAt, // 목록 정렬 키
    @Default('VYBE 운영팀') String authorName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoticeModel;

  /// 목록 배지 라벨. 알 수 없는 category는 '공지'로 폴백.
  String get categoryLabel => switch (category) {
        'update' => '업데이트',
        'event' => '이벤트',
        'maint' => '점검',
        _ => '공지',
      };

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
      isPinned: data['isPinned'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      // publishedAt 미기입 문서는 createdAt으로 대체 — 목록에서 사라지지 않게.
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate() ?? createdAt,
      authorName: data['authorName'] as String? ?? 'VYBE 운영팀',
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt,
    );
  }
}
