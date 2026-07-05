// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_schedule_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 클럽 상세 공연 일정 — performances 컬렉션에서 다가오는 공연을 조회해
/// 날짜별 카드 데이터(ScheduleDay)로 매핑. 섹션·전체 페이지 공용.

@ProviderFor(clubSchedule)
final clubScheduleProvider = ClubScheduleFamily._();

/// 클럽 상세 공연 일정 — performances 컬렉션에서 다가오는 공연을 조회해
/// 날짜별 카드 데이터(ScheduleDay)로 매핑. 섹션·전체 페이지 공용.

final class ClubScheduleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduleDay>>,
          List<ScheduleDay>,
          FutureOr<List<ScheduleDay>>
        >
    with
        $FutureModifier<List<ScheduleDay>>,
        $FutureProvider<List<ScheduleDay>> {
  /// 클럽 상세 공연 일정 — performances 컬렉션에서 다가오는 공연을 조회해
  /// 날짜별 카드 데이터(ScheduleDay)로 매핑. 섹션·전체 페이지 공용.
  ClubScheduleProvider._({
    required ClubScheduleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubScheduleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubScheduleHash();

  @override
  String toString() {
    return r'clubScheduleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ScheduleDay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScheduleDay>> create(Ref ref) {
    final argument = this.argument as String;
    return clubSchedule(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubScheduleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubScheduleHash() => r'567ae600941ace4a6ea445d3ddfe9fe769843b3b';

/// 클럽 상세 공연 일정 — performances 컬렉션에서 다가오는 공연을 조회해
/// 날짜별 카드 데이터(ScheduleDay)로 매핑. 섹션·전체 페이지 공용.

final class ClubScheduleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ScheduleDay>>, String> {
  ClubScheduleFamily._()
    : super(
        retry: null,
        name: r'clubScheduleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 클럽 상세 공연 일정 — performances 컬렉션에서 다가오는 공연을 조회해
  /// 날짜별 카드 데이터(ScheduleDay)로 매핑. 섹션·전체 페이지 공용.

  ClubScheduleProvider call(String clubId) =>
      ClubScheduleProvider._(argument: clubId, from: this);

  @override
  String toString() => r'clubScheduleProvider';
}
