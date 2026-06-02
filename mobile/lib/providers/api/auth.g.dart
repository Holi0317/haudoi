// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A notifier that monitors authentication state.
///
/// Listens to API errors (401, transport errors) and probes the server
/// to determine if the user is authenticated.

@ProviderFor(AuthState)
final authStateProvider = AuthStateProvider._();

/// A notifier that monitors authentication state.
///
/// Listens to API errors (401, transport errors) and probes the server
/// to determine if the user is authenticated.
final class AuthStateProvider
    extends $NotifierProvider<AuthState, AuthStateEnum> {
  /// A notifier that monitors authentication state.
  ///
  /// Listens to API errors (401, transport errors) and probes the server
  /// to determine if the user is authenticated.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  AuthState create() => AuthState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStateEnum value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStateEnum>(value),
    );
  }
}

String _$authStateHash() => r'9a59304a377008ab18c797490d122906aac0b525';

/// A notifier that monitors authentication state.
///
/// Listens to API errors (401, transport errors) and probes the server
/// to determine if the user is authenticated.

abstract class _$AuthState extends $Notifier<AuthStateEnum> {
  AuthStateEnum build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthStateEnum, AuthStateEnum>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStateEnum, AuthStateEnum>,
              AuthStateEnum,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// A notifier for managing authentication actions.
/// Return of this provider doesn't matter. Only use methods in the notifier instead.

@ProviderFor(Auth)
final authProvider = AuthProvider._();

/// A notifier for managing authentication actions.
/// Return of this provider doesn't matter. Only use methods in the notifier instead.
final class AuthProvider extends $AsyncNotifierProvider<Auth, void> {
  /// A notifier for managing authentication actions.
  /// Return of this provider doesn't matter. Only use methods in the notifier instead.
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();
}

String _$authHash() => r'8ad30c3ccc93098f7ee12e6b0d7152779662184a';

/// A notifier for managing authentication actions.
/// Return of this provider doesn't matter. Only use methods in the notifier instead.

abstract class _$Auth extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
