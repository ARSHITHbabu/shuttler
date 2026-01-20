// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionListHash() => r'136e1ad56bf7dad384d1a6fb815926a1eb46de90';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for all sessions, optionally filtered by status
///
/// Copied from [sessionList].
@ProviderFor(sessionList)
const sessionListProvider = SessionListFamily();

/// Provider for all sessions, optionally filtered by status
///
/// Copied from [sessionList].
class SessionListFamily extends Family<AsyncValue<List<Session>>> {
  /// Provider for all sessions, optionally filtered by status
  ///
  /// Copied from [sessionList].
  const SessionListFamily();

  /// Provider for all sessions, optionally filtered by status
  ///
  /// Copied from [sessionList].
  SessionListProvider call({String? status}) {
    return SessionListProvider(status: status);
  }

  @override
  SessionListProvider getProviderOverride(
    covariant SessionListProvider provider,
  ) {
    return call(status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionListProvider';
}

/// Provider for all sessions, optionally filtered by status
///
/// Copied from [sessionList].
class SessionListProvider extends AutoDisposeFutureProvider<List<Session>> {
  /// Provider for all sessions, optionally filtered by status
  ///
  /// Copied from [sessionList].
  SessionListProvider({String? status})
    : this._internal(
        (ref) => sessionList(ref as SessionListRef, status: status),
        from: sessionListProvider,
        name: r'sessionListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionListHash,
        dependencies: SessionListFamily._dependencies,
        allTransitiveDependencies: SessionListFamily._allTransitiveDependencies,
        status: status,
      );

  SessionListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String? status;

  @override
  Override overrideWith(
    FutureOr<List<Session>> Function(SessionListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionListProvider._internal(
        (ref) => create(ref as SessionListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Session>> createElement() {
    return _SessionListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionListProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionListRef on AutoDisposeFutureProviderRef<List<Session>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _SessionListProviderElement
    extends AutoDisposeFutureProviderElement<List<Session>>
    with SessionListRef {
  _SessionListProviderElement(super.provider);

  @override
  String? get status => (origin as SessionListProvider).status;
}

String _$activeSessionsHash() => r'cbc2d2fcee8db32e53a2bb5c42d1f958f1947018';

/// Provider for active sessions only
///
/// Copied from [activeSessions].
@ProviderFor(activeSessions)
final activeSessionsProvider =
    AutoDisposeFutureProvider<List<Session>>.internal(
      activeSessions,
      name: r'activeSessionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSessionsRef = AutoDisposeFutureProviderRef<List<Session>>;
String _$archivedSessionsHash() => r'a7035f37137ff89317cc8bc5178581d2cdcfda4d';

/// Provider for archived sessions only
///
/// Copied from [archivedSessions].
@ProviderFor(archivedSessions)
final archivedSessionsProvider =
    AutoDisposeFutureProvider<List<Session>>.internal(
      archivedSessions,
      name: r'archivedSessionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$archivedSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchivedSessionsRef = AutoDisposeFutureProviderRef<List<Session>>;
String _$sessionByIdHash() => r'cbd6ac90a17d1ed8738a46674071516939023881';

/// Provider for session by ID
///
/// Copied from [sessionById].
@ProviderFor(sessionById)
const sessionByIdProvider = SessionByIdFamily();

/// Provider for session by ID
///
/// Copied from [sessionById].
class SessionByIdFamily extends Family<AsyncValue<Session>> {
  /// Provider for session by ID
  ///
  /// Copied from [sessionById].
  const SessionByIdFamily();

  /// Provider for session by ID
  ///
  /// Copied from [sessionById].
  SessionByIdProvider call(int id) {
    return SessionByIdProvider(id);
  }

  @override
  SessionByIdProvider getProviderOverride(
    covariant SessionByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionByIdProvider';
}

/// Provider for session by ID
///
/// Copied from [sessionById].
class SessionByIdProvider extends AutoDisposeFutureProvider<Session> {
  /// Provider for session by ID
  ///
  /// Copied from [sessionById].
  SessionByIdProvider(int id)
    : this._internal(
        (ref) => sessionById(ref as SessionByIdRef, id),
        from: sessionByIdProvider,
        name: r'sessionByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionByIdHash,
        dependencies: SessionByIdFamily._dependencies,
        allTransitiveDependencies: SessionByIdFamily._allTransitiveDependencies,
        id: id,
      );

  SessionByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Session> Function(SessionByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionByIdProvider._internal(
        (ref) => create(ref as SessionByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Session> createElement() {
    return _SessionByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionByIdRef on AutoDisposeFutureProviderRef<Session> {
  /// The parameter `id` of this provider.
  int get id;
}

class _SessionByIdProviderElement
    extends AutoDisposeFutureProviderElement<Session>
    with SessionByIdRef {
  _SessionByIdProviderElement(super.provider);

  @override
  int get id => (origin as SessionByIdProvider).id;
}

String _$sessionManagerHash() => r'6423f6eb1b4e80baf432a012cd745770419574f4';

abstract class _$SessionManager
    extends BuildlessAutoDisposeAsyncNotifier<List<Session>> {
  late final String? status;

  FutureOr<List<Session>> build({String? status});
}

/// Provider class for session CRUD operations
///
/// Copied from [SessionManager].
@ProviderFor(SessionManager)
const sessionManagerProvider = SessionManagerFamily();

/// Provider class for session CRUD operations
///
/// Copied from [SessionManager].
class SessionManagerFamily extends Family<AsyncValue<List<Session>>> {
  /// Provider class for session CRUD operations
  ///
  /// Copied from [SessionManager].
  const SessionManagerFamily();

  /// Provider class for session CRUD operations
  ///
  /// Copied from [SessionManager].
  SessionManagerProvider call({String? status}) {
    return SessionManagerProvider(status: status);
  }

  @override
  SessionManagerProvider getProviderOverride(
    covariant SessionManagerProvider provider,
  ) {
    return call(status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionManagerProvider';
}

/// Provider class for session CRUD operations
///
/// Copied from [SessionManager].
class SessionManagerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<SessionManager, List<Session>> {
  /// Provider class for session CRUD operations
  ///
  /// Copied from [SessionManager].
  SessionManagerProvider({String? status})
    : this._internal(
        () => SessionManager()..status = status,
        from: sessionManagerProvider,
        name: r'sessionManagerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionManagerHash,
        dependencies: SessionManagerFamily._dependencies,
        allTransitiveDependencies:
            SessionManagerFamily._allTransitiveDependencies,
        status: status,
      );

  SessionManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String? status;

  @override
  FutureOr<List<Session>> runNotifierBuild(covariant SessionManager notifier) {
    return notifier.build(status: status);
  }

  @override
  Override overrideWith(SessionManager Function() create) {
    return ProviderOverride(
      origin: this,
      override: SessionManagerProvider._internal(
        () => create()..status = status,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SessionManager, List<Session>>
  createElement() {
    return _SessionManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionManagerProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionManagerRef on AutoDisposeAsyncNotifierProviderRef<List<Session>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _SessionManagerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<SessionManager, List<Session>>
    with SessionManagerRef {
  _SessionManagerProviderElement(super.provider);

  @override
  String? get status => (origin as SessionManagerProvider).status;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
