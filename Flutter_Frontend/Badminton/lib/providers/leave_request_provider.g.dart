// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allLeaveRequestsHash() => r'195c904e5103fe9777ccb74c29dc428a02264e24';

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

/// Provider for all leave requests (owner view - all requests)
///
/// Copied from [allLeaveRequests].
@ProviderFor(allLeaveRequests)
const allLeaveRequestsProvider = AllLeaveRequestsFamily();

/// Provider for all leave requests (owner view - all requests)
///
/// Copied from [allLeaveRequests].
class AllLeaveRequestsFamily extends Family<AsyncValue<List<LeaveRequest>>> {
  /// Provider for all leave requests (owner view - all requests)
  ///
  /// Copied from [allLeaveRequests].
  const AllLeaveRequestsFamily();

  /// Provider for all leave requests (owner view - all requests)
  ///
  /// Copied from [allLeaveRequests].
  AllLeaveRequestsProvider call({String? status}) {
    return AllLeaveRequestsProvider(status: status);
  }

  @override
  AllLeaveRequestsProvider getProviderOverride(
    covariant AllLeaveRequestsProvider provider,
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
  String? get name => r'allLeaveRequestsProvider';
}

/// Provider for all leave requests (owner view - all requests)
///
/// Copied from [allLeaveRequests].
class AllLeaveRequestsProvider
    extends AutoDisposeFutureProvider<List<LeaveRequest>> {
  /// Provider for all leave requests (owner view - all requests)
  ///
  /// Copied from [allLeaveRequests].
  AllLeaveRequestsProvider({String? status})
    : this._internal(
        (ref) => allLeaveRequests(ref as AllLeaveRequestsRef, status: status),
        from: allLeaveRequestsProvider,
        name: r'allLeaveRequestsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allLeaveRequestsHash,
        dependencies: AllLeaveRequestsFamily._dependencies,
        allTransitiveDependencies:
            AllLeaveRequestsFamily._allTransitiveDependencies,
        status: status,
      );

  AllLeaveRequestsProvider._internal(
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
    FutureOr<List<LeaveRequest>> Function(AllLeaveRequestsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllLeaveRequestsProvider._internal(
        (ref) => create(ref as AllLeaveRequestsRef),
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
  AutoDisposeFutureProviderElement<List<LeaveRequest>> createElement() {
    return _AllLeaveRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllLeaveRequestsProvider && other.status == status;
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
mixin AllLeaveRequestsRef on AutoDisposeFutureProviderRef<List<LeaveRequest>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _AllLeaveRequestsProviderElement
    extends AutoDisposeFutureProviderElement<List<LeaveRequest>>
    with AllLeaveRequestsRef {
  _AllLeaveRequestsProviderElement(super.provider);

  @override
  String? get status => (origin as AllLeaveRequestsProvider).status;
}

String _$coachLeaveRequestsHash() =>
    r'b682129ed85026e08a30f23c847ff035bc48fcab';

/// Provider for leave requests by coach ID (coach view - their own requests)
///
/// Copied from [coachLeaveRequests].
@ProviderFor(coachLeaveRequests)
const coachLeaveRequestsProvider = CoachLeaveRequestsFamily();

/// Provider for leave requests by coach ID (coach view - their own requests)
///
/// Copied from [coachLeaveRequests].
class CoachLeaveRequestsFamily extends Family<AsyncValue<List<LeaveRequest>>> {
  /// Provider for leave requests by coach ID (coach view - their own requests)
  ///
  /// Copied from [coachLeaveRequests].
  const CoachLeaveRequestsFamily();

  /// Provider for leave requests by coach ID (coach view - their own requests)
  ///
  /// Copied from [coachLeaveRequests].
  CoachLeaveRequestsProvider call(int coachId, {String? status}) {
    return CoachLeaveRequestsProvider(coachId, status: status);
  }

  @override
  CoachLeaveRequestsProvider getProviderOverride(
    covariant CoachLeaveRequestsProvider provider,
  ) {
    return call(provider.coachId, status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachLeaveRequestsProvider';
}

/// Provider for leave requests by coach ID (coach view - their own requests)
///
/// Copied from [coachLeaveRequests].
class CoachLeaveRequestsProvider
    extends AutoDisposeFutureProvider<List<LeaveRequest>> {
  /// Provider for leave requests by coach ID (coach view - their own requests)
  ///
  /// Copied from [coachLeaveRequests].
  CoachLeaveRequestsProvider(int coachId, {String? status})
    : this._internal(
        (ref) => coachLeaveRequests(
          ref as CoachLeaveRequestsRef,
          coachId,
          status: status,
        ),
        from: coachLeaveRequestsProvider,
        name: r'coachLeaveRequestsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachLeaveRequestsHash,
        dependencies: CoachLeaveRequestsFamily._dependencies,
        allTransitiveDependencies:
            CoachLeaveRequestsFamily._allTransitiveDependencies,
        coachId: coachId,
        status: status,
      );

  CoachLeaveRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coachId,
    required this.status,
  }) : super.internal();

  final int coachId;
  final String? status;

  @override
  Override overrideWith(
    FutureOr<List<LeaveRequest>> Function(CoachLeaveRequestsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachLeaveRequestsProvider._internal(
        (ref) => create(ref as CoachLeaveRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coachId: coachId,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LeaveRequest>> createElement() {
    return _CoachLeaveRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachLeaveRequestsProvider &&
        other.coachId == coachId &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coachId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachLeaveRequestsRef
    on AutoDisposeFutureProviderRef<List<LeaveRequest>> {
  /// The parameter `coachId` of this provider.
  int get coachId;

  /// The parameter `status` of this provider.
  String? get status;
}

class _CoachLeaveRequestsProviderElement
    extends AutoDisposeFutureProviderElement<List<LeaveRequest>>
    with CoachLeaveRequestsRef {
  _CoachLeaveRequestsProviderElement(super.provider);

  @override
  int get coachId => (origin as CoachLeaveRequestsProvider).coachId;
  @override
  String? get status => (origin as CoachLeaveRequestsProvider).status;
}

String _$pendingLeaveRequestsHash() =>
    r'fc74482c7bdd3e12e5bc677aaca11868cade9fca';

/// Provider for pending leave requests (owner view)
///
/// Copied from [pendingLeaveRequests].
@ProviderFor(pendingLeaveRequests)
final pendingLeaveRequestsProvider =
    AutoDisposeFutureProvider<List<LeaveRequest>>.internal(
      pendingLeaveRequests,
      name: r'pendingLeaveRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingLeaveRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingLeaveRequestsRef =
    AutoDisposeFutureProviderRef<List<LeaveRequest>>;
String _$leaveRequestByIdHash() => r'3be253ece69762b5683e74bf7cf4204204fb2b61';

/// Provider for leave request by ID
///
/// Copied from [leaveRequestById].
@ProviderFor(leaveRequestById)
const leaveRequestByIdProvider = LeaveRequestByIdFamily();

/// Provider for leave request by ID
///
/// Copied from [leaveRequestById].
class LeaveRequestByIdFamily extends Family<AsyncValue<LeaveRequest>> {
  /// Provider for leave request by ID
  ///
  /// Copied from [leaveRequestById].
  const LeaveRequestByIdFamily();

  /// Provider for leave request by ID
  ///
  /// Copied from [leaveRequestById].
  LeaveRequestByIdProvider call(int id) {
    return LeaveRequestByIdProvider(id);
  }

  @override
  LeaveRequestByIdProvider getProviderOverride(
    covariant LeaveRequestByIdProvider provider,
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
  String? get name => r'leaveRequestByIdProvider';
}

/// Provider for leave request by ID
///
/// Copied from [leaveRequestById].
class LeaveRequestByIdProvider extends AutoDisposeFutureProvider<LeaveRequest> {
  /// Provider for leave request by ID
  ///
  /// Copied from [leaveRequestById].
  LeaveRequestByIdProvider(int id)
    : this._internal(
        (ref) => leaveRequestById(ref as LeaveRequestByIdRef, id),
        from: leaveRequestByIdProvider,
        name: r'leaveRequestByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leaveRequestByIdHash,
        dependencies: LeaveRequestByIdFamily._dependencies,
        allTransitiveDependencies:
            LeaveRequestByIdFamily._allTransitiveDependencies,
        id: id,
      );

  LeaveRequestByIdProvider._internal(
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
    FutureOr<LeaveRequest> Function(LeaveRequestByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LeaveRequestByIdProvider._internal(
        (ref) => create(ref as LeaveRequestByIdRef),
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
  AutoDisposeFutureProviderElement<LeaveRequest> createElement() {
    return _LeaveRequestByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveRequestByIdProvider && other.id == id;
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
mixin LeaveRequestByIdRef on AutoDisposeFutureProviderRef<LeaveRequest> {
  /// The parameter `id` of this provider.
  int get id;
}

class _LeaveRequestByIdProviderElement
    extends AutoDisposeFutureProviderElement<LeaveRequest>
    with LeaveRequestByIdRef {
  _LeaveRequestByIdProviderElement(super.provider);

  @override
  int get id => (origin as LeaveRequestByIdProvider).id;
}

String _$leaveRequestManagerHash() =>
    r'a87ab54d8559e7462ffbb6b3dc3a7b86f2bc127f';

abstract class _$LeaveRequestManager
    extends BuildlessAutoDisposeAsyncNotifier<List<LeaveRequest>> {
  late final int? coachId;
  late final String? status;

  FutureOr<List<LeaveRequest>> build({int? coachId, String? status});
}

/// Provider for leave request management (CRUD operations)
///
/// Copied from [LeaveRequestManager].
@ProviderFor(LeaveRequestManager)
const leaveRequestManagerProvider = LeaveRequestManagerFamily();

/// Provider for leave request management (CRUD operations)
///
/// Copied from [LeaveRequestManager].
class LeaveRequestManagerFamily extends Family<AsyncValue<List<LeaveRequest>>> {
  /// Provider for leave request management (CRUD operations)
  ///
  /// Copied from [LeaveRequestManager].
  const LeaveRequestManagerFamily();

  /// Provider for leave request management (CRUD operations)
  ///
  /// Copied from [LeaveRequestManager].
  LeaveRequestManagerProvider call({int? coachId, String? status}) {
    return LeaveRequestManagerProvider(coachId: coachId, status: status);
  }

  @override
  LeaveRequestManagerProvider getProviderOverride(
    covariant LeaveRequestManagerProvider provider,
  ) {
    return call(coachId: provider.coachId, status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'leaveRequestManagerProvider';
}

/// Provider for leave request management (CRUD operations)
///
/// Copied from [LeaveRequestManager].
class LeaveRequestManagerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          LeaveRequestManager,
          List<LeaveRequest>
        > {
  /// Provider for leave request management (CRUD operations)
  ///
  /// Copied from [LeaveRequestManager].
  LeaveRequestManagerProvider({int? coachId, String? status})
    : this._internal(
        () => LeaveRequestManager()
          ..coachId = coachId
          ..status = status,
        from: leaveRequestManagerProvider,
        name: r'leaveRequestManagerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leaveRequestManagerHash,
        dependencies: LeaveRequestManagerFamily._dependencies,
        allTransitiveDependencies:
            LeaveRequestManagerFamily._allTransitiveDependencies,
        coachId: coachId,
        status: status,
      );

  LeaveRequestManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coachId,
    required this.status,
  }) : super.internal();

  final int? coachId;
  final String? status;

  @override
  FutureOr<List<LeaveRequest>> runNotifierBuild(
    covariant LeaveRequestManager notifier,
  ) {
    return notifier.build(coachId: coachId, status: status);
  }

  @override
  Override overrideWith(LeaveRequestManager Function() create) {
    return ProviderOverride(
      origin: this,
      override: LeaveRequestManagerProvider._internal(
        () => create()
          ..coachId = coachId
          ..status = status,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coachId: coachId,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    LeaveRequestManager,
    List<LeaveRequest>
  >
  createElement() {
    return _LeaveRequestManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveRequestManagerProvider &&
        other.coachId == coachId &&
        other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coachId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LeaveRequestManagerRef
    on AutoDisposeAsyncNotifierProviderRef<List<LeaveRequest>> {
  /// The parameter `coachId` of this provider.
  int? get coachId;

  /// The parameter `status` of this provider.
  String? get status;
}

class _LeaveRequestManagerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          LeaveRequestManager,
          List<LeaveRequest>
        >
    with LeaveRequestManagerRef {
  _LeaveRequestManagerProviderElement(super.provider);

  @override
  int? get coachId => (origin as LeaveRequestManagerProvider).coachId;
  @override
  String? get status => (origin as LeaveRequestManagerProvider).status;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
