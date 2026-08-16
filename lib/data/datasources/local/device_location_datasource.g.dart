// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_location_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceLocationDataSource)
final deviceLocationDataSourceProvider = DeviceLocationDataSourceProvider._();

final class DeviceLocationDataSourceProvider
    extends
        $FunctionalProvider<
          DeviceLocationDataSource,
          DeviceLocationDataSource,
          DeviceLocationDataSource
        >
    with $Provider<DeviceLocationDataSource> {
  DeviceLocationDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceLocationDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceLocationDataSourceHash();

  @$internal
  @override
  $ProviderElement<DeviceLocationDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceLocationDataSource create(Ref ref) {
    return deviceLocationDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceLocationDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceLocationDataSource>(value),
    );
  }
}

String _$deviceLocationDataSourceHash() =>
    r'400d3412b6da98c4c9b339d014e97b22e3221076';
