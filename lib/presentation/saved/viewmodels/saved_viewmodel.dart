import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/core/providers/auth_providers.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/favorite_model.dart';
import 'package:vybe/data/repositories/club_repository_impl.dart';
import 'package:vybe/data/repositories/favorite_repository_impl.dart';

part 'saved_viewmodel.g.dart';

/// 찜 1건 = 클럽 정보 + 찜 메타(그룹/저장시각).
class SavedEntry {
  final ClubModel club;
  final FavoriteModel favorite;

  const SavedEntry({required this.club, required this.favorite});

  String get clubId => club.clubId;
  DateTime get savedAt => favorite.createdAt;

  bool get isOpen => club.operatingHours.today.isCurrentlyOpen;

  /// 리스트 카드 하단 영업 상태 문구.
  String get hoursLabel {
    final today = club.operatingHours.today;
    if (isOpen && today.close != null) return '${today.close}에 영업 종료';
    if (today.isOpen && today.open != null) return '${today.open} 오픈';
    return '영업 정보 없음';
  }

  /// 저장 시각 → 상대 표기.
  String get savedAtLabel {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day)
        .difference(DateTime(savedAt.year, savedAt.month, savedAt.day))
        .inDays;
    if (d <= 0) return '오늘 저장';
    if (d == 1) return '어제 저장';
    if (d < 7) return '$d일 전 저장';
    if (d < 30) return '${d ~/ 7}주 전 저장';
    return '${d ~/ 30}개월 전 저장';
  }
}

/// 찜한 클럽 목록 (favorites 스트림 → 각 클럽 fetch).
@riverpod
Stream<List<SavedEntry>> savedClubs(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);

  final favRepo = ref.watch(favoriteRepositoryProvider);
  final clubRepo = ref.watch(clubRepositoryProvider);

  return favRepo.watchUserFavorites(uid).asyncMap((favs) async {
    final entries = await Future.wait(favs.map((f) async {
      final club = await clubRepo.getClub(f.clubId);
      // 비활성/삭제된 클럽 또는 노출 불가 클럽은 제외.
      if (club == null || !club.isActive) return null;
      return SavedEntry(club: club, favorite: f);
    }));
    final list = entries.whereType<SavedEntry>().toList();
    // 최근 찜 순(기본 정렬) — createdAt desc.
    list.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return list;
  });
}

/// 찜 화면 동작(찜 해제).
@riverpod
class SavedActions extends _$SavedActions {
  @override
  void build() {}

  String? get _uid => ref.read(currentUidProvider);

  Future<void> unsave(String clubId) async {
    final uid = _uid;
    if (uid == null) return;
    await ref.read(favoriteRepositoryProvider).removeFavorite(uid, clubId);
  }
}
