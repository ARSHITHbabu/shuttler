// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentAttendanceHash() => r'03f5cb699cd4b50f224c54d253d3441ca0a4c329';

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

/// Provider for student attendance by date and batch
///
/// Copied from [studentAttendance].
@ProviderFor(studentAttendance)
const studentAttendanceProvider = StudentAttendanceFamily();

/// Provider for student attendance by date and batch
///
/// Copied from [studentAttendance].
class StudentAttendanceFamily extends Family<AsyncValue<List<Attendance>>> {
  /// Provider for student attendance by date and batch
  ///
  /// Copied from [studentAttendance].
  const StudentAttendanceFamily();

  /// Provider for student attendance by date and batch
  ///
  /// Copied from [studentAttendance].
  StudentAttendanceProvider call(DateTime date, int batchId) {
    return StudentAttendanceProvider(date, batchId);
  }

  @override
  StudentAttendanceProvider getProviderOverride(
    covariant StudentAttendanceProvider provider,
  ) {
    return call(provider.date, provider.batchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentAttendanceProvider';
}

/// Provider for student attendance by date and batch
///
/// Copied from [studentAttendance].
class StudentAttendanceProvider
    extends AutoDisposeFutureProvider<List<Attendance>> {
  /// Provider for student attendance by date and batch
  ///
  /// Copied from [studentAttendance].
  StudentAttendanceProvider(DateTime date, int batchId)
    : this._internal(
        (ref) => studentAttendance(ref as StudentAttendanceRef, date, batchId),
        from: studentAttendanceProvider,
        name: r'studentAttendanceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentAttendanceHash,
        dependencies: StudentAttendanceFamily._dependencies,
        allTransitiveDependencies:
            StudentAttendanceFamily._allTransitiveDependencies,
        date: date,
        batchId: batchId,
      );

  StudentAttendanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
    required this.batchId,
  }) : super.internal();

  final DateTime date;
  final int batchId;

