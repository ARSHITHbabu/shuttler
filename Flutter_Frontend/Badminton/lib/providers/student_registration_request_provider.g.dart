// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_registration_request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentRegistrationRequestManagerHash() =>
    r'a36fa2b8a4095f10cf639b72766ce49a35b17f29';

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

/// Provider for all student registration requests (owner view)
///
/// Copied from [studentRegistrationRequestManager].
@ProviderFor(studentRegistrationRequestManager)
const studentRegistrationRequestManagerProvider =
    StudentRegistrationRequestManagerFamily();

/// Provider for all student registration requests (owner view)
///
/// Copied from [studentRegistrationRequestManager].
class StudentRegistrationRequestManagerFamily
    extends Family<AsyncValue<List<StudentRegistrationRequest>>> {
  /// Provider for all student registration requests (owner view)
  ///
  /// Copied from [studentRegistrationRequestManager].
  const StudentRegistrationRequestManagerFamily();

  /// Provider for all student registration requests (owner view)
  ///
  /// Copied from [studentRegistrationRequestManager].
  StudentRegistrationRequestManagerProvider call({String? status}) {
    return StudentRegistrationRequestManagerProvider(status: status);
  }

  @override
  StudentRegistrationRequestManagerProvider getProviderOverride(
    covariant StudentRegistrationRequestManagerProvider provider,
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
  String? get name => r'studentRegistrationRequestManagerProvider';
}

/// Provider for all student registration requests (owner view)
///
/// Copied from [studentRegistrationRequestManager].
class StudentRegistrationRequestManagerProvider
    extends AutoDisposeFutureProvider<List<StudentRegistrationRequest>> {
  /// Provider for all student registration requests (owner view)
  ///
  /// Copied from [studentRegistrationRequestManager].
  StudentRegistrationRequestManagerProvider({String? status})
    : this._internal(
        (ref) => studentRegistrationRequestManager(
          ref as StudentRegistrationRequestManagerRef,
          status: status,
        ),
        from: studentRegistrationRequestManagerProvider,
        name: r'studentRegistrationRequestManagerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentRegistrationRequestManagerHash,
        dependencies: StudentRegistrationRequestManagerFamily._dependencies,
        allTransitiveDependencies:
            StudentRegistrationRequestManagerFamily._allTransitiveDependencies,
        status: status,
      );

  StudentRegistrationRequestManagerProvider._internal(
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
    FutureOr<List<StudentRegistrationRequest>> Function(
      StudentRegistrationRequestManagerRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentRegistrationRequestManagerProvider._internal(
        (ref) => create(ref as StudentRegistrationRequestManagerRef),
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
  AutoDisposeFutureProviderElement<List<StudentRegistrationRequest>>
  createElement() {
    return _StudentRegistrationRequestManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentRegistrationRequestManagerProvider &&
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
mixin StudentRegistrationRequestManagerRef
    on AutoDisposeFutureProviderRef<List<StudentRegistrationRequest>> {
  /// The parameter `status` of this provider.
  String? get status;
}

class _StudentRegistrationRequestManagerProviderElement
    extends AutoDisposeFutureProviderElement<List<StudentRegistrationRequest>>
    with StudentRegistrationRequestManagerRef {
  _StudentRegistrationRequestManagerProviderElement(super.provider);

  @override
  String? get status =>
      (origin as StudentRegistrationRequestManagerProvider).status;
}

String _$studentRegistrationRequestByIdHash() =>
    r'aa5d3a39051c4b5a43f687b020a3eed215d2b09b';

/// Provider for student registration request by ID
///
/// Copied from [studentRegistrationRequestById].
@ProviderFor(studentRegistrationRequestById)
const studentRegistrationRequestByIdProvider =
    StudentRegistrationRequestByIdFamily();

/// Provider for student registration request by ID
///
/// Copied from [studentRegistrationRequestById].
class StudentRegistrationRequestByIdFamily
    extends Family<AsyncValue<StudentRegistrationRequest>> {
  /// Provider for student registration request by ID
  ///
  /// Copied from [studentRegistrationRequestById].
  const StudentRegistrationRequestByIdFamily();

  /// Provider for student registration request by ID
  ///
  /// Copied from [studentRegistrationRequestById].
  StudentRegistrationRequestByIdProvider call(int id) {
    return StudentRegistrationRequestByIdProvider(id);
  }

  @override
  StudentRegistrationRequestByIdProvider getProviderOverride(
    covariant StudentRegistrationRequestByIdProvider provider,
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
  String? get name => r'studentRegistrationRequestByIdProvider';
}

/// Provider for student registration request by ID
///
/// Copied from [studentRegistrationRequestById].
class StudentRegistrationRequestByIdProvider
    extends AutoDisposeFutureProvider<StudentRegistrationRequest> {
  /// Provider for student registration request by ID
  ///
  /// Copied from [studentRegistrationRequestById].
  StudentRegistrationRequestByIdProvider(int id)
    : this._internal(
        (ref) => studentRegistrationRequestById(
          ref as StudentRegistrationRequestByIdRef,
          id,
        ),
        from: studentRegistrationRequestByIdProvider,
        name: r'studentRegistrationRequestByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentRegistrationRequestByIdHash,
        dependencies: StudentRegistrationRequestByIdFamily._dependencies,
        allTransitiveDependencies:
            StudentRegistrationRequestByIdFamily._allTransitiveDependencies,
        id: id,
      );

  StudentRegistrationRequestByIdProvider._internal(
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
    FutureOr<StudentRegistrationRequest> Function(
      StudentRegistrationRequestByIdRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentRegistrationRequestByIdProvider._internal(
        (ref) => create(ref as StudentRegistrationRequestByIdRef),
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
  AutoDisposeFutureProviderElement<StudentRegistrationRequest> createElement() {
    return _StudentRegistrationRequestByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentRegistrationRequestByIdProvider && other.id == id;
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
mixin StudentRegistrationRequestByIdRef
    on AutoDisposeFutureProviderRef<StudentRegistrationRequest> {
  /// The parameter `id` of this provider.
  int get id;
}

class _StudentRegistrationRequestByIdProviderElement
    extends AutoDisposeFutureProviderElement<StudentRegistrationRequest>
    with StudentRegistrationRequestByIdRef {
  _StudentRegistrationRequestByIdProviderElement(super.provider);

  @override
  int get id => (origin as StudentRegistrationRequestByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
