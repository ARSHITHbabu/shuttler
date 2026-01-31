// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$performanceByStudentHash() =>
    r'6af99f97863718d4b55559755f579223e1019b75';

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

/// Provider for performance records by student
///
/// Copied from [performanceByStudent].
@ProviderFor(performanceByStudent)
const performanceByStudentProvider = PerformanceByStudentFamily();

/// Provider for performance records by student
///
/// Copied from [performanceByStudent].
class PerformanceByStudentFamily extends Family<AsyncValue<List<Performance>>> {
  /// Provider for performance records by student
  ///
  /// Copied from [performanceByStudent].
  const PerformanceByStudentFamily();

  /// Provider for performance records by student
  ///
  /// Copied from [performanceByStudent].
  PerformanceByStudentProvider call(
    int studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PerformanceByStudentProvider(
      studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  PerformanceByStudentProvider getProviderOverride(
    covariant PerformanceByStudentProvider provider,
  ) {
    return call(
      provider.studentId,
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
  String? get name => r'performanceByStudentProvider';
}

/// Provider for performance records by student
///
/// Copied from [performanceByStudent].
class PerformanceByStudentProvider
    extends AutoDisposeFutureProvider<List<Performance>> {
  /// Provider for performance records by student
  ///
  /// Copied from [performanceByStudent].
  PerformanceByStudentProvider(
    int studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         (ref) => performanceByStudent(
           ref as PerformanceByStudentRef,
           studentId,
           startDate: startDate,
           endDate: endDate,
         ),
         from: performanceByStudentProvider,
         name: r'performanceByStudentProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$performanceByStudentHash,
         dependencies: PerformanceByStudentFamily._dependencies,
         allTransitiveDependencies:
             PerformanceByStudentFamily._allTransitiveDependencies,
         studentId: studentId,
         startDate: startDate,
         endDate: endDate,
       );

  PerformanceByStudentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final int studentId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<Performance>> Function(PerformanceByStudentRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PerformanceByStudentProvider._internal(
        (ref) => create(ref as PerformanceByStudentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Performance>> createElement() {
    return _PerformanceByStudentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PerformanceByStudentProvider &&
        other.studentId == studentId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PerformanceByStudentRef
    on AutoDisposeFutureProviderRef<List<Performance>> {
  /// The parameter `studentId` of this provider.
  int get studentId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _PerformanceByStudentProviderElement
    extends AutoDisposeFutureProviderElement<List<Performance>>
    with PerformanceByStudentRef {
  _PerformanceByStudentProviderElement(super.provider);

  @override
  int get studentId => (origin as PerformanceByStudentProvider).studentId;
  @override
  DateTime? get startDate => (origin as PerformanceByStudentProvider).startDate;
  @override
  DateTime? get endDate => (origin as PerformanceByStudentProvider).endDate;
}

String _$performanceByIdHash() => r'7b1211a10863b1d1beb8de52116c687d6d5e1ea2';

/// Provider for performance record by ID
///
/// Copied from [performanceById].
@ProviderFor(performanceById)
const performanceByIdProvider = PerformanceByIdFamily();

/// Provider for performance record by ID
///
/// Copied from [performanceById].
class PerformanceByIdFamily extends Family<AsyncValue<Performance>> {
  /// Provider for performance record by ID
  ///
  /// Copied from [performanceById].
  const PerformanceByIdFamily();

  /// Provider for performance record by ID
  ///
  /// Copied from [performanceById].
  PerformanceByIdProvider call(int id) {
    return PerformanceByIdProvider(id);
  }

  @override
  PerformanceByIdProvider getProviderOverride(
    covariant PerformanceByIdProvider provider,
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
  String? get name => r'performanceByIdProvider';
}

/// Provider for performance record by ID
///
/// Copied from [performanceById].
class PerformanceByIdProvider extends AutoDisposeFutureProvider<Performance> {
  /// Provider for performance record by ID
  ///
  /// Copied from [performanceById].
  PerformanceByIdProvider(int id)
    : this._internal(
        (ref) => performanceById(ref as PerformanceByIdRef, id),
        from: performanceByIdProvider,
        name: r'performanceByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$performanceByIdHash,
        dependencies: PerformanceByIdFamily._dependencies,
        allTransitiveDependencies:
            PerformanceByIdFamily._allTransitiveDependencies,
        id: id,
      );

  PerformanceByIdProvider._internal(
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
    FutureOr<Performance> Function(PerformanceByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PerformanceByIdProvider._internal(
        (ref) => create(ref as PerformanceByIdRef),
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
  AutoDisposeFutureProviderElement<Performance> createElement() {
    return _PerformanceByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PerformanceByIdProvider && other.id == id;
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
mixin PerformanceByIdRef on AutoDisposeFutureProviderRef<Performance> {
  /// The parameter `id` of this provider.
  int get id;
}

class _PerformanceByIdProviderElement
    extends AutoDisposeFutureProviderElement<Performance>
    with PerformanceByIdRef {
  _PerformanceByIdProviderElement(super.provider);

  @override
  int get id => (origin as PerformanceByIdProvider).id;
}

String _$performanceTrendHash() => r'579cc9433e47203a516ad0237d6da6c052e78877';

/// Provider for performance trend data
///
/// Copied from [performanceTrend].
@ProviderFor(performanceTrend)
const performanceTrendProvider = PerformanceTrendFamily();

/// Provider for performance trend data
///
/// Copied from [performanceTrend].
class PerformanceTrendFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Provider for performance trend data
  ///
  /// Copied from [performanceTrend].
  const PerformanceTrendFamily();

  /// Provider for performance trend data
  ///
  /// Copied from [performanceTrend].
  PerformanceTrendProvider call(
    int studentId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return PerformanceTrendProvider(studentId, startDate, endDate);
  }

  @override
  PerformanceTrendProvider getProviderOverride(
    covariant PerformanceTrendProvider provider,
  ) {
    return call(provider.studentId, provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'performanceTrendProvider';
}

/// Provider for performance trend data
///
/// Copied from [performanceTrend].
class PerformanceTrendProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Provider for performance trend data
  ///
  /// Copied from [performanceTrend].
  PerformanceTrendProvider(int studentId, DateTime startDate, DateTime endDate)
    : this._internal(
        (ref) => performanceTrend(
          ref as PerformanceTrendRef,
          studentId,
          startDate,
          endDate,
        ),
        from: performanceTrendProvider,
        name: r'performanceTrendProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$performanceTrendHash,
        dependencies: PerformanceTrendFamily._dependencies,
        allTransitiveDependencies:
            PerformanceTrendFamily._allTransitiveDependencies,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

  PerformanceTrendProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final int studentId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(PerformanceTrendRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PerformanceTrendProvider._internal(
        (ref) => create(ref as PerformanceTrendRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PerformanceTrendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PerformanceTrendProvider &&
        other.studentId == studentId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PerformanceTrendRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `studentId` of this provider.
  int get studentId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _PerformanceTrendProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PerformanceTrendRef {
  _PerformanceTrendProviderElement(super.provider);

  @override
  int get studentId => (origin as PerformanceTrendProvider).studentId;
  @override
  DateTime get startDate => (origin as PerformanceTrendProvider).startDate;
  @override
  DateTime get endDate => (origin as PerformanceTrendProvider).endDate;
}

String _$averagePerformanceHash() =>
    r'59711a0df47b2b69328866866a21f84be6bc9bde';

/// Provider for average performance rating
///
/// Copied from [averagePerformance].
@ProviderFor(averagePerformance)
const averagePerformanceProvider = AveragePerformanceFamily();

/// Provider for average performance rating
///
/// Copied from [averagePerformance].
class AveragePerformanceFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for average performance rating
  ///
  /// Copied from [averagePerformance].
  const AveragePerformanceFamily();

  /// Provider for average performance rating
  ///
  /// Copied from [averagePerformance].
  AveragePerformanceProvider call(int studentId) {
    return AveragePerformanceProvider(studentId);
  }

  @override
  AveragePerformanceProvider getProviderOverride(
    covariant AveragePerformanceProvider provider,
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
  String? get name => r'averagePerformanceProvider';
}

/// Provider for average performance rating
///
/// Copied from [averagePerformance].
class AveragePerformanceProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for average performance rating
  ///
  /// Copied from [averagePerformance].
  AveragePerformanceProvider(int studentId)
    : this._internal(
        (ref) => averagePerformance(ref as AveragePerformanceRef, studentId),
        from: averagePerformanceProvider,
        name: r'averagePerformanceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$averagePerformanceHash,
        dependencies: AveragePerformanceFamily._dependencies,
        allTransitiveDependencies:
            AveragePerformanceFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  AveragePerformanceProvider._internal(
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
    FutureOr<Map<String, dynamic>> Function(AveragePerformanceRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AveragePerformanceProvider._internal(
        (ref) => create(ref as AveragePerformanceRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _AveragePerformanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AveragePerformanceProvider && other.studentId == studentId;
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
mixin AveragePerformanceRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _AveragePerformanceProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with AveragePerformanceRef {
  _AveragePerformanceProviderElement(super.provider);

  @override
  int get studentId => (origin as AveragePerformanceProvider).studentId;
}

String _$latestPerformanceHash() => r'0b04a67358b5d1730a1c0c610207e19231221af8';

/// Provider for latest performance record
///
/// Copied from [latestPerformance].
@ProviderFor(latestPerformance)
const latestPerformanceProvider = LatestPerformanceFamily();

/// Provider for latest performance record
///
/// Copied from [latestPerformance].
class LatestPerformanceFamily extends Family<AsyncValue<Performance?>> {
  /// Provider for latest performance record
  ///
  /// Copied from [latestPerformance].
  const LatestPerformanceFamily();

  /// Provider for latest performance record
  ///
  /// Copied from [latestPerformance].
  LatestPerformanceProvider call(int studentId) {
    return LatestPerformanceProvider(studentId);
  }

  @override
  LatestPerformanceProvider getProviderOverride(
    covariant LatestPerformanceProvider provider,
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
  String? get name => r'latestPerformanceProvider';
}

/// Provider for latest performance record
///
/// Copied from [latestPerformance].
class LatestPerformanceProvider
    extends AutoDisposeFutureProvider<Performance?> {
  /// Provider for latest performance record
  ///
  /// Copied from [latestPerformance].
  LatestPerformanceProvider(int studentId)
    : this._internal(
        (ref) => latestPerformance(ref as LatestPerformanceRef, studentId),
        from: latestPerformanceProvider,
        name: r'latestPerformanceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$latestPerformanceHash,
        dependencies: LatestPerformanceFamily._dependencies,
        allTransitiveDependencies:
            LatestPerformanceFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  LatestPerformanceProvider._internal(
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
    FutureOr<Performance?> Function(LatestPerformanceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LatestPerformanceProvider._internal(
        (ref) => create(ref as LatestPerformanceRef),
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
  AutoDisposeFutureProviderElement<Performance?> createElement() {
    return _LatestPerformanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestPerformanceProvider && other.studentId == studentId;
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
mixin LatestPerformanceRef on AutoDisposeFutureProviderRef<Performance?> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _LatestPerformanceProviderElement
    extends AutoDisposeFutureProviderElement<Performance?>
    with LatestPerformanceRef {
  _LatestPerformanceProviderElement(super.provider);

  @override
  int get studentId => (origin as LatestPerformanceProvider).studentId;
}

String _$performanceListHash() => r'0404fd4b9ab13be92e85be2ed6a8eee3b55ed775';

abstract class _$PerformanceList
    extends BuildlessAutoDisposeAsyncNotifier<List<Performance>> {
  late final int? studentId;
  late final DateTime? startDate;
  late final DateTime? endDate;

  FutureOr<List<Performance>> build({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Provider class for performance CRUD operations
///
/// Copied from [PerformanceList].
@ProviderFor(PerformanceList)
const performanceListProvider = PerformanceListFamily();

/// Provider class for performance CRUD operations
///
/// Copied from [PerformanceList].
class PerformanceListFamily extends Family<AsyncValue<List<Performance>>> {
  /// Provider class for performance CRUD operations
  ///
  /// Copied from [PerformanceList].
  const PerformanceListFamily();

  /// Provider class for performance CRUD operations
  ///
  /// Copied from [PerformanceList].
  PerformanceListProvider call({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PerformanceListProvider(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  PerformanceListProvider getProviderOverride(
    covariant PerformanceListProvider provider,
  ) {
    return call(
      studentId: provider.studentId,
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
  String? get name => r'performanceListProvider';
}

/// Provider class for performance CRUD operations
///
/// Copied from [PerformanceList].
class PerformanceListProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PerformanceList,
          List<Performance>
        > {
  /// Provider class for performance CRUD operations
  ///
  /// Copied from [PerformanceList].
  PerformanceListProvider({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         () => PerformanceList()
           ..studentId = studentId
           ..startDate = startDate
           ..endDate = endDate,
         from: performanceListProvider,
         name: r'performanceListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$performanceListHash,
         dependencies: PerformanceListFamily._dependencies,
         allTransitiveDependencies:
             PerformanceListFamily._allTransitiveDependencies,
         studentId: studentId,
         startDate: startDate,
         endDate: endDate,
       );

  PerformanceListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final int? studentId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  FutureOr<List<Performance>> runNotifierBuild(
    covariant PerformanceList notifier,
  ) {
    return notifier.build(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Override overrideWith(PerformanceList Function() create) {
    return ProviderOverride(
      origin: this,
      override: PerformanceListProvider._internal(
        () => create()
          ..studentId = studentId
          ..startDate = startDate
          ..endDate = endDate,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PerformanceList, List<Performance>>
  createElement() {
    return _PerformanceListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PerformanceListProvider &&
        other.studentId == studentId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PerformanceListRef
    on AutoDisposeAsyncNotifierProviderRef<List<Performance>> {
  /// The parameter `studentId` of this provider.
  int? get studentId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _PerformanceListProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PerformanceList,
          List<Performance>
        >
    with PerformanceListRef {
  _PerformanceListProviderElement(super.provider);

  @override
  int? get studentId => (origin as PerformanceListProvider).studentId;
  @override
  DateTime? get startDate => (origin as PerformanceListProvider).startDate;
  @override
  DateTime? get endDate => (origin as PerformanceListProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
