import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_notice_datasource.dart';
import 'package:vybe/data/models/notice_model.dart';
import 'package:vybe/domain/repositories/notice_repository.dart';

part 'notice_repository_impl.g.dart';

@Riverpod(keepAlive: true)
NoticeRepository noticeRepository(Ref ref) =>
    _NoticeRepositoryImpl(FirebaseNoticeDataSource());

class _NoticeRepositoryImpl implements NoticeRepository {
  final FirebaseNoticeDataSource _dataSource;

  _NoticeRepositoryImpl(this._dataSource);

  @override
  Future<List<NoticeModel>> getNotices({int limit = 50}) =>
      _dataSource.getNotices(limit: limit);

  @override
  Future<NoticeModel?> getNotice(String noticeId) =>
      _dataSource.getNotice(noticeId);
}
