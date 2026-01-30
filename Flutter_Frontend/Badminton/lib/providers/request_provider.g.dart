// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$requestByIdHash() => r'2f5d6d6425d8fd69c130d31bd0a4f63b422c1aeb';

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

/// Provider for request by ID
///
/// Copied from [requestById].
@ProviderFor(requestById)
const requestByIdProvider = RequestByIdFamily();

/// Provider for request by ID
///
/// Copied from [requestById].
class RequestByIdFamily extends Family<AsyncValue<Request>> {
  /// Provider for request by ID
  ///
  /// Copied from [requestById].
  const RequestByIdFamily();

  /// Provider for request by ID
  ///
  /// Copied from [requestById].
  RequestByIdProvider call(int id) {
    return RequestByIdProvider(id);
  }

  @override
  RequestByIdProvider getProviderOverride(
    covariant RequestByIdProvider provider,
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
  String? get name => r'requestByIdProvider';
}

/// Provider for request by ID
///
/// Copied from [requestById].
class RequestByIdProvider extends AutoDisposeFutureProvider<Request> {
  /// Provider for request by ID
  ///
  /// Copied from [requestById].
  RequestByIdProvider(int id)
    : this._internal(
        (ref) => requestById(ref as RequestByIdRef, id),
        from: requestByIdProvider,
        name: r'requestByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$requestByIdHash,
        dependencies: RequestByIdFamily._dependencies,
        allTransitiveDependencies: RequestByIdFamily._allTransitiveDependencies,
        id: id,
      );

