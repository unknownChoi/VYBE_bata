import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_folder_datasource.dart';
import 'package:vybe/data/models/folder_model.dart';
import 'package:vybe/domain/repositories/folder_repository.dart';

part 'folder_repository_impl.g.dart';

@riverpod
FolderRepository folderRepository(Ref ref) =>
    FolderRepositoryImpl(FirebaseFolderDataSource());

class FolderRepositoryImpl implements FolderRepository {
  final FirebaseFolderDataSource _dataSource;

  FolderRepositoryImpl(this._dataSource);

  @override
  Stream<List<FolderModel>> watchFolders(String userId) =>
      _dataSource.watchFolders(userId);

  @override
  Future<String> addFolder(
    String userId, {
    required String name,
    required String emoji,
    required int order,
  }) =>
      _dataSource.addFolder(userId, name: name, emoji: emoji, order: order);

  @override
  Future<void> deleteFolder(String userId, String folderId) =>
      _dataSource.deleteFolder(userId, folderId);
}
