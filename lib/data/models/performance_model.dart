import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_model.freezed.dart';

/// 공연 일정 항목 (장르 페이지 — 힙합 등).
/// clubs 컬렉션을 참조(clubId)하되, rail/hero 표시용으로 clubName·clubArea를 비정규화 보관.
/// 클럽 기본 정보(평점/영업/썸네일)는 clubId로 clubs에서 조인해 사용.
@freezed
abstract class PerformanceModel with _$PerformanceModel {
  const PerformanceModel._();

  const factory PerformanceModel({
    required String performanceId,
    required String clubId,
    required String clubName, // 비정규화 — 조인 없이 rail/hero 표시
    required String clubArea, // 비정규화 — 지역 표시
    required String genre, // "힙합" 등
    required String artistName, // 헤드라이너 (예: "YANO")
    required String artistType, // "rapper" | "dj"
    required DateTime startAt, // 공연 시작 시각
    required String date, // "YYYYMMDD" — 날짜 버킷
    @Default(false) bool isFeatured, // true = Hero 캐러셀
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _PerformanceModel;

  /// DJ(disc) 여부 — rail 아이콘 분기용.
  bool get isDj => artistType == 'dj';

  /// "오늘 22:00 공연" 같은 표시용 HH:mm (로컬 시각).
  String get hhmm {
    final t = startAt.toLocal();
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory PerformanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PerformanceModel(
      performanceId: data['performanceId'] as String? ?? doc.id,
      clubId: data['clubId'] as String? ?? '',
      clubName: data['clubName'] as String? ?? '',
      clubArea: data['clubArea'] as String? ?? '',
      genre: data['genre'] as String? ?? '',
      artistName: data['artistName'] as String? ?? '',
      artistType: data['artistType'] as String? ?? 'rapper',
      startAt: (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: data['date'] as String? ?? '',
      isFeatured: data['isFeatured'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