  @override
  Override overrideWith(
    FutureOr<List<Attendance>> Function(StudentAttendanceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentAttendanceProvider._internal(
        (ref) => create(ref as StudentAttendanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
        batchId: batchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Attendance>> createElement() {
    return _StudentAttendanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentAttendanceProvider &&
        other.date == date &&
        other.batchId == batchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, batchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentAttendanceRef on AutoDisposeFutureProviderRef<List<Attendance>> {
  /// The parameter `date` of this provider.
  DateTime get date;

  /// The parameter `batchId` of this provider.
  int get batchId;
}

class _StudentAttendanceProviderElement
    extends AutoDisposeFutureProviderElement<List<Attendance>>
    with StudentAttendanceRef {
  _StudentAttendanceProviderElement(super.provider);

  @override
  DateTime get date => (origin as StudentAttendanceProvider).date;
  @override
  int get batchId => (origin as StudentAttendanceProvider).batchId;
}

String _$coachAttendanceHash() => r'10fa4d41ebbbed3b1e5bf824a3ffc64b4425dc1c';

/// Provider for coach attendance by date
///
/// Copied from [coachAttendance].
@ProviderFor(coachAttendance)
const coachAttendanceProvider = CoachAttendanceFamily();

/// Provider for coach attendance by date
///
/// Copied from [coachAttendance].
class CoachAttendanceFamily extends Family<AsyncValue<List<CoachAttendance>>> {
  /// Provider for coach attendance by date
  ///
  /// Copied from [coachAttendance].
  const CoachAttendanceFamily();

  /// Provider for coach attendance by date
  ///
  /// Copied from [coachAttendance].
  CoachAttendanceProvider call(DateTime date) {
    return CoachAttendanceProvider(date);
  }

  @override
  CoachAttendanceProvider getProviderOverride(
    covariant CoachAttendanceProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachAttendanceProvider';
}

/// Provider for coach attendance by date
///
/// Copied from [coachAttendance].
class CoachAttendanceProvider
    extends AutoDisposeFutureProvider<List<CoachAttendance>> {
  /// Provider for coach attendance by date
  ///
  /// Copied from [coachAttendance].
  CoachAttendanceProvider(DateTime date)
    : this._internal(
        (ref) => coachAttendance(ref as CoachAttendanceRef, date),
        from: coachAttendanceProvider,
        name: r'coachAttendanceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachAttendanceHash,
        dependencies: CoachAttendanceFamily._dependencies,
        allTransitiveDependencies:
            CoachAttendanceFamily._allTransitiveDependencies,
        date: date,
      );

  CoachAttendanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<List<CoachAttendance>> Function(CoachAttendanceRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachAttendanceProvider._internal(
        (ref) => create(ref as CoachAttendanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CoachAttendance>> createElement() {
    return _CoachAttendanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachAttendanceProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachAttendanceRef
    on AutoDisposeFutureProviderRef<List<CoachAttendance>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _CoachAttendanceProviderElement
    extends AutoDisposeFutureProviderElement<List<CoachAttendance>>
    with CoachAttendanceRef {
  _CoachAttendanceProviderElement(super.provider);

  @override
  DateTime get date => (origin as CoachAttendanceProvider).date;
}

String _$batchStudentsForAttendanceHash() =>
    r'456546e7482fe194bc5ade91fe0627cc19b7a326';

/// Provider for students in a batch (for attendance marking)
///
/// Copied from [batchStudentsForAttendance].
@ProviderFor(batchStudentsForAttendance)
const batchStudentsForAttendanceProvider = BatchStudentsForAttendanceFamily();

/// Provider for students in a batch (for attendance marking)
///
/// Copied from [batchStudentsForAttendance].
class BatchStudentsForAttendanceFamily
    extends Family<AsyncValue<List<Student>>> {
  /// Provider for students in a batch (for attendance marking)
  ///
  /// Copied from [batchStudentsForAttendance].
  const BatchStudentsForAttendanceFamily();

  /// Provider for students in a batch (for attendance marking)
  ///
  /// Copied from [batchStudentsForAttendance].
  BatchStudentsForAttendanceProvider call(int batchId) {
    return BatchStudentsForAttendanceProvider(batchId);
  }

  @override
  BatchStudentsForAttendanceProvider getProviderOverride(
    covariant BatchStudentsForAttendanceProvider provider,
  ) {
    return call(provider.batchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'batchStudentsForAttendanceProvider';
}

/// Provider for students in a batch (for attendance marking)
///
/// Copied from [batchStudentsForAttendance].
class BatchStudentsForAttendanceProvider
    extends AutoDisposeFutureProvider<List<Student>> {
  /// Provider for students in a batch (for attendance marking)
  ///
  /// Copied from [batchStudentsForAttendance].
  BatchStudentsForAttendanceProvider(int batchId)
    : this._internal(
        (ref) => batchStudentsForAttendance(
          ref as BatchStudentsForAttendanceRef,
          batchId,
        ),
        from: batchStudentsForAttendanceProvider,
        name: r'batchStudentsForAttendanceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$batchStudentsForAttendanceHash,
        dependencies: BatchStudentsForAttendanceFamily._dependencies,
        allTransitiveDependencies:
            BatchStudentsForAttendanceFamily._allTransitiveDependencies,
        batchId: batchId,
      );

  BatchStudentsForAttendanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.batchId,
  }) : super.internal();

  final int batchId;

  @override
  Override overrideWith(
    FutureOr<List<Student>> Function(BatchStudentsForAttendanceRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BatchStudentsForAttendanceProvider._internal(
        (ref) => create(ref as BatchStudentsForAttendanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        batchId: batchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Student>> createElement() {
    return _BatchStudentsForAttendanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BatchStudentsForAttendanceProvider &&
        other.batchId == batchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, batchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BatchStudentsForAttendanceRef
    on AutoDisposeFutureProviderRef<List<Student>> {
  /// The parameter `batchId` of this provider.
  int get batchId;
}

class _BatchStudentsForAttendanceProviderElement
    extends AutoDisposeFutureProviderElement<List<Student>>
    with BatchStudentsForAttendanceRef {
  _BatchStudentsForAttendanceProviderElement(super.provider);

  @override
  int get batchId => (origin as BatchStudentsForAttendanceProvider).batchId;
}

String _$coachesForAttendanceHash() =>
    r'76e916e684f8c5747187953a98f48f17dadd5a20';

/// Provider for all coaches (for attendance marking)
///
/// Copied from [coachesForAttendance].
@ProviderFor(coachesForAttendance)
final coachesForAttendanceProvider =
    AutoDisposeFutureProvider<List<Coach>>.internal(
      coachesForAttendance,
      name: r'coachesForAttendanceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$coachesForAttendanceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CoachesForAttendanceRef = AutoDisposeFutureProviderRef<List<Coach>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