  RequestByIdProvider._internal(
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
    FutureOr<Request> Function(RequestByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RequestByIdProvider._internal(
        (ref) => create(ref as RequestByIdRef),
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
  AutoDisposeFutureProviderElement<Request> createElement() {
    return _RequestByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RequestByIdProvider && other.id == id;
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
mixin RequestByIdRef on AutoDisposeFutureProviderRef<Request> {
  /// The parameter `id` of this provider.
  int get id;
}

class _RequestByIdProviderElement
    extends AutoDisposeFutureProviderElement<Request>
    with RequestByIdRef {
  _RequestByIdProviderElement(super.provider);

  @override
  int get id => (origin as RequestByIdProvider).id;
}

String _$requestStatsHash() => r'7f3940812fb312c99505fdb41d4b05542b1db351';

/// Provider for request statistics
///
/// Copied from [requestStats].
@ProviderFor(requestStats)
final requestStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      requestStats,
      name: r'requestStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requestStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequestStatsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$pendingRequestsCountHash() =>
    r'0e886d75a2f340a5d16fd7814b6020b7725c2be7';

/// Provider for pending requests count (for badges)
///
/// Copied from [pendingRequestsCount].
@ProviderFor(pendingRequestsCount)
final pendingRequestsCountProvider = AutoDisposeFutureProvider<int>.internal(
  pendingRequestsCount,
  name: r'pendingRequestsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingRequestsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingRequestsCountRef = AutoDisposeFutureProviderRef<int>;
String _$requestsByTypeHash() => r'26a30032ecba484f9ba7e74a8ef28f099662755f';

/// Provider for requests by type
///
/// Copied from [requestsByType].
@ProviderFor(requestsByType)
const requestsByTypeProvider = RequestsByTypeFamily();

/// Provider for requests by type
///
/// Copied from [requestsByType].
class RequestsByTypeFamily extends Family<AsyncValue<List<Request>>> {
  /// Provider for requests by type
  ///
  /// Copied from [requestsByType].
  const RequestsByTypeFamily();

  /// Provider for requests by type
  ///
  /// Copied from [requestsByType].
  RequestsByTypeProvider call(String requestType, {String? status}) {
    return RequestsByTypeProvider(requestType, status: status);
  }

  @override
  RequestsByTypeProvider getProviderOverride(
    covariant RequestsByTypeProvider provider,
  ) {
    return call(provider.requestType, status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'requestsByTypeProvider';
}

/// Provider for requests by type
///
/// Copied from [requestsByType].
class RequestsByTypeProvider extends AutoDisposeFutureProvider<List<Request>> {
  /// Provider for requests by type
  ///
  /// Copied from [requestsByType].
  RequestsByTypeProvider(String requestType, {String? status})
    : this._internal(
        (ref) => requestsByType(
          ref as RequestsByTypeRef,
          requestType,
          status: status,
        ),
        from: requestsByTypeProvider,
        name: r'requestsByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$requestsByTypeHash,
        dependencies: RequestsByTypeFamily._dependencies,
        allTransitiveDependencies:
            RequestsByTypeFamily._allTransitiveDependencies,
        requestType: requestType,
        status: status,
      );

  RequestsByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestType,
    required this.status,
  }) : super.internal();

  final String requestType;
  final String? status;

  @override
  Override overrideWith(
    FutureOr<List<Request>> Function(RequestsByTypeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RequestsByTypeProvider._internal(
        (ref) => create(ref as RequestsByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestType: requestType,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Request>> createElement() {
    return _RequestsByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RequestsByTypeProvider &&
        other.requestType == requestType &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RequestsByTypeRef on AutoDisposeFutureProviderRef<List<Request>> {
  /// The parameter `requestType` of this provider.
  String get requestType;

  /// The parameter `status` of this provider.
  String? get status;
}

class _RequestsByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<Request>>
    with RequestsByTypeRef {
  _RequestsByTypeProviderElement(super.provider);

  @override
  String get requestType => (origin as RequestsByTypeProvider).requestType;
  @override
  String? get status => (origin as RequestsByTypeProvider).status;
}

String _$requestListHash() => r'949b7a3974cc93651c42592678ba0f83c1ad4ecf';

abstract class _$RequestList
    extends BuildlessAutoDisposeAsyncNotifier<List<Request>> {
  late final String? requestType;
  late final String? status;
  late final String? requesterType;
  late final int? requesterId;

  FutureOr<List<Request>> build({
    String? requestType,
    String? status,
    String? requesterType,
    int? requesterId,
  });
}

/// Provider for request list state with filters
///
/// Copied from [RequestList].
@ProviderFor(RequestList)
const requestListProvider = RequestListFamily();

/// Provider for request list state with filters
///
/// Copied from [RequestList].
class RequestListFamily extends Family<AsyncValue<List<Request>>> {
  /// Provider for request list state with filters
  ///
  /// Copied from [RequestList].
  const RequestListFamily();

  /// Provider for request list state with filters
  ///
  /// Copied from [RequestList].
  RequestListProvider call({
    String? requestType,
    String? status,
    String? requesterType,
    int? requesterId,
  }) {
    return RequestListProvider(
      requestType: requestType,
      status: status,
      requesterType: requesterType,
      requesterId: requesterId,
    );
  }

  @override
  RequestListProvider getProviderOverride(
    covariant RequestListProvider provider,
  ) {
    return call(
      requestType: provider.requestType,
      status: provider.status,
      requesterType: provider.requesterType,
      requesterId: provider.requesterId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'requestListProvider';
}

/// Provider for request list state with filters
///
/// Copied from [RequestList].
class RequestListProvider
    extends AutoDisposeAsyncNotifierProviderImpl<RequestList, List<Request>> {
  /// Provider for request list state with filters
  ///
  /// Copied from [RequestList].
  RequestListProvider({
    String? requestType,
    String? status,
    String? requesterType,
    int? requesterId,
  }) : this._internal(
         () => RequestList()
           ..requestType = requestType
           ..status = status
           ..requesterType = requesterType
           ..requesterId = requesterId,
         from: requestListProvider,
         name: r'requestListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$requestListHash,
         dependencies: RequestListFamily._dependencies,
         allTransitiveDependencies:
             RequestListFamily._allTransitiveDependencies,
         requestType: requestType,
         status: status,
         requesterType: requesterType,
         requesterId: requesterId,
       );

  RequestListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestType,
    required this.status,
    required this.requesterType,
    required this.requesterId,
  }) : super.internal();

  final String? requestType;
  final String? status;
  final String? requesterType;
  final int? requesterId;

  @override
  FutureOr<List<Request>> runNotifierBuild(covariant RequestList notifier) {
    return notifier.build(
      requestType: requestType,
      status: status,
      requesterType: requesterType,
      requesterId: requesterId,
    );
  }

  @override
  Override overrideWith(RequestList Function() create) {
    return ProviderOverride(
      origin: this,
      override: RequestListProvider._internal(
        () => create()
          ..requestType = requestType
          ..status = status
          ..requesterType = requesterType
          ..requesterId = requesterId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestType: requestType,
        status: status,
        requesterType: requesterType,
        requesterId: requesterId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<RequestList, List<Request>>
  createElement() {
    return _RequestListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RequestListProvider &&
        other.requestType == requestType &&
        other.status == status &&
        other.requesterType == requesterType &&
        other.requesterId == requesterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, requesterType.hashCode);
    hash = _SystemHash.combine(hash, requesterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RequestListRef on AutoDisposeAsyncNotifierProviderRef<List<Request>> {
  /// The parameter `requestType` of this provider.
  String? get requestType;

  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `requesterType` of this provider.
  String? get requesterType;

  /// The parameter `requesterId` of this provider.
  int? get requesterId;
}

class _RequestListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RequestList, List<Request>>
    with RequestListRef {
  _RequestListProviderElement(super.provider);

  @override
  String? get requestType => (origin as RequestListProvider).requestType;
  @override
  String? get status => (origin as RequestListProvider).status;
  @override
  String? get requesterType => (origin as RequestListProvider).requesterType;
  @override
  int? get requesterId => (origin as RequestListProvider).requesterId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
