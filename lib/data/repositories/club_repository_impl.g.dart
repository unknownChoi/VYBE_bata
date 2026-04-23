// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clubRepository)
final clubRepositoryProvider = ClubRepositoryProvider._();

final class ClubRepositoryProvider
    extends $FunctionalProvider<ClubRepository, ClubRepository, ClubRepository>
    with $Provider<ClubRepository> {
  ClubRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClubRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClubRepository create(Ref ref) {
    return clubRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClubRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClubRepository>(value),
    );
  }
}

String _$clubRepositoryHash() => r'15d07804f3a4d6dd78415474ef37c0aaaaf1a0fa';
