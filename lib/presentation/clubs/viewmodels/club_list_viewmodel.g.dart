// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 활성 클럽 목록 실시간 스트림

@ProviderFor(clubList)
final clubListProvider = ClubListProvider._();

/// 활성 클럽 목록 실시간 스트림

final class ClubListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClubModel>>,
          List<ClubModel>,
          Stream<List<ClubModel>>
        >
    with $FutureModifier<List<ClubModel>>, $StreamProvider<List<ClubModel>> {
  /// 활성 클럽 목록 실시간 스트림
  ClubListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubListHash();

  @$internal
  @override
  $StreamProviderElement<List<ClubModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ClubModel>> create(Ref ref) {
    return clubList(ref);
  }
}

String _$clubListHash() => r'ddc8dcfe47fe13c74d2d6cdb8995d78a29920a56';
