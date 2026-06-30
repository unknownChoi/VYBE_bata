import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vybe/data/datasources/remote/firebase_performance_datasource.dart';
import 'package:vybe/data/models/performance_model.dart';
import 'package:vybe/domain/repositories/performance_repository.dart';

part 'performance_repository_impl.g.dart';

@Riverpod(keepAlive: true)
PerformanceRepository performanceRepository(Ref ref) =>
    _PerformanceRepositoryImpl(FirebasePerformanceDataSource());

class _PerformanceRepositoryImpl implements PerformanceRepository {
  final FirebasePerformanceDataSource _dataSource;

  _PerformanceRepositoryImpl(this._dataSource);

  @override
  Future<List<PerformanceModel>> getTodayPerformances({
    String genre = '힙합',
    String? date,
  }) =>
      _dataSource.getTodayPerformances(genre: genre, date: date);
}
