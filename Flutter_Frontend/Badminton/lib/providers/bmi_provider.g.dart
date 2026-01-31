// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bmiByStudentHash() => r'66dc11ef2dfdc08ca19f63495574ef39c7cf30c2';

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

/// Provider for BMI records by student
///
/// Copied from [bmiByStudent].
@ProviderFor(bmiByStudent)
const bmiByStudentProvider = BmiByStudentFamily();

/// Provider for BMI records by student
///
/// Copied from [bmiByStudent].
class BmiByStudentFamily extends Family<AsyncValue<List<BMIRecord>>> {
  /// Provider for BMI records by student
  ///
  /// Copied from [bmiByStudent].
  const BmiByStudentFamily();

  /// Provider for BMI records by student
  ///
  /// Copied from [bmiByStudent].
  BmiByStudentProvider call(
    int studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BmiByStudentProvider(
      studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  BmiByStudentProvider getProviderOverride(
    covariant BmiByStudentProvider provider,
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
  String? get name => r'bmiByStudentProvider';
}

/// Provider for BMI records by student
///
/// Copied from [bmiByStudent].
class BmiByStudentProvider extends AutoDisposeFutureProvider<List<BMIRecord>> {
  /// Provider for BMI records by student
  ///
  /// Copied from [bmiByStudent].
  BmiByStudentProvider(int studentId, {DateTime? startDate, DateTime? endDate})
    : this._internal(
        (ref) => bmiByStudent(
          ref as BmiByStudentRef,
          studentId,
          startDate: startDate,
          endDate: endDate,
        ),
        from: bmiByStudentProvider,
        name: r'bmiByStudentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bmiByStudentHash,
        dependencies: BmiByStudentFamily._dependencies,
        allTransitiveDependencies:
            BmiByStudentFamily._allTransitiveDependencies,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

  BmiByStudentProvider._internal(
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
    FutureOr<List<BMIRecord>> Function(BmiByStudentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BmiByStudentProvider._internal(
        (ref) => create(ref as BmiByStudentRef),
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
  AutoDisposeFutureProviderElement<List<BMIRecord>> createElement() {
    return _BmiByStudentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BmiByStudentProvider &&
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
mixin BmiByStudentRef on AutoDisposeFutureProviderRef<List<BMIRecord>> {
  /// The parameter `studentId` of this provider.
  int get studentId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _BmiByStudentProviderElement
    extends AutoDisposeFutureProviderElement<List<BMIRecord>>
    with BmiByStudentRef {
  _BmiByStudentProviderElement(super.provider);

  @override
  int get studentId => (origin as BmiByStudentProvider).studentId;
  @override
  DateTime? get startDate => (origin as BmiByStudentProvider).startDate;
  @override
  DateTime? get endDate => (origin as BmiByStudentProvider).endDate;
}

String _$bmiByIdHash() => r'416fb7d2caec9c5e07f9dccfd850dc7fb2737656';

/// Provider for BMI record by ID
///
/// Copied from [bmiById].
@ProviderFor(bmiById)
const bmiByIdProvider = BmiByIdFamily();

/// Provider for BMI record by ID
///
/// Copied from [bmiById].
class BmiByIdFamily extends Family<AsyncValue<BMIRecord>> {
  /// Provider for BMI record by ID
  ///
  /// Copied from [bmiById].
  const BmiByIdFamily();

  /// Provider for BMI record by ID
  ///
  /// Copied from [bmiById].
  BmiByIdProvider call(int id) {
    return BmiByIdProvider(id);
  }

  @override
  BmiByIdProvider getProviderOverride(covariant BmiByIdProvider provider) {
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
  String? get name => r'bmiByIdProvider';
}

/// Provider for BMI record by ID
///
/// Copied from [bmiById].
class BmiByIdProvider extends AutoDisposeFutureProvider<BMIRecord> {
  /// Provider for BMI record by ID
  ///
  /// Copied from [bmiById].
  BmiByIdProvider(int id)
    : this._internal(
        (ref) => bmiById(ref as BmiByIdRef, id),
        from: bmiByIdProvider,
        name: r'bmiByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bmiByIdHash,
        dependencies: BmiByIdFamily._dependencies,
        allTransitiveDependencies: BmiByIdFamily._allTransitiveDependencies,
        id: id,
      );

  BmiByIdProvider._internal(
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
    FutureOr<BMIRecord> Function(BmiByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BmiByIdProvider._internal(
        (ref) => create(ref as BmiByIdRef),
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
  AutoDisposeFutureProviderElement<BMIRecord> createElement() {
    return _BmiByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BmiByIdProvider && other.id == id;
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
mixin BmiByIdRef on AutoDisposeFutureProviderRef<BMIRecord> {
  /// The parameter `id` of this provider.
  int get id;
}

class _BmiByIdProviderElement
    extends AutoDisposeFutureProviderElement<BMIRecord>
    with BmiByIdRef {
  _BmiByIdProviderElement(super.provider);

  @override
  int get id => (origin as BmiByIdProvider).id;
}

String _$latestBmiHash() => r'b057c4441c880b4a7b0f3512a390e958cdf94f55';

/// Provider for latest BMI record
///
/// Copied from [latestBmi].
@ProviderFor(latestBmi)
const latestBmiProvider = LatestBmiFamily();

/// Provider for latest BMI record
///
/// Copied from [latestBmi].
class LatestBmiFamily extends Family<AsyncValue<BMIRecord?>> {
  /// Provider for latest BMI record
  ///
  /// Copied from [latestBmi].
  const LatestBmiFamily();

  /// Provider for latest BMI record
  ///
  /// Copied from [latestBmi].
  LatestBmiProvider call(int studentId) {
    return LatestBmiProvider(studentId);
  }

  @override
  LatestBmiProvider getProviderOverride(covariant LatestBmiProvider provider) {
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
  String? get name => r'latestBmiProvider';
}

/// Provider for latest BMI record
///
/// Copied from [latestBmi].
class LatestBmiProvider extends AutoDisposeFutureProvider<BMIRecord?> {
  /// Provider for latest BMI record
  ///
  /// Copied from [latestBmi].
  LatestBmiProvider(int studentId)
    : this._internal(
        (ref) => latestBmi(ref as LatestBmiRef, studentId),
        from: latestBmiProvider,
        name: r'latestBmiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$latestBmiHash,
        dependencies: LatestBmiFamily._dependencies,
        allTransitiveDependencies: LatestBmiFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  LatestBmiProvider._internal(
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
    FutureOr<BMIRecord?> Function(LatestBmiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LatestBmiProvider._internal(
        (ref) => create(ref as LatestBmiRef),
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
  AutoDisposeFutureProviderElement<BMIRecord?> createElement() {
    return _LatestBmiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestBmiProvider && other.studentId == studentId;
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
mixin LatestBmiRef on AutoDisposeFutureProviderRef<BMIRecord?> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _LatestBmiProviderElement
    extends AutoDisposeFutureProviderElement<BMIRecord?>
    with LatestBmiRef {
  _LatestBmiProviderElement(super.provider);

  @override
  int get studentId => (origin as LatestBmiProvider).studentId;
}

String _$bmiTrendHash() => r'392c5170071d1840d4475f02c47c794c9c45db57';

/// Provider for BMI trend data
///
/// Copied from [bmiTrend].
@ProviderFor(bmiTrend)
const bmiTrendProvider = BmiTrendFamily();

/// Provider for BMI trend data
///
/// Copied from [bmiTrend].
class BmiTrendFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Provider for BMI trend data
  ///
  /// Copied from [bmiTrend].
  const BmiTrendFamily();

  /// Provider for BMI trend data
  ///
  /// Copied from [bmiTrend].
  BmiTrendProvider call(int studentId) {
    return BmiTrendProvider(studentId);
  }

  @override
  BmiTrendProvider getProviderOverride(covariant BmiTrendProvider provider) {
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
  String? get name => r'bmiTrendProvider';
}

/// Provider for BMI trend data
///
/// Copied from [bmiTrend].
class BmiTrendProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Provider for BMI trend data
  ///
  /// Copied from [bmiTrend].
  BmiTrendProvider(int studentId)
    : this._internal(
        (ref) => bmiTrend(ref as BmiTrendRef, studentId),
        from: bmiTrendProvider,
        name: r'bmiTrendProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bmiTrendHash,
        dependencies: BmiTrendFamily._dependencies,
        allTransitiveDependencies: BmiTrendFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  BmiTrendProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(BmiTrendRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BmiTrendProvider._internal(
        (ref) => create(ref as BmiTrendRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _BmiTrendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BmiTrendProvider && other.studentId == studentId;
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
mixin BmiTrendRef on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _BmiTrendProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with BmiTrendRef {
  _BmiTrendProviderElement(super.provider);

  @override
  int get studentId => (origin as BmiTrendProvider).studentId;
}

String _$bmiListHash() => r'91532bce3c89dc12993bf9be32232c7b239812a8';

abstract class _$BmiList
    extends BuildlessAutoDisposeAsyncNotifier<List<BMIRecord>> {
  late final int? studentId;
  late final DateTime? startDate;
  late final DateTime? endDate;

  FutureOr<List<BMIRecord>> build({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Provider class for BMI CRUD operations
///
/// Copied from [BmiList].
@ProviderFor(BmiList)
const bmiListProvider = BmiListFamily();

/// Provider class for BMI CRUD operations
///
/// Copied from [BmiList].
class BmiListFamily extends Family<AsyncValue<List<BMIRecord>>> {
  /// Provider class for BMI CRUD operations
  ///
  /// Copied from [BmiList].
  const BmiListFamily();

  /// Provider class for BMI CRUD operations
  ///
  /// Copied from [BmiList].
  BmiListProvider call({
    int? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BmiListProvider(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  BmiListProvider getProviderOverride(covariant BmiListProvider provider) {
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
  String? get name => r'bmiListProvider';
}

/// Provider class for BMI CRUD operations
///
/// Copied from [BmiList].
class BmiListProvider
    extends AutoDisposeAsyncNotifierProviderImpl<BmiList, List<BMIRecord>> {
  /// Provider class for BMI CRUD operations
  ///
  /// Copied from [BmiList].
  BmiListProvider({int? studentId, DateTime? startDate, DateTime? endDate})
    : this._internal(
        () => BmiList()
          ..studentId = studentId
          ..startDate = startDate
          ..endDate = endDate,
        from: bmiListProvider,
        name: r'bmiListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bmiListHash,
        dependencies: BmiListFamily._dependencies,
        allTransitiveDependencies: BmiListFamily._allTransitiveDependencies,
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

  BmiListProvider._internal(
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
  FutureOr<List<BMIRecord>> runNotifierBuild(covariant BmiList notifier) {
    return notifier.build(
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Override overrideWith(BmiList Function() create) {
    return ProviderOverride(
      origin: this,
      override: BmiListProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<BmiList, List<BMIRecord>>
  createElement() {
    return _BmiListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BmiListProvider &&
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
mixin BmiListRef on AutoDisposeAsyncNotifierProviderRef<List<BMIRecord>> {
  /// The parameter `studentId` of this provider.
  int? get studentId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _BmiListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BmiList, List<BMIRecord>>
    with BmiListRef {
  _BmiListProviderElement(super.provider);

  @override
  int? get studentId => (origin as BmiListProvider).studentId;
  @override
  DateTime? get startDate => (origin as BmiListProvider).startDate;
  @override
  DateTime? get endDate => (origin as BmiListProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
