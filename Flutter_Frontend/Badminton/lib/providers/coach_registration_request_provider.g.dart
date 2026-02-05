// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_registration_request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coachRegistrationRequestManagerHash() =>
    r'1e8b7b677823a90d4d5e7fc4cf60a071873c876d';

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

/// Provider for all coach registration requests (owner view)
///
/// Copied from [coachRegistrationRequestManager].
@ProviderFor(coachRegistrationRequestManager)
const coachRegistrationRequestManagerProvider =
    CoachRegistrationRequestManagerFamily();

/// Provider for all coach registration requests (owner view)
///
/// Copied from [coachRegistrationRequestManager].
class CoachRegistrationRequestManagerFamily
    extends Family<AsyncValue<List<CoachRegistrationRequest>>> {
  /// Provider for all coach registration requests (owner view)
  ///
  /// Copied from [coachRegistrationRequestManager].
  const CoachRegistrationRequestManagerFamily();

  /// Provider for all coach registration requests (owner view)
  ///
  /// Copied from [coachRegistrationRequestManager].
  CoachRegistrationRequestManagerProvider call({String? status}) {
    return CoachRegistrationRequestManagerProvider(status: status);
  }

  @override
  CoachRegistrationRequestManagerProvider getProviderOverride(
    covariant CoachRegistrationRequestManagerProvider provider,
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
  String? get name => r'coachRegistrationRequestManagerProvider';
}

/// Provider for all coach registration requests (owner view)
///
/// Copied from [coachRegistrationRequestManager].
class CoachRegistrationRequestManagerProvider
    extends AutoDisposeFutureProvider<List<CoachRegistrationRequest>> {
  /// Provider for all coach registration requests (owner view)
  ///
  /// Copied from [coachRegistrationRequestManager].
  CoachRegistrationRequestManagerProvider({String? status})
    : this._internal(
        (ref) => coachRegistrationRequestManager(
          ref as CoachRegistrationRequestManagerRef,
          status: status,
        ),
        from: coachRegistrationRequestManagerProvider,
        name: r'coachRegistrationRequestManagerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachRegistrationRequestManagerHash,
        dependencies: CoachRegistrationRequestManagerFamily._dependencies,
        allTransitiveDependencies:
            CoachRegistrationRequestManagerFamily._allTransitiveDependencies,
        status: status,
      );

  CoachRegistrationRequestManagerProvider._internal(
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
    FutureOr<List<CoachRegistrationRequest>> Function(
      CoachRegistrationRequestManagerRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachRegistrationRequestManagerProvider._internal(
        (ref) => create(ref as CoachRegistrationRequestManagerRef),
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
  AutoDisposeFutureProviderElement<List<CoachRegistrationRequest>>
  createElement() {
    return _CoachRegistrationRequestManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachRegistrationRequestManagerProvider &&
        other.status == status;
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
mixin CoachRegistrationRequestManagerRef
    on AutoDisposeFutureProviderRef<List<CoachRegistrationRequest>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _CoachRegistrationRequestManagerProviderElement
    extends AutoDisposeFutureProviderElement<List<CoachRegistrationRequest>>
    with CoachRegistrationRequestManagerRef {
  _CoachRegistrationRequestManagerProviderElement(super.provider);

  @override
  String? get status =>
      (origin as CoachRegistrationRequestManagerProvider).status;
}

String _$coachRegistrationRequestByIdHash() =>
    r'b133f6868efeec924781464663f70da2d12bf230';

/// Provider for coach registration request by ID
///
/// Copied from [coachRegistrationRequestById].
@ProviderFor(coachRegistrationRequestById)
const coachRegistrationRequestByIdProvider =
    CoachRegistrationRequestByIdFamily();

/// Provider for coach registration request by ID
///
/// Copied from [coachRegistrationRequestById].
class CoachRegistrationRequestByIdFamily
    extends Family<AsyncValue<CoachRegistrationRequest>> {
  /// Provider for coach registration request by ID
  ///
  /// Copied from [coachRegistrationRequestById].
  const CoachRegistrationRequestByIdFamily();

  /// Provider for coach registration request by ID
  ///
  /// Copied from [coachRegistrationRequestById].
  CoachRegistrationRequestByIdProvider call(int id) {
    return CoachRegistrationRequestByIdProvider(id);
  }

  @override
  CoachRegistrationRequestByIdProvider getProviderOverride(
    covariant CoachRegistrationRequestByIdProvider provider,
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
  String? get name => r'coachRegistrationRequestByIdProvider';
}

/// Provider for coach registration request by ID
///
/// Copied from [coachRegistrationRequestById].
class CoachRegistrationRequestByIdProvider
    extends AutoDisposeFutureProvider<CoachRegistrationRequest> {
  /// Provider for coach registration request by ID
  ///
  /// Copied from [coachRegistrationRequestById].
  CoachRegistrationRequestByIdProvider(int id)
    : this._internal(
        (ref) => coachRegistrationRequestById(
          ref as CoachRegistrationRequestByIdRef,
          id,
        ),
        from: coachRegistrationRequestByIdProvider,
        name: r'coachRegistrationRequestByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachRegistrationRequestByIdHash,
        dependencies: CoachRegistrationRequestByIdFamily._dependencies,
        allTransitiveDependencies:
            CoachRegistrationRequestByIdFamily._allTransitiveDependencies,
        id: id,
      );

  CoachRegistrationRequestByIdProvider._internal(
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
    FutureOr<CoachRegistrationRequest> Function(
      CoachRegistrationRequestByIdRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachRegistrationRequestByIdProvider._internal(
        (ref) => create(ref as CoachRegistrationRequestByIdRef),
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
  AutoDisposeFutureProviderElement<CoachRegistrationRequest> createElement() {
    return _CoachRegistrationRequestByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachRegistrationRequestByIdProvider && other.id == id;
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
mixin CoachRegistrationRequestByIdRef
    on AutoDisposeFutureProviderRef<CoachRegistrationRequest> {
  /// The parameter `id` of this provider.
  int get id;
}

class _CoachRegistrationRequestByIdProviderElement
    extends AutoDisposeFutureProviderElement<CoachRegistrationRequest>
    with CoachRegistrationRequestByIdRef {
  _CoachRegistrationRequestByIdProviderElement(super.provider);

  @override
  int get id => (origin as CoachRegistrationRequestByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
