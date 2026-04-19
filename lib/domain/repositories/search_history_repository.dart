import 'package:vybe/data/models/search_history_model.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistoryModel>> getSearchHistory(String userId);
  Future<void> addSearchHistory(String userId, String keyword);
  Future<void> deleteSearchHistory(String userId, String historyId);
  Future<void> clearAllSearchHistory(String userId);
}
