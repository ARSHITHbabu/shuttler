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

String _$coachAttendanceByCoachIdHash() =>
    r'224c2160148d66ed5c1b0dc300050e45627fdb17';

/// Provider for coach attendance by coach ID
///
/// Copied from [coachAttendanceByCoachId].
@ProviderFor(coachAttendanceByCoachId)
const coachAttendanceByCoachIdProvider = CoachAttendanceByCoachIdFamily();

/// Provider for coach attendance by coach ID
///
/// Copied from [coachAttendanceByCoachId].
class CoachAttendanceByCoachIdFamily
    extends Family<AsyncValue<List<CoachAttendance>>> {
  /// Provider for coach attendance by coach ID
  ///
  /// Copied from [coachAttendanceByCoachId].
  const CoachAttendanceByCoachIdFamily();

  /// Provider for coach attendance by coach ID
  ///
  /// Copied from [coachAttendanceByCoachId].
  CoachAttendanceByCoachIdProvider call(int coachId) {
    return CoachAttendanceByCoachIdProvider(coachId);
  }

  @override
  CoachAttendanceByCoachIdProvider getProviderOverride(
    covariant CoachAttendanceByCoachIdProvider provider,
  ) {
    return call(provider.coachId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachAttendanceByCoachIdProvider';
}

/// Provider for coach attendance by coach ID
///
/// Copied from [coachAttendanceByCoachId].
class CoachAttendanceByCoachIdProvider
    extends AutoDisposeFutureProvider<List<CoachAttendance>> {
  /// Provider for coach attendance by coach ID
  ///
  /// Copied from [coachAttendanceByCoachId].
  CoachAttendanceByCoachIdProvider(int coachId)
    : this._internal(
        (ref) => coachAttendanceByCoachId(
          ref as CoachAttendanceByCoachIdRef,
          coachId,
        ),
        from: coachAttendanceByCoachIdProvider,
        name: r'coachAttendanceByCoachIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachAttendanceByCoachIdHash,
        dependencies: CoachAttendanceByCoachIdFamily._dependencies,
        allTransitiveDependencies:
            CoachAttendanceByCoachIdFamily._allTransitiveDependencies,
        coachId: coachId,
      );

  CoachAttendanceByCoachIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coachId,
  }) : super.internal();

  final int coachId;

  @override
  Override overrideWith(
    FutureOr<List<CoachAttendance>> Function(
      CoachAttendanceByCoachIdRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachAttendanceByCoachIdProvider._internal(
        (ref) => create(ref as CoachAttendanceByCoachIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coachId: coachId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CoachAttendance>> createElement() {
    return _CoachAttendanceByCoachIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachAttendanceByCoachIdProvider &&
        other.coachId == coachId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coachId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachAttendanceByCoachIdRef
    on AutoDisposeFutureProviderRef<List<CoachAttendance>> {
  /// The parameter `coachId` of this provider.
  int get coachId;
}

class _CoachAttendanceByCoachIdProviderElement
    extends AutoDisposeFutureProviderElement<List<CoachAttendance>>
    with CoachAttendanceByCoachIdRef {
  _CoachAttendanceByCoachIdProviderElement(super.provider);

  @override
  int get coachId => (origin as CoachAttendanceByCoachIdProvider).coachId;
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
String _$attendanceByStudentHash() =>
    r'5bed01f0b787ce77ea1200b179df4dd3dd75f90f';

/// Provider for attendance records by student
///
/// Copied from [attendanceByStudent].
@ProviderFor(attendanceByStudent)
const attendanceByStudentProvider = AttendanceByStudentFamily();

/// Provider for attendance records by student
///
/// Copied from [attendanceByStudent].
class AttendanceByStudentFamily extends Family<AsyncValue<List<Attendance>>> {
  /// Provider for attendance records by student
  ///
  /// Copied from [attendanceByStudent].
  const AttendanceByStudentFamily();

  /// Provider for attendance records by student
  ///
  /// Copied from [attendanceByStudent].
  AttendanceByStudentProvider call(
    int studentId, {
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) {
    return AttendanceByStudentProvider(
      studentId,
      startDate: startDate,
      endDate: endDate,
      month: month,
      year: year,
    );
  }

  @override
  AttendanceByStudentProvider getProviderOverride(
    covariant AttendanceByStudentProvider provider,
  ) {
    return call(
      provider.studentId,
      startDate: provider.startDate,
      endDate: provider.endDate,
      month: provider.month,
      year: provider.year,
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
  String? get name => r'attendanceByStudentProvider';
}

/// Provider for attendance records by student
///
/// Copied from [attendanceByStudent].
class AttendanceByStudentProvider
    extends AutoDisposeFutureProvider<List<Attendance>> {
  /// Provider for attendance records by student
  ///
  /// Copied from [attendanceByStudent].
  AttendanceByStudentProvider(
    int studentId, {
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) : this._internal(
         (ref) => attendanceByStudent(
           ref as AttendanceByStudentRef,
           studentId,
           startDate: startDate,
           endDate: endDate,
           month: month,
           year: year,
         ),
         from: attendanceByStudentProvider,
         name: r'attendanceByStudentProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$attendanceByStudentHash,
         dependencies: AttendanceByStudentFamily._dependencies,
         allTransitiveDependencies:
             AttendanceByStudentFamily._allTransitiveDependencies,
         studentId: studentId,
         startDate: startDate,
         endDate: endDate,
         month: month,
         year: year,
       );

  AttendanceByStudentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.startDate,
    required this.endDate,
    required this.month,
    required this.year,
  }) : super.internal();

  final int studentId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;

  @override
  Override overrideWith(
    FutureOr<List<Attendance>> Function(AttendanceByStudentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttendanceByStudentProvider._internal(
        (ref) => create(ref as AttendanceByStudentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        month: month,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Attendance>> createElement() {
    return _AttendanceByStudentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceByStudentProvider &&
        other.studentId == studentId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AttendanceByStudentRef on AutoDisposeFutureProviderRef<List<Attendance>> {
  /// The parameter `studentId` of this provider.
  int get studentId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `month` of this provider.
  int? get month;

  /// The parameter `year` of this provider.
  int? get year;
}

class _AttendanceByStudentProviderElement
    extends AutoDisposeFutureProviderElement<List<Attendance>>
    with AttendanceByStudentRef {
  _AttendanceByStudentProviderElement(super.provider);

  @override
  int get studentId => (origin as AttendanceByStudentProvider).studentId;
  @override
  DateTime? get startDate => (origin as AttendanceByStudentProvider).startDate;
  @override
  DateTime? get endDate => (origin as AttendanceByStudentProvider).endDate;
  @override
  int? get month => (origin as AttendanceByStudentProvider).month;
  @override
  int? get year => (origin as AttendanceByStudentProvider).year;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
