// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feeByIdHash() => r'2c5b3d7b203ad246548c268775f6b87194af9fb2';

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

/// Provider for fee by ID
///
/// Copied from [feeById].
@ProviderFor(feeById)
const feeByIdProvider = FeeByIdFamily();

/// Provider for fee by ID
///
/// Copied from [feeById].
class FeeByIdFamily extends Family<AsyncValue<Fee>> {
  /// Provider for fee by ID
  ///
  /// Copied from [feeById].
  const FeeByIdFamily();

  /// Provider for fee by ID
  ///
  /// Copied from [feeById].
  FeeByIdProvider call(int id) {
    return FeeByIdProvider(id);
  }

  @override
  FeeByIdProvider getProviderOverride(covariant FeeByIdProvider provider) {
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
  String? get name => r'feeByIdProvider';
}

/// Provider for fee by ID
///
/// Copied from [feeById].
class FeeByIdProvider extends AutoDisposeFutureProvider<Fee> {
  /// Provider for fee by ID
  ///
  /// Copied from [feeById].
  FeeByIdProvider(int id)
    : this._internal(
        (ref) => feeById(ref as FeeByIdRef, id),
        from: feeByIdProvider,
        name: r'feeByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feeByIdHash,
        dependencies: FeeByIdFamily._dependencies,
        allTransitiveDependencies: FeeByIdFamily._allTransitiveDependencies,
        id: id,
      );

