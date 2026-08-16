// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive — 앱 실행 내내 같은 인스턴스를 쓴다(매번 디스크를 열지 않게).

@ProviderFor(localPrefs)
final localPrefsProvider = LocalPrefsProvider._();

/// keepAlive — 앱 실행 내내 같은 인스턴스를 쓴다(매번 디스크를 열지 않게).

final class LocalPrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalPrefs>,
          LocalPrefs,
          FutureOr<LocalPrefs>
        >
    with $FutureModifier<LocalPrefs>, $FutureProvider<LocalPrefs> {
  /// keepAlive — 앱 실행 내내 같은 인스턴스를 쓴다(매번 디스크를 열지 않게).
  LocalPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localPrefsHash();

  @$internal
  @override
  $FutureProviderElement<LocalPrefs> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LocalPrefs> create(Ref ref) {
    return localPrefs(ref);
  }
}

String _$localPrefsHash() => r'e89257634413959bc99bad9c8b40f1492545e002';
