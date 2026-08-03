// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 알림 목록 + 읽음 처리.
///
/// 화면(위젯)은 상태를 들고 있지 않고 이 ViewModel만 구독한다.
/// autoDispose라 화면을 나가면 상태가 비워져 재진입 시 다시 로딩부터 시작한다.

@ProviderFor(NotificationViewModel)
final notificationViewModelProvider = NotificationViewModelProvider._();

/// 알림 목록 + 읽음 처리.
///
/// 화면(위젯)은 상태를 들고 있지 않고 이 ViewModel만 구독한다.
/// autoDispose라 화면을 나가면 상태가 비워져 재진입 시 다시 로딩부터 시작한다.
final class NotificationViewModelProvider
    extends $NotifierProvider<NotificationViewModel, NotificationState> {
  /// 알림 목록 + 읽음 처리.
  ///
  /// 화면(위젯)은 상태를 들고 있지 않고 이 ViewModel만 구독한다.
  /// autoDispose라 화면을 나가면 상태가 비워져 재진입 시 다시 로딩부터 시작한다.
  NotificationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationViewModelHash();

  @$internal
  @override
  NotificationViewModel create() => NotificationViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationState>(value),
    );
  }
}

String _$notificationViewModelHash() =>
    r'd0bd583caeb85a43a7727bc0784ab9fbe68c6c53';

/// 알림 목록 + 읽음 처리.
///
/// 화면(위젯)은 상태를 들고 있지 않고 이 ViewModel만 구독한다.
/// autoDispose라 화면을 나가면 상태가 비워져 재진입 시 다시 로딩부터 시작한다.

abstract class _$NotificationViewModel extends $Notifier<NotificationState> {
  NotificationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NotificationState, NotificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationState, NotificationState>,
              NotificationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
