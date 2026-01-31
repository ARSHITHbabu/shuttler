// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentByIdHash() => r'599e09b9d1a6daad696194c9e583a941d902d4c9';

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

/// Provider for student by ID
///
/// Copied from [studentById].
@ProviderFor(studentById)
const studentByIdProvider = StudentByIdFamily();

/// Provider for student by ID
///
/// Copied from [studentById].
class StudentByIdFamily extends Family<AsyncValue<Student>> {
  /// Provider for student by ID
  ///
  /// Copied from [studentById].
  const StudentByIdFamily();

  /// Provider for student by ID
  ///
  /// Copied from [studentById].
  StudentByIdProvider call(int id) {
    return StudentByIdProvider(id);
  }

  @override
  StudentByIdProvider getProviderOverride(
    covariant StudentByIdProvider provider,
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
  String? get name => r'studentByIdProvider';
}

/// Provider for student by ID
///
/// Copied from [studentById].
class StudentByIdProvider extends AutoDisposeFutureProvider<Student> {
  /// Provider for student by ID
  ///
  /// Copied from [studentById].
  StudentByIdProvider(int id)
    : this._internal(
        (ref) => studentById(ref as StudentByIdRef, id),
        from: studentByIdProvider,
        name: r'studentByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentByIdHash,
        dependencies: StudentByIdFamily._dependencies,
        allTransitiveDependencies: StudentByIdFamily._allTransitiveDependencies,
        id: id,
      );

