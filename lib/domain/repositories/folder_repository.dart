import 'package:vybe/data/models/folder_model.dart';

abstract class FolderRepository {
  Stream<List<FolderModel>> watchFolders(String userId);
  Future<String> addFolder(
    String userId, {
    required String name,
    required String emoji,
    required int order,
  });
  Future<void> deleteFolder(String userId, String folderId);
}
