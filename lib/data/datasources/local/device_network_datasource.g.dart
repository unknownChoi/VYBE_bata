// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_network_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceNetworkDataSource)
final deviceNetworkDataSourceProvider = DeviceNetworkDataSourceProvider._();

final class DeviceNetworkDataSourceProvider
    extends
        $FunctionalProvider<
          DeviceNetworkDataSource,
          DeviceNetworkDataSource,
          DeviceNetworkDataSource
        >
    with $Provider<DeviceNetworkDataSource> {
  DeviceNetworkDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceNetworkDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceNetworkDataSourceHash();

  @$internal
  @override
  $ProviderElement<DeviceNetworkDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceNetworkDataSource create(Ref ref) {
    return deviceNetworkDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceNetworkDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceNetworkDataSource>(value),
    );
  }
}

String _$deviceNetworkDataSourceHash() =>
    r'e4348f2e856477a7820da7ff505715bac1b9392c';