  StudentByIdProvider._internal(
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
    FutureOr<Student> Function(StudentByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentByIdProvider._internal(
        (ref) => create(ref as StudentByIdRef),
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
  AutoDisposeFutureProviderElement<Student> createElement() {
    return _StudentByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentByIdProvider && other.id == id;
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
mixin StudentByIdRef on AutoDisposeFutureProviderRef<Student> {
  /// The parameter `id` of this provider.
  int get id;
}

class _StudentByIdProviderElement
    extends AutoDisposeFutureProviderElement<Student>
    with StudentByIdRef {
  _StudentByIdProviderElement(super.provider);

  @override
  int get id => (origin as StudentByIdProvider).id;
}

String _$studentSearchHash() => r'75050da4a5f3be1fbe1eb62287bf3dd08d060c65';

/// Provider for student search
///
/// Copied from [studentSearch].
@ProviderFor(studentSearch)
const studentSearchProvider = StudentSearchFamily();

/// Provider for student search
///
/// Copied from [studentSearch].
class StudentSearchFamily extends Family<AsyncValue<List<Student>>> {
  /// Provider for student search
  ///
  /// Copied from [studentSearch].
  const StudentSearchFamily();

  /// Provider for student search
  ///
  /// Copied from [studentSearch].
  StudentSearchProvider call(String query) {
    return StudentSearchProvider(query);
  }

  @override
  StudentSearchProvider getProviderOverride(
    covariant StudentSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentSearchProvider';
}

/// Provider for student search
///
/// Copied from [studentSearch].
class StudentSearchProvider extends AutoDisposeFutureProvider<List<Student>> {
  /// Provider for student search
  ///
  /// Copied from [studentSearch].
  StudentSearchProvider(String query)
    : this._internal(
        (ref) => studentSearch(ref as StudentSearchRef, query),
        from: studentSearchProvider,
        name: r'studentSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentSearchHash,
        dependencies: StudentSearchFamily._dependencies,
        allTransitiveDependencies:
            StudentSearchFamily._allTransitiveDependencies,
        query: query,
      );

  StudentSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Student>> Function(StudentSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentSearchProvider._internal(
        (ref) => create(ref as StudentSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Student>> createElement() {
    return _StudentSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentSearchRef on AutoDisposeFutureProviderRef<List<Student>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _StudentSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<Student>>
    with StudentSearchRef {
  _StudentSearchProviderElement(super.provider);

  @override
  String get query => (origin as StudentSearchProvider).query;
}

String _$studentByBatchHash() => r'd9cbd686f731c9990595d252181c67b946e086ac';

/// Provider for students by batch
///
/// Copied from [studentByBatch].
@ProviderFor(studentByBatch)
const studentByBatchProvider = StudentByBatchFamily();

/// Provider for students by batch
///
/// Copied from [studentByBatch].
class StudentByBatchFamily extends Family<AsyncValue<List<Student>>> {
  /// Provider for students by batch
  ///
  /// Copied from [studentByBatch].
  const StudentByBatchFamily();

  /// Provider for students by batch
  ///
  /// Copied from [studentByBatch].
  StudentByBatchProvider call(int batchId) {
    return StudentByBatchProvider(batchId);
  }

  @override
  StudentByBatchProvider getProviderOverride(
    covariant StudentByBatchProvider provider,
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
  String? get name => r'studentByBatchProvider';
}

/// Provider for students by batch
///
/// Copied from [studentByBatch].
class StudentByBatchProvider extends AutoDisposeFutureProvider<List<Student>> {
  /// Provider for students by batch
  ///
  /// Copied from [studentByBatch].
  StudentByBatchProvider(int batchId)
    : this._internal(
        (ref) => studentByBatch(ref as StudentByBatchRef, batchId),
        from: studentByBatchProvider,
        name: r'studentByBatchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentByBatchHash,
        dependencies: StudentByBatchFamily._dependencies,
        allTransitiveDependencies:
            StudentByBatchFamily._allTransitiveDependencies,
        batchId: batchId,
      );

  StudentByBatchProvider._internal(
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
    FutureOr<List<Student>> Function(StudentByBatchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentByBatchProvider._internal(
        (ref) => create(ref as StudentByBatchRef),
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
    return _StudentByBatchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentByBatchProvider && other.batchId == batchId;
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
mixin StudentByBatchRef on AutoDisposeFutureProviderRef<List<Student>> {
  /// The parameter `batchId` of this provider.
  int get batchId;
}

class _StudentByBatchProviderElement
    extends AutoDisposeFutureProviderElement<List<Student>>
    with StudentByBatchRef {
  _StudentByBatchProviderElement(super.provider);

  @override
  int get batchId => (origin as StudentByBatchProvider).batchId;
}

String _$studentStatsHash() => r'2101635509dd51900174c47592449fc653ecac80';

/// Provider for student statistics
///
/// Copied from [studentStats].
@ProviderFor(studentStats)
final studentStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      studentStats,
      name: r'studentStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentStatsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$studentDashboardHash() => r'9a5fa11942b04b570659301fa7fa85fb32741a70';

/// Provider for student dashboard data (stats and upcoming sessions)
///
/// Copied from [studentDashboard].
@ProviderFor(studentDashboard)
const studentDashboardProvider = StudentDashboardFamily();

/// Provider for student dashboard data (stats and upcoming sessions)
///
/// Copied from [studentDashboard].
class StudentDashboardFamily extends Family<AsyncValue<StudentDashboardData>> {
  /// Provider for student dashboard data (stats and upcoming sessions)
  ///
  /// Copied from [studentDashboard].
  const StudentDashboardFamily();

  /// Provider for student dashboard data (stats and upcoming sessions)
  ///
  /// Copied from [studentDashboard].
  StudentDashboardProvider call(int studentId) {
    return StudentDashboardProvider(studentId);
  }

  @override
  StudentDashboardProvider getProviderOverride(
    covariant StudentDashboardProvider provider,
  ) {
    return call(provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentDashboardProvider';
}

/// Provider for student dashboard data (stats and upcoming sessions)
///
/// Copied from [studentDashboard].
class StudentDashboardProvider
    extends AutoDisposeFutureProvider<StudentDashboardData> {
  /// Provider for student dashboard data (stats and upcoming sessions)
  ///
  /// Copied from [studentDashboard].
  StudentDashboardProvider(int studentId)
    : this._internal(
        (ref) => studentDashboard(ref as StudentDashboardRef, studentId),
        from: studentDashboardProvider,
        name: r'studentDashboardProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentDashboardHash,
        dependencies: StudentDashboardFamily._dependencies,
        allTransitiveDependencies:
            StudentDashboardFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentDashboardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final int studentId;

  @override
  Override overrideWith(
    FutureOr<StudentDashboardData> Function(StudentDashboardRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentDashboardProvider._internal(
        (ref) => create(ref as StudentDashboardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StudentDashboardData> createElement() {
    return _StudentDashboardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentDashboardProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentDashboardRef
    on AutoDisposeFutureProviderRef<StudentDashboardData> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _StudentDashboardProviderElement
    extends AutoDisposeFutureProviderElement<StudentDashboardData>
    with StudentDashboardRef {
  _StudentDashboardProviderElement(super.provider);

  @override
  int get studentId => (origin as StudentDashboardProvider).studentId;
}

String _$studentSchedulesHash() => r'aa57e204f934d84f67776e3395065b86f78a6cbf';

/// Provider for student schedules (all schedules for batches student is enrolled in)
///
/// Copied from [studentSchedules].
@ProviderFor(studentSchedules)
const studentSchedulesProvider = StudentSchedulesFamily();

/// Provider for student schedules (all schedules for batches student is enrolled in)
///
/// Copied from [studentSchedules].
class StudentSchedulesFamily extends Family<AsyncValue<List<Schedule>>> {
  /// Provider for student schedules (all schedules for batches student is enrolled in)
  ///
  /// Copied from [studentSchedules].
  const StudentSchedulesFamily();

  /// Provider for student schedules (all schedules for batches student is enrolled in)
  ///
  /// Copied from [studentSchedules].
  StudentSchedulesProvider call(int studentId) {
    return StudentSchedulesProvider(studentId);
  }

  @override
  StudentSchedulesProvider getProviderOverride(
    covariant StudentSchedulesProvider provider,
  ) {
    return call(provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentSchedulesProvider';
}

/// Provider for student schedules (all schedules for batches student is enrolled in)
///
/// Copied from [studentSchedules].
class StudentSchedulesProvider
    extends AutoDisposeFutureProvider<List<Schedule>> {
  /// Provider for student schedules (all schedules for batches student is enrolled in)
  ///
  /// Copied from [studentSchedules].
  StudentSchedulesProvider(int studentId)
    : this._internal(
        (ref) => studentSchedules(ref as StudentSchedulesRef, studentId),
        from: studentSchedulesProvider,
        name: r'studentSchedulesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentSchedulesHash,
        dependencies: StudentSchedulesFamily._dependencies,
        allTransitiveDependencies:
            StudentSchedulesFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentSchedulesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final int studentId;

  @override
  Override overrideWith(
    FutureOr<List<Schedule>> Function(StudentSchedulesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentSchedulesProvider._internal(
        (ref) => create(ref as StudentSchedulesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Schedule>> createElement() {
    return _StudentSchedulesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSchedulesProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentSchedulesRef on AutoDisposeFutureProviderRef<List<Schedule>> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _StudentSchedulesProviderElement
    extends AutoDisposeFutureProviderElement<List<Schedule>>
    with StudentSchedulesRef {
  _StudentSchedulesProviderElement(super.provider);

  @override
  int get studentId => (origin as StudentSchedulesProvider).studentId;
}

String _$studentListHash() => r'34ee8a637f622f49796dd3b3f756b2629273a38d';

/// Provider for student list state
///
/// Copied from [StudentList].
@ProviderFor(StudentList)
final studentListProvider =
    AutoDisposeAsyncNotifierProvider<StudentList, List<Student>>.internal(
      StudentList.new,
      name: r'studentListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StudentList = AutoDisposeAsyncNotifier<List<Student>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
