// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noticeRepository)
final noticeRepositoryProvider = NoticeRepositoryProvider._();

final class NoticeRepositoryProvider
    extends
        $FunctionalProvider<
          NoticeRepository,
          NoticeRepository,
          NoticeRepository
        >
    with $Provider<NoticeRepository> {
  NoticeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticeRepositoryHash();

  @$internal
  @override
  $ProviderElement<NoticeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoticeRepository create(Ref ref) {
    return noticeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoticeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoticeRepository>(value),
    );
  }
}

String _$noticeRepositoryHash() => r'671f985f455e5713234c51edd5f08a94da5e4f52';