  FeeByIdProvider._internal(
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
  Override overrideWith(FutureOr<Fee> Function(FeeByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FeeByIdProvider._internal(
        (ref) => create(ref as FeeByIdRef),
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
  AutoDisposeFutureProviderElement<Fee> createElement() {
    return _FeeByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeByIdProvider && other.id == id;
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
mixin FeeByIdRef on AutoDisposeFutureProviderRef<Fee> {
  /// The parameter `id` of this provider.
  int get id;
}

class _FeeByIdProviderElement extends AutoDisposeFutureProviderElement<Fee>
    with FeeByIdRef {
  _FeeByIdProviderElement(super.provider);

  @override
  int get id => (origin as FeeByIdProvider).id;
}

String _$feeByStudentHash() => r'90532180b106819720a5fb167619f17a8f33ee8f';

/// Provider for fees by student
///
/// Copied from [feeByStudent].
@ProviderFor(feeByStudent)
const feeByStudentProvider = FeeByStudentFamily();

/// Provider for fees by student
///
/// Copied from [feeByStudent].
class FeeByStudentFamily extends Family<AsyncValue<List<Fee>>> {
  /// Provider for fees by student
  ///
  /// Copied from [feeByStudent].
  const FeeByStudentFamily();

  /// Provider for fees by student
  ///
  /// Copied from [feeByStudent].
  FeeByStudentProvider call(int studentId) {
    return FeeByStudentProvider(studentId);
  }

  @override
  FeeByStudentProvider getProviderOverride(
    covariant FeeByStudentProvider provider,
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
  String? get name => r'feeByStudentProvider';
}

/// Provider for fees by student
///
/// Copied from [feeByStudent].
class FeeByStudentProvider extends AutoDisposeFutureProvider<List<Fee>> {
  /// Provider for fees by student
  ///
  /// Copied from [feeByStudent].
  FeeByStudentProvider(int studentId)
    : this._internal(
        (ref) => feeByStudent(ref as FeeByStudentRef, studentId),
        from: feeByStudentProvider,
        name: r'feeByStudentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feeByStudentHash,
        dependencies: FeeByStudentFamily._dependencies,
        allTransitiveDependencies:
            FeeByStudentFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  FeeByStudentProvider._internal(
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
    FutureOr<List<Fee>> Function(FeeByStudentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeeByStudentProvider._internal(
        (ref) => create(ref as FeeByStudentRef),
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
  AutoDisposeFutureProviderElement<List<Fee>> createElement() {
    return _FeeByStudentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeByStudentProvider && other.studentId == studentId;
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
mixin FeeByStudentRef on AutoDisposeFutureProviderRef<List<Fee>> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _FeeByStudentProviderElement
    extends AutoDisposeFutureProviderElement<List<Fee>>
    with FeeByStudentRef {
  _FeeByStudentProviderElement(super.provider);

  @override
  int get studentId => (origin as FeeByStudentProvider).studentId;
}

String _$feeStatsHash() => r'cdddb7cb62c6f36faefe64dc5f4d539b8e45cc5a';

/// Provider for fee statistics
///
/// Copied from [feeStats].
@ProviderFor(feeStats)
final feeStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      feeStats,
      name: r'feeStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feeStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeeStatsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$pendingFeesHash() => r'0515bb6c324cec2908723843dcb5f6206d133e8d';

/// Provider for pending fees
///
/// Copied from [pendingFees].
@ProviderFor(pendingFees)
final pendingFeesProvider = AutoDisposeFutureProvider<List<Fee>>.internal(
  pendingFees,
  name: r'pendingFeesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingFeesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingFeesRef = AutoDisposeFutureProviderRef<List<Fee>>;
String _$overdueFeesHash() => r'76ff037326b09e80213bc8b78d0341ab351b77cd';

/// Provider for overdue fees
///
/// Copied from [overdueFees].
@ProviderFor(overdueFees)
final overdueFeesProvider = AutoDisposeFutureProvider<List<Fee>>.internal(
  overdueFees,
  name: r'overdueFeesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overdueFeesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverdueFeesRef = AutoDisposeFutureProviderRef<List<Fee>>;
String _$studentsWithBatchFeesHash() =>
    r'7f5fdf3b12e7db458a79c70798d6c490292b14c3';

/// Provider for all students with their batch enrollments and fee status
/// Returns students grouped by batch with their fee information
///
/// Copied from [studentsWithBatchFees].
@ProviderFor(studentsWithBatchFees)
final studentsWithBatchFeesProvider =
    AutoDisposeFutureProvider<Map<int, List<StudentWithBatchFee>>>.internal(
      studentsWithBatchFees,
      name: r'studentsWithBatchFeesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentsWithBatchFeesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentsWithBatchFeesRef =
    AutoDisposeFutureProviderRef<Map<int, List<StudentWithBatchFee>>>;
String _$feeListHash() => r'9ebeb757b7e2d70076e44f64cefee8a5c8ac830c';

abstract class _$FeeList extends BuildlessAutoDisposeAsyncNotifier<List<Fee>> {
  late final int? studentId;
  late final int? batchId;
  late final String? status;
  late final DateTime? startDate;
  late final DateTime? endDate;

  FutureOr<List<Fee>> build({
    int? studentId,
    int? batchId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Provider for fee list state
///
/// Copied from [FeeList].
@ProviderFor(FeeList)
const feeListProvider = FeeListFamily();

/// Provider for fee list state
///
/// Copied from [FeeList].
class FeeListFamily extends Family<AsyncValue<List<Fee>>> {
  /// Provider for fee list state
  ///
  /// Copied from [FeeList].
  const FeeListFamily();

  /// Provider for fee list state
  ///
  /// Copied from [FeeList].
  FeeListProvider call({
    int? studentId,
    int? batchId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FeeListProvider(
      studentId: studentId,
      batchId: batchId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  FeeListProvider getProviderOverride(covariant FeeListProvider provider) {
    return call(
      studentId: provider.studentId,
      batchId: provider.batchId,
      status: provider.status,
      startDate: provider.startDate,
      endDate: provider.endDate,
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
  String? get name => r'feeListProvider';
}

/// Provider for fee list state
///
/// Copied from [FeeList].
class FeeListProvider
    extends AutoDisposeAsyncNotifierProviderImpl<FeeList, List<Fee>> {
  /// Provider for fee list state
  ///
  /// Copied from [FeeList].
  FeeListProvider({
    int? studentId,
    int? batchId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         () => FeeList()
           ..studentId = studentId
           ..batchId = batchId
           ..status = status
           ..startDate = startDate
           ..endDate = endDate,
         from: feeListProvider,
         name: r'feeListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$feeListHash,
         dependencies: FeeListFamily._dependencies,
         allTransitiveDependencies: FeeListFamily._allTransitiveDependencies,
         studentId: studentId,
         batchId: batchId,
         status: status,
         startDate: startDate,
         endDate: endDate,
       );

  FeeListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.batchId,
    required this.status,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final int? studentId;
  final int? batchId;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  FutureOr<List<Fee>> runNotifierBuild(covariant FeeList notifier) {
    return notifier.build(
      studentId: studentId,
      batchId: batchId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Override overrideWith(FeeList Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeeListProvider._internal(
        () => create()
          ..studentId = studentId
          ..batchId = batchId
          ..status = status
          ..startDate = startDate
          ..endDate = endDate,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        batchId: batchId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<FeeList, List<Fee>> createElement() {
    return _FeeListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeeListProvider &&
        other.studentId == studentId &&
        other.batchId == batchId &&
        other.status == status &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, batchId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeeListRef on AutoDisposeAsyncNotifierProviderRef<List<Fee>> {
  /// The parameter `studentId` of this provider.
  int? get studentId;

  /// The parameter `batchId` of this provider.
  int? get batchId;

  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _FeeListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<FeeList, List<Fee>>
    with FeeListRef {
  _FeeListProviderElement(super.provider);

  @override
  int? get studentId => (origin as FeeListProvider).studentId;
  @override
  int? get batchId => (origin as FeeListProvider).batchId;
  @override
  String? get status => (origin as FeeListProvider).status;
  @override
  DateTime? get startDate => (origin as FeeListProvider).startDate;
  @override
  DateTime? get endDate => (origin as FeeListProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
